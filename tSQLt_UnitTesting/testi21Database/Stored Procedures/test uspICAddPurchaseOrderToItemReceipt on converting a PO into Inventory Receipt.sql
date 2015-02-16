CREATE PROCEDURE [testi21Database].[test uspICAddPurchaseOrderToItemReceipt on converting a PO into Inventory Receipt]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				
		DECLARE @UOMBushel AS INT = 1
		DECLARE @UOMPound AS INT = 2				
				
		DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
		DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
		DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'				

		-- Create the fake data
		EXEC testi21Database.[Fake inventory items]

		-- Creata fake data for security user
		EXEC tSQLt.FakeTable 'dbo.tblSMUserSecurity';
		DECLARE @intUserId AS INT = 39989
		DECLARE @intEntityId AS INT = 19945

		INSERT INTO tblSMUserSecurity (
			intUserSecurityID
			,intEntityId 
		)
		VALUES (@intUserId, @intEntityId);

		EXEC tSQLt.FakeTable 'dbo.tblPOPurchase';
		EXEC tSQLt.FakeTable 'dbo.tblPOPurchaseDetail', @Identity = 1;

		DECLARE @ShipTo_DefaultLocation AS INT = 1
		DECLARE @ShipTo_NewHaven AS INT = 2
		DECLARE @ShipTo_BetterHaven AS INT = 3
		DECLARE @ShipVia_UPS AS INT = 1
		DECLARE @Currency_USD AS INT = 1
		DECLARE @FreightTerm AS INT = 1
		DECLARE @Vendor_CoolAmish AS INT = 1

		-- Fake PO Header data
		INSERT INTO dbo.tblPOPurchase (intPurchaseId, strPurchaseOrderNumber, intShipToId, strReference, intShipViaId, intCurrencyId, intFreightTermId, dblShipping, dblTotal, intVendorId) VALUES (1, N'PO-10001', @ShipTo_DefaultLocation, N'This is a reference', @ShipVia_UPS, @Currency_USD, @FreightTerm, 100.00, 2000.00, @Vendor_CoolAmish)

		-- Fake PO Detail data
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 11, @WetGrains, 10, 0, @UOMBushel, 50.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 12, @PremiumGrains, 5, 0, @UOMBushel, 100.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 13, @HotGrains, 2, 0, @UOMBushel, 200.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 14, @ColdGrains, 4, 0, @UOMBushel, 125.00)

		-- Fake starting numbers data
		EXEC tSQLt.FakeTable 'dbo.tblSMStartingNumber';
		INSERT INTO dbo.tblSMStartingNumber (intStartingNumberId, strTransactionType, strPrefix, intNumber, strModule, ysnEnable, intConcurrencyId) VALUES (23, N'Inventory Receipt', N'INVRCT-', 1000, 'Inventory', 1, 1)

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		
		-- Assert table for tblICInventoryReceipt
		SELECT	strReceiptNumber
				,dtmReceiptDate
				,intVendorId
				,strReceiptType
				,intLocationId
				,strVendorRefNo
				,intShipViaId
				,intCurrencyId
				,intFreightTermId
				,strAllocateFreight
				,dblUnitWeightMile
				,dblFreightRate
				,dblFuelSurcharge
				,dblInvoiceAmount
				,ysnInvoicePaid
				,intConcurrencyId
				,intCreatedUserId
				,intEntityId
		INTO	expected_tblICInventoryReceipt
		FROM	dbo.tblICInventoryReceipt
		WHERE	1 = 0 
		
		SELECT	intInventoryReceiptId
				,intLineNo
				,intItemId
				,intSourceId
				,dblOrderQty
				,dblOpenReceive
				,dblReceived
				,intUnitMeasureId
				,intNoPackages
				,intPackTypeId
				,dblExpPackageWeight
				,dblUnitCost
				,dblLineTotal
				,intSort
				,intConcurrencyId			
		INTO	expected_tblICInventoryReceiptItem
		FROM	dbo.tblICInventoryReceiptItem
		WHERE	1 = 0
		
			
		-- Setup the expected data
		---------------------------------------------------------
		-- Header
		---------------------------------------------------------
		INSERT INTO expected_tblICInventoryReceipt 
		SELECT strReceiptNumber = 'INVRCT-1000'
				,dtmReceiptDate = dbo.fnRemoveTimeOnDate(GETDATE())
				,intVendorId = @Vendor_CoolAmish
				,strReceiptType = @ReceiptType_PurchaseOrder
				,intItemLocationId = @Default_Location
				,strVendorRefNo = N'This is a reference'
				,intShipViaId = @ShipVia_UPS
				,intCurrencyId = @Currency_USD
				,intFreightTermId = @FreightTerm
				,strAllocateFreight = N'No'
				,dblUnitWeightMile = 0
				,dblFreightRate = 100.00
				,dblFuelSurcharge = 0 
				,dblInvoiceAmount = 2000.00
				,ysnInvoicePaid = 0
				,intConcurrencyId = 1
				,intCreatedUserId = @intUserId
				,intEntityId = @intEntityId
		
		---------------------------------------------------------
		-- Detail 
		---------------------------------------------------------
		INSERT INTO expected_tblICInventoryReceiptItem 
		SELECT	intInventoryReceiptId = 1
				,intLineNo = 1
				,intItemId = @WetGrains
				,intSourceId = 1
				,dblOrderQty = 10
				,dblOpenReceive = 10
				,dblReceived = 0
				,intUnitMeasureId = @UOMBushel
				,intNoPackages = 0
				,intPackTypeId = 0 
				,dblExpPackageWeight = 0
				,dblUnitCost = 50.00
				,dblLineTotal = 0
				,intSort = 11
				,intConcurrencyId = 1
		UNION ALL 
		SELECT	intInventoryReceiptId = 1
				,intLineNo = 2
				,intItemId = @PremiumGrains
				,intSourceId = 1
				,dblOrderQty = 5
				,dblOpenReceive = 5
				,dblReceived = 0
				,intUnitMeasureId = @UOMBushel
				,intNoPackages = 0
				,intPackTypeId = 0 
				,dblExpPackageWeight = 0
				,dblUnitCost = 100.00
				,dblLineTotal = 0
				,intSort = 12
				,intConcurrencyId = 1
		UNION ALL 
		SELECT	intInventoryReceiptId = 1
				,intLineNo = 3
				,intItemId = @HotGrains
				,intSourceId = 1
				,dblOrderQty = 2
				,dblOpenReceive = 2
				,dblReceived = 0
				,intUnitMeasureId = @UOMBushel
				,intNoPackages = 0
				,intPackTypeId = 0 
				,dblExpPackageWeight = 0
				,dblUnitCost = 200.00
				,dblLineTotal = 0
				,intSort = 13
				,intConcurrencyId = 1
		UNION ALL 
		SELECT	intInventoryReceiptId = 1
				,intLineNo = 4
				,intItemId = @ColdGrains
				,intSourceId = 1
				,dblOrderQty = 4
				,dblOpenReceive = 4
				,dblReceived = 0
				,intUnitMeasureId = @UOMBushel
				,intNoPackages = 0
				,intPackTypeId = 0 
				,dblExpPackageWeight = 0
				,dblUnitCost = 125.00
				,dblLineTotal = 0
				,intSort = 14
				,intConcurrencyId = 1					
	END
	
	-- Act
	BEGIN 
		DECLARE @InventoryReceiptIdResult AS INT 

		EXEC dbo.uspICAddPurchaseOrderToItemReceipt
			@PurchaseOrderId = 1
			,@intUserId = @intUserId
			,@InventoryReceiptId = @InventoryReceiptIdResult OUTPUT
			
		SELECT	strReceiptNumber
				,dtmReceiptDate
				,intVendorId
				,strReceiptType
				,intLocationId
				,strVendorRefNo
				,intShipViaId
				,intCurrencyId
				,intFreightTermId
				,strAllocateFreight
				,dblUnitWeightMile
				,dblFreightRate
				,dblFuelSurcharge
				,dblInvoiceAmount
				,ysnInvoicePaid
				,intConcurrencyId
				,intCreatedUserId
				,intEntityId				
		INTO	actual_tblICInventoryReceipt
		FROM	dbo.tblICInventoryReceipt
		
		SELECT	intInventoryReceiptId
				,intLineNo
				,intItemId
				,intSourceId
				,dblOrderQty
				,dblOpenReceive
				,dblReceived
				,intUnitMeasureId
				,intNoPackages
				,intPackTypeId
				,dblExpPackageWeight
				,dblUnitCost
				,dblLineTotal
				,intSort
				,intConcurrencyId
		INTO	actual_tblICInventoryReceiptItem
		FROM	dbo.tblICInventoryReceiptItem	
	END 

	-- Assert
	BEGIN 
		-- Check if the output parameter value returned is correct. 
		EXEC tSQLt.AssertEquals @InventoryReceiptIdResult, 1

		-- Check if the expected data in the tables are created
		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryReceipt', 'actual_tblICInventoryReceipt'
		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryReceiptItem', 'actual_tblICInventoryReceiptItem'
	END 
	
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual_tblICInventoryReceipt') IS NOT NULL 
		DROP TABLE actual_tblICInventoryReceipt

	IF OBJECT_ID('actual_tblICInventoryReceiptItem') IS NOT NULL 
		DROP TABLE actual_tblICInventoryReceiptItem

	IF OBJECT_ID('expected_tblICInventoryReceipt') IS NOT NULL 
		DROP TABLE expected_tblICInventoryReceiptItem

	IF OBJECT_ID('expected_tblICInventoryReceiptItem') IS NOT NULL 
		DROP TABLE expected_tblICInventoryReceiptItem
END