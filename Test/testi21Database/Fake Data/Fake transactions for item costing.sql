CREATE PROCEDURE [testi21Database].[Fake transactions for item costing]
AS
BEGIN	
	-- Fake inventory items. 
	BEGIN 
		-- Create the CONSTANT variables for the costing methods
		DECLARE @AVERAGECOST AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4 	
				,@ACTUALCOST AS INT = 5	

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

	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemStockUOM', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemPricing', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOCostAdjustmentLog', @Identity = 1;

	-- Re-create the index
	CREATE CLUSTERED INDEX [IDX_tblICInventoryFIFO]
		ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOId] ASC);

	-- Declare the variables for the transaction types
	DECLARE @PurchaseType AS INT = 4
	DECLARE @SalesType AS INT = 5

	-- Fake data for tblICInventoryFIFO
	BEGIN
		INSERT INTO dbo.tblICInventoryFIFO (
				intItemId
				, intItemLocationId
				, intItemUOMId
				, dtmDate
				, dblStockIn
				, dblStockOut
				, dblCost
				, intConcurrencyId
				, intTransactionId
				, intTransactionDetailId
				, strTransactionId
		) 
		SELECT	intItemId = @WetGrains
				, intItemLocationId = @WetGrains_DefaultLocation
				, intItemUOMId = @WetGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblStockIn = 100 
				, dblStockOut = 0
				, dblCost = 22.00
				, intConcurrencyId = 1
				, intTransactionId = 1
				, intTransactionDetailId = 1
				, strTransactionId = 'PURCHASE-100000'
		UNION ALL 
		SELECT	intItemId = @StickyGrains
				, intItemLocationId = @StickyGrains_DefaultLocation
				, intItemUOMId = @StickyGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblStockIn = 150
				, dblStockOut = 0
				, dblCost = 33.00
				, intConcurrencyId = 1
				, intTransactionId = 2
				, intTransactionDetailId = 2
				, strTransactionId = 'PURCHASE-200000'
		UNION ALL 
		SELECT	intItemId = @PremiumGrains
				, intItemLocationId = @PremiumGrains_DefaultLocation
				, intItemUOMId = @PremiumGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblStockIn = 200
				, dblStockOut = 0
				, dblCost = 44.00
				, intConcurrencyId = 1
				, intTransactionId = 3
				, intTransactionDetailId = 3
				, strTransactionId = 'PURCHASE-300000'
		UNION ALL 
		SELECT	intItemId = @ColdGrains
				, intItemLocationId = @ColdGrains_DefaultLocation
				, intItemUOMId = @ColdGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblStockIn = 250
				, dblStockOut = 0
				, dblCost = 55.00
				, intConcurrencyId = 1
				, intTransactionId = 4
				, intTransactionDetailId = 4
				, strTransactionId = 'PURCHASE-400000'
		UNION ALL 
		SELECT	intItemId = @HotGrains
				, intItemLocationId = @HotGrains_DefaultLocation
				, intItemUOMId = @HotGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblStockIn = 300
				, dblStockOut = 0
				, dblCost = 66.00
				, intConcurrencyId = 1
				, intTransactionId = 5
				, intTransactionDetailId = 5
				, strTransactionId = 'PURCHASE-500000'

	END 

	-- Fake data for item stock table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains,		@WetGrains_DefaultLocation,		100)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains,		@StickyGrains_DefaultLocation,	150)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains,	@PremiumGrains_DefaultLocation, 200)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains,		@ColdGrains_DefaultLocation,	250)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains,		@HotGrains_DefaultLocation,		300)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains,		@WetGrains_NewHaven,		0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains,		@StickyGrains_NewHaven,		0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains,	@PremiumGrains_NewHaven,	0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains,		@ColdGrains_NewHaven,		0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains,		@HotGrains_NewHaven,		0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains,		@WetGrains_BetterHaven,		0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains,		@StickyGrains_BetterHaven,	0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains,	@PremiumGrains_BetterHaven,	0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains,		@ColdGrains_BetterHaven,	0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains,		@HotGrains_BetterHaven,		0)
	END

	-- Fake data for item stock UOM table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains,		@WetGrains_DefaultLocation,		@WetGrains_BushelUOM,		100)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains,	@StickyGrains_DefaultLocation,	@StickyGrains_BushelUOM,	150)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains,	@PremiumGrains_DefaultLocation, @PremiumGrains_BushelUOM,	200)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains,		@ColdGrains_DefaultLocation,	@ColdGrains_BushelUOM,		250)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains,		@HotGrains_DefaultLocation,		@HotGrains_BushelUOM,		300)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains,		@WetGrains_NewHaven,		@WetGrains_BushelUOM,			0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains,	@StickyGrains_NewHaven,		@StickyGrains_BushelUOM,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains,	@PremiumGrains_NewHaven,	@PremiumGrains_BushelUOM,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains,		@ColdGrains_NewHaven,		@ColdGrains_BushelUOM,			0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains,		@HotGrains_NewHaven,		@HotGrains_BushelUOM,			0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains,		@WetGrains_BetterHaven,		@WetGrains_BushelUOM,			0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains,	@StickyGrains_BetterHaven,	@StickyGrains_BushelUOM,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains,	@PremiumGrains_BetterHaven,	@PremiumGrains_BushelUOM,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains,		@ColdGrains_BetterHaven,	@ColdGrains_BushelUOM,			0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains,		@HotGrains_BetterHaven,		@HotGrains_BushelUOM,			0)
	END

	-- Fake data for item pricing table
	BEGIN 
		-- Add pricing information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@WetGrains,		@WetGrains_DefaultLocation,		22, 22)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@StickyGrains,		@StickyGrains_DefaultLocation,	33, 33)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@PremiumGrains,	@PremiumGrains_DefaultLocation, 44, 44)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@ColdGrains,		@ColdGrains_DefaultLocation,	55, 55)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@HotGrains,		@HotGrains_DefaultLocation,		66, 66)

		-- Add pricing information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@WetGrains,		@WetGrains_NewHaven,		0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@StickyGrains,		@StickyGrains_NewHaven,		0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@PremiumGrains,	@PremiumGrains_NewHaven,	0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@ColdGrains,		@ColdGrains_NewHaven,		0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@HotGrains,		@HotGrains_NewHaven,		0, 0)

		-- Add pricing information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@WetGrains,		@WetGrains_BetterHaven,		0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@StickyGrains,		@StickyGrains_BetterHaven,	0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@PremiumGrains,	@PremiumGrains_BetterHaven,	0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@ColdGrains,		@ColdGrains_BetterHaven,	0, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost, dblLastCost) VALUES (@HotGrains,		@HotGrains_BetterHaven,		0, 0)
	END

	-- Fake data for tblICInventoryTransaction
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (
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
				, intTransactionDetailId
				, strTransactionId
				, strBatchId
				, intTransactionTypeId
				, intLotId
				, intConcurrencyId
				, intCostingMethod 
				, ysnIsUnposted
		) 
		SELECT	intItemId = @WetGrains
				, intItemLocationId = @WetGrains_DefaultLocation
				, intItemUOMId = @WetGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblQty = 100
				, dblUOMQty = 1
				, dblCost = 22.00
				, dblValue = 0 
				, dblSalesPrice = 0
				, intCurrencyId = 1
				, dblExchangeRate = 1
				, intTransactionId = 1
				, intTransactionDetailId = 1
				, strTransactionId = 'PURCHASE-100000'
				, strBatchId = 'BATCH-100000'
				, intTransactionTypeId = @PurchaseType
				, intLotId = NULL
				, intConcurrencyId = 1
				, intCostingMethod = @AVERAGECOST
				, ysnIsUnposted = 0
		UNION ALL 
		SELECT	intItemId = @StickyGrains
				, intItemLocationId = @StickyGrains_DefaultLocation
				, intItemUOMId = @StickyGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblQty = 150
				, dblUOMQty = 1
				, dblCost = 33.00
				, dblValue = 0 
				, dblSalesPrice = 0
				, intCurrencyId = 1
				, dblExchangeRate = 1
				, intTransactionId = 2
				, intTransactionDetailId = 2
				, strTransactionId = 'PURCHASE-200000'
				, strBatchId = 'BATCH-200000'
				, intTransactionTypeId = @PurchaseType
				, intLotId = NULL
				, intConcurrencyId = 1
				, intCostingMethod = @AVERAGECOST
				, ysnIsUnposted = 0
		UNION ALL 
		SELECT	intItemId = @PremiumGrains
				, intItemLocationId = @PremiumGrains_DefaultLocation
				, intItemUOMId = @PremiumGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblQty = 200
				, dblUOMQty = 1
				, dblCost = 44.00
				, dblValue = 0 
				, dblSalesPrice = 0
				, intCurrencyId = 1
				, dblExchangeRate = 1
				, intTransactionId = 3
				, intTransactionDetailId = 3
				, strTransactionId = 'PURCHASE-300000'
				, strBatchId = 'BATCH-300000'
				, intTransactionTypeId = @PurchaseType
				, intLotId = NULL
				, intConcurrencyId = 1
				, intCostingMethod = @AVERAGECOST
				, ysnIsUnposted = 0
		UNION ALL 
		SELECT	intItemId = @ColdGrains
				, intItemLocationId = @ColdGrains_DefaultLocation
				, intItemUOMId = @ColdGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblQty = 250
				, dblUOMQty = 1
				, dblCost = 55.00
				, dblValue = 0 
				, dblSalesPrice = 0
				, intCurrencyId = 1
				, dblExchangeRate = 1
				, intTransactionId = 3
				, intTransactionDetailId = 4
				, strTransactionId = 'PURCHASE-400000'
				, strBatchId = 'BATCH-400000'
				, intTransactionTypeId = @PurchaseType
				, intLotId = NULL
				, intConcurrencyId = 1
				, intCostingMethod = @AVERAGECOST
				, ysnIsUnposted = 0
		UNION ALL 
		SELECT	intItemId = @HotGrains
				, intItemLocationId = @HotGrains_DefaultLocation
				, intItemUOMId = @HotGrains_BushelUOM
				, dtmDate = 'January 1, 2014'
				, dblQty = 300
				, dblUOMQty = 1
				, dblCost = 66.00
				, dblValue = 0 
				, dblSalesPrice = 0
				, intCurrencyId = 1
				, dblExchangeRate = 1
				, intTransactionId = 5
				, intTransactionDetailId = 5
				, strTransactionId = 'PURCHASE-500000'
				, strBatchId = 'BATCH-500000'
				, intTransactionTypeId = @PurchaseType
				, intLotId = NULL
				, intConcurrencyId = 1
				, intCostingMethod = @AVERAGECOST
				, ysnIsUnposted = 0
	END 
END