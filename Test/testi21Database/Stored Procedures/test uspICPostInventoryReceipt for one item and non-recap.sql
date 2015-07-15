﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for one item and non-recap]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items];
		EXEC testi21Database.[Fake open fiscal year and accounting periods];

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
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
			,1
		);	
	
		INSERT INTO tblICInventoryReceiptItem(
			intInventoryReceiptId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblUnitCost
			,intUnitMeasureId
			,intOwnershipType
		)
		VALUES (
			1
			,@WetGrains
			,10
			,10
			,12.50
			,@WetGrains_BushelUOMId
			,1
		);
		
		CREATE TABLE actual (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)
		
		CREATE TABLE expected (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)
		
		INSERT INTO expected VALUES (125.000000, 0)
		INSERT INTO expected VALUES (0, 125.000000)

		-- Add a spy for uspICPostInventoryReceiptIntegrations
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostInventoryReceiptIntegrations';				
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
		DROP TABLE dbo.expected

END 
