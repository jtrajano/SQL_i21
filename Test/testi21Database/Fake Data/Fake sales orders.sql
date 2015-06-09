CREATE PROCEDURE [testi21Database].[Fake sales orders]
AS
BEGIN	
	EXEC testi21Database.[Fake inventory items];
	EXEC testi21Database.[Fake data for customers];
	EXEC [testi21Database].[Fake data for ship via];
	
	-- Fake Inventory Items variables
	BEGIN 
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7
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

		-- Declare the account ids
		DECLARE @Inventory_Default AS INT = 1000
		DECLARE @CostOfGoods_Default AS INT = 2000
		DECLARE @APClearing_Default AS INT = 3000
		DECLARE @WriteOffSold_Default AS INT = 4000
		DECLARE @RevalueSold_Default AS INT = 5000 
		DECLARE @AutoNegative_Default AS INT = 6000
		DECLARE @InventoryInTransit_Default AS INT = 7000
		DECLARE @AccountReceivable_Default AS INT = 8000

		DECLARE @Inventory_NewHaven AS INT = 1001
		DECLARE @CostOfGoods_NewHaven AS INT = 2001
		DECLARE @APClearing_NewHaven AS INT = 3001
		DECLARE @WriteOffSold_NewHaven AS INT = 4001
		DECLARE @RevalueSold_NewHaven AS INT = 5001
		DECLARE @AutoNegative_NewHaven AS INT = 6001
		DECLARE @InventoryInTransit_NewHaven AS INT = 7001
		DECLARE @AccountReceivable_NewHaven AS INT = 8001

		DECLARE @Inventory_BetterHaven AS INT = 1002
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @APClearing_BetterHaven AS INT = 3002
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
		DECLARE @RevalueSold_BetterHaven AS INT = 5002
		DECLARE @AutoNegative_BetterHaven AS INT = 6002
		DECLARE @InventoryInTransit_BetterHaven AS INT = 7002
		DECLARE @AccountReceivable_BetterHaven AS INT = 8002

		DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
		DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
		DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102

		-- Declare Account Categories
		DECLARE @AccountCategoryName_Inventory AS NVARCHAR(100) = 'Inventory'
		DECLARE @AccountCategoryId_Inventory AS INT = 27

		DECLARE @AccountCategoryName_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
		DECLARE @AccountCategoryId_CostOfGoods AS INT = 10

		DECLARE @AccountCategoryName_APClearing AS NVARCHAR(100) = 'AP Clearing'
		DECLARE @AccountCategoryId_APClearing AS INT = 45
	
		DECLARE @AccountCategoryName_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
		DECLARE @AccountCategoryId_WriteOffSold AS INT = 42

		DECLARE @AccountCategoryName_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
		DECLARE @AccountCategoryId_RevalueSold AS INT = 43

		DECLARE @AccountCategoryName_AutoNegative AS NVARCHAR(100) = 'Auto Negative'
		DECLARE @AccountCategoryId_AutoNegative AS INT = 44

		DECLARE @AccountCategoryName_InventoryInTransit AS NVARCHAR(100) = 'Inventory In Transit'
		DECLARE @AccountCategoryId_InventoryInTransit AS INT = 46

		-- Declare the item categories
		DECLARE @HotItems AS INT = 1
		DECLARE @ColdItems AS INT = 2

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
	END 

	-- Fake customer variables 
	BEGIN 
		DECLARE @Customer_Paul_Unlimited AS NVARCHAR(50) = 'Paul Unlimited'
		DECLARE @Customer_Paul_Unlimited_Id AS INT = 1
	END

	-- Fake Ship Via variables
	BEGIN 
		DECLARE @Ship_Via_Truck AS NVARCHAR(50) = 'Truck'
				,@Ship_Via_Truck_Id AS INT = 1
	END 
	
	-- Create the fake tables for Inventory Shipment. 
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;

	-- Set all items as stock-keeping
	UPDATE dbo.tblICItem
	SET strType = 'Inventory' 

	-- Modify the starting number table to perform the test. 
	UPDATE dbo.tblSMStartingNumber 
	SET		strPrefix = 'INVSHIP-'
			,intNumber = 1
	WHERE	strTransactionType = 'Inventory Shipment'

	-- Creata fake data for security user
	EXEC tSQLt.FakeTable 'dbo.tblSMUserSecurity';
	DECLARE @intUserId AS INT = 39989
	DECLARE @intEntityId AS INT = 19945

	INSERT INTO dbo.tblSMUserSecurity (
		intUserSecurityID
		,intEntityId 
	)
	VALUES (@intUserId, @intEntityId);

	EXEC tSQLt.FakeTable 'dbo.tblSOSalesOrder';
	EXEC tSQLt.FakeTable 'dbo.tblSOSalesOrderDetail', @Identity = 1;

	-- Sales Order Ids 
	DECLARE @STR_SO_10001 AS NVARCHAR(50) = 'SO-10001'

	DECLARE @INT_SO_10001 AS INT = 1
	
	-- Create Fake data for SO-10001	
	BEGIN 

		INSERT INTO dbo.tblSOSalesOrder (
				intSalesOrderId
				,strSalesOrderNumber
				,strSalesOrderOriginId
				,intEntityCustomerId
				,dtmDate
				,dtmDueDate
				,intCurrencyId
				,intCompanyLocationId
				,intEntitySalespersonId
				,intShipViaId
				,strPONumber
				,intTermId
				,dblSalesOrderSubtotal
				,dblShipping
				,dblTax
				,dblSalesOrderTotal
				,dblDiscount
				,dblAmountDue
				,dblPayment
				,strTransactionType
				,strOrderStatus
				,intAccountId
				,dtmProcessDate
				,ysnProcessed
				,strComments
				,strShipToLocationName
				,strShipToAddress
				,strShipToCity
				,strShipToState
				,strShipToZipCode
				,strShipToCountry
				,strBillToLocationName
				,strBillToAddress
				,strBillToCity
				,strBillToState
				,strBillToZipCode
				,strBillToCountry
				,intConcurrencyId
				,intEntityId		
		)
		SELECT	intSalesOrderId				= @INT_SO_10001
				,strSalesOrderNumber		= @STR_SO_10001
				,strSalesOrderOriginId		= NULL 
				,intEntityCustomerId		= @Customer_Paul_Unlimited_Id
				,dtmDate					= '01/03/2015'
				,dtmDueDate					= '01/03/2016'
				,intCurrencyId				= 1
				,intCompanyLocationId		= @Default_Location
				,intEntitySalespersonId		= NULL 
				,intShipViaId				= @Ship_Via_Truck_Id
				,strPONumber				= 'VENDOR-PO-00001'
				,intTermId					= 1
				,dblSalesOrderSubtotal		= 0.00 
				,dblShipping				= 0.00 
				,dblTax						= 0.00 
				,dblSalesOrderTotal			= 0.00 
				,dblDiscount				= 0.00 
				,dblAmountDue				= 0.00 
				,dblPayment					= 0.00 
				,strTransactionType			= 'Sales Order'
				,strOrderStatus				= 'Open'
				,intAccountId				= @AccountReceivable_Default
				,dtmProcessDate				= NULL 
				,ysnProcessed				= 0 
				,strComments				= 'Comments from Sales Order'
				,strShipToLocationName		= 'STo Location Name'
				,strShipToAddress			= 'STo Line Address'
				,strShipToCity				= 'STo City'
				,strShipToState				= 'STo State'
				,strShipToZipCode			= 'STo Zip'
				,strShipToCountry			= 'STo Country'
				,strBillToLocationName		= 'BTo Location Name'
				,strBillToAddress			= 'BTo Line Address'
				,strBillToCity				= 'BTo City'
				,strBillToState				= 'BTo State'
				,strBillToZipCode			= 'BTo Zip'
				,strBillToCountry			= 'BTo Country'
				,intConcurrencyId			= 1
				,intEntityId				= 1

		INSERT INTO dbo.tblSOSalesOrderDetail (
			intSalesOrderId
			,intItemId
			,strItemDescription
			,intItemUOMId
			,dblQtyOrdered
			,dblQtyAllocated
			,dblQtyShipped
			,dblDiscount
			,intTaxId
			,dblPrice
			,dblTotalTax
			,dblTotal
			,strComments
			,intAccountId
			,intCOGSAccountId
			,intSalesAccountId
			,intInventoryAccountId
			,intStorageLocationId
			,intConcurrencyId		
		)
		SELECT 
			intSalesOrderId			= @INT_SO_10001
			,intItemId				= @WetGrains
			,strItemDescription		= 'Wet Grains'
			,intItemUOMId			= @WetGrains_BushelUOM
			,dblQtyOrdered			= 10
			,dblQtyAllocated		= 0
			,dblQtyShipped			= 0
			,dblDiscount			= 0 
			,intTaxId				= NULL 
			,dblPrice				= 25.10
			,dblTotalTax			= 0.00
			,dblTotal				= 251.00
			,strComments			= 'Line detail comments'
			,intAccountId			= NULL 
			,intCOGSAccountId		= NULL 
			,intSalesAccountId		= NULL 
			,intInventoryAccountId	= NULL 
			,intStorageLocationId	= @StorageSilo_RM_DL
			,intConcurrencyId		= 1
	END 

END