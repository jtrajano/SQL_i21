CREATE PROCEDURE [testi21Database].[test uspICAddInventoryTransfer to add a transfers from transport]
AS
BEGIN
	-- Fake data
	BEGIN 
		EXEC testi21Database.[Fake data for inventory transfer table]

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

		-- Declare the variables for sub-locations
		DECLARE @Raw_Materials_SubLocation_DefaultLocation AS INT = 1
				,@FinishedGoods_SubLocation_DefaultLocation AS INT = 2
				,@Raw_Materials_SubLocation_NewHaven AS INT = 3
				,@FinishedGoods_SubLocation_NewHaven AS INT = 4
				,@Raw_Materials_SubLocation_BetterHaven AS INT = 5
				,@FinishedGoods_SubLocation_BetterHaven AS INT = 6

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

		DECLARE -- Transfer Types
				@TRANSFER_TYPE_LocationToLocation AS NVARCHAR(50) = 'Location to Location'
				,@TRANSFER_TYPE_StorageToStorage AS NVARCHAR(50) = 'Storage to Storage'

				-- Source Types
				,@SOURCE_TYPE_None AS INT = 1
				,@SOURCE_TYPE_Scale AS INT = 2
				,@SOURCE_TYPE_InboundShipment AS INT = 3
				,@SOURCE_TYPE_Transports AS INT = 4
	END 

	-- Setup the expected and actual table
	BEGIN 
		CREATE TABLE expected (
			intSourceId INT
			,intInventoryTransferId INT 	
		)

		CREATE TABLE actual	 (
			intSourceId INT
			,intInventoryTransferId INT 	
		)
	END 

	-- Arrange 
	BEGIN 
		DECLARE @TransferEntries AS InventoryTransferStagingTable
				,@intUserId AS INT = 1
	END 
	
	-- Act 	
	BEGIN 
		INSERT INTO @TransferEntries (
			-- Header
			[dtmTransferDate]
			,[strTransferType]
			,[intSourceType]
			,[strDescription]
			,[intFromLocationId]
			,[intToLocationId]
			,[ysnShipmentRequired]
			,[intStatusId]
			,[intShipViaId]
			,[intFreightUOMId]

			-- Detail 
			,[intItemId]
			,[intLotId]
			,[intItemUOMId]
			,[dblQuantityToTransfer]
			,[strNewLotId]
			,[intFromSubLocationId]
			,[intToSubLocationId]
			,[intFromStorageLocationId]
			,[intToStorageLocationId]

			-- Integration Field
			,[intInventoryTransferId]
			,[intSourceId]		
		)
		SELECT 
			-- Header
			[dtmTransferDate]			= '09/08/2009'
			,[strTransferType]			= 'Location to Location'
			,[intSourceType]			= 0
			,[strDescription]			= 'Description goes here'
			,[intFromLocationId]		= @Default_Location
			,[intToLocationId]			= @NewHaven
			,[ysnShipmentRequired]		= 0
			,[intStatusId]				= 1
			,[intShipViaId]				= 1 
			,[intFreightUOMId]			= 1 

			-- Detail 
			,[intItemId]				= @CornCommodity
			,[intLotId]					= NULL 
			,[intItemUOMId]				= @Corn_BushelUOM
			,[dblQuantityToTransfer]	= 10
			,[strNewLotId]				= NULL 
			,[intFromSubLocationId]		= NULL 
			,[intToSubLocationId]		= NULL 
			,[intFromStorageLocationId]	= NULL 
			,[intToStorageLocationId]	= NULL 

			-- Integration Field
			,[intInventoryTransferId]	= NULL 
			,[intSourceId]				= '1000'

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult')) 
		BEGIN 
			CREATE TABLE #tmpAddInventoryTransferResult (
				intSourceId INT
				,intInventoryTransferId INT
			)
		END 

		EXEC dbo.uspICAddInventoryTransfer
			@TransferEntries
			,@intUserId
	END 

	-- Assert
	BEGIN

		DECLARE @strTransferNo AS NVARCHAR(50)
		SELECT	@strTransferNo = tblICInventoryTransfer.strTransferNo
		FROM	dbo.tblICInventoryTransfer INNER JOIN #tmpAddInventoryTransferResult 
					ON tblICInventoryTransfer.intInventoryTransferId = #tmpAddInventoryTransferResult.intInventoryTransferId

		EXEC tSQLt.AssertEquals @strTransferNo, 'INVTRN-1001'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
