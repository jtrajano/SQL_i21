CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustmentSplitLotChange for calling uspICCreateLotNumberOnInventoryAdjustmentSplitLot]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory adjustment table];

		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @intTransactionId AS INT = 7
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

		CREATE TABLE actual (
			intTransactionId INT
			,intUserId INT
		)
		
		CREATE TABLE expected (
			intTransactionId INT
			,intUserId INT
		)

		-- Add a spy for uspICCreateLotNumberOnInventoryAdjustmentSplitLot
		EXEC tSQLt.SpyProcedure 'dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot';		

		-- Setup the expected parameter for uspICPostInventoryAdjustment
		INSERT INTO expected (intTransactionId, intUserId) VALUES (@intTransactionId, @intUserId)
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentSplitLotChange
			@intTransactionId
	 		,@intUserId
	END 

	-- Assert 
	BEGIN 
		-- Get the actual 
		INSERT INTO actual (
			intTransactionId
			,intUserId 
		) 
		SELECT	intTransactionId
				,intUserId
		FROM	dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot_SpyProcedureLog	

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 	

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
