﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for calling uspICPostStorage]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory receipt table];

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
		DECLARE @strTransactionId AS NVARCHAR(40) = 'INVRCPT-XXXXX2'
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblAPBill', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblAPBillDetail', @Identity = 1;

		-- Add a spy for uspICPostStorage
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostStorage';		
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intEntityId		
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.AssertObjectExists 'uspICPostStorage_SpyProcedureLog'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END 