CREATE PROCEDURE [testi21Database].[test uspICUnpostFIFOOut for sell 1-sell 2-unpost sell 1]
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
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3
		DECLARE @InventoryAdjustment AS INT = 1
		DECLARE @InventoryReceipt AS INT = 2
		DECLARE @InventoryShipment AS INT = 3;

		CREATE TABLE actualFIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE expectedFIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE actualTransactionToReverse (
			intInventoryTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedInventoryTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedInventoryTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		CREATE TABLE expectedTransactionToReverse (
			intInventoryTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedInventoryTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedInventoryTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		-- Call the fake data stored procedure
		EXEC [testi21Database].[Fake data for simple Items]

		-- Add fake data for tblICInventoryFIFO
		INSERT INTO dbo.tblICInventoryFIFO (
				dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
				,intTransactionId
				,strTransactionId
				,intItemId
				,intLocationId
		)
		SELECT	dtmDate = '1/1/2014'
				,dblStockIn = 0
				,dblStockOut = 100
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
		UNION ALL 
		SELECT	dtmDate = '1/4/2014'
				,dblStockIn = 0
				,dblStockOut = 15
				,dblCost = 2.15
				,intTransactionId = 2
				,strTransactionId = 'InvShip-0000002'
				,intItemId = @WetGrains
				,intLocationId = @NewHaven

		-- Add fake data for tblICInventoryFIFOOut
		-- None needed for the fifo-out table 

		-- Add fake data for tblICInventoryTransaction
		INSERT INTO dbo.tblICInventoryTransaction (
			dtmDate
			,dblUnitQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intTransactionId
			,strTransactionId
			,intRelatedInventoryTransactionId
			,strRelatedInventoryTransactionId
			,intTransactionTypeId
			,ysnIsUnposted
			,intItemId
			,intLocationId
			,strBatchId
		)
		SELECT	dtmDate = '1/1/2014'
				,dblUnitQty = -100
				,dblCost = 2.15
				,dblValue = NULL 
				,dblSalesPrice = 12.15
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intRelatedInventoryTransactionId = NULL 
				,strRelatedInventoryTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
				,strBatchId = 'BATCH-0001'
		UNION ALL 
		SELECT	dtmDate = '1/4/2014'
				,dblUnitQty = -15
				,dblCost = 2.15
				,dblValue = NULL 
				,dblSalesPrice = 14.25
				,intTransactionId = 2
				,strTransactionId = 'InvShip-0000002'
				,intRelatedInventoryTransactionId = NULL 
				,strRelatedInventoryTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @NewHaven		
				,strBatchId = 'BATCH-0002'		
		UNION ALL 
		SELECT	dtmDate = '1/5/2014'
				,dblUnitQty = -15
				,dblCost = 2.15
				,dblValue = NULL 
				,dblSalesPrice = 12.00
				,intTransactionId = 1 
				,strTransactionId = 'WildCard-000001'
				,intRelatedInventoryTransactionId = NULL 
				,strRelatedInventoryTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
				,strBatchId = 'BATCH-0003'

		-- Setup the expected data for FIFO
		INSERT INTO expectedFIFO (
			strTransactionId
			,intTransactionId
			,dblStockIn
			,dblStockOut
		)
		-- This cost bucket is updated:
		SELECT	strTransactionId = 'InvShip-0000001'
				,intTransactionId = 1
				,dblStockIn = 100 -- The out qty is updated from zero to 100.  
				,dblStockOut = 100
		UNION ALL 
		-- This cost bucket remains the same:
		SELECT	strTransactionId = 'InvShip-0000002'
				,intTransactionId = 2
				,dblStockIn = 0
				,dblStockOut = 15
				
		-- Setup the expected data for transactions to reverse 
		INSERT INTO expectedTransactionToReverse (
				intInventoryTransactionId
				,intTransactionId
				,strTransactionId
				,intRelatedInventoryTransactionId
				,strRelatedInventoryTransactionId
				,intTransactionTypeId		
		)
		SELECT	intInventoryTransactionId = 1
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intRelatedInventoryTransactionId = NULL 
				,strRelatedInventoryTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostFIFOOut
		DECLARE @strTransactionId AS NVARCHAR(20) = 'InvShip-0000001'
		DECLARE @intTransactionId AS INT = 1
		
		INSERT INTO actualTransactionToReverse 
		EXEC dbo.uspICUnpostFIFOOut @strTransactionId, @intTransactionId
		
		-- Get the actual FIFO data
		INSERT INTO actualFIFO (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
		)
		SELECT strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut		
		FROM dbo.tblICInventoryFIFO		
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedFIFO', 'actualFIFO';
		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualFIFO') IS NOT NULL 
		DROP TABLE actualFIFO

	IF OBJECT_ID('expectedFIFO') IS NOT NULL 
		DROP TABLE dbo.expectedFIFO

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE dbo.expectedTransactionToReverse
END