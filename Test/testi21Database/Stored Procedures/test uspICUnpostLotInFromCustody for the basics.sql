﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostLotInFromCustody for the basics]
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

		CREATE TABLE actualLot (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE expectedLot (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE actualTransactionToReverse (
			intInventoryLotInCustodyTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryLotInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		CREATE TABLE expectedTransactionToReverse (
			intInventoryLotInCustodyTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryLotInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		-- Create the temp table 
		CREATE TABLE #tmpInventoryTransactionStockToReverse (
			intInventoryLotInCustodyTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryLotInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustodyTransaction', @Identity = 1;		
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.ExpectException
			@ExpectedMessage = 'Unable to unpost the transaction.'
			,@ExpectedErrorNumber = 51130
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostLotOut
		DECLARE @strTransactionId AS NVARCHAR(20) = 'InvShip-0000001'
		DECLARE @intTransactionId AS INT = 1
		
		EXEC dbo.uspICUnpostLotInFromCustody @strTransactionId, @intTransactionId

		INSERT INTO actualTransactionToReverse
		SELECT * FROM #tmpInventoryTransactionStockToReverse
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualLot') IS NOT NULL 
		DROP TABLE actualLot

	IF OBJECT_ID('expectedLot') IS NOT NULL 
		DROP TABLE dbo.expectedLot

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE dbo.expectedTransactionToReverse
END