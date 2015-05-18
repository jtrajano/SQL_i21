CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for calling uspICCreateLotNumberOnInventoryReceipt]
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
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

		CREATE TABLE actual (
			strTransactionId NVARCHAR(40)
		)
		
		CREATE TABLE expected (
			strTransactionId NVARCHAR(40)
		)

		-- Add a spy for uspICCreateLotNumberOnInventoryReceipt
		EXEC tSQLt.SpyProcedure 'dbo.uspICCreateLotNumberOnInventoryReceipt';		

		-- Setup the expected parameter for uspPOReceived
		INSERT INTO expected (strTransactionId) VALUES (@strTransactionId)
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
	 		,@intUserId
			,@intEntityId		
	END 

	-- Assert 
	BEGIN 
		-- Get the actual 
		INSERT INTO actual (
			strTransactionId
		) 
		SELECT	strTransactionId
		FROM	dbo.uspICCreateLotNumberOnInventoryReceipt_SpyProcedureLog	

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 
	

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
