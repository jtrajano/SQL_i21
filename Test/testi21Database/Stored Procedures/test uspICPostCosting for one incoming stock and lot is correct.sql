CREATE PROCEDURE testi21Database.[test uspICPostCosting for one incoming stock and lot is correct]
AS

BEGIN 
	-- Create the fake data
	EXEC testi21Database.[Fake transactions for lot items and costing]

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
END 

BEGIN

	DECLARE @SubLocation AS INT = 1
	DECLARE @StorageLocation AS INT = 2

	-- Arrange 
	BEGIN 

		-- Create the expected and actual tables. 
		CREATE TABLE expected (
			[intLotId]					INT 
			,[intItemId]				INT 
			,[intLocationId]			INT 
			,[intItemLocationId]		INT 
			,[intItemUOMId]				INT 
			,[strLotNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intSubLocationId]			INT 
			,[intStorageLocationId]		INT 
			,[dblQty]					NUMERIC(18,6) 
			,[dblLastCost]				NUMERIC(18,6) 
			,[dtmExpiryDate]			DATETIME 
			,[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intLotStatusId]			INT 
			,[intParentLotId]			INT 
			,[intSplitFromLotId]		INT 
			,[dblWeight]				NUMERIC(18,6) 
			,[intWeightUOMId]			INT 
			,[dblWeightPerQty]			NUMERIC(18,6) 
			,[intOriginId]				INT 
			,[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strVessel]				NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[strMarkings]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS 
			,[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS 
			,[intVendorId]				INT 
			,[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intVendorLocationId]		INT NULL 
			,[strVendorLocation]		NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strContractNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,[dtmManufacturedDate]		DATETIME 
			,[ysnReleasedToWarehouse]	BIT 
			,[ysnProduced]				BIT 
			,[dtmDateCreated]			DATETIME 
			,[intCreatedUserId]			INT 
			,[intConcurrencyId]			INT 
		)

		SELECT * INTO actual FROM expected

		DECLARE @InventoryReceipt AS INT = 4	
		DECLARE @InventoryShipment AS INT = 5

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsForPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';
		DECLARE @intUserId AS INT = 1;

		-- Setup the items to post
		INSERT INTO @ItemsForPost (  
			intItemId  
			,intItemLocationId 
			,intItemUOMId  
			,dtmDate  
			,dblQty  
			,dblUOMQty  
			,dblCost  
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
		SELECT	intItemId				= @ManualLotGrains
				,intItemLocationId		= @ManualLotGrains_DefaultLocation
				,intItemUOMId			= @ManualGrains_BushelUOM
				,dtmDate				= '01/01/2015'
				,dblQty					= 20			
				,dblUOMQty				= @BushelUnitQty
				,dblCost				= 12.20
				,dblSalesPrice			= 0  
				,intCurrencyId			= 1
				,dblExchangeRate		= 1  
				,intTransactionId		= 1
				,intTransactionDetailId = 1
				,strTransactionId		= 'RECEIPT-00001'
				,intTransactionTypeId	= @InventoryReceipt  
				,intLotId				= 1
				,intSubLocationId		= @SubLocation
				,intStorageLocationId	= @StorageLocation

			-- Setup the expected lot data
			INSERT INTO expected 
			SELECT	*
			FROM	dbo.tblICLot

			UPDATE	expected
			SET		dblQty = dblQty + 20 -- + 20 bushels
					,dblWeight = 250 + (20 * 2.500) -- + 50 pounds (20 bushel x 2.5 pound/bushel)
					,dblLastCost = 12.20 / @BushelUnitQty -- $12.20 / bushel unit qty
	END 	
	
	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries  
		EXEC dbo.uspICPostCosting
			@ItemsForPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intUserId

		INSERT INTO actual 
		SELECT	*
		FROM	dbo.tblICLot
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
