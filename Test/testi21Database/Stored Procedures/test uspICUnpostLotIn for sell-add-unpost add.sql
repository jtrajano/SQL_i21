﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostLotIn for sell-add-unpost add]
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

		-- Mark all item sa lot items
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
				,dblStockIn = 25
				,dblStockOut = 25
				,dblCost = 3.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6
		UNION ALL 
		SELECT	intLotId = 12345
				,dblStockIn = 100
				,dblStockOut = 25
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6


		-- Add fake data for tblICInventoryLotOut
		INSERT INTO dbo.tblICInventoryLotOut (
			intInventoryLotId
			,intInventoryTransactionId
			,dblQty
			,intRevalueLotId
		) 
		SELECT	intInventoryLotId = 2
				,intInventoryTransactionId = 3
				,dblQty = 25
				,intRevalueLotId = 1

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
				,intLotId = 12345

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
				,intLotId = 12345
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = 75 - 53.75
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
				,intLotId = 12345
				
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
		SELECT	strTransactionId = 'InvShip-0000001'
				,intTransactionId = 1
				,dblStockIn = 0
				,dblStockOut = 25
				,dblCost = 3.00
				,intLotId = 12345
		UNION ALL 
		SELECT	strTransactionId = 'InvRcpt-0000001'
				,intTransactionId = 1
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
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
		EXEC tSQLt.AssertEqualsTable 'expectedLot', 'actualLot', 'Failed to generate the expected Lot Cost Bucket records.';
		--EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse';
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