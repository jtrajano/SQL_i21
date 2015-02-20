CREATE PROCEDURE [testi21Database].[test uspICUnpostLIFOIn for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1

		-- Declare the variables for location
		DECLARE @BetterHaven AS INT = 3
				,@WetGrains_BetterHaven AS INT = 11	

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
		DECLARE @WRITE_OFF_SOLD AS INT = 2
		DECLARE @REVALUE_SOLD AS INT = 3		
		DECLARE @InventoryReceipt AS INT = 4
		DECLARE @InventoryShipment AS INT = 5;

		CREATE TABLE actualLIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE expectedLIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE actualTransactionToReverse (
			intInventoryTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		CREATE TABLE expectedTransactionToReverse (
			intInventoryTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		-- Create the temp table 
		CREATE TABLE #tmpInventoryTransactionStockToReverse (
			intInventoryTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		-- Call the fake data stored procedure
		EXEC testi21Database.[Fake inventory items]
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOOut', @Identity = 1;
	
		-- Negative stock options
		DECLARE @AllowNegativeStock AS INT = 1
		DECLARE @AllowNegativeStockWithWriteOff AS INT = 2
		DECLARE @DoNotAllowNegativeStock AS INT = 3

		-- Setup Wet Grains and allow negative stock on it. 
		UPDATE	ItemLocation
		SET		intAllowNegativeInventory = @AllowNegativeStockWithWriteOff
		FROM	dbo.tblICItemLocation ItemLocation
		WHERE	intItemLocationId = @WetGrains_BetterHaven
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostLIFOOut
		DECLARE @strTransactionId AS NVARCHAR(20) = 'InvShip-0000001'
		DECLARE @intTransactionId AS INT = 1
		
		EXEC dbo.uspICUnpostLIFOIn @strTransactionId, @intTransactionId

		INSERT INTO actualTransactionToReverse
		SELECT * FROM #tmpInventoryTransactionStockToReverse
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedLIFO', 'actualLIFO';
		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualLIFO') IS NOT NULL 
		DROP TABLE actualLIFO

	IF OBJECT_ID('expectedLIFO') IS NOT NULL 
		DROP TABLE dbo.expectedLIFO

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE dbo.expectedTransactionToReverse
END