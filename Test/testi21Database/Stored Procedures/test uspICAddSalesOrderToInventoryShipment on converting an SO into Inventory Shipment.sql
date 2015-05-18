CREATE PROCEDURE [testi21Database].[test uspICAddSalesOrderToInventoryShipment on converting an SO into Inventory Shipment]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake inventory items]
		EXEC testi21Database.[Fake data for customers]
		
		-- Set all items as stock-keeping
		UPDATE dbo.tblICItem
		SET strType = 'Inventory' 

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

		-- Declare the account ids
		DECLARE @AccountReceivable_Default AS INT = 8000
		DECLARE @AccountReceivable_NewHaven AS INT = 8001
		DECLARE @AccountReceivable_BetterHaven AS INT = 8002
				
		DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
				,@SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
				,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'			

		DECLARE @SALES_CONTRACT_TYPE_ID AS INT = 1
				,@SALES_ORDER_TYPE_ID AS INT = 2
				,@TRANSFER_ORDER_TYPE_ID AS INT = 3

		-- Creata fake data for security user
		EXEC tSQLt.FakeTable 'dbo.tblSMUserSecurity';
		DECLARE @intUserId AS INT = 39989
		DECLARE @intEntityId AS INT = 19945

		INSERT INTO tblSMUserSecurity (
			intUserSecurityID
			,intEntityId 
		)
		VALUES (@intUserId, @intEntityId);

		EXEC tSQLt.FakeTable 'dbo.tblSOSalesOrder';
		EXEC tSQLt.FakeTable 'dbo.tblSOSalesOrderDetail', @Identity = 1;

		DECLARE @ShipTo_DefaultLocation AS INT = 1
		DECLARE @ShipTo_NewHaven AS INT = 2
		DECLARE @ShipTo_BetterHaven AS INT = 3
		DECLARE @ShipVia_UPS AS INT = 1
		DECLARE @Currency_USD AS INT = 1
		DECLARE @FreightTerm AS INT = 1
		DECLARE @Vendor_CoolAmish AS INT = 1

		-- Fake SO Header data
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
		SELECT	intSalesOrderId				= 1
				,strSalesOrderNumber		= 'SO-10001'
				,strSalesOrderOriginId		= NULL 
				,intEntityCustomerId		= 1
				,dtmDate					= '01/03/2015'
				,dtmDueDate					= '01/03/2016'
				,intCurrencyId				= 1
				,intCompanyLocationId		= 1
				,intEntitySalespersonId		= NULL 
				,intShipViaId				= 1
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
				,strOrderStatus				= 'Pending'
				,intAccountId				= @AccountReceivable_Default
				,dtmProcessDate				= NULL 
				,ysnProcessed				= 0 
				,strComments				= 'Comments here'
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

		-- Fake SO Detail data
		--INSERT INTO dbo.tblSOSalesOrderDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 11, @WetGrains, 10, 0, @WetGrains_BushelUOMId, 50.00)
		--INSERT INTO dbo.tblSOSalesOrderDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 12, @PremiumGrains, 5, 0, @PremiumGrains_BushelUOMId, 100.00)
		--INSERT INTO dbo.tblSOSalesOrderDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 13, @HotGrains, 2, 0, @HotGrains_BushelUOMId, 200.00)
		--INSERT INTO dbo.tblSOSalesOrderDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 14, @ColdGrains, 4, 0, @ColdGrains_BushelUOMId, 125.00)

		-- Fake starting numbers data
		EXEC tSQLt.FakeTable 'dbo.tblSMStartingNumber';
		INSERT INTO dbo.tblSMStartingNumber (intStartingNumberId, strTransactionType, strPrefix, intNumber, strModule, ysnEnable, intConcurrencyId) VALUES (31, N'Inventory Shipment', N'INVSHIP-', 1000, 'Inventory', 1, 1)

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;
		
		---- Assert table for tblICInventoryShipment
		--SELECT	strReceiptNumber
		--		,dtmReceiptDate
		--		,intEntityVendorId
		--		,strReceiptType
		--		,intLocationId
		--		,strVendorRefNo
		--		,intShipViaId
		--		,intCurrencyId
		--		,intFreightTermId
		--		,strAllocateFreight
		--		,dblUnitWeightMile
		--		,dblFreightRate
		--		,dblFuelSurcharge
		--		,dblInvoiceAmount
		--		,ysnInvoicePaid
		--		,intConcurrencyId
		--		,intCreatedUserId
		--		,intEntityId
		--INTO	expected_tblICInventoryShipment
		--FROM	dbo.tblICInventoryShipment
		--WHERE	1 = 0 
		
		--SELECT	intInventoryReceiptId
		--		,intLineNo
		--		,intItemId
		--		,intSourceId
		--		,dblOrderQty
		--		,dblOpenReceive
		--		,dblReceived
		--		,intUnitMeasureId
		--		,dblUnitCost
		--		,dblLineTotal
		--		,intSort
		--		,intConcurrencyId			
		--INTO	expected_tblICInventoryShipmentItem
		--FROM	dbo.tblICInventoryShipmentItem
		--WHERE	1 = 0
		
			
		-- Setup the expected data
		---------------------------------------------------------
		-- Header
		---------------------------------------------------------
		--INSERT INTO expected_tblICInventoryShipment 
		--SELECT strReceiptNumber = 'INVRCT-1000'
		--		,dtmReceiptDate = dbo.fnRemoveTimeOnDate(GETDATE())
		--		,intEntityVendorId = @Vendor_CoolAmish
		--		,strReceiptType = @SALES_ORDER_TYPE_ID
		--		,intItemLocationId = @Default_Location
		--		,strVendorRefNo = N'This is a reference'
		--		,intShipViaId = @ShipVia_UPS
		--		,intCurrencyId = @Currency_USD
		--		,intFreightTermId = @FreightTerm
		--		,strAllocateFreight = N'No'
		--		,dblUnitWeightMile = 0
		--		,dblFreightRate = 100.00
		--		,dblFuelSurcharge = 0 
		--		,dblInvoiceAmount = ((10 - 0) * 50.00)
		--							+ ((5-0) * 100.00)
		--							+ ((2-0) * 200.00)
		--							+ ((4-0) * 125.00)
		--		,ysnInvoicePaid = 0
		--		,intConcurrencyId = 1
		--		,intCreatedUserId = @intUserId
		--		,intEntityId = @intEntityId
		
		-----------------------------------------------------------
		---- Detail 
		-----------------------------------------------------------
		--INSERT INTO expected_tblICInventoryShipmentItem 
		--SELECT	intInventoryReceiptId = 1
		--		,intLineNo = 1
		--		,intItemId = @WetGrains
		--		,intSourceId = 1
		--		,dblOrderQty = 10
		--		,dblOpenReceive = (10 - 0)
		--		,dblReceived = 0
		--		,intUnitMeasureId = @WetGrains_BushelUOMId
		--		,dblUnitCost = 50.00
		--		,dblLineTotal = ((10 - 0) * 50.00)
		--		,intSort = 11
		--		,intConcurrencyId = 1
		--UNION ALL 
		--SELECT	intInventoryReceiptId = 1
		--		,intLineNo = 2
		--		,intItemId = @PremiumGrains
		--		,intSourceId = 1
		--		,dblOrderQty = 5
		--		,dblOpenReceive = (5-0)
		--		,dblReceived = 0
		--		,intUnitMeasureId = @PremiumGrains_BushelUOMId
		--		,dblUnitCost = 100.00
		--		,dblLineTotal = ((5-0) * 100.00)
		--		,intSort = 12
		--		,intConcurrencyId = 1
		--UNION ALL 
		--SELECT	intInventoryReceiptId = 1
		--		,intLineNo = 3
		--		,intItemId = @HotGrains
		--		,intSourceId = 1
		--		,dblOrderQty = 2
		--		,dblOpenReceive = (2-0)
		--		,dblReceived = 0
		--		,intUnitMeasureId = @HotGrains_BushelUOMId
		--		,dblUnitCost = 200.00
		--		,dblLineTotal = ((2-0) * 200.00)
		--		,intSort = 13
		--		,intConcurrencyId = 1
		--UNION ALL 
		--SELECT	intInventoryReceiptId = 1
		--		,intLineNo = 4
		--		,intItemId = @ColdGrains
		--		,intSourceId = 1
		--		,dblOrderQty = 4
		--		,dblOpenReceive = (4-0)
		--		,dblReceived = 0
		--		,intUnitMeasureId = @ColdGrains_BushelUOMId
		--		,dblUnitCost = 125.00
		--		,dblLineTotal = ((4-0) * 125.00)
		--		,intSort = 14
		--		,intConcurrencyId = 1					
	END

	-- Act
	BEGIN 
		DECLARE @InventoryShipmentIdResult AS INT 

		EXEC dbo.uspICAddSalesOrderToInventoryShipment
			@SalesOrderId = 1
			,@intUserId = @intUserId
			,@InventoryShipmentId = @InventoryShipmentIdResult OUTPUT
			
		--SELECT	strReceiptNumber
		--		,dtmReceiptDate
		--		,intEntityVendorId
		--		,strReceiptType
		--		,intLocationId
		--		,strVendorRefNo
		--		,intShipViaId
		--		,intCurrencyId
		--		,intFreightTermId
		--		,strAllocateFreight
		--		,dblUnitWeightMile
		--		,dblFreightRate
		--		,dblFuelSurcharge
		--		,dblInvoiceAmount
		--		,ysnInvoicePaid
		--		,intConcurrencyId
		--		,intCreatedUserId
		--		,intEntityId				
		--INTO	actual_tblICInventoryShipment
		--FROM	dbo.tblICInventoryShipment
		
		--SELECT	intInventoryReceiptId
		--		,intLineNo
		--		,intItemId
		--		,intSourceId
		--		,dblOrderQty
		--		,dblOpenReceive
		--		,dblReceived
		--		,intUnitMeasureId
		--		,dblUnitCost
		--		,dblLineTotal
		--		,intSort
		--		,intConcurrencyId
		--INTO	actual_tblICInventoryShipmentItem
		--FROM	dbo.tblICInventoryShipmentItem	
	END 

	-- Assert
	BEGIN 
		-- Check if the output parameter value returned is correct. 
		EXEC tSQLt.AssertEquals @InventoryShipmentIdResult, 1

		-- Check if the expected data in the tables are created
		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryShipment', 'actual_tblICInventoryShipment'
		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryShipmentItem', 'actual_tblICInventoryShipmentItem'
	END 
	
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual_tblICInventoryShipment') IS NOT NULL 
		DROP TABLE actual_tblICInventoryShipment

	IF OBJECT_ID('actual_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE actual_tblICInventoryShipmentItem

	IF OBJECT_ID('expected_tblICInventoryShipment') IS NOT NULL 
		DROP TABLE expected_tblICInventoryShipmentItem

	IF OBJECT_ID('expected_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE expected_tblICInventoryShipmentItem
END
