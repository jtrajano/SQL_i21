CREATE PROCEDURE [testi21Database].[Fake transactions for item custody]
AS

-- Fake data
BEGIN
	EXEC testi21Database.[Fake inventory items];

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
END 

BEGIN	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOInCustody', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOInCustody', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionInCustody', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionInCustody', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;

	-- Declare fake lot ids
	DECLARE @Lot_1 AS INT = 1
			,@Lot_2 AS INT = 2
			,@Lot_3 AS INT = 3
			,@Lot_4 AS INT = 4
			,@Lot_5 AS INT = 5

	-- Re-create the index
	CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLotInCustody]
		ON [dbo].[tblICInventoryLotInCustody]([intInventoryLotInCustodyId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC, [intItemUOMId] ASC);

	-- Fake data for tblICInventoryLotInCustody (the cost bucket for custody items)
	BEGIN
		INSERT INTO dbo.tblICInventoryLotInCustody (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, intLotId
				, dtmDate
				, dblStockIn
				, dblStockOut
				, dblCost
		) 
		--------------------------------------------------------------
		-- Lot Costing
		--------------------------------------------------------------
		SELECT	intItemId = @WetGrains
				, intItemLocationId = @WetGrains_DefaultLocation
				, intItemUOMId = @WetGrains_PoundUOM
				, intLotId = @Lot_1
				, dtmDate = 'January 1, 2015'
				, dblStockIn = 110 
				, dblStockOut = 0 
				, dblCost = 11.00
		UNION ALL 
		SELECT	intItemId = @StickyGrains
				, intItemLocationId = @StickyGrains_DefaultLocation
				, intItemUOMId = @StickyGrains_PoundUOM
				, intLotId = @Lot_2
				, dtmDate = 'February 1, 2015'
				, dblStockIn = 220
				, dblStockOut = 0 
				, dblCost = 22.00
		UNION ALL 
		SELECT	intItemId = @PremiumGrains
				, intItemLocationId = @PremiumGrains_DefaultLocation
				, intItemUOMId = @PremiumGrains_PoundUOM
				, intLotId = @Lot_3
				, dtmDate = 'March 1, 2015'
				, dblStockIn = 330
				, dblStockOut = 0 
				, dblCost = 33.00
		UNION ALL 
		SELECT	intItemId = @ColdGrains
				, intItemLocationId = @ColdGrains_DefaultLocation
				, intItemUOMId = @ColdGrains_PoundUOM
				, intLotId = @Lot_4
				, dtmDate = 'April 1, 2015'
				, dblStockIn = 440
				, dblStockOut = 0 
				, dblCost = 44.00
		UNION ALL 
		SELECT	intItemId = @HotGrains
				, intItemLocationId = @HotGrains_DefaultLocation
				, intItemUOMId = @HotGrains_PoundUOM
				, intLotId = @Lot_5
				, dtmDate = 'May 1, 2015'
				, dblStockIn = 550
				, dblStockOut = 0 
				, dblCost = 55.00

	END

	-- Fake data for tblICInventoryFIFOInCustody (the cost bucket for custody items)
	BEGIN 
		INSERT INTO dbo.tblICInventoryFIFOInCustody (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, dtmDate
				, dblStockIn
				, dblStockOut
				, dblCost
		) 
		--------------------------------------------------------------
		-- FIFO 
		--------------------------------------------------------------
		SELECT	intItemId = @WetGrains
				, intItemLocationId = @WetGrains_NewHaven
				, intItemUOMId = @WetGrains_PoundUOM
				, dtmDate = 'January 2, 2015'
				, dblStockIn = 660 
				, dblStockOut = 0 
				, dblCost = 11.00
		UNION ALL 
		SELECT	intItemId = @StickyGrains
				, intItemLocationId = @StickyGrains_NewHaven
				, intItemUOMId = @StickyGrains_PoundUOM
				, dtmDate = 'February 2, 2015'
				, dblStockIn = 770
				, dblStockOut = 0 
				, dblCost = 22.00
		UNION ALL 
		SELECT	intItemId = @PremiumGrains
				, intItemLocationId = @PremiumGrains_NewHaven
				, intItemUOMId = @PremiumGrains_PoundUOM
				, dtmDate = 'March 2, 2015'
				, dblStockIn = 880
				, dblStockOut = 0 
				, dblCost = 33.00
		UNION ALL 
		SELECT	intItemId = @ColdGrains
				, intItemLocationId = @ColdGrains_NewHaven
				, intItemUOMId = @ColdGrains_PoundUOM
				, dtmDate = 'April 2, 2015'
				, dblStockIn = 990
				, dblStockOut = 0 
				, dblCost = 44.00
		UNION ALL 
		SELECT	intItemId = @HotGrains
				, intItemLocationId = @HotGrains_NewHaven
				, intItemUOMId = @HotGrains_PoundUOM
				, dtmDate = 'May 2, 2015'
				, dblStockIn = 1100
				, dblStockOut = 0 
				, dblCost = 55.00				
	END 

	-- Fake data for tblICInventoryLIFOInCustody (the cost bucket for custody items)
	BEGIN 
		INSERT INTO dbo.tblICInventoryLIFOInCustody (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, dtmDate
				, dblStockIn
				, dblStockOut
				, dblCost
		) 
		--------------------------------------------------------------
		-- LIFO 
		--------------------------------------------------------------
		SELECT	intItemId = @WetGrains
				, intItemLocationId = @WetGrains_BetterHaven
				, intItemUOMId = @WetGrains_PoundUOM
				, dtmDate = 'January 3, 2015'
				, dblStockIn = 1200 
				, dblStockOut = 0 
				, dblCost = 11.00
		UNION ALL 
		SELECT	intItemId = @StickyGrains
				, intItemLocationId = @StickyGrains_BetterHaven
				, intItemUOMId = @StickyGrains_PoundUOM
				, dtmDate = 'February 3, 2015'
				, dblStockIn = 1300
				, dblStockOut = 0 
				, dblCost = 22.00
		UNION ALL 
		SELECT	intItemId = @PremiumGrains
				, intItemLocationId = @PremiumGrains_BetterHaven
				, intItemUOMId = @PremiumGrains_PoundUOM
				, dtmDate = 'March 3, 2015'
				, dblStockIn = 1400
				, dblStockOut = 0 
				, dblCost = 33.00
		UNION ALL 
		SELECT	intItemId = @ColdGrains
				, intItemLocationId = @ColdGrains_BetterHaven
				, intItemUOMId = @ColdGrains_PoundUOM
				, dtmDate = 'April 3, 2015'
				, dblStockIn = 1500
				, dblStockOut = 0 
				, dblCost = 44.00
		UNION ALL 
		SELECT	intItemId = @HotGrains
				, intItemLocationId = @HotGrains_BetterHaven
				, intItemUOMId = @HotGrains_PoundUOM
				, dtmDate = 'May 3, 2015'
				, dblStockIn = 1600
				, dblStockOut = 0 
				, dblCost = 55.00				
	END 

	-- Fake data for item stock table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStock (
				intItemId
				, intItemLocationId
				, dblUnitInCustody
		)		 
		SELECT	intItemId			= @WetGrains
				, intItemLocationId	= @WetGrains_DefaultLocation
				, dblUnitInCustody	= 110
		UNION ALL 
		SELECT	intItemId			= @StickyGrains
				, intItemLocationId	= @StickyGrains_DefaultLocation
				, dblUnitInCustody	= 220
		UNION ALL 
		SELECT	intItemId			= @PremiumGrains
				, intItemLocationId	= @PremiumGrains_DefaultLocation
				, dblUnitInCustody	= 330
		UNION ALL 
		SELECT	intItemId			= @ColdGrains
				, intItemLocationId	= @ColdGrains_DefaultLocation
				, dblUnitInCustody	= 440
		UNION ALL 
		SELECT	intItemId			= @HotGrains
				, intItemLocationId	= @HotGrains_DefaultLocation
				, dblUnitInCustody	= 550

		-- Add stock information for items under location 2 ('NEW HAVEN')
		UNION ALL 
		SELECT	intItemId			= @WetGrains
				, intItemLocationId	= @WetGrains_NewHaven
				, dblUnitInCustody	= 660
		UNION ALL 
		SELECT	intItemId			= @StickyGrains
				, intItemLocationId	= @StickyGrains_NewHaven
				, dblUnitInCustody	= 770
		UNION ALL 
		SELECT	intItemId			= @PremiumGrains
				, intItemLocationId	= @PremiumGrains_NewHaven
				, dblUnitInCustody	= 880
		UNION ALL 
		SELECT	intItemId			= @ColdGrains
				, intItemLocationId	= @ColdGrains_NewHaven
				, dblUnitInCustody	= 990
		UNION ALL 
		SELECT	intItemId			= @HotGrains
				, intItemLocationId	= @HotGrains_NewHaven
				, dblUnitInCustody	= 1100

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		UNION ALL 
		SELECT	intItemId			= @WetGrains
				, intItemLocationId	= @WetGrains_BetterHaven
				, dblUnitInCustody	= 1200
		UNION ALL 
		SELECT	intItemId			= @StickyGrains
				, intItemLocationId	= @StickyGrains_BetterHaven
				, dblUnitInCustody	= 1300
		UNION ALL 
		SELECT	intItemId			= @PremiumGrains
				, intItemLocationId	= @PremiumGrains_BetterHaven
				, dblUnitInCustody	= 1400
		UNION ALL 
		SELECT	intItemId			= @ColdGrains
				, intItemLocationId	= @ColdGrains_BetterHaven
				, dblUnitInCustody	= 1500
		UNION ALL 
		SELECT	intItemId			= @HotGrains
				, intItemLocationId	= @HotGrains_BetterHaven
				, dblUnitInCustody	= 1600
	END

	-- Fake data for item stock UOM table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStockUOM (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, dblInCustody		
		) 
		SELECT	intItemId			= @WetGrains
				, intItemLocationId	= @WetGrains_DefaultLocation
				, intItemUOMId		= @WetGrains_PoundUOM
				, dblInCustody		= 110
		UNION ALL 
		SELECT	intItemId			= @StickyGrains
				, intItemLocationId	= @StickyGrains_DefaultLocation
				, intItemUOMId		= @StickyGrains_PoundUOM
				, dblInCustody		= 220
		UNION ALL 
		SELECT	intItemId			= @PremiumGrains
				, intItemLocationId	= @PremiumGrains_DefaultLocation
				, intItemUOMId		= @PremiumGrains_PoundUOM
				, dblInCustody		= 330
		UNION ALL 
		SELECT	intItemId			= @ColdGrains
				, intItemLocationId	= @ColdGrains_DefaultLocation
				, intItemUOMId		= @ColdGrains_PoundUOM
				, dblInCustody		= 440
		UNION ALL 
		SELECT	intItemId			= @HotGrains
				, intItemLocationId	= @HotGrains_DefaultLocation
				, intItemUOMId		= @HotGrains_PoundUOM
				, dblInCustody		= 550

		-- Add stock information for items under location 2 ('NEW HAVEN')
		UNION ALL
		SELECT	intItemId			= @WetGrains
				, intItemLocationId	= @WetGrains_NewHaven
				, intItemUOMId		= @WetGrains_PoundUOM
				, dblInCustody		= 660
		UNION ALL 
		SELECT	intItemId			= @StickyGrains
				, intItemLocationId	= @StickyGrains_NewHaven
				, intItemUOMId		= @StickyGrains_PoundUOM
				, dblInCustody		= 770
		UNION ALL 
		SELECT	intItemId			= @PremiumGrains
				, intItemLocationId	= @PremiumGrains_NewHaven
				, intItemUOMId		= @PremiumGrains_PoundUOM
				, dblInCustody		= 880
		UNION ALL 
		SELECT	intItemId			= @ColdGrains
				, intItemLocationId	= @ColdGrains_NewHaven
				, intItemUOMId		= @ColdGrains_PoundUOM
				, dblInCustody		= 990
		UNION ALL 
		SELECT	intItemId			= @HotGrains
				, intItemLocationId	= @HotGrains_NewHaven
				, intItemUOMId		= @HotGrains_PoundUOM
				, dblInCustody		= 1100

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		UNION ALL
		SELECT	intItemId			= @WetGrains
				, intItemLocationId	= @WetGrains_BetterHaven
				, intItemUOMId		= @WetGrains_PoundUOM
				, dblInCustody		= 1200
		UNION ALL 
		SELECT	intItemId			= @StickyGrains
				, intItemLocationId	= @StickyGrains_BetterHaven
				, intItemUOMId		= @StickyGrains_PoundUOM
				, dblInCustody		= 1300
		UNION ALL 
		SELECT	intItemId			= @PremiumGrains
				, intItemLocationId	= @PremiumGrains_BetterHaven
				, intItemUOMId		= @PremiumGrains_PoundUOM
				, dblInCustody		= 1400
		UNION ALL 
		SELECT	intItemId			= @ColdGrains
				, intItemLocationId	= @ColdGrains_BetterHaven
				, intItemUOMId		= @ColdGrains_PoundUOM
				, dblInCustody		= 1500
		UNION ALL 
		SELECT	intItemId			= @HotGrains
				, intItemLocationId	= @HotGrains_BetterHaven
				, intItemUOMId		= @HotGrains_PoundUOM
				, dblInCustody		= 1600
	END

	-- Fake data for tblICInventoryTransactionInCustody
	BEGIN 
		DECLARE @intTransactionTypeId AS INT
		SELECT	TOP 1 
				@intTransactionTypeId = intTransactionTypeId
		FROM dbo.tblICInventoryTransactionType
		WHERE strName = 'Inventory Receipt'

		INSERT INTO dbo.tblICInventoryTransactionInCustody (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, dtmDate
				, dblQty
				, dblUOMQty
				, dblCost
				, dblValue
				, dblSalesPrice
				, intCurrencyId
				, dblExchangeRate
				, intTransactionId
				, strTransactionId
				, strBatchId
				, intTransactionTypeId
				, intLotId
				, intConcurrencyId
		) 
		---------------------------------------------------------------
		-- Lot Costing transactions
		---------------------------------------------------------------
		SELECT	intItemId				= @WetGrains
				, intItemLocationId		= @WetGrains_DefaultLocation
				, intItemUOMId			= @WetGrains_PoundUOM
				, dtmDate				= 'January 1, 2015'
				, dblQty				= 110
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 11.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 1
				, strTransactionId		= 'INVRCT-00001'
				, strBatchId			= 'BATCH-00001'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_1
				, intConcurrencyId		= 1
		UNION ALL 		
		SELECT	intItemId				= @StickyGrains
				, intItemLocationId		= @StickyGrains_DefaultLocation
				, intItemUOMId			= @StickyGrains_PoundUOM
				, dtmDate				= 'February 1, 2015'
				, dblQty				= 220
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 22.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 2
				, strTransactionId		= 'INVRCT-00002'
				, strBatchId			= 'BATCH-00002'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_2
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @PremiumGrains
				, intItemLocationId		= @PremiumGrains_DefaultLocation
				, intItemUOMId			= @PremiumGrains_PoundUOM
				, dtmDate				= 'March 1, 2015'
				, dblQty				= 330
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 33.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 3
				, strTransactionId		= 'INVRCT-00003'
				, strBatchId			= 'BATCH-00003'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_3
				, intConcurrencyId		= 1				
		UNION ALL 		
		SELECT	intItemId				= @ColdGrains
				, intItemLocationId		= @ColdGrains_DefaultLocation
				, intItemUOMId			= @ColdGrains_PoundUOM
				, dtmDate				= 'April 1, 2015'
				, dblQty				= 440
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 44.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 4
				, strTransactionId		= 'INVRCT-00004'
				, strBatchId			= 'BATCH-00004'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_4
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @HotGrains
				, intItemLocationId		= @HotGrains_DefaultLocation
				, intItemUOMId			= @HotGrains_PoundUOM
				, dtmDate				= 'May 1, 2015'
				, dblQty				= 550
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 55.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 5
				, strTransactionId		= 'INVRCT-00005'
				, strBatchId			= 'BATCH-00005'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_5
				, intConcurrencyId		= 1						
		---------------------------------------------------------------
		-- FIFO / Average  Costing transactions
		---------------------------------------------------------------		
		UNION ALL 
		SELECT	intItemId				= @WetGrains
				, intItemLocationId		= @WetGrains_NewHaven
				, intItemUOMId			= @WetGrains_PoundUOM
				, dtmDate				= 'January 2, 2015'
				, dblQty				= 110
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 11.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 6
				, strTransactionId		= 'INVRCT-00006'
				, strBatchId			= 'BATCH-00006'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1
		UNION ALL 		
		SELECT	intItemId				= @StickyGrains
				, intItemLocationId		= @StickyGrains_NewHaven
				, intItemUOMId			= @StickyGrains_PoundUOM
				, dtmDate				= 'February 2, 2015'
				, dblQty				= 220
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 22.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 7
				, strTransactionId		= 'INVRCT-00007'
				, strBatchId			= 'BATCH-00007'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @PremiumGrains
				, intItemLocationId		= @PremiumGrains_NewHaven
				, intItemUOMId			= @PremiumGrains_PoundUOM
				, dtmDate				= 'March 2, 2015'
				, dblQty				= 330
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 33.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 8
				, strTransactionId		= 'INVRCT-00008'
				, strBatchId			= 'BATCH-00008'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1				
		UNION ALL 		
		SELECT	intItemId				= @ColdGrains
				, intItemLocationId		= @ColdGrains_NewHaven
				, intItemUOMId			= @ColdGrains_PoundUOM
				, dtmDate				= 'April 2, 2015'
				, dblQty				= 440
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 44.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 9
				, strTransactionId		= 'INVRCT-00009'
				, strBatchId			= 'BATCH-00009'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @HotGrains
				, intItemLocationId		= @HotGrains_NewHaven
				, intItemUOMId			= @HotGrains_PoundUOM
				, dtmDate				= 'May 2, 2015'
				, dblQty				= 550
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 55.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 10
				, strTransactionId		= 'INVRCT-00010'
				, strBatchId			= 'BATCH-00010'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1				
		---------------------------------------------------------------
		-- LIFO Costing transactions
		---------------------------------------------------------------		
		UNION ALL 
		SELECT	intItemId				= @WetGrains
				, intItemLocationId		= @WetGrains_BetterHaven
				, intItemUOMId			= @WetGrains_PoundUOM
				, dtmDate				= 'January 3, 2015'
				, dblQty				= 1200
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 11.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 11
				, strTransactionId		= 'INVRCT-00011'
				, strBatchId			= 'BATCH-00011'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1
		UNION ALL 		
		SELECT	intItemId				= @StickyGrains
				, intItemLocationId		= @StickyGrains_BetterHaven
				, intItemUOMId			= @StickyGrains_PoundUOM
				, dtmDate				= 'February 3, 2015'
				, dblQty				= 1300
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 22.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 12
				, strTransactionId		= 'INVRCT-00012'
				, strBatchId			= 'BATCH-00012'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @PremiumGrains
				, intItemLocationId		= @PremiumGrains_BetterHaven
				, intItemUOMId			= @PremiumGrains_PoundUOM
				, dtmDate				= 'March 3, 2015'
				, dblQty				= 1400
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 33.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 13
				, strTransactionId		= 'INVRCT-00013'
				, strBatchId			= 'BATCH-00013'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1				
		UNION ALL 		
		SELECT	intItemId				= @ColdGrains
				, intItemLocationId		= @ColdGrains_BetterHaven
				, intItemUOMId			= @ColdGrains_PoundUOM
				, dtmDate				= 'April 3, 2015'
				, dblQty				= 1500
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 44.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 14
				, strTransactionId		= 'INVRCT-00014'
				, strBatchId			= 'BATCH-00014'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @HotGrains
				, intItemLocationId		= @HotGrains_BetterHaven
				, intItemUOMId			= @HotGrains_PoundUOM
				, dtmDate				= 'May 3, 2015'
				, dblQty				= 1600
				, dblUOMQty				= @PoundUnitQty
				, dblCost				= 55.00
				, dblValue				= 0 
				, dblSalesPrice			= 0.00
				, intCurrencyId			= NULL 
				, dblExchangeRate		= 1
				, intTransactionId		= 15
				, strTransactionId		= 'INVRCT-00015'
				, strBatchId			= 'BATCH-00015'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= NULL
				, intConcurrencyId		= 1								
	END 

	-- Fake data for tblICInventoryLotTransactionInCustody
	BEGIN 
		SELECT	TOP 1 
				@intTransactionTypeId = intTransactionTypeId
		FROM dbo.tblICInventoryTransactionType
		WHERE strName = 'Inventory Receipt'

		INSERT INTO dbo.tblICInventoryLotTransactionInCustody (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, dtmDate
				, dblQty				
				, dblCost
				, intTransactionId
				, strTransactionId
				, strBatchId
				, intTransactionTypeId
				, intLotId
				, intConcurrencyId
		) 
		SELECT	intItemId				= @WetGrains
				, intItemLocationId		= @WetGrains_DefaultLocation
				, intItemUOMId			= @WetGrains_PoundUOM
				, dtmDate				= 'January 1, 2015'
				, dblQty				= 110
				, dblCost				= 11.00
				, intTransactionId		= 1
				, strTransactionId		= 'INVRCT-00001'
				, strBatchId			= 'BATCH-00001'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_1
				, intConcurrencyId		= 1
		UNION ALL 		
		SELECT	intItemId				= @StickyGrains
				, intItemLocationId		= @StickyGrains_DefaultLocation
				, intItemUOMId			= @StickyGrains_PoundUOM
				, dtmDate				= 'February 1, 2015'
				, dblQty				= 220
				, dblCost				= 22.00
				, intTransactionId		= 2
				, strTransactionId		= 'INVRCT-00002'
				, strBatchId			= 'BATCH-00002'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_2
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @PremiumGrains
				, intItemLocationId		= @PremiumGrains_DefaultLocation
				, intItemUOMId			= @PremiumGrains_PoundUOM
				, dtmDate				= 'March 1, 2015'
				, dblQty				= 330
				, dblCost				= 33.00
				, intTransactionId		= 3
				, strTransactionId		= 'INVRCT-00003'
				, strBatchId			= 'BATCH-00003'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_3
				, intConcurrencyId		= 1				
		UNION ALL 		
		SELECT	intItemId				= @ColdGrains
				, intItemLocationId		= @ColdGrains_DefaultLocation
				, intItemUOMId			= @ColdGrains_PoundUOM
				, dtmDate				= 'April 1, 2015'
				, dblQty				= 440
				, dblCost				= 44.00
				, intTransactionId		= 4
				, strTransactionId		= 'INVRCT-00004'
				, strBatchId			= 'BATCH-00004'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_4
				, intConcurrencyId		= 1		
		UNION ALL 		
		SELECT	intItemId				= @HotGrains
				, intItemLocationId		= @HotGrains_DefaultLocation
				, intItemUOMId			= @HotGrains_PoundUOM
				, dtmDate				= 'May 1, 2015'
				, dblQty				= 550
				, dblCost				= 55.00
				, intTransactionId		= 5
				, strTransactionId		= 'INVRCT-00005'
				, strBatchId			= 'BATCH-00005'
				, intTransactionTypeId	= @intTransactionTypeId
				, intLotId				= @Lot_5
				, intConcurrencyId		= 1								
	END 
END