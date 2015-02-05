CREATE PROCEDURE testi21Database.[test uspICPostCosting for two incoming stock and the item stock is correct]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for item costing]

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3
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

		-- Declare the variables for the currencies and unit of measure
		DECLARE @USD AS INT = 1;
		
		DECLARE @Each AS INT = 1;

		-- Declare the account ids
		DECLARE @Inventory_Default AS INT = 1000
		DECLARE @CostOfGoods_Default AS INT = 2000
		DECLARE @APClearing_Default AS INT = 3000
		DECLARE @WriteOffSold_Default AS INT = 4000
		DECLARE @RevalueSold_Default AS INT = 5000 
		DECLARE @AutoNegative_Default AS INT = 6000

		DECLARE @Inventory_NewHaven AS INT = 1001
		DECLARE @CostOfGoods_NewHaven AS INT = 2001
		DECLARE @APClearing_NewHaven AS INT = 3001
		DECLARE @WriteOffSold_NewHaven AS INT = 4001
		DECLARE @RevalueSold_NewHaven AS INT = 5001
		DECLARE @AutoNegative_NewHaven AS INT = 6001

		DECLARE @Inventory_BetterHaven AS INT = 1002
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @APClearing_BetterHaven AS INT = 3002
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
		DECLARE @RevalueSold_BetterHaven AS INT = 5002
		DECLARE @AutoNegative_BetterHaven AS INT = 6002

		-- Create the expected and actual tables. 
		SELECT intItemId, intItemLocationId, dblAverageCost, dblUnitOnHand INTO expected FROM dbo.tblICItemStock WHERE 1 = 0		
		SELECT intItemId, intItemLocationId, dblAverageCost, dblUnitOnHand INTO actual FROM dbo.tblICItemStock WHERE 1 = 0

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';
		DECLARE @intUserId AS INT = 1;

		-- Setup the items to post
		INSERT INTO @ItemsToPost 
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 14, 2014'
				,dblUnitQty = 100
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
		UNION ALL 
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = 75
				,dblUOMQty = 1
				,dblCost = 18.25
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000002'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL

		-- Setup the expected tblICItemStock
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,dblAverageCost
				,dblUnitOnHand
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dblAverageCost = 18.068182 -- The long value is 18.06818181818182. It must round to 6 decimal places
				,dblUnitOnHand = 275
	END 	
	
	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries  
		EXEC dbo.uspICPostCosting
			@ItemsToPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intUserId

		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,dblAverageCost
				,dblUnitOnHand	
		)
		SELECT	intItemId
				,intItemLocationId
				,dblAverageCost
				,dblUnitOnHand
		FROM	dbo.tblICItemStock
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