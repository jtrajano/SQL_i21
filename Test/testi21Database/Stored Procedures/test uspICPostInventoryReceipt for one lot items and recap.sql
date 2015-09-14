﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for one lot items and recap]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items];

		-- Declare the variables for grains (item)
		DECLARE @ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1

		-- Declare the variables for the Item UOM Ids
		DECLARE @ManualLotGrains_BushelUOMId AS INT = 6
				,@SerializedLotGrains_BushelUOMId AS INT = 7

				,@ManualLotGrains_PoundUOMId AS INT = 13
				,@SerializedLotGrains_PoundUOMId AS INT = 14

		-- Declare Item-Locations
		DECLARE @ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17

		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 1
		DECLARE @strTransactionId AS NVARCHAR(40) = 'Dummy-000001'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblAPBill', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblAPBillDetail', @Identity = 1;

		INSERT INTO tblICInventoryReceipt (
			strReceiptNumber
			,intLocationId
			,dtmReceiptDate
		)
		VALUES (
			@strTransactionId
			,@Default_Location
			,@dtmDate	
		);	
	
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId, intItemId, dblOrderQty, dblOpenReceive, dblUnitCost, intUnitMeasureId) VALUES (1, @ManualLotGrains,		10,	10,	12.50, @ManualLotGrains_BushelUOMId);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId, intItemId, dblOrderQty, dblOpenReceive, dblUnitCost, intUnitMeasureId) VALUES (1, @SerializedLotGrains,	30,	20,	13.50, @SerializedLotGrains_BushelUOMId);

		-- @ManualLotGrains: 1
		INSERT INTO tblICInventoryReceiptItemLot(intInventoryReceiptItemId, intItemUnitMeasureId, intLotId, strLotNumber, dblQuantity) VALUES (1, @ManualLotGrains_BushelUOMId, 1, 'ManualLot-0001', 10)
		
		-- @SerializedLotGrains: 2
		INSERT INTO tblICInventoryReceiptItemLot(intInventoryReceiptItemId, intItemUnitMeasureId, intLotId, strLotNumber, dblQuantity) VALUES (2, @SerializedLotGrains_BushelUOMId, 2, 'SerialLot-0001', 20)

		-- Fake data for the lot numbers
		INSERT INTO tblICLot (intItemLocationId, intItemUOMId, strLotNumber) VALUES (@ManualLotGrains_DefaultLocation, @ManualLotGrains_BushelUOMId, 'ManualLot-0001')
		INSERT INTO tblICLot (intItemLocationId, intItemUOMId, strLotNumber) VALUES (@SerializedLotGrains_DefaultLocation, @SerializedLotGrains_BushelUOMId, 'SerialLot-0001')

		CREATE TABLE actual (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)
		
		CREATE TABLE expected (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)

		DECLARE @amount AS NUMERIC(18,6)
		
		-- ManualLot-0001
		SET @amount = 10 * 12.50;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		-- SerialLot-0001
		SET @amount = 20 * 13.50
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)
		
		-- Add a spy for uspPOReceived
		EXEC tSQLt.SpyProcedure 'dbo.uspPOReceived';						
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
	 		,@intUserId
			,@intEntityId
			
		INSERT INTO actual (dblDebit, dblCredit) 
		SELECT dblDebit, dblCredit 
		FROM dbo.tblGLDetailRecap
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

		--Assert uspPOReceived is NOT called 
		IF @ysnRecap = 1 AND EXISTS (SELECT 1 FROM dbo.uspPOReceived_SpyProcedureLog)
			EXEC tSQLt.Fail 'uspPOReceived should NOT been called when @ysnRecap = 1'
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END 