

CREATE PROCEDURE [testi21Database].[test uspICValidateCostingOnPost if negative stock qty is not allowed]
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
		DECLARE @Items AS ItemCostingTableType

		-- Insert a record to process 
		INSERT	@Items (
				intItemId
				, intItemLocationId
				, dtmDate
				, dblUnitQty
				, dblUOMQty
				, dblCost
				, dblSalesPrice
				, intCurrencyId
				, dblExchangeRate
				, intTransactionId
				, strTransactionId
				, intTransactionTypeId
				, intLotId
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @BetterHaven -- <<< NEGATIVE STOCK IS NOT ALLOWED AT THIS LOCATION
				,dtmDate = GETDATE()
				,dblUnitQty = -10
				,dblUOMQty = 1
				,dblCost = 1.00
				,dblSalesPrice = 2.00
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-XXXXX'
				,intTransactionTypeId = 1
				,intLotId = NULL 
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = GETDATE()
				,dblUnitQty = -10000
				,dblUOMQty = 1
				,dblCost = 1.00
				,dblSalesPrice = 2.00
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-XXXXX'
				,intTransactionTypeId = 1
				,intLotId = NULL 
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @NewHaven
				,dtmDate = GETDATE()
				,dblUnitQty = -10000
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
		EXEC testi21Database.[Fake transactions for item costing]
	END 
	
	-- Test case 1: 
	BEGIN 
		-- Assert the error expected
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50029

		-- Act 
		EXEC dbo.uspICValidateCostingOnPost @ItemsToValidate = @Items;
	END 
END 
