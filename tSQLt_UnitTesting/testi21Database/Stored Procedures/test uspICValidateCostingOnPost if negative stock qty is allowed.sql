

CREATE PROCEDURE [testi21Database].[test uspICValidateCostingOnPost if negative stock qty is allowed]
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
		DECLARE @Default_Location AS INT = 1 -- This location allows negative stock (yes)
				,@NewHaven AS INT = 2 -- This location allows negative stock (yes with auto write-off)
				,@BetterHaven AS INT = 3 -- This location does not allow negative stock

		-- Create the items to validate variable. 
		DECLARE @Items AS ItemCostingTableType

		-- Insert a record to process 
		INSERT	@Items (
				intItemId
				, intLocationId
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
				,intLocationId = @Default_Location
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
				,intLocationId = @NewHaven
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
		EXEC testi21Database.[Fake data for simple Items]; 
	END 
	
	-- Test case 1: 
	BEGIN 
		-- Assert the error expected
		EXEC tSQLt.ExpectNoException;

		-- Act 
		EXEC dbo.uspICValidateCostingOnPost @ItemsToValidate = @Items;
	END 
END 
