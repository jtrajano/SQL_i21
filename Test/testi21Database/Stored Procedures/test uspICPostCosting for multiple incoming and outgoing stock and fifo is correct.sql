CREATE PROCEDURE testi21Database.[test uspICPostCosting for multiple incoming and outgoing stock and fifo is correct]
AS
BEGIN
	-- Fake inventory items. 
	BEGIN 

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7
				,@CornCommodity AS INT = 8
				,@OtherCharges AS INT = 9
				,@SurchargeOtherCharges AS INT = 10
				,@SurchargeOnSurcharge AS INT = 11
				,@SurchargeOnSurchargeOnSurcharge AS INT = 12
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for sub-locations
		DECLARE @Raw_Materials_SubLocation_DefaultLocation AS INT = 1
				,@FinishedGoods_SubLocation_DefaultLocation AS INT = 2
				,@Raw_Materials_SubLocation_NewHaven AS INT = 3
				,@FinishedGoods_SubLocation_NewHaven AS INT = 4
				,@Raw_Materials_SubLocation_BetterHaven AS INT = 5
				,@FinishedGoods_SubLocation_BetterHaven AS INT = 6

		-- Declare the variables for storage locations
		DECLARE @StorageSilo_RM_DL AS INT = 1
				,@StorageSilo_FG_DL AS INT = 2
				,@StorageSilo_RM_NH AS INT = 3
				,@StorageSilo_FG_NH AS INT = 4
				,@StorageSilo_RM_BH AS INT = 5
				,@StorageSilo_FG_BH AS INT = 6

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

		DECLARE @WetGrains_BushelUOM AS INT = 1,		@StickyGrains_BushelUOM AS INT = 2,		@PremiumGrains_BushelUOM AS INT = 3,
				@ColdGrains_BushelUOM AS INT = 4,		@HotGrains_BushelUOM AS INT = 5,		@ManualGrains_BushelUOM AS INT = 6,
				@SerializedGrains_BushelUOM AS INT = 7	

		DECLARE @WetGrains_PoundUOM AS INT = 8,			@StickyGrains_PoundUOM AS INT = 9,		@PremiumGrains_PoundUOM AS INT = 10,
				@ColdGrains_PoundUOM AS INT = 11,		@HotGrains_PoundUOM AS INT = 12,		@ManualGrains_PoundUOM AS INT = 13,
				@SerializedGrains_PoundUOM AS INT = 14	

		DECLARE @WetGrains_KgUOM AS INT = 15,			@StickyGrains_KgUOM AS INT = 16,		@PremiumGrains_KgUOM AS INT = 17,
				@ColdGrains_KgUOM AS INT = 18,			@HotGrains_KgUOM AS INT = 19,			@ManualGrains_KgUOM AS INT = 20,
				@SerializedGrains_KgUOM AS INT = 21

		DECLARE @WetGrains_25KgBagUOM AS INT = 22,		@StickyGrains_25KgBagUOM AS INT = 23,	@PremiumGrains_25KgBagUOM AS INT = 24,
				@ColdGrains_25KgBagUOM AS INT = 25,		@HotGrains_25KgBagUOM AS INT = 26,		@ManualGrains_25KgBagUOM AS INT = 27,
				@SerializedGrains_25KgBagUOM AS INT = 28

		DECLARE @WetGrains_10LbBagUOM AS INT = 29,		@StickyGrains_10LbBagUOM AS INT = 30,	@PremiumGrains_10LbBagUOM AS INT = 31,
				@ColdGrains_10LbBagUOM AS INT = 32,		@HotGrains_10LbBagUOM AS INT = 33,		@ManualGrains_10LbBagUOM AS INT = 34,
				@SerializedGrains_10LbBagUOM AS INT = 35

		DECLARE @WetGrains_TonUOM AS INT = 36,			@StickyGrains_TonUOM AS INT = 37,		@PremiumGrains_TonUOM AS INT = 38,
				@ColdGrains_TonUOM AS INT = 39,			@HotGrains_TonUOM AS INT = 40,			@ManualGrains_TonUOM AS INT = 41,
				@SerializedGrains_TonUOM AS INT = 42

		DECLARE @Corn_BushelUOM AS INT = 43,			@Corn_PoundUOM AS INT = 44,				@Corn_KgUOM AS INT = 45, 
				@Corn_25KgBagUOM AS INT = 46,			@Corn_10LbBagUOM AS INT = 47,			@Corn_TonUOM AS INT = 48

		DECLARE @OtherCharges_PoundUOM AS INT = 49
		DECLARE @SurchargeOtherCharges_PoundUOM AS INT = 50
		DECLARE @SurchargeOnSurcharge_PoundUOM AS INT = 51
		DECLARE @SurchargeOnSurchargeOnSurcharge_PoundUOM AS INT = 52

		DECLARE @UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'
				,@UNIT_TYPE_Packed AS NVARCHAR(50) = 'Packed'

		EXEC testi21Database.[Fake inventory items];
	END 	

	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for FIFO or Ave costing]

		-- Flag all item to allow negative stock 
		UPDATE dbo.tblICItemLocation
		SET intAllowNegativeInventory = 1

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3
		DECLARE @PurchaseType AS INT = 1
		DECLARE @SalesType AS INT = 2

		-- Declare the variables for the currencies and unit of measure
		DECLARE @USD AS INT = 1;		
		DECLARE @Each AS INT = 1;

		-- Create the expected and actual tables. 
		SELECT intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost INTO expected FROM dbo.tblICInventoryFIFO WHERE 1 = 0;
		SELECT intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost INTO actual FROM dbo.tblICInventoryFIFO WHERE 1 = 0;

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
		-- in (Stock goes up to 200)
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = 100
				,dblUOMQty = 1
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to 170)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = -30
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 2
				,strTransactionId = 'SALE-000001'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to 135)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = -35
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 3
				,strTransactionId = 'SALE-000002'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to 90)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = -45
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 4
				,strTransactionId = 'SALE-000003'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to -42)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = -132
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 27.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 5
				,strTransactionId = 'SALE-000004'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- in (Stock goes up to -22)
		UNION ALL		
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = 20
				,dblUOMQty = 1
				,dblCost = 15.50
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 6
				,strTransactionId = 'PURCHASE-000002'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- in (Stock goes up to 0)
		UNION ALL				
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = 22
				,dblUOMQty = 1
				,dblCost = 16.50
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 7
				,strTransactionId = 'PURCHASE-000003'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- in (Stock goes up to 100)
		UNION ALL				
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblQty = 100
				,dblUOMQty = 1
				,dblCost = 18.00
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,intTransactionDetailId = 8
				,strTransactionId = 'PURCHASE-000004'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL

		-- Setup the expected (for tblICInventoryFIFO)
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'January 1, 2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 22.00
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 14.00
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 42
				,dblStockOut = 42
				,dblCost = 18.00
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 20
				,dblStockOut = 20
				,dblCost = 15.50
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 22
				,dblStockOut = 22
				,dblCost = 16.50
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOM
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 18.00
	END 	

	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries  
		EXEC dbo.uspICPostCosting
			@ItemsToPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intEntityUserSecurityId

		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT	intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
		FROM	dbo.tblICInventoryFIFO
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @WetGrains_DefaultLocation
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