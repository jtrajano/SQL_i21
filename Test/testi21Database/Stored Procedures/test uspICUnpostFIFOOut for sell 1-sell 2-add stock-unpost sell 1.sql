﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostFIFOOut for sell 1-sell 2-add stock-unpost sell 1]
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
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6
		UNION ALL 
		SELECT	dtmDate = '1/4/2014'
				,dblStockIn = 15
				,dblStockOut = 15
				,dblCost = 2.15
				,intTransactionId = 2
				,strTransactionId = 'InvShip-0000002'
				,intItemId = @WetGrains
				,intItemLocationId = 6
		UNION ALL 
		SELECT	dtmDate = '1/6/2014'
				,dblStockIn = 130
				,dblStockOut = 115
				,dblCost = 3.40
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intItemId = @WetGrains
				,intItemLocationId = 6

		-- Add fake data for tblICInventoryFIFOOut
		INSERT INTO dbo.tblICInventoryFIFOOut (intInventoryFIFOId, intInventoryTransactionId, dblQty) VALUES (3, 4, 100)
		INSERT INTO dbo.tblICInventoryFIFOOut (intInventoryFIFOId, intInventoryTransactionId, dblQty) VALUES (3, 6, 15)

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
				,dblQty = -100
				,dblCost = 2.15
				,dblValue = 0 
				,dblSalesPrice = 12.15
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
		SELECT	dtmDate = '1/4/2014'
				,dblQty = -15
				,dblCost = 2.15
				,dblValue = 0 
				,dblSalesPrice = 14.25
				,intTransactionId = 2
				,strTransactionId = 'InvShip-0000002'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6		
				,strBatchId = 'BATCH-0002'		
		UNION ALL 
		SELECT	dtmDate = '1/6/2014'
				,dblQty = 130
				,dblCost = 3.40
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
				,strBatchId = 'BATCH-0003'
		-- Revalue sold for InvShip-0000001
		UNION ALL 		
		SELECT	dtmDate = '1/6/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = -340.00
				,dblSalesPrice = 0
				,intTransactionId = 1 
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1 
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @REVALUE_SOLD
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0003'
		-- Write-Off sold for InvShip-0000001
		UNION ALL 		
		SELECT	dtmDate = '1/6/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = 215.00
				,dblSalesPrice = 0
				,intTransactionId = 1 
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1 
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @WRITE_OFF_SOLD
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0003'
		-- Revalue sold for InvShip-0000002
		UNION ALL 		
		SELECT	dtmDate = '1/6/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = -51.00
				,dblSalesPrice = 0
				,intTransactionId = 1 
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 2
				,strRelatedTransactionId = 'InvShip-0000002'
				,intTransactionTypeId = @REVALUE_SOLD
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0003'
		-- Write-Off sold for InvShip-0000002
		UNION ALL 		
		SELECT	dtmDate = '1/6/2014'
				,dblQty = 0
				,dblCost = 0
				,dblValue = 32.25
				,dblSalesPrice = 0
				,intTransactionId = 1 
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 2
				,strRelatedTransactionId = 'InvShip-0000002'
				,intTransactionTypeId = @WRITE_OFF_SOLD
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 6
				,strBatchId = 'BATCH-0003'

		-- Setup the expected data for FIFO
		INSERT INTO expectedFIFO (
			strTransactionId
			,intTransactionId
			,dblStockIn
			,dblStockOut
		)
		-- This cost bucket remains the same: 
		SELECT	strTransactionId = 'InvShip-0000001'
				,intTransactionId = 1
				,dblStockIn = 100 
				,dblStockOut = 100		
		-- This cost bucket remains the same:
		UNION ALL 
		SELECT	strTransactionId = 'InvShip-0000002'
				,intTransactionId = 2
				,dblStockIn = 15
				,dblStockOut = 15				
		-- This cost bucket is updated: 
		UNION ALL 
		SELECT	strTransactionId = 'InvRcpt-0000001'
				,intTransactionId = 1
				,dblStockIn = 130
				,dblStockOut = 15 -- Changed from 115 to 15. 
				
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
				,strTransactionId = 'InvShip-0000001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
		UNION ALL 
		SELECT	intInventoryTransactionId = 4
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @REVALUE_SOLD
		UNION ALL 
		SELECT	intInventoryTransactionId = 5
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @WRITE_OFF_SOLD
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostFIFOOut
		DECLARE @strTransactionId AS NVARCHAR(40) = 'InvShip-0000001'
		DECLARE @intTransactionId AS INT = 1
		
		EXEC dbo.uspICUnpostFIFOOut @strTransactionId, @intTransactionId

		INSERT INTO actualTransactionToReverse 
		SELECT * FROM #tmpInventoryTransactionStockToReverse

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
		DROP TABLE expectedFIFO

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE expectedTransactionToReverse
END