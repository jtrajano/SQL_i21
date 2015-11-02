﻿CREATE PROCEDURE [testi21Database].[test uspICValidateCostingOnUnpost if negative stock qty is not allowed]
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
		DECLARE @Default_Location AS INT = 1 -- This location allows negative stock
				,@NewHaven AS INT = 2 -- This location allows negative stock
				,@BetterHaven AS INT = 3 -- This location does not allow negative stock

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Create the items to validate variable. 
		DECLARE @Items AS dbo.UnpostItemsTableType

		-- Insert the items unpost 
		INSERT	@Items (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dblQty
				,dblUOMQty
				,intInventoryTransactionId
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 11 --@BetterHaven -- <<< NEGATIVE STOCK IS NOT ALLOWED AT THIS LOCATION
				,intItemUOMId = @WetGrains_BushelUOMId
				,dblQty = -10
				,dblUOMQty = 1
				,intInventoryTransactionId = 1
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 1 --@Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dblQty = -10000
				,dblUOMQty = 1
				,intInventoryTransactionId = 2
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 6 --@NewHaven
				,intItemUOMId = @WetGrains_BushelUOMId
				,dblQty = -10000
				,dblUOMQty = 1
				,intInventoryTransactionId = 3


		-- Use the simple item mock data
		EXEC testi21Database.[Fake transactions for item costing]
	END 
	
	-- Test case 1: 
	BEGIN 
		-- Assert the error expected
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 80003

		-- Act 
		EXEC dbo.uspICValidateCostingOnUnpost @ItemsToValidate = @Items;
	END 
END 