CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for calling uspPOReceived]
AS
BEGIN
	-- Arrange 
	BEGIN 
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

		EXEC [testi21Database].[Fake inventory items];
		EXEC testi21Database.[Fake open fiscal year and accounting periods];

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

		INSERT INTO tblICInventoryReceipt (
			strReceiptNumber
			,intLocationId
			,dtmReceiptDate
		)
		VALUES (
			@strTransactionId
			,@NewHaven
			,@dtmDate	
		);	
	
		INSERT INTO tblICInventoryReceiptItem(
			intInventoryReceiptId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblUnitCost
			,intUnitMeasureId
		)
		VALUES (
			1
			,@WetGrains
			,10
			,10
			,12.50
			,@WetGrains_BushelUOMId
		);
		
		CREATE TABLE actual (
			receiptItemId INT
		)
		
		CREATE TABLE expected (
			receiptItemId INT
		)
		
		-- Add a spy for uspPOReceived
		EXEC tSQLt.SpyProcedure 'dbo.uspPOReceived';		

		-- Setup the expected parameter for uspPOReceived
		INSERT INTO expected (receiptItemId) VALUES (1)
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
	 		,@intUserId
			,@intEntityId
		
		-- Get the actual 
		INSERT INTO actual (receiptItemId) 
		SELECT receiptItemId
		FROM dbo.uspPOReceived_SpyProcedureLog	
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
