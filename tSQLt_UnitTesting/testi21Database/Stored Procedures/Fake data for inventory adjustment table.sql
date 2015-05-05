CREATE PROCEDURE [testi21Database].[Fake data for inventory adjustment table]
AS
BEGIN
	EXEC [testi21Database].[Fake inventory items];
	EXEC testi21Database.[Fake open fiscal year and accounting periods]
		
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryAdjustment';	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryAdjustmentDetail', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICLot';	

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

	-- Create mock data for the starting number 
	EXEC tSQLt.FakeTable 'dbo.tblSMStartingNumber';	
	INSERT	[dbo].[tblSMStartingNumber] (
			[intStartingNumberId] 
			,[strTransactionType]
			,[strPrefix]
			,[intNumber]
			,[strModule]
			,[ysnEnable]
			,[intConcurrencyId]
	)
	SELECT	[intStartingNumberId]	= 24
			,[strTransactionType]	= N'Lot Number'
			,[strPrefix]			= N'LOT-'
			,[intNumber]			= 10000
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	UNION ALL
	SELECT	[intStartingNumberId]	= 3
			,[strTransactionType]	= N'Batch Post'
			,[strPrefix]			= N'BATCH-'
			,[intNumber]			= 1
			,[strModule]			= N'Posting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1

	-- Create mock data for Lot Numbers
	DECLARE @ManualLotGrains_Lot_100001 AS INT = 1
			,@ManualLotGrains_Lot_100002 AS INT = 2

	-- Lot Status
	DECLARE @LOT_STATUS_Active AS INT = 1
			,@LOT_STATUS_On_Hold AS INT = 2
			,@LOT_STATUS_Quarantine AS INT = 3

	INSERT INTO dbo.tblICLot (
		intLotId
		,intItemId
		,intLocationId
		,intItemLocationId
		,intItemUOMId
		,strLotNumber
		,intSubLocationId
		,intStorageLocationId
		,dblQty
		,dblLastCost
		,dtmExpiryDate
		,strLotAlias
		,intLotStatusId
		,dblWeight
		,intWeightUOMId
		,dblWeightPerQty
	)
	SELECT 
		intLotId				= @ManualLotGrains_Lot_100001
		,intItemId				= @ManualLotGrains
		,intLocationId			= @Default_Location
		,intItemLocationId		= @ManualLotGrains_DefaultLocation
		,intItemUOMId			= @ManualGrains_25KgBagUOM
		,strLotNumber			= 'MG-LOT-100001'
		,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
		,intStorageLocationId	= @StorageSilo_RM_DL
		,dblQty					= 1000 
		,dblLastCost			= 2.50
		,dtmExpiryDate			= '01/10/2018'
		,strLotAlias			= 'Fine grade raw material'
		,intLotStatusId			= @LOT_STATUS_Active
		,dblWeight				= 55115.60
		,intWeightUOMId			= @ManualGrains_PoundUOM
		,dblWeightPerQty		= 55.1156
	UNION ALL 
	SELECT 
		intLotId				= @ManualLotGrains_Lot_100002
		,intItemId				= @ManualLotGrains
		,intLocationId			= @Default_Location
		,intItemLocationId		= @ManualLotGrains_DefaultLocation
		,intItemUOMId			= @ManualGrains_25KgBagUOM
		,strLotNumber			= 'MG-LOT-100002'
		,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
		,intStorageLocationId	= @StorageSilo_RM_DL
		,dblQty					= 300 
		,dblLastCost			= 7.50
		,dtmExpiryDate			= '12/11/2018'
		,strLotAlias			= 'Bagged lot item'
		,intLotStatusId			= @LOT_STATUS_Active
		,dblWeight				= NULL 
		,intWeightUOMId			= NULL 
		,dblWeightPerQty		= NULL 

		
	-- TODO: 
	-- The following are the scenarios you can do within Inventory adjustment:
	-- 1. Add stock from zero. This includes both Lot tracked and non-Lot Items. 
	-- 2. Reduce stock from zero. This includes both Lot tracked and non-Lot Items. 
	-- 3. Add stock from an existing stock . This includes both Lot tracked and non-Lot Items. 
	-- 4. Reduce stock from an existing stock. This includes both Lot tracked and non-Lot Items. 
	-- 5. Change status of an existing Lot
	-- 6. Change the expiry date of an existing lot. 
	-- 7. Change the value/cost of an existing stock. 

	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QTY_CHANGE AS INT = 1
			,@ADJUSTMENT_TYPE_UOM_CHANGE AS INT = 2
			,@ADJUSTMENT_TYPE_ITEM_CHANGE AS INT = 3
			,@ADJUSTMENT_TYPE_LOT_STATUS_CHANGE AS INT = 4
			,@ADJUSTMENT_TYPE_LOT_ID_CHANGE AS INT = 5
			,@ADJUSTMENT_TYPE_EXPIRY_DATE_CHANGE AS INT = 6

	DECLARE @intInventoryAdjustmentId AS INT 

	-- ADJ-1
	BEGIN 
		SET @intInventoryAdjustmentId = 1
		INSERT INTO dbo.tblICInventoryAdjustment (
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
		)
		SELECT 	intInventoryAdjustmentId = @intInventoryAdjustmentId
				,intLocationId		= @NewHaven
				,dtmAdjustmentDate  = GETDATE()     
				,intAdjustmentType	= @ADJUSTMENT_TYPE_QTY_CHANGE 
				,strAdjustmentNo    = 'ADJ-1'                              
				,strDescription     = 'Header only record'                                                                          
				,intSort			= 1
				,ysnPosted			= 0
				,intEntityId		= 1
				,intConcurrencyId	= 1
	END 

	-- ADJ-2
	BEGIN 
		SET @intInventoryAdjustmentId = 2
		INSERT INTO dbo.tblICInventoryAdjustment (
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
		)
		SELECT 	intInventoryAdjustmentId = @intInventoryAdjustmentId
				,intLocationId		= @Default_Location
				,dtmAdjustmentDate  = '05/14/2015'
				,intAdjustmentType	= @ADJUSTMENT_TYPE_QTY_CHANGE 
				,strAdjustmentNo    = 'ADJ-2'                              
				,strDescription     = 'With a lot item in the detail. Change Qty from 1,000 to 750.'
				,intSort			= 1
				,ysnPosted			= 0
				,intEntityId		= 1
				,intConcurrencyId	= 1

		INSERT INTO dbo.tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentId
				,intSubLocationId
				,intStorageLocationId
				,intItemId
				,intNewItemId
				,intLotId
				,intNewLotId
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
				,dtmExpiryDate
				,dtmNewExpiryDate
				,intLotStatusId
				,intNewLotStatusId
				,dblCost
				,dblNewCost
				,dblLineTotal
				,intSort
		)
		SELECT 
				intInventoryAdjustmentId	= @intInventoryAdjustmentId
				,intSubLocationId			= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId		= @StorageSilo_RM_DL
				,intItemId					= @ManualLotGrains
				,intNewItemId				= NULL 
				,intLotId					= @ManualLotGrains_Lot_100001
				,intNewLotId				= NULL 
				,strNewLotNumber			= NULL 
				,dblQuantity				= 1000.00
				,dblNewQuantity				= 750.00 -- Bring down qty from 1,000 to 750.00
				,dblAdjustByQuantity		= -250.00
				,intItemUOMId				= @ManualGrains_25KgBagUOM
				,intNewItemUOMId			= NULL 
				,intWeightUOMId				= @ManualGrains_PoundUOM
				,intNewWeightUOMId			= NULL 
				,dblWeight					= 55115.60
				,dblNewWeight				= NULL 
				,dblWeightPerQty			= 55.1156
				,dblNewWeightPerQty			= NULL 
				,dtmExpiryDate				= '01/10/2018'
				,dtmNewExpiryDate			= NULL 
				,intLotStatusId				= 1
				,intNewLotStatusId			= NULL 
				,dblCost					= 2.50
				,dblNewCost					= NULL 
				,dblLineTotal				= 1875.00
				,intSort					= 1

	END

	-- ADJ-3
	BEGIN 
		SET @intInventoryAdjustmentId = 3
		INSERT INTO dbo.tblICInventoryAdjustment (
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
		)
		SELECT 	intInventoryAdjustmentId = @intInventoryAdjustmentId
				,intLocationId		= @Default_Location
				,dtmAdjustmentDate  = '05/14/2015'
				,intAdjustmentType	= @ADJUSTMENT_TYPE_QTY_CHANGE 
				,strAdjustmentNo    = 'ADJ-3'                              
				,strDescription     = 'With a lot item in the detail that is purely in 25 kg bags, no weight UOM.'
				,intSort			= 1
				,ysnPosted			= 0
				,intEntityId		= 1
				,intConcurrencyId	= 1

		INSERT INTO dbo.tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentId
				,intSubLocationId
				,intStorageLocationId
				,intItemId
				,intNewItemId
				,intLotId
				,intNewLotId
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
				,dtmExpiryDate
				,dtmNewExpiryDate
				,intLotStatusId
				,intNewLotStatusId
				,dblCost
				,dblNewCost
				,dblLineTotal
				,intSort
		)
		SELECT 
				intInventoryAdjustmentId	= @intInventoryAdjustmentId
				,intSubLocationId			= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId		= @StorageSilo_RM_DL
				,intItemId					= @ManualLotGrains
				,intNewItemId				= NULL 
				,intLotId					= @ManualLotGrains_Lot_100002
				,intNewLotId				= NULL 
				,strNewLotNumber			= NULL 
				,dblQuantity				= 300.00
				,dblNewQuantity				= 212 -- Bring down qty from 300 to 212
				,dblAdjustByQuantity		= -88
				,intItemUOMId				= @ManualGrains_25KgBagUOM
				,intNewItemUOMId			= NULL 
				,intWeightUOMId				= NULL 
				,intNewWeightUOMId			= NULL 
				,dblWeight					= 0.00
				,dblNewWeight				= NULL 
				,dblWeightPerQty			= 0.00
				,dblNewWeightPerQty			= NULL 
				,dtmExpiryDate				= '12/11/2018'
				,dtmNewExpiryDate			= NULL 
				,intLotStatusId				= 1
				,intNewLotStatusId			= NULL 
				,dblCost					= 7.50
				,dblNewCost					= NULL 
				,dblLineTotal				= 660.00
				,intSort					= 1

	END

	-- ADJ-4
	BEGIN 
		SET @intInventoryAdjustmentId = 4
		INSERT INTO dbo.tblICInventoryAdjustment (
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
		)
		SELECT 	intInventoryAdjustmentId = @intInventoryAdjustmentId
				,intLocationId		= @Default_Location
				,dtmAdjustmentDate  = '05/14/2015'
				,intAdjustmentType	= @ADJUSTMENT_TYPE_LOT_STATUS_CHANGE
				,strAdjustmentNo    = 'ADJ-4'                              
				,strDescription     = 'Change lot status from Active to Quarantine.'
				,intSort			= 1
				,ysnPosted			= 0
				,intEntityId		= 1
				,intConcurrencyId	= 1

		INSERT INTO dbo.tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentId	
				,intSubLocationId			
				,intStorageLocationId		
				,intItemId					
				,intLotId					
				,intLotStatusId				
				,intNewLotStatusId			
		)
		SELECT 
				intInventoryAdjustmentId	= @intInventoryAdjustmentId
				,intSubLocationId			= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId		= @StorageSilo_RM_DL
				,intItemId					= @ManualLotGrains
				,intLotId					= @ManualLotGrains_Lot_100001
				,intLotStatusId				= 1
				,intNewLotStatusId			= @LOT_STATUS_Quarantine 
	END

	-- ADJ-5
	BEGIN 
		SET @intInventoryAdjustmentId = 5
		INSERT INTO dbo.tblICInventoryAdjustment (
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
		)
		SELECT 	intInventoryAdjustmentId = @intInventoryAdjustmentId
				,intLocationId		= @Default_Location
				,dtmAdjustmentDate  = '05/14/2015'
				,intAdjustmentType	= @ADJUSTMENT_TYPE_QTY_CHANGE 
				,strAdjustmentNo    = 'ADJ-5'                              
				,strDescription     = 'Qty Adjustment for Non lot items.'
				,intSort			= 1
				,ysnPosted			= 0
				,intEntityId		= 1
				,intConcurrencyId	= 1

		INSERT INTO dbo.tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentId
				,intSubLocationId
				,intStorageLocationId
				,intItemId
				,intNewItemId
				,intLotId
				,intNewLotId
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
				,dtmExpiryDate
				,dtmNewExpiryDate
				,intLotStatusId
				,intNewLotStatusId
				,dblCost
				,dblNewCost
				,dblLineTotal
				,intSort
		)
		SELECT 
				intInventoryAdjustmentId	= @intInventoryAdjustmentId
				,intSubLocationId			= NULL 
				,intStorageLocationId		= NULL
				,intItemId					= @WetGrains
				,intNewItemId				= NULL 
				,intLotId					= NULL 
				,intNewLotId				= NULL 
				,strNewLotNumber			= NULL 
				,dblQuantity				= 100
				,dblNewQuantity				= 400
				,dblAdjustByQuantity		= 300
				,intItemUOMId				= @WetGrains_PoundUOMId
				,intNewItemUOMId			= NULL 
				,intWeightUOMId				= NULL 
				,intNewWeightUOMId			= NULL 
				,dblWeight					= 0.00
				,dblNewWeight				= NULL 
				,dblWeightPerQty			= 0.00
				,dblNewWeightPerQty			= NULL 
				,dtmExpiryDate				= NULL 
				,dtmNewExpiryDate			= NULL 
				,intLotStatusId				= NULL 
				,intNewLotStatusId			= NULL 
				,dblCost					= 7.50
				,dblNewCost					= NULL 
				,dblLineTotal				= 2250.00
				,intSort					= 1

	END

END 
