CREATE PROCEDURE testi21Database.[test uspICPostCosting for two incoming stock and the inventory-transaction is correct]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for FIFO or Ave costing]

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
				,@WRITE_OFF_SOLD AS INT = 2
				,@REVALUE_SOLD AS INT = 3

		DECLARE @PurchaseType AS INT = 4
		DECLARE @SalesType AS INT = 5

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5

		---- Declare the variables for location
		--DECLARE @Default_Location AS INT = 1
		--		,@NewHaven AS INT = 2
		--		,@BetterHaven AS INT = 3

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Declare Item-Locations
		DECLARE @WetGrains_DefaultLocation AS INT = 1
				,@StickyGrains_DefaultLocation AS INT = 2
				,@PremiumGrains_DefaultLocation AS INT = 3
				,@ColdGrains_DefaultLocation AS INT = 4
				,@HotGrains_DefaultLocation AS INT = 5

				,@WetGrains_NewHaven AS INT = 6
				,@StickyGrains_NewHaven AS INT = 7
				,@PremiumGrains_NewHaven AS INT = 8
				,@ColdGrains_NewHaven AS INT = 9
				,@HotGrains_NewHaven AS INT = 10

				,@WetGrains_BetterHaven AS INT = 11
				,@StickyGrains_BetterHaven AS INT = 12
				,@PremiumGrains_BetterHaven AS INT = 13
				,@ColdGrains_BetterHaven AS INT = 14
				,@HotGrains_BetterHaven AS INT = 15

				,@ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17

				,@CornCommodity_DefaultLocation AS INT = 18
				,@CornCommodity_NewHaven AS INT = 19
				,@CornCommodity_BetterHaven AS INT = 20

				,@ManualLotGrains_NewHaven AS INT = 21
				,@SerializedLotGrains_NewHaven AS INT = 22

				,@OtherCharges_DefaultLocation AS INT = 23
				,@SurchargeOtherCharges_DefaultLocation AS INT = 24
				,@SurchargeOnSurcharge_DefaultLocation AS INT = 25
				,@SurchargeOnSurchargeOnSurcharge_DefaultLocation AS INT = 26

				,@OtherCharges_NewHaven AS INT = 27
				,@SurchargeOtherCharges_NewHaven AS INT = 28
				,@SurchargeOnSurcharge_NewHaven AS INT = 29
				,@SurchargeOnSurchargeOnSurcharge_NewHaven AS INT = 30

				,@OtherCharges_BetterHaven AS INT = 31
				,@SurchargeOtherCharges_BetterHaven AS INT = 32
				,@SurchargeOnSurcharge_BetterHaven AS INT = 33
				,@SurchargeOnSurchargeOnSurcharge_BetterHaven AS INT = 34

		DECLARE	@UOM_Bushel AS INT = 1
				,@UOM_Pound AS INT = 2
				,@UOM_Kg AS INT = 3
				,@UOM_25KgBag AS INT = 4
				,@UOM_10LbBag AS INT = 5
				,@UOM_Ton AS INT = 6

		DECLARE @BushelUnitQty AS NUMERIC(18,6) = 1
				,@PoundUnitQty AS NUMERIC(18,6) = 1
				,@KgUnitQty AS NUMERIC(18,6) = 2.20462
				,@25KgBagUnitQty AS NUMERIC(18,6) = 55.1155
				,@10LbBagUnitQty AS NUMERIC(18,6) = 10
				,@TonUnitQty AS NUMERIC(18,6) = 2204.62

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

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
		SELECT * INTO expected FROM dbo.tblICInventoryTransaction		
		SELECT * INTO actual FROM dbo.tblICInventoryTransaction

		-- Drop the dtmCreated column. We don't need to assert it. 
		ALTER TABLE expected
			DROP COLUMN dtmCreated

		-- Drop the dtmCreated column. We don't need to assert it. 
		ALTER TABLE actual
			DROP COLUMN dtmCreated

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';
		DECLARE @intEntityUserSecurityId AS INT = 1;

		-- Setup the items to post
		INSERT INTO @ItemsToPost (
				intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblSalesPrice 
				,dblValue 
				,intCurrencyId 
				,dblExchangeRate 
				,intTransactionId 
				,intTransactionDetailId 
				,strTransactionId 
				,intTransactionTypeId 
				,intLotId 
				,intSubLocationId 
				,intStorageLocationId 
		)
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 14, 2014'
				,dblQty = 100
				,dblUOMQty = @BushelUnitQty
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 1
				,strTransactionId = 'PURCHASE-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intSubLocationId = NULL
				,intStorageLocationId = NULL
		UNION ALL 
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblQty = 75
				,dblUOMQty = @BushelUnitQty
				,dblCost = 18.25
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 2
				,strTransactionId = 'PURCHASE-000002'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intSubLocationId = NULL
				,intStorageLocationId = NULL

		-- Setup the expected tblICInventoryTransaction
		INSERT INTO expected (
				intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty
				,dblCost 
				,dblValue 
				,dblSalesPrice 
				,intCurrencyId 
				,dblExchangeRate 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,intLotId 
				,intCreatedEntityId 
				,intConcurrencyId 
				,intCostingMethod
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 14, 2014'
				,dblQty = 100
				,dblUOMQty = @BushelUnitQty
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 0 
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intCreatedEntityId = 1
				,intConcurrencyId = 1
				,intCostingMethod = 1 -- Average Costing
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblQty = 75
				,dblUOMQty = @BushelUnitQty
				,dblCost = 18.25
				,dblValue = 0
				,dblSalesPrice = 0 
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000002'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intCreatedEntityId = 1
				,intConcurrencyId = 1
				,intCostingMethod = 1 -- Average Costing
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BushelUOMId
				,intItemUOMId = NULL 
				,dtmDate = 'November 14, 2014'
				,dblQty = 0
				,dblUOMQty = 0
				,dblCost = 0
				,dblValue = -0.00000000000005 -- (18.06818181818181818182 * 275) - (100.0 * 22.0) - (100.0 * 14.0) - (75.0 * 18.25)
				,dblSalesPrice = 0 
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @AUTO_NEGATIVE
				,intLotId = NULL
				,intCreatedUserId = 1
				,intConcurrencyId = 1
				,intCostingMethod = 1 -- Average Costing
	END 

	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries 
		EXEC dbo.uspICPostCosting
			@ItemsToPost
			,@strBatchId 
			,NULL -- @strAccountToCounterInventory 
			,@intEntityUserSecurityId

		INSERT INTO actual (
				intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty
				,dblCost 
				,dblValue 
				,dblSalesPrice 
				,intCurrencyId 
				,dblExchangeRate 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,intLotId 
				,intCreatedEntityId 
				,intConcurrencyId 
				,intCostingMethod		
		)
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty
				,dblCost 
				,dblValue 
				,dblSalesPrice 
				,intCurrencyId 
				,dblExchangeRate 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,intLotId 
				,intCreatedEntityId 
				,intConcurrencyId 
				,intCostingMethod
		FROM	dbo.tblICInventoryTransaction
		WHERE	strBatchId = 'BATCH-000001'
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