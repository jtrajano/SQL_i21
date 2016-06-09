CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustment_CreatePostSplitLot for a successful post with new weight]
AS
BEGIN 
	-- Variables from Fake items
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

		-- Lot Status
		DECLARE @LOT_STATUS_Active AS INT = 1
				,@LOT_STATUS_On_Hold AS INT = 2
				,@LOT_STATUS_Quarantine AS INT = 3

		DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
				,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
				,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
				,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
				,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
				,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6

		DECLARE @ManualLotGrains_Lot_100001 AS INT = 1
				,@ManualLotGrains_Lot_100002 AS INT = 2
				,@ManualLotGrains_Lot_100003 AS INT = 3
	END

	-- Arrange 
	BEGIN 
		DECLARE @TRANSACTION_TYPE_CONSUME AS INT = 8
				,@TRANSACTION_TYPE_PRODUCE AS INT = 9
				,@TRANSACTION_TYPE_INVENTORY_ADJUSTMENT AS INT = 10

		DECLARE @intInventoryAdjustmentId AS INT 

		-- Call the fake data stored procedures
		EXEC testi21Database.[Fake data for inventory adjustment table];

		-- Create the expected and actual tables for inventory adjustment.
		EXEC testi21Database.[Inventory Adjustment expected tables]

		-- Setup the Lot number string variables. 
		DECLARE @MG_LOT_100001 AS NVARCHAR(50) = 'MG-LOT-100001'
				,@MG_LOT_100002 AS NVARCHAR(50) = 'MG-LOT-100002'
				,@Invalid_Lot AS NVARCHAR(50) = 'INVALID LOT'
	END 	

	-- Act
	BEGIN 
		EXEC dbo.uspICInventoryAdjustment_CreatePostSplitLot	
			@intItemId						= @ManualLotGrains 
			,@dtmDate						= '01/30/2014' 
			,@intLocationId					= @Default_Location 
			,@intSubLocationId				= @Raw_Materials_SubLocation_DefaultLocation 
			,@intStorageLocationId			= @StorageSilo_RM_DL 
			,@strLotNumber					= @MG_LOT_100001 
			-- Parameters for the new values: 
			,@intNewLocationId				= NULL 
			,@intNewSubLocationId			= NULL 
			,@intNewStorageLocationId		= NULL 
			,@strNewLotNumber				= 'NEW-LOT-100001' 
			,@dblAdjustByQuantity			= -2
			,@dblNewSplitLotQuantity		= NULL 
			,@dblNewWeight					= 2000 
			,@intNewItemUOMId				= NULL 
			,@intNewWeightUOMId				= NULL 
			,@dblNewUnitCost				= NULL 
			,@intItemUOMId					= @ManualGrains_25KgBagUOM
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId					= 1  
			,@intSourceTransactionTypeId	= @TRANSACTION_TYPE_PRODUCE 
			,@intEntityUserSecurityId		= 1 
			,@intInventoryAdjustmentId		= @intInventoryAdjustmentId OUTPUT  
	END 
	
	-- Assert 
	BEGIN 
		DECLARE @Expected_InventoryAdjustment_Id AS INT = 14
				,@Expected_InventoryAdjustment AS NVARCHAR(50) = 'ADJ-1001'

		-- Setup the expected data (HEADER)
		INSERT INTO expected_tblICInventoryAdjustment (
				intInventoryAdjustmentId		
				,intLocationId					
				,dtmAdjustmentDate				
				,intAdjustmentType				
				,strAdjustmentNo				
				,strDescription					
				,intSort						
				,ysnPosted						
				,intEntityId					
				,intConcurrencyId				
				,dtmPostedDate					
				,dtmUnpostedDate				
		)
		SELECT
				intInventoryAdjustmentId	= @Expected_InventoryAdjustment_Id	
				,intLocationId				= @Default_Location
				,dtmAdjustmentDate			= '01/30/2014' 		
				,intAdjustmentType			= @ADJUSTMENT_TYPE_SplitLot
				,strAdjustmentNo			= @Expected_InventoryAdjustment
				,strDescription				= ''
				,intSort					= 1
				,ysnPosted					= 1
				,intEntityId				= 1
				,intConcurrencyId			= 2
				,dtmPostedDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dtmUnpostedDate			= NULL 

		-- Setup the expected data (DETAIL)
		INSERT INTO expected_tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentDetailId	
				,intInventoryAdjustmentId		
				,intSubLocationId				
				,intStorageLocationId			
				,intItemId						
				,intLotId						
				,strNewLotNumber 				
				,dblQuantity
				,dblNewQuantity
				,dblAdjustByQuantity
				,intItemUOMId
				,intNewItemUOMId
				,intWeightUOMId
				,intNewWeightUOMId
				,dblWeight
				,dblNewWeight
				,dblWeightPerQty
				,dblNewWeightPerQty
				,dblCost
				,dblNewCost
				,intConcurrencyId						
		)
		SELECT 
				intInventoryAdjustmentDetailId	= 13
				,intInventoryAdjustmentId		= @Expected_InventoryAdjustment_Id
				,intSubLocationId				= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId			= @StorageSilo_RM_DL
				,intItemId						= @ManualLotGrains
				,intLotId						= @ManualLotGrains_Lot_100001
				,strNewLotNumber				= 'NEW-LOT-100001' 				
				,dblQuantity					= 1000.00
				,dblNewQuantity					= 998.00
				,dblAdjustByQuantity			= -2
				,intItemUOMId					= @ManualGrains_25KgBagUOM
				,intNewItemUOMId				= NULL 
				,intWeightUOMId					= @ManualGrains_PoundUOM
				,intNewWeightUOMId				= NULL 
				,dblWeight						= 55.1155 * 1000
				,dblNewWeight					= 2000 
				,dblWeightPerQty				= 55.1155
				,dblNewWeightPerQty				= 2000 / 2
				,dblCost						= 2.50
				,dblNewCost						= NULL 
				,intConcurrencyId				= 1

		-- Setup the expected data (Lot)
		INSERT INTO expected_tblICLot (
			intLotId
			,strLotNumber
			,dblQty
			,dblWeight
			,dblWeightPerQty
		)
		SELECT 
			intLotId			= @ManualLotGrains_Lot_100001
			,strLotNumber		= @MG_LOT_100001
			,dblQty				= 1000.00 - 2
			,dblWeight			= 55115.50 - (55.1155 * 2)
			,dblWeightPerQty	= 55.115500

		-- Get the actual data (Detail)
		INSERT INTO actual_tblICInventoryAdjustment (
				intInventoryAdjustmentId		
				,intLocationId					
				,dtmAdjustmentDate				
				,intAdjustmentType				
				,strAdjustmentNo				
				,strDescription					
				,intSort						
				,ysnPosted						
				,intEntityId					
				,intConcurrencyId				
				,dtmPostedDate					
				,dtmUnpostedDate				
		)
		SELECT
				intInventoryAdjustmentId		
				,intLocationId					
				,dtmAdjustmentDate				
				,intAdjustmentType				
				,strAdjustmentNo				
				,strDescription					
				,intSort						
				,ysnPosted						
				,intEntityId					
				,intConcurrencyId				
				,dbo.fnRemoveTimeOnDate(dtmPostedDate)	-- Remove the time so that we can test it. 
				,dtmUnpostedDate	
		FROM	dbo.tblICInventoryAdjustment 
		WHERE	intInventoryAdjustmentId = @intInventoryAdjustmentId

		-- Get the actual data (DETAIL)
		INSERT INTO actual_tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentDetailId	
				,intInventoryAdjustmentId		
				,intSubLocationId				
				,intStorageLocationId			
				,intItemId						
				,intLotId						
				,strNewLotNumber 				
				,dblQuantity
				,dblNewQuantity
				,dblAdjustByQuantity
				,intItemUOMId
				,intNewItemUOMId
				,intWeightUOMId
				,intNewWeightUOMId
				,dblWeight
				,dblNewWeight
				,dblWeightPerQty
				,dblNewWeightPerQty
				,dblCost
				,dblNewCost
				,intConcurrencyId							
		)
		SELECT 
				intInventoryAdjustmentDetailId	
				,intInventoryAdjustmentId		
				,intSubLocationId				
				,intStorageLocationId			
				,intItemId						
				,intLotId						
				,strNewLotNumber 				
				,dblQuantity
				,dblNewQuantity
				,dblAdjustByQuantity
				,intItemUOMId
				,intNewItemUOMId
				,intWeightUOMId
				,intNewWeightUOMId
				,dblWeight
				,dblNewWeight
				,dblWeightPerQty
				,dblNewWeightPerQty
				,dblCost
				,dblNewCost
				,intConcurrencyId	
		FROM	dbo.tblICInventoryAdjustmentDetail
		WHERE	intInventoryAdjustmentId = @intInventoryAdjustmentId

		-- Get the actual data (Lot)
		INSERT INTO actual_tblICLot (
			intLotId
			,strLotNumber
			,dblQty
			,dblWeight
			,dblWeightPerQty
		)
		SELECT 
			intLotId
			,strLotNumber
			,dblQty
			,dblWeight
			,dblWeightPerQty
		FROM dbo.tblICLot 
		WHERE intLotId = @ManualLotGrains_Lot_100001

	END 	

	EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryAdjustment', 'actual_tblICInventoryAdjustment'
	EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryAdjustmentDetail', 'actual_tblICInventoryAdjustmentDetail'
	EXEC tSQLt.AssertEqualsTable 'expected_tblICLot', 'actual_tblICLot'

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('expected_tblICInventoryAdjustment') IS NOT NULL 
		DROP TABLE expected_tblICInventoryAdjustment

	IF OBJECT_ID('expected_tblICInventoryAdjustmentDetail') IS NOT NULL 
		DROP TABLE expected_tblICInventoryAdjustmentDetail

	IF OBJECT_ID('expected_tblICLot') IS NOT NULL 
		DROP TABLE expected_tblICLot

	IF OBJECT_ID('actual_tblICInventoryAdjustment') IS NOT NULL 
		DROP TABLE actual_tblICInventoryAdjustment

	IF OBJECT_ID('actual_tblICInventoryAdjustmentDetail') IS NOT NULL 
		DROP TABLE actual_tblICInventoryAdjustmentDetail

	IF OBJECT_ID('actual_tblICLot') IS NOT NULL 
		DROP TABLE actual_tblICLot
END 