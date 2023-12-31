﻿CREATE PROCEDURE [testi21Database].[test uspICGetItemsFromItemReceipt for getting data from the receipt]
AS
BEGIN
	-- Fake data
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

		DECLARE -- Receipt Types
				@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
				,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
				,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
				,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'

				-- Source Types
				,@SOURCE_TYPE_NONE AS INT = 1
				,@SOURCE_TYPE_SCALE AS INT = 2
				,@SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 3

				-- Ownership Types
				,@OWNERSHIP_TYPE_OWN AS INT = 1
				,@OWNERSHIP_TYPE_STORAGE AS INT = 2
				,@OWNERSHIP_TYPE_CONSIGNED_PURCHASE AS INT = 3
				,@OWNERSHIP_TYPE_CONSIGNED_SALE AS INT = 4

		DECLARE @BaseCurrencyId AS INT = 1;

		EXEC [testi21Database].[Fake data for inventory receipt table]
	END

	-- Arrange 
	BEGIN 
		DECLARE @intReceiptId AS INT = 1 -- INVRCPT-XXXXX1. It has all kinds of items on it. 
		DECLARE @result AS ReceiptItemTableType
		
		-- Create the expected table. 
		SELECT *
		INTO expected
		FROM @result

		-- Create the actual table. 
		SELECT * 
		INTO actual 
		FROM @result 				
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		INSERT INTO @result 
		EXEC dbo.uspICGetItemsFromItemReceipt
			@intReceiptId
	END 

	-- Setup the expected result
	BEGIN 
		INSERT INTO expected (
			-- Header 
			[intInventoryReceiptId] 
			,[strInventoryReceiptId] 
			,[strReceiptType] 
			,[intSourceType] 
			,[dtmDate] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			-- Detail 
			,[intInventoryReceiptDetailId] 
			,[intItemId] 
			,[intLotId] 
			,[strLotNumber] 
			,[intLocationId] 
			,[intItemLocationId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intWeightUOMId] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNetWeight] 
			,[dblCost] 
			,[intContainerId] 
			,[intOwnershipType] 
			,[intOrderId] 
			,[intSourceId] 
			,[intLineNo] 
		)
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 1
			,[intItemId]					= @WetGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @WetGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @WetGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 10
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 1.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 1
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 2
			,[intItemId]					= @StickyGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @StickyGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @StickyGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 10
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 2.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 2
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 3
			,[intItemId]					= @PremiumGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @PremiumGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @PremiumGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 10
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 3.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 3
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 4
			,[intItemId]					= @ColdGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @ColdGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @ColdGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 10
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 4.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 4
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 5
			,[intItemId]					= @HotGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @HotGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @HotGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 10
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 5.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 5
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 6
			,[intItemId]					= @ManualLotGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @ManualLotGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @ManualGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 7
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 6.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 6
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 6
			,[intItemId]					= @ManualLotGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @ManualLotGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @ManualGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 3
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 6.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 6

		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 7
			,[intItemId]					= @SerializedLotGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @SerializedLotGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @SerializedGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 2
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 7.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 7
		UNION ALL 
		SELECT 
			-- Header 
			[intInventoryReceiptId]			= 1
			,[strInventoryReceiptId]		= 'INVRCPT-XXXXX1'
			,[strReceiptType]				= @RECEIPT_TYPE_PURCHASE_ORDER
			,[intSourceType]				= @SOURCE_TYPE_NONE
			,[dtmDate]						= '01/10/2014'
			,[intCurrencyId]				= @BaseCurrencyId
			,[dblExchangeRate]				= 1
			-- Detail 
			,[intInventoryReceiptDetailId]	= 7
			,[intItemId]					= @SerializedLotGrains
			,[intLotId]						= NULL 
			,[strLotNumber]					= NULL 
			,[intLocationId]				= @Default_Location
			,[intItemLocationId]			= @SerializedLotGrains_DefaultLocation
			,[intSubLocationId]				= NULL 
			,[intStorageLocationId]			= NULL 
			,[intItemUOMId]					= @SerializedGrains_BushelUOM
			,[intWeightUOMId]				= NULL 
			,[dblQty]						= 8
			,[dblUOMQty]					= @BushelUnitQty
			,[dblNetWeight]					= 0.00 
			,[dblCost]						= 7.00
			,[intContainerId]				= NULL 
			,[intOwnershipType]				= @OWNERSHIP_TYPE_OWN
			,[intOrderId]					= NULL 
			,[intSourceId]					= NULL 
			,[intLineNo]					= 7
	END 

	-- Assert
	BEGIN
		-- Get the result and insert it to the actual table. 
		INSERT INTO actual (
			-- Header 
			[intInventoryReceiptId] 
			,[strInventoryReceiptId] 
			,[strReceiptType] 
			,[intSourceType] 
			,[dtmDate] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			-- Detail 
			,[intInventoryReceiptDetailId] 
			,[intItemId] 
			,[intLotId] 
			,[strLotNumber] 
			,[intLocationId] 
			,[intItemLocationId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intWeightUOMId] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNetWeight] 
			,[dblCost] 
			,[intContainerId] 
			,[intOwnershipType] 
			,[intOrderId] 
			,[intSourceId] 
			,[intLineNo] 
		)
		SELECT 
			-- Header 
			[intInventoryReceiptId] 
			,[strInventoryReceiptId] 
			,[strReceiptType] 
			,[intSourceType] 
			,[dtmDate] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			-- Detail 
			,[intInventoryReceiptDetailId] 
			,[intItemId] 
			,[intLotId] 
			,[strLotNumber] 
			,[intLocationId] 
			,[intItemLocationId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intWeightUOMId] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNetWeight] 
			,[dblCost] 
			,[intContainerId] 
			,[intOwnershipType] 
			,[intOrderId] 
			,[intSourceId] 
			,[intLineNo] 
		FROM @result

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END 