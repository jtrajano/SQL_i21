CREATE PROCEDURE [testi21Database].[Fake data for cost adjustment]
	@intCostingMethod AS INT = NULL 
AS
BEGIN
	-- Variables from [Fake inventory items]
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

		DECLARE @Lot_0001 AS INT = 1
				,@Lot_0002 AS INT = 2
				,@Lot_0003 AS INT = 3
				,@Lot_0004 AS INT = 4
				,@Lot_0005 AS INT = 5
				,@Lot_0006 AS INT = 6
				,@Lot_0007 AS INT = 7

		DECLARE @LotNumber_0001 AS NVARCHAR(50) = 'LOT-0001'
				,@LotNumber_0002 AS NVARCHAR(50) = 'LOT-0002'
				,@LotNumber_0003 AS NVARCHAR(50) = 'LOT-0003'
				,@LotNumber_0004 AS NVARCHAR(50) = 'LOT-0004'
				,@LotNumber_0005 AS NVARCHAR(50) = 'LOT-0005'
				,@LotNumber_0006 AS NVARCHAR(50) = 'LOT-0006'
				,@LotNumber_0007 AS NVARCHAR(50) = 'LOT-0007'
	END 
	
	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@LOTCOST AS INT = 4 	
			,@ACTUALCOST AS INT = 5	

	EXEC [testi21Database].[Fake COA used for fake inventory items];
	EXEC [testi21Database].[Fake open fiscal year and accounting periods]; 

	IF @intCostingMethod = @LIFO
	BEGIN 
		EXEC [testi21Database].[Fake transactions for LIFO costing]; 
	END 
	ELSE IF @intCostingMethod = @LOTCOST
	BEGIN 
		EXEC [testi21Database].[Fake transactions for Lot costing]
	END
	ELSE IF @intCostingMethod = @ACTUALCOST
	BEGIN 
		EXEC [testi21Database].[Fake transactions for Actual costing]
	END 
	ELSE 
	BEGIN 
		EXEC [testi21Database].[Fake transactions for FIFO or Ave costing]; 
	END 
	
	-- IMPORTANT NOTE: Below will add the Inventory Receipt transactions in relation to the fake data in [Fake transactions for FIFO or Ave costing]
		
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemTax', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemLot', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptCharge', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptChargePerItem', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemAllocatedCharge', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblAPBill', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblAPBillDetail', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransfer', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransferDetail', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;			
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItemLot', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentCharge', @Identity = 1;	

		
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
			,[intNumber]			= 100001
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
	UNION ALL
	SELECT	[intStartingNumberId]	= 23
			,[strTransactionType]	= N'Inventory Receipt'
			,[strPrefix]			= N'INVRCT-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1

	DECLARE -- Receipt Types
			@RECEIPT_TYPE_PurchaseContract AS NVARCHAR(50) = 'Purchase Contract'
			,@RECEIPT_TYPE_PurchaseOrder AS NVARCHAR(50) = 'Purchase Order'
			,@RECEIPT_TYPE_TransferOrder AS NVARCHAR(50) = 'Transfer Order'
			,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'

			-- Source Types
			,@SOURCE_TYPE_None AS INT = 1
			,@SOURCE_TYPE_Scale AS INT = 2
			,@SOURCE_TYPE_InboundShipment AS INT = 3

			-- Ownership Types
			,@OWNERSHIP_TYPE_Own AS INT = 1
			,@OWNERSHIP_TYPE_Storage AS INT = 2
			,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
			,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4
	
	-- Declare the variables for Inventory Receipt Transactions 
	DECLARE @strReceiptNumber AS NVARCHAR(40)
			,@intReceiptNumber AS INT
			,@intEntityVendorId_ReceiptVendor AS INT = 1
			,@intEntityVendorId_ThirdPartyVendor AS INT = 2				
	
			,@BaseCurrencyId AS INT = 1
			,@dblExchangeRate AS NUMERIC(18,6) = 1
			,@dtmDate AS DATETIME
			,@InventoryReceiptTypeId AS INT = 4

			,@intEntityId AS INT = 1
			,@intUserId AS INT = 1
			,@intContractId AS INT
			
	--------------------------------------------------------
	-- Add a posted PURCHASE-100000
	-- @WetGrains
	-- 100 Bushels
	-- $22.00 per Bushel
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'PURCHASE-100000'
		SET @dtmDate = 'January 1, 2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intSourceType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				--,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @RECEIPT_TYPE_PurchaseOrder
				,intSourceType			= @SOURCE_TYPE_None
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				--,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 1
		SET @intReceiptNumber = SCOPE_IDENTITY();

		INSERT INTO dbo.tblICInventoryReceiptItem (
			intInventoryReceiptId
			,intLineNo
			,intSourceId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblReceived
			,intUnitMeasureId
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
			,intOwnershipType
		)
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= NULL 
				,intItemId				= @WetGrains
				,dblOrderQty			= 100
				,dblOpenReceive			= 100
				,dblReceived			= 0
				,intUnitMeasureId		= @WetGrains_BushelUOM
				,dblUnitCost			= 22.00
				,dblLineTotal			= 100 * 22.00
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType		= @OWNERSHIP_TYPE_Own

		IF @intCostingMethod = @LOTCOST
		BEGIN
			INSERT INTO dbo.tblICInventoryReceiptItemLot (
				[intInventoryReceiptItemId]
				,[intLotId]
				,[strLotNumber]
				,[strLotAlias]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intItemUnitMeasureId]
				,[dblQuantity]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[dblCost]
				,[intUnitPallet]
				,[dblStatedGrossPerUnit]
				,[dblStatedTarePerUnit]
				,[strContainerNo]
				,[intEntityVendorId]
				,[strMarkings]
				,[intOriginId]
				,[intGradeId]
				,[intSeasonCropYear]
				,[strVendorLotId]
				,[dtmManufacturedDate]
				,[strRemarks]
				,[strCondition]
				,[dtmCertified]
				,[dtmExpiryDate]
				,[intSort]
				,[intConcurrencyId]
			)
			SELECT	
				[intInventoryReceiptItemId]	= 1
				,[intLotId]					= @Lot_0001
				,[strLotNumber]				= @LotNumber_0001
				,[strLotAlias]				= 'LOT ALIAS FOR 0001'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @WetGrains_DefaultLocation 
				,[dblQuantity]				= 30 
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 22.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0001' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0001' 
				,[strCondition]				= 'Condition for 0001'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
			UNION ALL
			SELECT	
				[intInventoryReceiptItemId]	= 1
				,[intLotId]					= @Lot_0002
				,[strLotNumber]				= @LotNumber_0002
				,[strLotAlias]				= 'LOT ALIAS FOR 0002'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @WetGrains_DefaultLocation 
				,[dblQuantity]				= 30 
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 22.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0002' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0002' 
				,[strCondition]				= 'Condition for 0002'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
			UNION ALL
			SELECT	
				[intInventoryReceiptItemId]	= 1
				,[intLotId]					= @Lot_0003
				,[strLotNumber]				= @LotNumber_0003
				,[strLotAlias]				= 'LOT ALIAS FOR 0003'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @WetGrains_DefaultLocation 
				,[dblQuantity]				= 40 
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 22.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0003' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0003' 
				,[strCondition]				= 'Condition for 0003'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
		END 
	END				

	--------------------------------------------------------
	-- Add a posted PURCHASE-200000
	-- @StickyGrains
	-- 150 Bushels
	-- $33.00 per Bushel
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'PURCHASE-200000'
		SET @dtmDate = 'January 1, 2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intSourceType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				--,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @RECEIPT_TYPE_PurchaseOrder
				,intSourceType			= @SOURCE_TYPE_None
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				--,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 1
		SET @intReceiptNumber = SCOPE_IDENTITY();

		INSERT INTO dbo.tblICInventoryReceiptItem (
			intInventoryReceiptId
			,intLineNo
			,intSourceId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblReceived
			,intUnitMeasureId
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
			,intOwnershipType
		)
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= NULL 
				,intItemId				= @StickyGrains
				,dblOrderQty			= 150
				,dblOpenReceive			= 150
				,dblReceived			= 0
				,intUnitMeasureId		= @StickyGrains_BushelUOM
				,dblUnitCost			= 33.00
				,dblLineTotal			= 150 * 33.00
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType		= @OWNERSHIP_TYPE_Own

		IF @intCostingMethod = @LOTCOST
		BEGIN
			INSERT INTO dbo.tblICInventoryReceiptItemLot (
				[intInventoryReceiptItemId]
				,[intLotId]
				,[strLotNumber]
				,[strLotAlias]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intItemUnitMeasureId]
				,[dblQuantity]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[dblCost]
				,[intUnitPallet]
				,[dblStatedGrossPerUnit]
				,[dblStatedTarePerUnit]
				,[strContainerNo]
				,[intEntityVendorId]
				,[strMarkings]
				,[intOriginId]
				,[intGradeId]
				,[intSeasonCropYear]
				,[strVendorLotId]
				,[dtmManufacturedDate]
				,[strRemarks]
				,[strCondition]
				,[dtmCertified]
				,[dtmExpiryDate]
				,[intSort]
				,[intConcurrencyId]
			)
			SELECT	
				[intInventoryReceiptItemId]	= 2
				,[intLotId]					= @Lot_0004
				,[strLotNumber]				= @LotNumber_0004
				,[strLotAlias]				= 'LOT ALIAS FOR 0004'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @StickyGrains_DefaultLocation 
				,[dblQuantity]				= 150
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 33.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0004' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0004' 
				,[strCondition]				= 'Condition for 0004'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
		END 
	END

	--------------------------------------------------------
	-- Add a posted PURCHASE-300000
	-- @PremiumGrains
	-- 200 Bushels
	-- $44.00 per Bushel
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'PURCHASE-300000'
		SET @dtmDate = 'January 1, 2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intSourceType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				--,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @RECEIPT_TYPE_PurchaseOrder
				,intSourceType			= @SOURCE_TYPE_None
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				--,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 1
		SET @intReceiptNumber = SCOPE_IDENTITY();

		INSERT INTO dbo.tblICInventoryReceiptItem (
			intInventoryReceiptId
			,intLineNo
			,intSourceId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblReceived
			,intUnitMeasureId
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
			,intOwnershipType
		)
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= NULL 
				,intItemId				= @PremiumGrains
				,dblOrderQty			= 200
				,dblOpenReceive			= 200
				,dblReceived			= 0
				,intUnitMeasureId		= @PremiumGrains_BushelUOM
				,dblUnitCost			= 44.00
				,dblLineTotal			= 200 * 44.00
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType		= @OWNERSHIP_TYPE_Own

		IF @intCostingMethod = @LOTCOST
		BEGIN
			INSERT INTO dbo.tblICInventoryReceiptItemLot (
				[intInventoryReceiptItemId]
				,[intLotId]
				,[strLotNumber]
				,[strLotAlias]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intItemUnitMeasureId]
				,[dblQuantity]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[dblCost]
				,[intUnitPallet]
				,[dblStatedGrossPerUnit]
				,[dblStatedTarePerUnit]
				,[strContainerNo]
				,[intEntityVendorId]
				,[strMarkings]
				,[intOriginId]
				,[intGradeId]
				,[intSeasonCropYear]
				,[strVendorLotId]
				,[dtmManufacturedDate]
				,[strRemarks]
				,[strCondition]
				,[dtmCertified]
				,[dtmExpiryDate]
				,[intSort]
				,[intConcurrencyId]
			)
			SELECT	
				[intInventoryReceiptItemId]	= 3
				,[intLotId]					= @Lot_0005
				,[strLotNumber]				= @LotNumber_0005
				,[strLotAlias]				= 'LOT ALIAS FOR 0005'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @PremiumGrains_DefaultLocation 
				,[dblQuantity]				= 200
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 44.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0005' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0005' 
				,[strCondition]				= 'Condition for 0005'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
		END 
	END

	--------------------------------------------------------
	-- Add a posted PURCHASE-400000
	-- @ColdGrains
	-- 250 Bushels
	-- $55.00 per Bushel
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'PURCHASE-400000'
		SET @dtmDate = 'January 1, 2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intSourceType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				--,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @RECEIPT_TYPE_PurchaseOrder
				,intSourceType			= @SOURCE_TYPE_None
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				--,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 1
		SET @intReceiptNumber = SCOPE_IDENTITY();

		INSERT INTO dbo.tblICInventoryReceiptItem (
			intInventoryReceiptId
			,intLineNo
			,intSourceId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblReceived
			,intUnitMeasureId
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
			,intOwnershipType
		)
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= NULL 
				,intItemId				= @ColdGrains
				,dblOrderQty			= 250
				,dblOpenReceive			= 250
				,dblReceived			= 0
				,intUnitMeasureId		= @ColdGrains_BushelUOM
				,dblUnitCost			= 55.00
				,dblLineTotal			= 250 * 55.00
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType		= @OWNERSHIP_TYPE_Own

		IF @intCostingMethod = @LOTCOST
		BEGIN
			INSERT INTO dbo.tblICInventoryReceiptItemLot (
				[intInventoryReceiptItemId]
				,[intLotId]
				,[strLotNumber]
				,[strLotAlias]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intItemUnitMeasureId]
				,[dblQuantity]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[dblCost]
				,[intUnitPallet]
				,[dblStatedGrossPerUnit]
				,[dblStatedTarePerUnit]
				,[strContainerNo]
				,[intEntityVendorId]
				,[strMarkings]
				,[intOriginId]
				,[intGradeId]
				,[intSeasonCropYear]
				,[strVendorLotId]
				,[dtmManufacturedDate]
				,[strRemarks]
				,[strCondition]
				,[dtmCertified]
				,[dtmExpiryDate]
				,[intSort]
				,[intConcurrencyId]
			)
			SELECT	
				[intInventoryReceiptItemId]	= 4
				,[intLotId]					= @Lot_0006
				,[strLotNumber]				= @LotNumber_0006
				,[strLotAlias]				= 'LOT ALIAS FOR 0006'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @ColdGrains_DefaultLocation 
				,[dblQuantity]				= 250
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 55.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0006' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0006' 
				,[strCondition]				= 'Condition for 0006'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
		END
	END

	--------------------------------------------------------
	-- Add a posted PURCHASE-500000
	-- @HotGrains
	-- 300 Bushels
	-- $66.00 per Bushel
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'PURCHASE-500000'
		SET @dtmDate = 'January 1, 2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intSourceType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				--,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @RECEIPT_TYPE_PurchaseOrder
				,intSourceType			= @SOURCE_TYPE_None
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				--,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 1
		SET @intReceiptNumber = SCOPE_IDENTITY();

		INSERT INTO dbo.tblICInventoryReceiptItem (
			intInventoryReceiptId
			,intLineNo
			,intSourceId
			,intItemId
			,dblOrderQty
			,dblOpenReceive
			,dblReceived
			,intUnitMeasureId
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
			,intOwnershipType
		)
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= NULL 
				,intItemId				= @HotGrains
				,dblOrderQty			= 300
				,dblOpenReceive			= 300
				,dblReceived			= 0
				,intUnitMeasureId		= @HotGrains_BushelUOM
				,dblUnitCost			= 66.00
				,dblLineTotal			= 300 * 66.00
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType		= @OWNERSHIP_TYPE_Own

		IF @intCostingMethod = @LOTCOST
		BEGIN
			INSERT INTO dbo.tblICInventoryReceiptItemLot (
				[intInventoryReceiptItemId]
				,[intLotId]
				,[strLotNumber]
				,[strLotAlias]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intItemUnitMeasureId]
				,[dblQuantity]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[dblCost]
				,[intUnitPallet]
				,[dblStatedGrossPerUnit]
				,[dblStatedTarePerUnit]
				,[strContainerNo]
				,[intEntityVendorId]
				,[strMarkings]
				,[intOriginId]
				,[intGradeId]
				,[intSeasonCropYear]
				,[strVendorLotId]
				,[dtmManufacturedDate]
				,[strRemarks]
				,[strCondition]
				,[dtmCertified]
				,[dtmExpiryDate]
				,[intSort]
				,[intConcurrencyId]
			)
			SELECT	
				[intInventoryReceiptItemId]	= 5
				,[intLotId]					= @Lot_0007
				,[strLotNumber]				= @LotNumber_0007
				,[strLotAlias]				= 'LOT ALIAS FOR 0007'
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[intItemUnitMeasureId]		= @HotGrains_DefaultLocation 
				,[dblQuantity]				= 300
				,[dblGrossWeight]			= 0 
				,[dblTareWeight]			= 0
				,[dblCost]					= 66.00 
				,[intUnitPallet]			= NULL 
				,[dblStatedGrossPerUnit]	= NULL 
				,[dblStatedTarePerUnit]		= NULL 
				,[strContainerNo]			= NULL 
				,[intEntityVendorId]		= NULL 
				,[strMarkings]				= 'Markings for 0007' 
				,[intOriginId]				= NULL 
				,[intGradeId]				= NULL 
				,[intSeasonCropYear]		= NULL 
				,[strVendorLotId]			= NULL 
				,[dtmManufacturedDate]		= GETDATE() 
				,[strRemarks]				= 'Remarks for 0007' 
				,[strCondition]				= 'Condition for 0007'
				,[dtmCertified]				= GETDATE()
				,[dtmExpiryDate]			= GETDATE()
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
		END
	END	
END 