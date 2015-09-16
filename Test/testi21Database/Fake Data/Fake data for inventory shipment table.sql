CREATE PROCEDURE [testi21Database].[Fake data for inventory shipment table]
AS
-- Fake data
BEGIN 

	EXEC [testi21Database].[Fake inventory items];
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;	

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
	DECLARE @AccountCategoryId_Inventory AS INT -- = 27

	SELECT @AccountCategoryId_Inventory = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_Inventory

	DECLARE @AccountCategoryName_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
	DECLARE @AccountCategoryId_CostOfGoods AS INT -- = 10

	SELECT @AccountCategoryId_CostOfGoods = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_CostOfGoods

	DECLARE @AccountCategoryName_APClearing AS NVARCHAR(100) = 'AP Clearing'
	DECLARE @AccountCategoryId_APClearing AS INT --= 45

	SELECT @AccountCategoryId_APClearing = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_APClearing
	
	DECLARE @AccountCategoryName_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
	DECLARE @AccountCategoryId_WriteOffSold AS INT -- = 42

	SELECT @AccountCategoryId_WriteOffSold = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_WriteOffSold

	DECLARE @AccountCategoryName_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
	DECLARE @AccountCategoryId_RevalueSold AS INT -- = 43

	SELECT @AccountCategoryId_RevalueSold = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_RevalueSold

	DECLARE @AccountCategoryName_AutoNegative AS NVARCHAR(100) = 'Auto Negative'
	DECLARE @AccountCategoryId_AutoNegative AS INT -- = 44

	SELECT @AccountCategoryId_AutoNegative = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_AutoNegative

	DECLARE @AccountCategoryName_InventoryInTransit AS NVARCHAR(100) = 'Inventory In Transit'
	DECLARE @AccountCategoryId_InventoryInTransit AS INT -- = 46

	SELECT @AccountCategoryId_InventoryInTransit = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_InventoryInTransit

	DECLARE @AccountCategoryName_InventoryAdjustment AS NVARCHAR(100) = 'Inventory Adjustment'
	DECLARE @AccountCategoryId_InventoryAdjustment AS INT -- = 50

	SELECT @AccountCategoryId_InventoryAdjustment = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_InventoryAdjustment

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
	-- Declare the constants 
	DECLARE	-- Order Types
			@STR_ORDER_TYPE_SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
			,@STR_ORDER_TYPE_SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
			,@STR_ORDER_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
			,@INT_ORDER_TYPE_SALES_CONTRACT AS INT = 1
			,@INT_ORDER_TYPE_SALES_ORDER AS INT = 2
			,@INT_ORDER_TYPE_TRANSFER_ORDER AS INT = 3

			-- Source Types
			,@STR_SOURCE_TYPE_NONE AS NVARCHAR(50) = 'None'
			,@STR_SOURCE_TYPE_SCALE AS NVARCHAR(50) = 'Scale'
			,@STR_SOURCE_TYPE_INBOUND_SHIPMENT AS NVARCHAR(50) = 'Inbound Shipment'
			,@STR_SOURCE_TYPE_TRANSPORT AS NVARCHAR(50) = 'Transport'

			,@INT_SOURCE_TYPE_NONE AS INT = 0
			,@INT_SOURCE_TYPE_SCALE AS INT = 1
			,@INT_SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
			,@INT_SOURCE_TYPE_TRANSPORT AS INT = 2

			-- Ownership Types
			,@OWNERSHIP_TYPE_OWN AS INT = 1
			,@OWNERSHIP_TYPE_STORAGE AS INT = 2
			,@OWNERSHIP_TYPE_CONSIGNED_PURCHASE AS INT = 3
			,@OWNERSHIP_TYPE_CONSIGNED_SALE AS INT = 4			

	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItemLot', @Identity = 1;	

	EXEC tSQLt.ApplyConstraint 'dbo.tblICLot', 'UN_tblICLot';		

	-- Declare the variables for the transaction 
	DECLARE @strShipmentNumber AS NVARCHAR(40);
	DECLARE @intShipmentNumber AS INT;
	DECLARE @BaseCurrencyId AS INT = 1;
	DECLARE @dblExchangeRate AS NUMERIC(18,6) = 1;
	DECLARE @dtmDate AS DATETIME;
	DECLARE @InventoryReceiptTypeId AS INT = 4;
	DECLARE @intEntityId AS INT = 1;
	DECLARE @intUserId AS INT = 1;


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
		
	--------------------------------------------------------
	-- Add INVSHIP-XXXXX1
	-- It has one item in it. 
	--------------------------------------------------------
	BEGIN
		SET @strShipmentNumber = 'INVSHIP-XXXXX1'
		SET @dtmDate = '01/10/2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryShipment (
			strShipmentNumber
			,dtmShipDate
			,intOrderType
			,intSourceType
			,strReferenceNumber
			,dtmRequestedArrivalDate
			,intShipFromLocationId
			,intEntityCustomerId
			,intShipToLocationId
			,intFreightTermId
			,strBOLNumber
			,intShipViaId
			,strVessel
			,strProNumber
			,strDriverId
			,strSealNumber
			,strDeliveryInstruction
			,dtmAppointmentTime
			,dtmDepartureTime
			,dtmArrivalTime
			,dtmDeliveredDate
			,dtmFreeTime
			,strReceivedBy
			,strComment
			,ysnPosted
			,intEntityId
			,intCreatedUserId
			,intConcurrencyId
		)
		SELECT 
			strShipmentNumber			= @strShipmentNumber
			,dtmShipDate				= dbo.fnRemoveTimeOnDate(@dtmDate)
			,intOrderType				= @INT_ORDER_TYPE_SALES_ORDER
			,intSourceType				= @INT_SOURCE_TYPE_NONE
			,strReferenceNumber			= ''
			,dtmRequestedArrivalDate	= NULL 
			,intShipFromLocationId		= @Default_Location
			,intEntityCustomerId		= NULL 
			,intShipToLocationId		= @Default_Location
			,intFreightTermId			= NULL 
			,strBOLNumber				= NULL 
			,intShipViaId				= NULL 
			,strVessel					= NULL 
			,strProNumber				= NULL 
			,strDriverId				= NULL 
			,strSealNumber				= NULL 
			,strDeliveryInstruction		= NULL 
			,dtmAppointmentTime			= NULL 
			,dtmDepartureTime			= NULL 
			,dtmArrivalTime				= NULL 
			,dtmDeliveredDate			= NULL 
			,dtmFreeTime				= NULL 
			,strReceivedBy				= NULL 
			,strComment					= NULL 
			,ysnPosted					= 0 
			,intEntityId				= 1
			,intCreatedUserId			= 1
			,intConcurrencyId			= 1

		SET @intShipmentNumber = SCOPE_IDENTITY();

		INSERT INTO dbo.tblICInventoryShipmentItem (
				intInventoryShipmentId
				,intOrderId
				,intSourceId
				,intLineNo
				,intItemId
				,intSubLocationId
				,intOwnershipType
				,dblQuantity
				,intItemUOMId
				,intWeightUOMId
				,dblUnitPrice
				,intTaxCodeId
				,intDockDoorId
				,strNotes
				,intSort
				,intConcurrencyId
		)
		SELECT  intInventoryShipmentId	= @intShipmentNumber
				,intOrderId				= NULL 
				,intSourceId			= NULL 
				,intLineNo				= 1
				,intItemId				= @WetGrains
				,intSubLocationId		= @Raw_Materials_SubLocation_DefaultLocation
				,intOwnershipType		= @OWNERSHIP_TYPE_OWN
				,dblQuantity			= 1.00
				,intItemUOMId			= @WetGrains_PoundUOM
				,intWeightUOMId			= NULL 
				,dblUnitPrice			= 13.02
				,intTaxCodeId			= NULL 
				,intDockDoorId			= NULL 
				,strNotes				= NULL
				,intSort				= 1
				,intConcurrencyId		= 1	
	END

END