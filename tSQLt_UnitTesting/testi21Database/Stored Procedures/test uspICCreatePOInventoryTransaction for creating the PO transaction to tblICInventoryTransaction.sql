CREATE PROCEDURE [testi21Database].[test uspICCreatePOInventoryTransaction for creating the PO transaction to tblICInventoryTransaction]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items]

		-- Create the fake PO tables 
		EXEC tSQLt.FakeTable 'dbo.tblPOPurchase';
		EXEC tSQLt.FakeTable 'dbo.tblPOPurchaseDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt';
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@WetGrains_DefaultLocation AS INT = 1
				,@StickyGrains_DefaultLocation AS INT = 2
				,@PremiumGrains_DefaultLocation AS INT = 3
				,@ColdGrains_DefaultLocation AS INT = 4
				,@HotGrains_DefaultLocation AS INT = 5

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5
				
		DECLARE @UOMBushel AS INT = 1
		DECLARE @UOMPound AS INT = 2			
				
		DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
		DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
		DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'	

		DECLARE @ShipTo_DefaultLocation AS INT = @Default_Location

		DECLARE @ShipVia_UPS AS INT = 1
		DECLARE @Currency_USD AS INT = 1
		DECLARE @FreightTerm AS INT = 1
		DECLARE @Vendor_CoolAmish AS INT = 1

		DECLARE @intPurchaseId AS INT = 100
		DECLARE @intInventoryReceiptId AS INT = 560
		DECLARE @dtmDate AS DATETIME = '01/06/2014'

		-- Fake PO Header data
		INSERT INTO dbo.tblPOPurchase (intPurchaseId, strPurchaseOrderNumber, intShipToId, strReference, intShipViaId, intCurrencyId, intFreightTermId, dblShipping, dblTotal, intVendorId, dtmDate) VALUES (@intPurchaseId, N'PO-10001', @ShipTo_DefaultLocation, N'This is a reference', @ShipVia_UPS, @Currency_USD, @FreightTerm, 100.00, 2000.00, @Vendor_CoolAmish, @dtmDate)

		-- Fake PO Detail data
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (@intPurchaseId, 1, @WetGrains, 10, 0, @WetGrains_BushelUOMId, 50.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (@intPurchaseId, 2, @PremiumGrains, 5, 0, @PremiumGrains_BushelUOMId, 100.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (@intPurchaseId, 3, @HotGrains, 2, 0, @HotGrains_BushelUOMId, 200.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (@intPurchaseId, 4, @ColdGrains, 4, 0, @ColdGrains_BushelUOMId, 125.00)
		INSERT INTO dbo.tblPOPurchaseDetail(intPurchaseId, intLineNo, intItemId, dblQtyOrdered, dblQtyReceived, intUnitOfMeasureId, dblCost) VALUES (@intPurchaseId, 5, @WetGrains, 10, 0, @WetGrains_BushelUOMId, 53.25)

		-- Fake Inventory Receipt header
		INSERT INTO dbo.tblICInventoryReceipt (
			intInventoryReceiptId
			,strReceiptType
			,intLocationId
		)
		VALUES (
			@intInventoryReceiptId
			,@ReceiptType_PurchaseOrder
			,@Default_Location
		)

		-- Fake Inventory Receipt Item (detail)
		INSERT INTO dbo.tblICInventoryReceiptItem (
			intInventoryReceiptId
			,intItemId
			,intSourceId
			,intUnitMeasureId
		)
		SELECT 
			intInventoryReceiptId = @intInventoryReceiptId
			,intItemId = @WetGrains
			,intSourceId = @intPurchaseId
			,intUnitMeasureId = @WetGrains_BushelUOMId
		UNION ALL 
		SELECT 
			intInventoryReceiptId = @intInventoryReceiptId
			,intItemId = @PremiumGrains
			,intSourceId = @intPurchaseId
			,intUnitMeasureId = @PremiumGrains_BushelUOMId

		-- Setup the expected and actual tables. 
		CREATE TABLE expected (
			[intInventoryTransactionId] INT NOT NULL IDENTITY, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[intItemUOMId] INT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblValue] NUMERIC(18, 6) NULL, 
			[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[intCurrencyId] INT NULL,
			[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
			[intTransactionId] INT NOT NULL, 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intTransactionTypeId] INT NOT NULL, 
			[intLotId] INT NULL, 
			[ysnIsUnposted] BIT NULL,
			[intRelatedInventoryTransactionId] INT NULL,
			[intRelatedTransactionId] INT NULL,
			[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
			[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
			[intCreatedUserId] INT NULL
		)

		CREATE TABLE actual (
			[intInventoryTransactionId] INT NULL, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[intItemUOMId] INT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblValue] NUMERIC(18, 6) NULL, 
			[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[intCurrencyId] INT NULL,
			[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
			[intTransactionId] INT NOT NULL, 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intTransactionTypeId] INT NOT NULL, 
			[intLotId] INT NULL, 
			[ysnIsUnposted] BIT NULL,
			[intRelatedInventoryTransactionId] INT NULL,
			[intRelatedTransactionId] INT NULL,
			[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
			[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
			[intCreatedUserId] INT NULL
		)

		DECLARE @intTransactionTypeId AS INT 
				,@TransactionTypeName AS NVARCHAR(200)

		SELECT	@intTransactionTypeId = intTransactionTypeId
				,@TransactionTypeName = strName
		FROM	tblICInventoryTransactionType 
		WHERE	strName = 'Purchase Order'

		DECLARE @intUserId AS INT = 98

		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,ysnIsUnposted
				,intRelatedInventoryTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,strTransactionForm
				,intCreatedUserId
		)
		SELECT	intItemId					= @WetGrains
				,intItemLocationId			= @WetGrains_DefaultLocation
				,intItemUOMId				= @WetGrains_BushelUOMId
				,dtmDate					= @dtmDate
				,dblQty						= (10 + 10)
				,dblUOMQty					= 1
				,dblCost					= 0
				,dblValue					= (10 * 50.00) + (10 * 53.25)
				,dblSalesPrice				= 0
				,intCurrencyId				= NULL
				,dblExchangeRate			= 1
				,intTransactionId			= @intPurchaseId
				,strTransactionId			= 'PO-10001'
				,strBatchId					= ''
				,intTransactionTypeId		= @intTransactionTypeId
				,intLotId					= NULL 
				,ysnIsUnposted				= 0
				,intRelatedInventoryTransactionId	= NULL 
				,intRelatedTransactionId	= NULL 
				,strRelatedTransactionId	= NULL 
				,strTransactionForm			= @TransactionTypeName
				,intCreatedUserId			= @intUserId
		UNION ALL 
		SELECT	intItemId					= @PremiumGrains
				,intItemLocationId			= @PremiumGrains_DefaultLocation
				,intItemUOMId				= @PremiumGrains_BushelUOMId
				,dtmDate					= @dtmDate
				,dblQty						= 5
				,dblUOMQty					= 1
				,dblCost					= 0
				,dblValue					= (5 * 100.00)
				,dblSalesPrice				= 0
				,intCurrencyId				= NULL
				,dblExchangeRate			= 1
				,intTransactionId			= @intPurchaseId
				,strTransactionId			= 'PO-10001'
				,strBatchId					= ''
				,intTransactionTypeId		= @intTransactionTypeId
				,intLotId					= NULL 
				,ysnIsUnposted				= 0
				,intRelatedInventoryTransactionId	= NULL 
				,intRelatedTransactionId	= NULL 
				,strRelatedTransactionId	= NULL 
				,strTransactionForm			= @TransactionTypeName
				,intCreatedUserId			= @intUserId
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICCreatePOInventoryTransaction @intInventoryReceiptId, @intUserId
	END 

	-- Assert
	BEGIN 
		INSERT INTO actual (
				intInventoryTransactionId
				,intItemId
				,intItemLocationId
				,intItemUOMId 
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,ysnIsUnposted
				,intRelatedInventoryTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,strTransactionForm
				,intCreatedUserId
		)
		SELECT	intInventoryTransactionId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,ysnIsUnposted
				,intRelatedInventoryTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,strTransactionForm
				,intCreatedUserId
		FROM	dbo.tblICInventoryTransaction

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END