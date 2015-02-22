CREATE PROCEDURE [testi21Database].[test uspICValidateCostingOnPost as it checks for an invalid item]
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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Create the items to validate variable. 
		DECLARE @Items AS ItemCostingTableType

		-- Insert a record to process 
		INSERT	@Items (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
		)
		SELECT	intItemId = @InvalidItem
				,intItemLocationId = @Default_Location
				,intItemUOMId = -1 
				,dtmDate = GETDATE()
				,dblQty = 10
				,dblUOMQty = 1
				,dblCost = 1.00
				,dblSalesPrice = 2.00
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-XXXXX'
				,intTransactionTypeId = 1
				,intLotId = NULL 

		-- Use the simple item mock data
		EXEC testi21Database.[Fake inventory items]; 
	END 
	
	-- Test case 1: 
	BEGIN 
		-- Assert the error expected
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50027

		-- Act 
		EXEC dbo.uspICValidateCostingOnPost @ItemsToValidate = @Items;
	END 
END 
