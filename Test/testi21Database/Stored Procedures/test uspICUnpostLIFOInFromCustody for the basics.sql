﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostLIFOInFromCustody for the basics]
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
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryCostBucketInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		CREATE TABLE expectedTransactionToReverse (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryCostBucketInCustodyId INT 
			,dblQty NUMERIC(38,20) 
		)

		-- Create the temp table 
		CREATE TABLE #tmpInventoryTransactionStockToReverse (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryCostBucketInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOInCustody', @Identity = 1;
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostLIFOInFromCustody
		DECLARE @strTransactionId AS NVARCHAR(20) = 'InvShip-0000001'
		DECLARE @intTransactionId AS INT = 1
		
		EXEC dbo.uspICUnpostLIFOInFromCustody @strTransactionId, @intTransactionId

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