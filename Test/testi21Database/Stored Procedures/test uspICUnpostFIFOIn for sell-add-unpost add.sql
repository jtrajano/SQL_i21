CREATE PROCEDURE [testi21Database].[test uspICUnpostFIFOIn for sell-add-unpost add]
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

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
				,@WRITE_OFF_SOLD AS INT = 2
				,@REVALUE_SOLD AS INT = 3		
				,@AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35

		DECLARE @InventoryReceipt AS INT = 4
		DECLARE @InventoryShipment AS INT = 5;

		DECLARE @strTransactionId AS NVARCHAR(20)
		DECLARE @intTransactionId AS INT
		DECLARE @ysnRecap AS BIT 

		CREATE TABLE actualFIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(38, 20)
		)

		CREATE TABLE expectedFIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(38, 20)
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
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;

		-- Add fake data for tblICInventoryFIFO
		INSERT INTO dbo.tblICInventoryFIFO (
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
				,dblStockIn = 25
				,dblStockOut = 25
				,dblCost = 3.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblStockIn = 100
				,dblStockOut = 25
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6

		-- Add fake data for tblICInventoryFIFOOut
		INSERT INTO dbo.tblICInventoryFIFOOut (
			intInventoryFIFOId
			,intInventoryTransactionId
			,dblQty
			,intRevalueFifoId
		) 
		SELECT	intInventoryFIFOId = 2
				,intInventoryTransactionId = 3
				,dblQty = 25
				,intRevalueFifoId = 1

		-- Add fake data for tblICInventoryTransaction
		INSERT INTO dbo.tblICInventoryTransaction (
			dtmDate
			,dblQty
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
				,dblQty = -25
				,dblCost = 3.00
				,dblValue = 0 
				,dblSalesPrice = 12.99
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0001'

		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblQty = 100
				,dblCost = 2.15
				,dblValue = 0 
				,dblSalesPrice = 0
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryReceipt
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0002'
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = (75) - (53.75)
				,dblSalesPrice = 0
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0002'

		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = 0
				,dblSalesPrice = 0
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @AUTO_NEGATIVE
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0002'

		-- Setup the expected data for FIFO
		INSERT INTO expectedFIFO (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT	strTransactionId = 'InvShip-0000001'
				,intTransactionId = 1
				,dblStockIn = 0
				,dblStockOut = 25
				,dblCost = 3.00
		UNION ALL 
		SELECT	strTransactionId = 'InvRcpt-0000001'
				,intTransactionId = 1
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15

		-- Setup the expected data for transactions to reverse 
		INSERT INTO expectedTransactionToReverse (
				intInventoryTransactionId
				,intTransactionId
				,strTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,intTransactionTypeId		
		)
		SELECT	intInventoryTransactionId = 2
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = NULL
				,strRelatedTransactionId = NULL
				,intTransactionTypeId = @InventoryReceipt
		UNION ALL 
		SELECT	intInventoryTransactionId = 3
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK						
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostFIFOOut
		SET @strTransactionId = 'InvRcpt-0000001'
		SET @intTransactionId = 1
		SET @ysnRecap = 0
		
		EXEC dbo.uspICUnpostFIFOIn @strTransactionId, @intTransactionId, @ysnRecap

		INSERT INTO actualTransactionToReverse
		SELECT * FROM #tmpInventoryTransactionStockToReverse
				
		-- Get the actual FIFO data
		INSERT INTO actualFIFO (
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
		FROM dbo.tblICInventoryFIFO		
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedFIFO', 'actualFIFO', 'Failed to generate the expected FIFO Cost Bucket';
		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse', 'Failed to generate the expected records for #tmpInventoryTransactionStockToReverse';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualFIFO') IS NOT NULL 
		DROP TABLE actualFIFO

	IF OBJECT_ID('expectedFIFO') IS NOT NULL 
		DROP TABLE expectedFIFO

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE expectedTransactionToReverse
END