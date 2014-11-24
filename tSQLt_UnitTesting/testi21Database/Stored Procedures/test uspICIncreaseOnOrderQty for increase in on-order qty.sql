﻿CREATE PROCEDURE [testi21Database].[test uspICIncreaseOnOrderQty for increase in on-order qty]
AS
BEGIN
	-- Arrange 
	BEGIN 
		----------------------------------
		-- DECLARE THE CONSTANTS
		----------------------------------
		DECLARE @PurchaseType AS INT = 1
		DECLARE @SalesType AS INT = 2

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3

		DECLARE @USD AS INT = 1;		
		DECLARE @Each AS INT = 1;

		----------------------------------------
		-- Create the Fake data
		----------------------------------------
		EXEC testi21Database.[Fake data for simple Items];

		-----------------------------------
		-- Create the test tables
		-----------------------------------
		CREATE TABLE expected (
			intItemId INT
			,intLocationId INT
			,dblOnOrder NUMERIC(18,6)
		)

		INSERT INTO expected (
				intItemId
				,intLocationId
				,dblOnOrder
		)
		SELECT	intItemId = @WetGrains
				,intLocationId = @Default_Location
				,dblOnOrder = 100

		CREATE TABLE actual (
			intItemId INT
			,intLocationId INT
			,dblOnOrder NUMERIC(18,6)
		)

		-----------------------------------
		-- Create the test variables
		-----------------------------------

		DECLARE @Items AS ItemCostingTableType;
		
		---------------------------------------------------
		-- Setup the items to increase on-order qty
		---------------------------------------------------
		INSERT INTO @Items 
		SELECT 	intItemId = @WetGrains
				,intLocationId = @Default_Location
				,dtmDate = 'November 24, 2014'
				,dblUnitQty = 100
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PO-000001'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICIncreaseOnOrderQty @Items

		INSERT INTO actual (
				intItemId
				,intLocationId
				,dblOnOrder
		)
		SELECT	intItemId
				,intLocationId
				,dblOnOrder
		FROM	tblICItemStock 
		WHERE	intItemId = @WetGrains
				AND intLocationId = @Default_Location
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END