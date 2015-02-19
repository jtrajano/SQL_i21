CREATE PROCEDURE [testi21Database].[test uspICIncreaseOnOrderQty for decrease in on-order qty on multiple items]
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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		DECLARE @USD AS INT = 1;		
		DECLARE @Each AS INT = 1;

		----------------------------------------
		-- Create the Fake data
		----------------------------------------
		EXEC testi21Database.[Fake inventory items];

		-----------------------------------
		-- Create the test tables
		-----------------------------------
		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,dblOnOrder NUMERIC(18,6)
		)

		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,dblOnOrder
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dblOnOrder = -450

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,dblOnOrder NUMERIC(18,6)
		)

		-----------------------------------
		-- Create the test variables
		-----------------------------------

		DECLARE @Items AS ItemCostingTableType;
		
		---------------------------------------------------
		-- Setup the items to decrease the on-order qty
		---------------------------------------------------
		INSERT INTO @Items 
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 24, 2014'
				,dblQty = -200
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PO-000001'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 24, 2014'
				,dblQty = -250
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
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
				,intItemLocationId
				,dblOnOrder
		)
		SELECT	intItemId
				,intItemLocationId
				,dblOnOrder
		FROM	tblICItemStock 
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @Default_Location
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