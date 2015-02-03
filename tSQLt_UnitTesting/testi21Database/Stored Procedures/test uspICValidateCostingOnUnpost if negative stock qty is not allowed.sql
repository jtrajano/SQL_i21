CREATE PROCEDURE [testi21Database].[test uspICValidateCostingOnUnpost if negative stock qty is not allowed]
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

		-- Create the items to validate variable. 
		DECLARE @Items AS dbo.UnpostItemsTableType

		-- Insert the items unpost 
		INSERT	@Items (
				intItemId
				,intItemLocationId
				,dblTotalQty
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 11 --@BetterHaven -- <<< NEGATIVE STOCK IS NOT ALLOWED AT THIS LOCATION
				,dblTotalQty = -10 
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 1 --@Default_Location
				,dblTotalQty = -10000
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 6 --@NewHaven
				,dblTotalQty = -10000

		-- Use the simple item mock data
		EXEC testi21Database.[Fake transactions for item costing]
	END 
	
	-- Test case 1: 
	BEGIN 
		-- Assert the error expected
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50029

		-- Act 
		EXEC dbo.uspICValidateCostingOnUnpost @ItemsToValidate = @Items;
	END 
END 
