﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostFIFOIn for sell-add-unpost add]
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

		CREATE TABLE actualFIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
		)

		CREATE TABLE expectedFIFO (
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
				,dblStockIn = 25
				,dblStockOut = 25
				,dblCost = 3.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblStockIn = 100
				,dblStockOut = 25
				,dblCost = 2.15
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intItemId = @WetGrains
				,intLocationId = @NewHaven

		-- Add fake data for tblICInventoryFIFOOut
		INSERT INTO dbo.tblICInventoryFIFOOut (
			intInventoryFIFOId
			,intInventoryTransactionId
			,dblQty
			,intRevalueFifoId
		) 
		SELECT	intInventoryFIFOId = 2
				,intInventoryTransactionId = 4
				,dblQty = 25
				,intRevalueFifoId = 1

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
			,intLocationId
			,strBatchId
		)
		SELECT	dtmDate = '1/1/2014'
				,dblUnitQty = -25
				,dblCost = 3.00
				,dblValue = NULL 
				,dblSalesPrice = 12.99
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0000001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = @InventoryShipment
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
				,strBatchId = 'BATCH-0001'

		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
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
				,intLocationId = @NewHaven
				,strBatchId = 'BATCH-0002'
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblUnitQty = 0
				,dblCost = 0
				,dblValue = -53.75
				,dblSalesPrice = 0
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @REVALUE_SOLD
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
				,strBatchId = 'BATCH-0002'
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblUnitQty = 0
				,dblCost = 0
				,dblValue = 75
				,dblSalesPrice = 0
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @WRITE_OFF_SOLD
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @NewHaven
				,strBatchId = 'BATCH-0002'
		UNION ALL 
		SELECT	dtmDate = '1/2/2014'
				,dblUnitQty = 0
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
				,intLocationId = @NewHaven
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
				,intTransactionTypeId = @REVALUE_SOLD				
		UNION ALL 
		SELECT	intInventoryTransactionId = 4
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @WRITE_OFF_SOLD
		UNION ALL 
		SELECT	intInventoryTransactionId = 5
				,intTransactionId = 1
				,strTransactionId = 'InvRcpt-0000001'
				,intRelatedTransactionId = 1
				,strRelatedTransactionId = 'InvShip-0000001'
				,intTransactionTypeId = @AUTO_NEGATIVE				
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostFIFOOut
		SET @strTransactionId = 'InvRcpt-0000001'
		SET @intTransactionId = 1
		
		INSERT INTO actualTransactionToReverse 
		EXEC dbo.uspICUnpostFIFOIn @strTransactionId, @intTransactionId
				
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