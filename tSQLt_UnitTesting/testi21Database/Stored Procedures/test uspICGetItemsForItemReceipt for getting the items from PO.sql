
CREATE PROCEDURE [testi21Database].[test uspICGetItemsForItemReceipt for getting the items from PO]
AS
BEGIN
	-- Arrange 
	BEGIN 

		-- Create the assert tables 
		-- Assert table for the expected
		SELECT	intItemId				= PODetail.intItemId
				,intLocationId			= PODetail.intLocationId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= PODetail.dblQtyOrdered 
				,dblUOMQty				= UOMConversion.dblConversionToStock 
				,dblCost				= PODetail.dblCost
				,dblSalesPrice			= 0
				,intCurrencyId			= PO.intCurrencyId
				,dblExchangeRate		= 1
				,intTransactionId		= PO.intPurchaseId
				,strTransactionId		= PO.strPurchaseOrderNumber
				,intTransactionTypeId	= CAST(NULL AS INT) 
				,intLotId				= CAST(NULL AS INT) 
		INTO	expected
		FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
					ON PO.intPurchaseId = PODetail.intPurchaseId
				LEFT JOIN dbo.tblICUnitMeasure UOM
					ON PODetail.intUnitOfMeasureId = UOM.intUnitMeasureId
				INNER JOIN dbo.tblICUnitMeasureConversion UOMConversion
					ON UOM.intUnitMeasureId = UOMConversion.intUnitMeasureId
		WHERE	1 = 0

		-- Assert table for the actual 
		SELECT	* 
		INTO	actual
		FROM	expected

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
				
		DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
		DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
		DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'
		
		DECLARE @intPurchaseOrderType AS INT = 1
		DECLARE @intTransferOrderType AS INT = 2
		DECLARE @intDirectType AS INT = 3

		-- Create the fake data
		EXEC testi21Database.[Fake data for simple Items]

		-- Create the fake table and data for the unit of measure
		EXEC tSQLt.FakeTable 'dbo.tblICUnitMeasure', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICUnitMeasureConversion', @Identity = 1;

		DECLARE @UOMBushel AS INT = 1
		DECLARE @UOMPound AS INT = 2

		INSERT INTO dbo.tblICUnitMeasure (strUnitMeasure) VALUES ('Bushel')
		INSERT INTO dbo.tblICUnitMeasure (strUnitMeasure) VALUES ('Pound')
		INSERT INTO dbo.tblICUnitMeasureConversion (intUnitMeasureId, dblConversionToStock, dblConversionFromStock) VALUES (@UOMBushel, 1, 1)
		INSERT INTO dbo.tblICUnitMeasureConversion (intUnitMeasureId, dblConversionToStock, dblConversionFromStock) VALUES (@UOMPound, 0.016667, 60)

		DROP VIEW vyuAPPurchase		
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
		INSERT INTO dbo.tblPOPurchase (intPurchaseId, strPurchaseOrderNumber, intShipToId, strReference, intShipViaId, intCurrencyId, intFreightId, dblShipping, dblTotal, intVendorId) VALUES (1, N'PO-10001', @ShipTo_DefaultLocation, N'This is a reference', @ShipVia_UPS, @Currency_USD, @FreightTerm, 100.00, 2000.00, @Vendor_CoolAmish)

		-- Fake PO Detail data
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 1, @WetGrains, 10, 0, @UOMBushel, 50.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 2, @PremiumGrains, 5, 0, @UOMBushel, 100.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 3, @HotGrains, 2, 0, @UOMBushel, 200.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 4, @ColdGrains, 4, 0, @UOMBushel, 125.00)

		-- Setup the expected data
		INSERT INTO expected
		SELECT	intItemId				= @WetGrains
				,intLocationId			= @Default_Location
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= 10
				,dblUOMQty				= 1
				,dblCost				= 50.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
		UNION ALL 
		SELECT	intItemId				= @PremiumGrains
				,intLocationId			= @Default_Location
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= 5
				,dblUOMQty				= 1
				,dblCost				= 100.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
		UNION ALL 
		SELECT	intItemId				= @HotGrains
				,intLocationId			= @Default_Location
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= 2
				,dblUOMQty				= 1
				,dblCost				= 200.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
		UNION ALL 
		SELECT	intItemId				= @ColdGrains
				,intLocationId			= @Default_Location
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= 4
				,dblUOMQty				= 1
				,dblCost				= 125.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
	END 
	
	-- Act 
	BEGIN 
		INSERT INTO actual (
			intItemId
			,intLocationId
			,dtmDate
			,dblUnitQty
			,dblUOMQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
		)
		EXEC dbo.uspICGetItemsForItemReceipt 
			@intSourceTransactionId = 1
			,@strSourceType = 'Purchase Order'	
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 