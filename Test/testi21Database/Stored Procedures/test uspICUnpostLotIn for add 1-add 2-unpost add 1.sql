﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostLotIn for add 1-add 2-unpost add 1]
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
		DECLARE @WRITE_OFF_SOLD AS INT = 2
		DECLARE @REVALUE_SOLD AS INT = 3		
		DECLARE @InventoryReceipt AS INT = 4
		DECLARE @InventoryShipment AS INT = 5;

		DECLARE @strTransactionId AS NVARCHAR(20)
		DECLARE @intTransactionId AS INT

		CREATE TABLE actualLot (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(38, 20)
			,intLotId INT
		)

		CREATE TABLE expectedLot (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(38, 20)
			,intLotId INT
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
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotOut', @Identity = 1;

		-- Mark all item as lot items
		UPDATE dbo.tblICItem
		SET strLotTracking = 'Yes - Manual'

		-- Add fake data for tblICInventoryLot
		INSERT INTO dbo.tblICInventoryLot (
				intLotId
				,dblStockIn
				,dblStockOut
				,dblCost
				,intTransactionId
				,strTransactionId
				,intItemId
				,intItemLocationId
		)
		SELECT	intLotId = 12345
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6
		UNION ALL 
		SELECT	intLotId = 12345
				,dblStockIn = 23
				,dblStockOut = 0
				,dblCost = 2.24
				,intTransactionId = 2
				,strTransactionId = 'InvRcpt-0000002'
				,intItemId = @WetGrains
				,intItemLocationId = 6

		-- Add fake data for tblICInventoryLotOut
		-- No Lot out data.

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
			,intLotId
		)
		SELECT	dtmDate = '1/1/2014'
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
				,strBatchId = 'BATCH-0001'
				,intLotId = 12345
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblQty = 23
				,dblCost = 2.24
				,dblValue = 0 
				,dblSalesPrice = 0
				,intTransactionId = 2
				,strTransactionId = 'InvRcpt-0000002'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryReceipt
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0002'
				,intLotId = 12345

		-- Setup the expected data for Lot
		INSERT INTO expectedLot (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
				,intLotId
		)
		SELECT	strTransactionId = 'InvRcpt-0000001'
				,intTransactionId = 1
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,intLotId = 12345
		UNION ALL 
		SELECT	strTransactionId = 'InvRcpt-0000002'
				,intTransactionId = 2
				,dblStockIn = 23
				,dblStockOut = 0
				,dblCost = 2.24
				,intLotId = 12345

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
		-- Call the uspICUnpostLotOut
		SET @strTransactionId = 'InvRcpt-0000001'
		SET @intTransactionId = 1
		
		EXEC dbo.uspICUnpostLotIn @strTransactionId, @intTransactionId

		INSERT INTO actualTransactionToReverse
		SELECT * FROM #tmpInventoryTransactionStockToReverse
				
		-- Get the actual Lot data
		INSERT INTO actualLot (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
				,intLotId
		)
		SELECT strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut		
				,dblCost
				,intLotId
		FROM dbo.tblICInventoryLot		
	END 	
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedLot', 'actualLot';
		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualLot') IS NOT NULL 
		DROP TABLE actualLot

	IF OBJECT_ID('expectedLot') IS NOT NULL 
		DROP TABLE expectedLot

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE expectedTransactionToReverse
END