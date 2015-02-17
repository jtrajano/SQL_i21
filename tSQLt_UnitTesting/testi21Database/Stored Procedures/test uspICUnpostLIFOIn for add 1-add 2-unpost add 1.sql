CREATE PROCEDURE [testi21Database].[test uspICUnpostLIFOIn for add 1-add 2-unpost add 1]
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

		DECLARE @strTransactionId AS NVARCHAR(20)
		DECLARE @intTransactionId AS INT

		CREATE TABLE actualLIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
		)

		CREATE TABLE expectedLIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
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
		
		-- Add fake data for tblICInventoryLIFO
		INSERT INTO dbo.tblICInventoryLIFO (
				dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
				,intTransactionId
				,strTransactionId
				,intItemId
				,intItemLocationId
		)
		SELECT	dtmDate = '1/1/2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblStockIn = 23
				,dblStockOut = 0
				,dblCost = 2.24
				,intTransactionId = 2
				,strTransactionId = 'InvRcpt-0000002'
				,intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven

		-- Add fake data for tblICInventoryLIFOOut
		-- No LIFO out data.

		-- Add fake data for tblICInventoryTransaction
		INSERT INTO dbo.tblICInventoryTransaction (
			dtmDate
			,dblUnitQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intTransactionId
			,strTransactionId
			,intRelatedTransactionId
			,strRelatedTransactionId
			,intTransactionTypeId
			,ysnIsUnposted
			,intItemId
			,intItemLocationId
			,strBatchId
		)
		SELECT	dtmDate = '1/1/2014'
				,dblUnitQty = 100
				,dblCost = 2.15
				,dblValue = NULL 
				,dblSalesPrice = 0
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryReceipt
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,strBatchId = 'BATCH-0001'
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblUnitQty = 23
				,dblCost = 2.24
				,dblValue = NULL 
				,dblSalesPrice = 0
				,intTransactionId = 2
				,strTransactionId = 'InvRcpt-0000002'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryReceipt
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,strBatchId = 'BATCH-0002'

		-- Setup the expected data for LIFO
		INSERT INTO expectedLIFO (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT	strTransactionId = 'InvRcpt-0000001'
				,intTransactionId = 1
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
		UNION ALL 
		SELECT	strTransactionId = 'InvRcpt-0000002'
				,intTransactionId = 2
				,dblStockIn = 23
				,dblStockOut = 0
				,dblCost = 2.24

		-- Setup the expected data for transactions to reverse 
		INSERT INTO expectedTransactionToReverse (
				intInventoryTransactionId
				,intTransactionId
				,strTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,intTransactionTypeId		
		)
		SELECT	intInventoryTransactionId = 1
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryReceipt
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostLIFOOut
		SET @strTransactionId = 'InvRcpt-0000001'
		SET @intTransactionId = 1
		
		EXEC dbo.uspICUnpostLIFOIn @strTransactionId, @intTransactionId

		INSERT INTO actualTransactionToReverse
		SELECT * FROM #tmpInventoryTransactionStockToReverse
				
		-- Get the actual LIFO data
		INSERT INTO actualLIFO (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut		
				,dblCost
		FROM dbo.tblICInventoryLIFO		
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
