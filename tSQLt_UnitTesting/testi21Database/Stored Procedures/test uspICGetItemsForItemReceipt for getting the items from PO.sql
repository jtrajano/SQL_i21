CREATE PROCEDURE [testi21Database].[test uspICGetItemsForItemReceipt for getting the items from PO]
AS
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

	-- Arrange 
	BEGIN 
		-- Create the assert tables 
		-- Assert table for the expected
		SELECT	intItemId				= PODetail.intItemId
				,intItemLocationId		= ItemLocation.intItemLocationId
				,intItemUOMId			= PODetail.intUnitOfMeasureId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblQty					= PODetail.dblQtyOrdered 
				,dblUOMQty				= ItemUOM.dblUnitQty  
				,dblCost				= PODetail.dblCost
				,dblSalesPrice			= 0
				,intCurrencyId			= PO.intCurrencyId
				,dblExchangeRate		= 1
				,intTransactionId		= PO.intPurchaseId
				,strTransactionId		= PO.strPurchaseOrderNumber
				,intTransactionTypeId	= CAST(NULL AS INT) 
				,intLotId				= CAST(NULL AS INT) 
				,intSubLocationId		= CAST(NULL AS INT) 
				,intStorageLocationId	= CAST(NULL AS INT) 
		INTO	expected
		FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
					ON PO.intPurchaseId = PODetail.intPurchaseId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON PODetail.intItemId = ItemUOM.intItemId
					AND PODetail.intUnitOfMeasureId = ItemUOM.intUnitMeasureId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON PODetail.intItemId = ItemLocation.intItemId
					AND PODetail.intLocationId = ItemLocation.intLocationId
		WHERE	1 = 0

		-- Assert table for the actual 
		SELECT	* 
		INTO	actual
		FROM	expected
				
		DECLARE @UOMBushel AS INT = 1
		DECLARE @UOMPound AS INT = 2			
				
		DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
		DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
		DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'
		
		DECLARE @intPurchaseOrderType AS INT = 1
		DECLARE @intTransferOrderType AS INT = 2
		DECLARE @intDirectType AS INT = 3

		-- Create the fake data
		EXEC testi21Database.[Fake inventory items]

		-- Mark all items as stock-keeping items. 
		UPDATE dbo.tblICItem
		SET strType = 'Inventory'

		-- Create the fake PO tables 
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
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 1, @WetGrains, 10, 0, @WetGrains_BushelUOMId, 50.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 2, @PremiumGrains, 5, 0, @PremiumGrains_BushelUOMId, 100.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 3, @HotGrains, 2, 0, @HotGrains_BushelUOMId, 200.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (1, 4, @ColdGrains, 4, 0, @ColdGrains_BushelUOMId, 125.00)

		-- Setup the expected data
		INSERT INTO expected
		SELECT	intItemId				= @WetGrains
				,intItemLocationId		= @WetGrains_DefaultLocation
				,intItemUOMId			= @WetGrains_BushelUOMId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblQty					= 10
				,dblUOMQty				= 1
				,dblCost				= 50.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
				,intSubLocationId		= NULL
				,intStorageLocationId	= NULL
		UNION ALL 
		SELECT	intItemId				= @PremiumGrains
				,intItemLocationId		= @PremiumGrains_DefaultLocation
				,intItemUOMId			= @PremiumGrains_BushelUOMId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblQty					= 5
				,dblUOMQty				= 1
				,dblCost				= 100.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
				,intSubLocationId		= NULL
				,intStorageLocationId	= NULL
		UNION ALL 
		SELECT	intItemId				= @HotGrains
				,intItemLocationId		= @HotGrains_DefaultLocation
				,intItemUOMId			= @HotGrains_BushelUOMId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblQty					= 2
				,dblUOMQty				= 1
				,dblCost				= 200.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
				,intSubLocationId		= NULL
				,intStorageLocationId	= NULL
		UNION ALL 
		SELECT	intItemId				= @ColdGrains
				,intItemLocationId		= @ColdGrains_DefaultLocation
				,intItemUOMId			= @ColdGrains_BushelUOMId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblQty					= 4
				,dblUOMQty				= 1
				,dblCost				= 125.00
				,dblSalesPrice			= 0
				,intCurrencyId			= @Currency_USD
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= N'PO-10001'
				,intTransactionTypeId	= @intPurchaseOrderType
				,intLotId				= NULL 
				,intSubLocationId		= NULL
				,intStorageLocationId	= NULL

	END 
		
	-- Act 
	BEGIN 
		INSERT INTO actual (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
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
