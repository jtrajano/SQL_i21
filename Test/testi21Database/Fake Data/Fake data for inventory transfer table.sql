CREATE PROCEDURE [testi21Database].[Fake data for inventory transfer table]
AS
BEGIN
	EXEC [testi21Database].[Fake inventory items];
	EXEC testi21Database.[Fake open fiscal year and accounting periods]
	EXEC [testi21Database].[Fake data for ship via];
		
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransfer', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransferDetail', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	
	
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
	UNION ALL
	SELECT	[intStartingNumberId]	= 41
			,[strTransactionType]	= N'Inventory Transfer'
			,[strPrefix]			= N'INVTRN-'
			,[intNumber]			= 1001
			,[strModule]			= N'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1	

	-- Create mock data for Lot Numbers
	DECLARE @ManualLotGrains_Lot_100001 AS INT = 1
			,@ManualLotGrains_Lot_100002 AS INT = 2
			,@ManualLotGrains_Lot_100003 AS INT = 3

	-- Lot Status
	DECLARE @LOT_STATUS_Active AS INT = 1
			,@LOT_STATUS_On_Hold AS INT = 2
			,@LOT_STATUS_Quarantine AS INT = 3

	SET IDENTITY_INSERT tblICLot ON
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
		,dblWeight				= 55115.50
		,intWeightUOMId			= @ManualGrains_PoundUOM
		,dblWeightPerQty		= 55.115500
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
	UNION ALL 
	SELECT 
		intLotId				= @ManualLotGrains_Lot_100003
		,intItemId				= @ManualLotGrains
		,intLocationId			= @Default_Location
		,intItemLocationId		= @ManualLotGrains_DefaultLocation
		,intItemUOMId			= @ManualGrains_25KgBagUOM
		,strLotNumber			= 'MG-LOT-100003'
		,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
		,intStorageLocationId	= @StorageSilo_RM_DL
		,dblQty					= 600 
		,dblLastCost			= 3.50
		,dtmExpiryDate			= '01/25/2018'
		,strLotAlias			= 'Like MG-LOT-100001 except the expiry date.'
		,intLotStatusId			= @LOT_STATUS_Active
		,dblWeight				= 33069.36
		,intWeightUOMId			= @ManualGrains_PoundUOM
		,dblWeightPerQty		= 55.115500
	SET IDENTITY_INSERT tblICLot OFF

	-- Add cost buckets to the lot records
	INSERT INTO tblICInventoryLot (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,dblStockIn
		,dblStockOut
		,dblCost
	)
	SELECT
		intItemId				= @ManualLotGrains
		,intItemLocationId		= @ManualLotGrains_DefaultLocation
		,intItemUOMId			= @ManualGrains_PoundUOM
		,dtmDate				= '01/01/2014'
		,intLotId				= @ManualLotGrains_Lot_100001
		,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
		,intStorageLocationId	= @StorageSilo_RM_DL
		,dblStockIn				= 1000 * @25KgBagUnitQty
		,dblStockOut			= 0 
		,dblCost				= 2.50 / @25KgBagUnitQty

	DECLARE @Ship_Via_Truck AS NVARCHAR(50) = 'Truck'
			,@Ship_Via_Truck_Id AS INT = 1
			
	DECLARE	-- Inventory transfer transaction types. 
			@INVENTORY_TRANSFER_TYPE AS INT = 12
			,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 13

			-- Transfer types. 
			,@TRANSFER_TYPE_LOCATION_TO_LOCATION AS NVARCHAR(50) = 'Location to Location'
			,@TRANSFER_TYPE_STORAGE_TO_STORAGE AS NVARCHAR(50) = 'Storage to Storage'

			,@STATUS_OPEN AS INT = 1
			,@STATUS_PARTIAL AS INT = 2
			,@STATUS_CLOSED AS INT = 3
			,@STATUS_SHORT_CLOSED AS INT = 4

	DECLARE @intInventoryTransferId AS INT 

	SET IDENTITY_INSERT tblICInventoryTransfer ON 

	-- INVTRN-1
	BEGIN 
		SET @intInventoryTransferId = 1
		INSERT INTO dbo.tblICInventoryTransfer (
				intInventoryTransferId
				,strTransferNo
				,dtmTransferDate
				,strTransferType
				,intTransferredById
				,strDescription
				,intFromLocationId
				,intToLocationId
				,ysnShipmentRequired
				,intStatusId
				,intShipViaId
				,intFreightUOMId
				,ysnPosted
				,intCreatedUserId
				,intEntityId
				,intSort
				,intConcurrencyId
		)
		SELECT 	intInventoryTransferId	= @intInventoryTransferId
				,strTransferNo			= 'INVTRN-1'
				,dtmTransferDate		= dbo.fnRemoveTimeOnDate(GETDATE()) 
				,strTransferType		= @TRANSFER_TYPE_LOCATION_TO_LOCATION
				,intTransferredById		= 10
				,strDescription			= 'Transfer with no details'
				,intFromLocationId		= @Default_Location
				,intToLocationId		= @NewHaven
				,ysnShipmentRequired	= 0
				,intStatusId			= @STATUS_OPEN
				,intShipViaId			= @Ship_Via_Truck_Id
				,intFreightUOMId		= NULL 
				,ysnPosted				= 0
				,intCreatedUserId		= 1
				,intEntityId			= 10
				,intSort				= 1
				,intConcurrencyId		= 1
	END 

	-- INVTRN-2
	BEGIN 
		SET @intInventoryTransferId = 2
		INSERT INTO dbo.tblICInventoryTransfer (
				intInventoryTransferId
				,strTransferNo
				,dtmTransferDate
				,strTransferType
				,intTransferredById
				,strDescription
				,intFromLocationId
				,intToLocationId
				,ysnShipmentRequired
				,intStatusId
				,intShipViaId
				,intFreightUOMId
				,ysnPosted
				,intCreatedUserId
				,intEntityId
				,intSort
				,intConcurrencyId
		)
		SELECT 	intInventoryTransferId	= @intInventoryTransferId
				,strTransferNo			= 'INVTRN-2'
				,dtmTransferDate		= dbo.fnRemoveTimeOnDate(GETDATE()) 
				,strTransferType		= @TRANSFER_TYPE_LOCATION_TO_LOCATION
				,intTransferredById		= 10
				,strDescription			= 'Transfer with NO shipment required.'
				,intFromLocationId		= @Default_Location
				,intToLocationId		= @NewHaven
				,ysnShipmentRequired	= 0
				,intStatusId			= @STATUS_OPEN
				,intShipViaId			= @Ship_Via_Truck_Id
				,intFreightUOMId		= NULL 
				,ysnPosted				= 0
				,intCreatedUserId		= 1
				,intEntityId			= 10
				,intSort				= 1
				,intConcurrencyId		= 1

		INSERT INTO dbo.tblICInventoryTransferDetail (
				intInventoryTransferId
				,intItemId
				,intLotId
				,intFromSubLocationId
				,intToSubLocationId
				,intFromStorageLocationId
				,intToStorageLocationId
				,dblQuantity
				,intItemUOMId
				,intItemWeightUOMId
				,dblGrossWeight
				,dblTareWeight
				,intNewLotId
				,strNewLotId
				,dblCost
				,intTaxCodeId
				,dblFreightRate
				,dblFreightAmount
				,intSort
				,intConcurrencyId		
		)
		SELECT 
				intInventoryTransferId		= @intInventoryTransferId
				,intItemId					= @ManualLotGrains
				,intLotId					= @ManualLotGrains_Lot_100001
				,intFromSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
				,intToSubLocationId			= NULL 
				,intFromStorageLocationId	= @StorageSilo_RM_DL
				,intToStorageLocationId		= NULL 
				,dblQuantity				= 100
				,intItemUOMId				= @ManualGrains_25KgBagUOM
				,intItemWeightUOMId			= NULL 
				,dblGrossWeight				= NULL
				,dblTareWeight				= NULL
				,intNewLotId				= NULL
				,strNewLotId				= NULL
				,dblCost					= NULL
				,intTaxCodeId				= NULL
				,dblFreightRate				= NULL
				,dblFreightAmount			= NULL
				,intSort					= NULL
				,intConcurrencyId			= NULL
	END 

	-- INVTRN-3
	BEGIN 
		SET @intInventoryTransferId = 3
		INSERT INTO dbo.tblICInventoryTransfer (
				intInventoryTransferId
				,strTransferNo
				,dtmTransferDate
				,strTransferType
				,intTransferredById
				,strDescription
				,intFromLocationId
				,intToLocationId
				,ysnShipmentRequired
				,intStatusId
				,intShipViaId
				,intFreightUOMId
				,ysnPosted
				,intCreatedUserId
				,intEntityId
				,intSort
				,intConcurrencyId
		)
		SELECT 	intInventoryTransferId	= @intInventoryTransferId
				,strTransferNo			= 'INVTRN-3'
				,dtmTransferDate		= dbo.fnRemoveTimeOnDate(GETDATE()) 
				,strTransferType		= @TRANSFER_TYPE_LOCATION_TO_LOCATION
				,intTransferredById		= 10
				,strDescription			= 'Transfer with shipment required.'
				,intFromLocationId		= @Default_Location
				,intToLocationId		= @NewHaven
				,ysnShipmentRequired	= 1
				,intStatusId			= @STATUS_OPEN
				,intShipViaId			= @Ship_Via_Truck_Id
				,intFreightUOMId		= NULL 
				,ysnPosted				= 0
				,intCreatedUserId		= 1
				,intEntityId			= 10
				,intSort				= 1
				,intConcurrencyId		= 1

		INSERT INTO dbo.tblICInventoryTransferDetail (
				intInventoryTransferId
				,intItemId
				,intLotId
				,intFromSubLocationId
				,intToSubLocationId
				,intFromStorageLocationId
				,intToStorageLocationId
				,dblQuantity
				,intItemUOMId
				,intItemWeightUOMId
				,dblGrossWeight
				,dblTareWeight
				,intNewLotId
				,strNewLotId
				,dblCost
				,intTaxCodeId
				,dblFreightRate
				,dblFreightAmount
				,intSort
				,intConcurrencyId		
		)
		SELECT 
				intInventoryTransferId		= @intInventoryTransferId
				,intItemId					= @ManualLotGrains
				,intLotId					= @ManualLotGrains_Lot_100001
				,intFromSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
				,intToSubLocationId			= NULL 
				,intFromStorageLocationId	= @StorageSilo_RM_DL
				,intToStorageLocationId		= NULL 
				,dblQuantity				= 75
				,intItemUOMId				= @ManualGrains_25KgBagUOM
				,intItemWeightUOMId			= NULL 
				,dblGrossWeight				= NULL
				,dblTareWeight				= NULL
				,intNewLotId				= NULL
				,strNewLotId				= NULL
				,dblCost					= NULL
				,intTaxCodeId				= NULL
				,dblFreightRate				= NULL
				,dblFreightAmount			= NULL
				,intSort					= NULL
				,intConcurrencyId			= NULL
	END 

	SET IDENTITY_INSERT tblICInventoryTransfer OFF
END