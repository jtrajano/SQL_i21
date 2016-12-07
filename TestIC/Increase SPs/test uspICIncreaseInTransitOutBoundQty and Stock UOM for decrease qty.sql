CREATE PROCEDURE [testIC].[test uspICIncreaseInTransitOutBoundQty and Stock UOM for decrease qty]
AS
BEGIN
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

		-- Declare the variables for company locations
		DECLARE @Paris AS INT = 1
				,@Florence AS INT = 2
				,@Tokyo AS INT = 3
				,@Manila AS INT = 3

		-- Declare the item-locations 
		DECLARE @WetGrains_Paris AS INT = 1
				,@WetGrains_Florence AS INT = 2
				,@WetGrains_Tokyo AS INT = 3
				,@WetGrains_Manila AS INT = 4

				,@StickyGrains_Paris AS INT = 5
				,@StickyGrains_Florence AS INT = 6
				,@StickyGrains_Tokyo AS INT = 7
				,@StickyGrains_Manila AS INT = 8

				,@PremiumGrains_Paris AS INT = 9
				,@PremiumGrains_Florence AS INT = 10
				,@PremiumGrains_Tokyo AS INT = 11
				,@PremiumGrains_Manila AS INT = 12

				,@ColdGrains_Paris AS INT = 13
				,@ColdGrains_Florence AS INT = 14
				,@ColdGrains_Tokyo AS INT = 15
				,@ColdGrains_Manila AS INT = 16

				,@HotGrains_Paris AS INT = 17
				,@HotGrains_Florence AS INT = 18
				,@HotGrains_Tokyo AS INT = 19
				,@HotGrains_Manila AS INT = 20

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5
	END


	BEGIN 
		EXEC testIC.[Fake Item Stock]
		EXEC testIC.[Fake Item Stock UOM]
		EXEC testIC.[Fake Item Pricing]
		EXEC testIC.[Fake Item UOM]
	END 

	-- Arrange 
	BEGIN 
		-----------------------------------
		-- Create the test tables
		-----------------------------------
		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,dblInTransitOutbound NUMERIC(18,6)
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,dblInTransitOutbound NUMERIC(18,6)
		)

		-----------------------------------
		-- Create the test variables
		-----------------------------------
		DECLARE @Items AS InTransitTableType;
		
		---------------------------------------------------
		-- Setup the items to increase reserved qty
		---------------------------------------------------
		INSERT INTO @Items (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[dblQty] 
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId] 
		)
		SELECT 
			[intItemId] = @WetGrains
			,[intItemLocationId] = @WetGrains_Paris
			,[intItemUOMId] = @WetGrains_BushelUOMId
			,[intLotId] = NULL 
			,[intSubLocationId] = NULL  
			,[intStorageLocationId] = NULL 
			,[dblQty] = -20
			,[intTransactionId] = 1
			,[strTransactionId] = 'TRANS-000001'
			,[intTransactionTypeId] = @SalesType


		---------------------------------------------------
		-- Setup the expected data
		---------------------------------------------------
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,dblInTransitOutbound
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_Paris
				,dblInTransitOutbound = -20
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICIncreaseInTransitOutBoundQty @Items

		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,dblInTransitOutbound
		)
		SELECT	intItemId
				,intItemLocationId
				,dblInTransitOutbound
		FROM	tblICItemStockUOM 
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @WetGrains_Paris
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END