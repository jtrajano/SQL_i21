CREATE PROCEDURE [testi21Database].[test uspICPostCustody for calling uspICPostFIFOInCustody]
AS
-- Fake data Variables
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

	-- Declare the account ids
	DECLARE @Inventory_Default AS INT = 1000
	DECLARE @CostOfGoods_Default AS INT = 2000
	DECLARE @APClearing_Default AS INT = 3000
	DECLARE @WriteOffSold_Default AS INT = 4000
	DECLARE @RevalueSold_Default AS INT = 5000 
	DECLARE @AutoNegative_Default AS INT = 6000
	DECLARE @InventoryInTransit_Default AS INT = 7000
	DECLARE @AccountReceivable_Default AS INT = 8000
	DECLARE @InventoryAdjustment_Default AS INT = 9000

	DECLARE @Inventory_NewHaven AS INT = 1001
	DECLARE @CostOfGoods_NewHaven AS INT = 2001
	DECLARE @APClearing_NewHaven AS INT = 3001
	DECLARE @WriteOffSold_NewHaven AS INT = 4001
	DECLARE @RevalueSold_NewHaven AS INT = 5001
	DECLARE @AutoNegative_NewHaven AS INT = 6001
	DECLARE @InventoryInTransit_NewHaven AS INT = 7001
	DECLARE @AccountReceivable_NewHaven AS INT = 8001
	DECLARE @InventoryAdjustment_NewHaven AS INT = 9001

	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002
	DECLARE @InventoryInTransit_BetterHaven AS INT = 7002
	DECLARE @AccountReceivable_BetterHaven AS INT = 8002
	DECLARE @InventoryAdjustment_BetterHaven AS INT = 9002

	DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
	DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
	DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102

	-- Declare Account Categories
	DECLARE @AccountCategoryName_Inventory AS NVARCHAR(100) = 'Inventory'
	DECLARE @AccountCategoryId_Inventory AS INT = 27

	DECLARE @AccountCategoryName_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
	DECLARE @AccountCategoryId_CostOfGoods AS INT = 10

	DECLARE @AccountCategoryName_APClearing AS NVARCHAR(100) = 'AP Clearing'
	DECLARE @AccountCategoryId_APClearing AS INT = 45
	
	DECLARE @AccountCategoryName_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
	DECLARE @AccountCategoryId_WriteOffSold AS INT = 42

	DECLARE @AccountCategoryName_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
	DECLARE @AccountCategoryId_RevalueSold AS INT = 43

	DECLARE @AccountCategoryName_AutoNegative AS NVARCHAR(100) = 'Auto Negative'
	DECLARE @AccountCategoryId_AutoNegative AS INT = 44

	DECLARE @AccountCategoryName_InventoryInTransit AS NVARCHAR(100) = 'Inventory In Transit'
	DECLARE @AccountCategoryId_InventoryInTransit AS INT = 46

	DECLARE @AccountCategoryName_InventoryAdjustment AS NVARCHAR(100) = 'Inventory Adjustment'
	DECLARE @AccountCategoryId_InventoryAdjustment AS INT = 50

	-- Declare the item categories
	DECLARE @HotItems AS INT = 1
	DECLARE @ColdItems AS INT = 2

	-- Declare the commodities
	DECLARE @Commodity_Corn AS INT = 999

	-- Declare the costing methods
	DECLARE @AverageCosting AS INT = 1
	DECLARE @FIFO AS INT = 2
	DECLARE @LIFO AS INT = 3

	-- Negative stock options
	DECLARE @AllowNegativeStock AS INT = 1
	DECLARE @AllowNegativeStockWithWriteOff AS INT = 2
	DECLARE @DoNotAllowNegativeStock AS INT = 3

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

	-- Declare fake lot ids
	DECLARE @Lot_1 AS INT = 1
			,@Lot_2 AS INT = 2
			,@Lot_3 AS INT = 3
			,@Lot_4 AS INT = 4
			,@Lot_5 AS INT = 5
END 

BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC [testi21Database].[Fake transactions for item custody]

		-- Add a spy for uspICPostFIFOInCustody
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostFIFOInCustody';		

		-- Create the expected and actual tables. 
		SELECT intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost INTO expected FROM dbo.tblICInventoryLotInCustody WHERE 1 = 0		
		SELECT intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost INTO actual FROM dbo.tblICInventoryLotInCustody WHERE 1 = 0

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20);
		DECLARE @intUserId AS INT = 1;
		DECLARE @intTransactionTypeId AS INT 
		DECLARE @intNewLotId AS INT = 1999

		SELECT	TOP  1
				@intTransactionTypeId = intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType
		WHERE	strName = 'Inventory Shipment'

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
				,ysnIsCustody 	
		)
		SELECT	intItemId				= @WetGrains
				,intItemLocationId		= @WetGrains_NewHaven
				,intItemUOMId			= @WetGrains_PoundUOM
				,dtmDate				= 'January 25, 2015'
				,dblQty					= -10
				,dblUOMQty				= @PoundUnitQty
				,dblCost				= 12.00
				,dblSalesPrice			= 90.00
				,dblValue				= 0.00
				,intCurrencyId			= NULL 
				,dblExchangeRate		= 1
				,intTransactionId		= 985
				,intTransactionDetailId	= 41
				,strTransactionId		= 'INVSHIP-10001'
				,intTransactionTypeId	= @intTransactionTypeId
				,intLotId				= NULL  
				,intSubLocationId		= NULL 
				,intStorageLocationId 	= NULL 
				,ysnIsCustody			= 1
		UNION ALL 
		SELECT	intItemId				= @WetGrains
				,intItemLocationId		= @WetGrains_NewHaven
				,intItemUOMId			= @WetGrains_PoundUOM
				,dtmDate				= 'January 25, 2015'
				,dblQty					= -10
				,dblUOMQty				= @PoundUnitQty
				,dblCost				= 12.00
				,dblSalesPrice			= 90.00
				,dblValue				= 0.00
				,intCurrencyId			= NULL 
				,dblExchangeRate		= 1
				,intTransactionId		= 986
				,intTransactionDetailId	= 42
				,strTransactionId		= 'INVSHIP-10002'
				,intTransactionTypeId	= @intTransactionTypeId
				,intLotId				= NULL  
				,intSubLocationId		= NULL 
				,intStorageLocationId 	= NULL 
				,ysnIsCustody			= 1
	END 

	-- Act
	BEGIN 	
		-- Call uspICPostCustody to process stocks for custody. 
		EXEC dbo.uspICPostCustody
			@ItemsToPost
			,@strBatchId 
			,@intUserId
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.AssertObjectExists 'uspICPostFIFOInCustody_SpyProcedureLog'
	END 
END 

-- Clean-up: remove the tables used in the unit test
IF OBJECT_ID('actual') IS NOT NULL 
	DROP TABLE actual

IF OBJECT_ID('expected') IS NOT NULL 
	DROP TABLE dbo.expected
