﻿CREATE PROCEDURE [testi21Database].[test uspICAddPurchaseOrderToInventoryReceipt on converting a PO into Inventory Receipt and it excludes non-stock types]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake inventory items]

		-- Mark all items as stock tracking units 
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
				
		DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
		DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
		DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'				

		-- Creata fake data for security user
		EXEC tSQLt.FakeTable 'dbo.tblSMUserSecurity';
		DECLARE @intEntityId AS INT = 19945

		INSERT INTO tblSMUserSecurity (
			intEntityId
		)
		VALUES (@intEntityId);

		EXEC tSQLt.FakeTable 'dbo.tblPOPurchase';
		EXEC tSQLt.FakeTable 'dbo.tblPOPurchaseDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblPOPurchaseDetailTax', @Identity = 1;

		DECLARE @ShipTo_DefaultLocation AS INT = 1
		DECLARE @ShipTo_NewHaven AS INT = 2
		DECLARE @ShipTo_BetterHaven AS INT = 3
		DECLARE @ShipVia_UPS AS INT = 1
		DECLARE @Currency_USD AS INT = 1
		DECLARE @FreightTerm AS INT = 1
		DECLARE @Vendor_CoolAmish AS INT = 1

		-- Fake PO Header data
		INSERT INTO dbo.tblPOPurchase (intPurchaseId, strPurchaseOrderNumber, intShipToId, strReference, intShipViaId, intCurrencyId, intFreightTermId, dblShipping, dblTotal, intEntityVendorId) VALUES (1, N'PO-10001', @ShipTo_DefaultLocation, N'This is a reference', @ShipVia_UPS, @Currency_USD, @FreightTerm, 100.00, 2000.00, @Vendor_CoolAmish)

		-- Fake PO Detail data
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 11, @WetGrains, 10, 0, @WetGrains_BushelUOMId, 50.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 12, @PremiumGrains, 5, 0, @PremiumGrains_BushelUOMId, 100.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 13, @HotGrains, 2, 0, @HotGrains_BushelUOMId, 200.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 14, @ColdGrains, 4, 0, @ColdGrains_BushelUOMId, 125.00)

		-- Fake starting numbers data
		EXEC tSQLt.FakeTable 'dbo.tblSMStartingNumber';
		INSERT INTO dbo.tblSMStartingNumber (intStartingNumberId, strTransactionType, strPrefix, intNumber, strModule, ysnEnable, intConcurrencyId) VALUES (23, N'Inventory Receipt', N'INVRCT-', 1000, 'Inventory', 1, 1)

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptCharge', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemTax', @Identity = 1;

		-- Make some items as non-inventory
		UPDATE	Item
		SET		strType = 'Non-Inventory'
		FROM	dbo.tblICItem Item
		WHERE	intItemId IN (@HotGrains, @ColdGrains)
		
		-- Assert table for tblICInventoryReceipt
		SELECT	strReceiptNumber
				,dtmReceiptDate
				,intEntityVendorId
				,strReceiptType
				,intLocationId
				,strVendorRefNo
				,intShipViaId
				,intCurrencyId
				,intFreightTermId
				,dblInvoiceAmount
				,ysnInvoicePaid
				,intConcurrencyId
				,intEntityId
		INTO	expected_tblICInventoryReceipt
		FROM	dbo.tblICInventoryReceipt
		WHERE	1 = 0 
		
		SELECT	intInventoryReceiptId
				,intLineNo
				,intItemId
				,intOrderId
				,dblOrderQty
				,dblOpenReceive
				,dblReceived
				,intUnitMeasureId
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
		INSERT INTO expected_tblICInventoryReceipt (
			strReceiptNumber		
			,dtmReceiptDate		
			,intEntityVendorId	
			,strReceiptType		
			,intLocationId	
			,strVendorRefNo		
			,intShipViaId		
			,intCurrencyId		
			,intFreightTermId	
			,dblInvoiceAmount	
			,ysnInvoicePaid		
			,intConcurrencyId	
			,intEntityId					
		)
		SELECT strReceiptNumber		= 'INVRCT-1000'
				,dtmReceiptDate		= dbo.fnRemoveTimeOnDate(GETDATE())
				,intEntityVendorId	= @Vendor_CoolAmish
				,strReceiptType		= @ReceiptType_PurchaseOrder
				,intLocationId		= @Default_Location
				,strVendorRefNo		= N'This is a reference'
				,intShipViaId		= @ShipVia_UPS
				,intCurrencyId		= @Currency_USD
				,intFreightTermId	= @FreightTerm
				,dblInvoiceAmount	= ((10 - 0) * 50.00) + ((5-0) * 100.00)
				,ysnInvoicePaid		= 0
				,intConcurrencyId	= 1
				,intEntityId		= @intEntityId
		
		-----------------------------------------------------------
		---- Detail 
		-----------------------------------------------------------
		INSERT INTO expected_tblICInventoryReceiptItem 
		SELECT	intInventoryReceiptId = 1
				,intLineNo = 1
				,intItemId = @WetGrains
				,intOrderId = 1
				,dblOrderQty = 10
				,dblOpenReceive = (10 - 0)
				,dblReceived = 0
				,intUnitMeasureId = @WetGrains_BushelUOMId
				,dblUnitCost = 50.00
				,dblLineTotal = ((10 - 0) * 50.00)
				,intSort = 11
				,intConcurrencyId = 1
		UNION ALL 
		SELECT	intInventoryReceiptId = 1
				,intLineNo = 2
				,intItemId = @PremiumGrains
				,intOrderId = 1
				,dblOrderQty = 5
				,dblOpenReceive = (5-0)
				,dblReceived = 0
				,intUnitMeasureId = @PremiumGrains_BushelUOMId
				,dblUnitCost = 100.00
				,dblLineTotal = ((5-0) * 100.00)
				,intSort = 12
				,intConcurrencyId = 1					
	END

	-- Act
	BEGIN 
		DECLARE @InventoryReceiptIdResult AS INT 

		EXEC dbo.uspICAddPurchaseOrderToInventoryReceipt
			@PurchaseOrderId = 1
			,@intEntityUserSecurityId = @intEntityId
			,@InventoryReceiptId = @InventoryReceiptIdResult OUTPUT
			
		SELECT	strReceiptNumber
				,dtmReceiptDate
				,intEntityVendorId
				,strReceiptType
				,intLocationId
				,strVendorRefNo
				,intShipViaId
				,intCurrencyId
				,intFreightTermId
				,dblInvoiceAmount
				,ysnInvoicePaid
				,intConcurrencyId
				,intCreatedUserId
				,intEntityId				
		INTO	actual_tblICInventoryReceipt
		FROM	dbo.tblICInventoryReceipt
		WHERE	intInventoryReceiptId = @InventoryReceiptIdResult

		SELECT	intInventoryReceiptId
				,intLineNo
				,intItemId
				,intOrderId
				,dblOrderQty
				,dblOpenReceive
				,dblReceived
				,intUnitMeasureId
				,dblUnitCost
				,dblLineTotal
				,intSort
				,intConcurrencyId
		INTO	actual_tblICInventoryReceiptItem
		FROM	dbo.tblICInventoryReceiptItem	
		WHERE	intInventoryReceiptId = @InventoryReceiptIdResult
	END 
		
	-- Assert
	BEGIN 
		-- Check if the output parameter value returned is correct. 
		EXEC tSQLt.AssertEquals @InventoryReceiptIdResult, 1

		-- Check if the expected data in the tables are created
		--EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryReceipt', 'actual_tblICInventoryReceipt'
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