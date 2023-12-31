﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for multiple items and non-recap]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items];
		EXEC testi21Database.[Fake open fiscal year and accounting periods];

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5
				,@ManualLotGrains_BushelUOMId AS INT = 6
				,@SerializedLotGrains_BushelUOMId AS INT = 7

				,@WetGrains_PoundUOMId AS INT = 8
				,@StickyGrains_PoundUOMId AS INT = 9
				,@PremiumGrains_PoundUOMId AS INT = 10
				,@ColdGrains_PoundUOMId AS INT = 11
				,@HotGrains_PoundUOMId AS INT = 12
				,@ManualLotGrains_PoundUOMId AS INT = 13
				,@SerializedLotGrains_PoundUOMId AS INT = 14

		-- Declare Item-Locations
		DECLARE @WetGrains_DefaultLocation AS INT = 1
				,@StickyGrains_DefaultLocation AS INT = 2
				,@PremiumGrains_DefaultLocation AS INT = 3
				,@ColdGrains_DefaultLocation AS INT = 4
				,@HotGrains_DefaultLocation AS INT = 5

				,@WetGrains_NewHaven AS INT = 6
				,@StickyGrains_NewHaven AS INT = 7
				,@PremiumGrains_NewHaven AS INT = 8
				,@ColdGrains_NewHaven AS INT = 9
				,@HotGrains_NewHaven AS INT = 10

				,@WetGrains_BetterHaven AS INT = 11
				,@StickyGrains_BetterHaven AS INT = 12
				,@PremiumGrains_BetterHaven AS INT = 13
				,@ColdGrains_BetterHaven AS INT = 14
				,@HotGrains_BetterHaven AS INT = 15

				,@ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17

				-- Source Types
				,@SOURCE_TYPE_NONE AS INT = 0
				,@SOURCE_TYPE_SCALE AS INT = 1
				,@SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
				,@SOURCE_TYPE_TRANSPORT AS INT = 3

		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'Dummy-000001'
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemTax', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptCharge', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblAPBill', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblAPBillDetail', @Identity = 1;

		INSERT INTO tblICInventoryReceipt (
			strReceiptNumber
			,intLocationId
			,dtmReceiptDate
			,strReceiptType
			,intSourceType
		)
		VALUES (
			@strTransactionId
			,@NewHaven
			,@dtmDate	
			,'Purchase Order'
			,@SOURCE_TYPE_NONE
		);	
	
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblOpenReceive,dblUnitCost,intUnitMeasureId,intOwnershipType) VALUES (1, @WetGrains, 10, 10, 12.50, @WetGrains_BushelUOMId, 1);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblOpenReceive,dblUnitCost,intUnitMeasureId,intOwnershipType) VALUES (1, @StickyGrains, 20, 10, 13.50, @StickyGrains_BushelUOMId, 1);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblOpenReceive,dblUnitCost,intUnitMeasureId,intOwnershipType) VALUES (1, @PremiumGrains, 30, 10, 9.10, @PremiumGrains_BushelUOMId, 1);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblOpenReceive,dblUnitCost,intUnitMeasureId,intOwnershipType) VALUES (1, @WetGrains, 40, 10, 15.52, @WetGrains_BushelUOMId, 1);
		
		CREATE TABLE actual (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)
		
		CREATE TABLE expected (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)

		DECLARE @amount AS NUMERIC(18,6) = 10 * 12.50;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		SET @amount = 10 * 13.50;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		SET @amount = 10 * 9.10;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		SET @amount = 10 * 15.52;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)
		
		-- Add a spy for uspICPostInventoryReceiptIntegrations
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostInventoryReceiptIntegrations';						
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intEntityId
			
		INSERT INTO actual (dblDebit, dblCredit) 
		SELECT dblDebit, dblCredit 
		FROM dbo.tblGLDetail
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

		--Assert uspICPostInventoryReceiptIntegrations is called 
		IF @ysnRecap = 0 AND NOT EXISTS (SELECT 1 FROM dbo.uspICPostInventoryReceiptIntegrations_SpyProcedureLog)
			EXEC tSQLt.Fail 'uspICPostInventoryReceiptIntegrations should been called when @ysnRecap = 0'
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END
