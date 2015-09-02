CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustmentLotMove for generating the items to post, new item UOM]
AS
BEGIN
	-- Item Ids
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@InvalidItem AS INT = -1

	-- Company Location Ids
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

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5
			,@ManualLotGrains_BushelUOMId AS INT = 6
			,@SerializedLotGrains_BushelUOMId AS INT = 7

			,@WetGrains_PoundUOMId AS INT = 8
			,@StickyGrains_PoundUOMId AS INT = 9
			,@PremiumGrains_PoundUOMId AS INT = 10
			,@ColdGrains_PoundUOMId AS INT = 11
			,@HotGrains_PoundUOMId AS INT = 12
			,@ManualLotGrains_PoundUOMId AS INT = 13
			,@SerializedLotGrains_PoundUOMId AS INT = 14

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

	-- Create mock data for Lot Numbers
	DECLARE @ManualLotGrains_Lot_100001 AS INT = 1
			,@ManualLotGrains_Lot_100002 AS INT = 2

	-- Lot Status
	DECLARE @LOT_STATUS_Active AS INT = 1
			,@LOT_STATUS_On_Hold AS INT = 2
			,@LOT_STATUS_Quarantine AS INT = 3

	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
			,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
			,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
			,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
			,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
			,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6
			,@ADJUSTMENT_TYPE_LotMerge AS INT = 7
			,@ADJUSTMENT_TYPE_LotMove AS INT = 8

	DECLARE @INVENTORY_ADJUSTMENT_QuantityChange AS INT = 10
			,@INVENTORY_ADJUSTMENT_UOMChange AS INT = 14
			,@INVENTORY_ADJUSTMENT_ItemChange AS INT = 15
			,@INVENTORY_ADJUSTMENT_LotStatusChange AS INT = 16
			,@INVENTORY_ADJUSTMENT_SplitLot AS INT = 17
			,@INVENTORY_ADJUSTMENT_ExpiryDateChange AS INT = 18
			,@INVENTORY_ADJUSTMENT_LotMerge AS INT = 19
			,@INVENTORY_ADJUSTMENT_LotMove AS INT = 20

	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory adjustment table];

		DECLARE	@intTransactionId AS INT = 11
				,@strBatchId AS NVARCHAR(50) = 'BATCH-XXX1'
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50) = 'Inventory Adjustment'
				,@intUserId AS INT = 1
				,@strAdjustmentDescription AS NVARCHAR(255)

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

		DECLARE @TestItemToPost AS ItemCostingTableType

		SELECT * 
		INTO actual 
		FROM @TestItemToPost

		SELECT * 
		INTO expected
		FROM @TestItemToPost

		-- Change the all split lot into lot merge type
		UPDATE dbo.tblICInventoryAdjustment
		SET intAdjustmentType = @ADJUSTMENT_TYPE_LotMove 
		WHERE intAdjustmentType = @ADJUSTMENT_TYPE_SplitLot	

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
				,intTransactionDetailId	
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		)
		SELECT 	intItemId				= @ManualLotGrains
				,intItemLocationId		= @ManualLotGrains_DefaultLocation
				,intItemUOMId			= @ManualGrains_25KgBagUOM
				,dtmDate				= '05/21/2015'
				,dblQty					= -500.000000
				,dblUOMQty				= @25KgBagUnitQty
				,dblCost				= 2.500000 * @25KgBagUnitQty
				,dblValue				= 0
				,dblSalesPrice			= 0
				,intCurrencyId			= NULL 
				,dblExchangeRate		= 1
				,intTransactionId		= 11
				,intTransactionDetailId	= 10
				,strTransactionId		= 'ADJ-11'
				,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_LotMove
				,intLotId				= @ManualLotGrains_Lot_100001
				,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId	= @StorageSilo_RM_DL
		UNION ALL 
		SELECT	
				intItemId				= @ManualLotGrains
				,intItemLocationId		= @ManualLotGrains_DefaultLocation
				,intItemUOMId			= @ManualGrains_10LbBagUOM
				,dtmDate				= '05/21/2015'
				,dblQty					= 500 
				,dblUOMQty				= @10LbBagUnitQty
				,dblCost				= 2.50 * @25KgBagUnitQty
				,dblValue				= 0
				,dblSalesPrice			= 0
				,intCurrencyId			= NULL 
				,dblExchangeRate		= 1
				,intTransactionId		= 11
				,intTransactionDetailId	= 10
				,strTransactionId		= 'ADJ-11'
				,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_LotMove
				,intLotId				= 4
				,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId	= @StorageSilo_RM_DL
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentLotMove
				@intTransactionId
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
				,@strAdjustmentDescription

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
				,intTransactionDetailId
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		) 
		SELECT 
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
				,intTransactionDetailId
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
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