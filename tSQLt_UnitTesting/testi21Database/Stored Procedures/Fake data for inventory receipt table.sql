CREATE PROCEDURE [testi21Database].[Fake data for inventory receipt table]
AS
BEGIN
	EXEC [testi21Database].[Fake inventory items];

	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemLot', @Identity = 1;	

	EXEC tSQLt.ApplyConstraint 'dbo.tblICLot', 'UN_tblICLot';		

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

	-- Declare the variables for the transaction 
	DECLARE @strReceiptNumber AS NVARCHAR(40);
	DECLARE @intReceiptNumber AS INT;
	DECLARE @BaseCurrencyId AS INT = 1;
	DECLARE @dblExchangeRate AS NUMERIC(18,6) = 1;
	DECLARE @dtmDate AS DATETIME;
	DECLARE @InventoryReceiptTypeId AS INT = 4;
	DECLARE @intEntityId AS INT = 1;
	DECLARE @intUserId AS INT = 1;

	DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
	DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
	DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'

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
	-- Add INVRCPT-XXXXX1
	-- It has all kinds of items on it. 
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'INVRCPT-XXXXX1'
		SET @dtmDate = '01/10/2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @ReceiptType_PurchaseOrder
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
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
			,intNoPackages
			,intPackageTypeId
			,dblExpPackageWeight
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
		)
		-- intInventoryReceiptItemId: 1
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= ''
				,intItemId				= @WetGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @WetGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 1.00
				,dblLineTotal			= 10.00
				,intSort				= 1
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 2
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 2
				,intSourceId			= ''
				,intItemId				= @StickyGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @StickyGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 2.00
				,dblLineTotal			= 20.00
				,intSort				= 2
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 3
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 3
				,intSourceId			= ''
				,intItemId				= @PremiumGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @PremiumGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 3.00
				,dblLineTotal			= 30.00
				,intSort				= 3
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 4
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 4
				,intSourceId			= ''
				,intItemId				= @ColdGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @ColdGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 4.00
				,dblLineTotal			= 40.00
				,intSort				= 4
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 5
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 5
				,intSourceId			= ''
				,intItemId				= @HotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @HotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 5.00
				,dblLineTotal			= 50.00
				,intSort				= 5
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 6
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 6
				,intSourceId			= ''
				,intItemId				= @ManualLotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @ManualLotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 6.00
				,dblLineTotal			= 60.00
				,intSort				= 6
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 7
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 7
				,intSourceId			= ''
				,intItemId				= @SerializedLotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @SerializedLotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 7.00
				,dblLineTotal			= 70.00
				,intSort				= 7
				,intConcurrencyId		= 1

		INSERT INTO dbo.tblICInventoryReceiptItemLot (
				intInventoryReceiptItemId
				,dblQuantity
				,intSort
				,intConcurrencyId
		)
		-- Manual Lot Grains
		-- intInventoryReceiptItemLotId: 1
		SELECT	intInventoryReceiptItemId	= 6
				,dblQuantity				= 7
				,intSort					= 1
				,intConcurrencyId			= 1
		-- intInventoryReceiptItemLotId: 2
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 6
				,dblQuantity				= 3
				,intSort					= 2
				,intConcurrencyId			= 1

		-- Serial Lot Grains
		-- intInventoryReceiptItemLotId: 3
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 7
				,dblQuantity				= 2
				,intSort					= 1
				,intConcurrencyId			= 1

		-- intInventoryReceiptItemLotId: 4
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 7
				,dblQuantity				= 8
				,intSort					= 2
				,intConcurrencyId			= 1
	
	END

	--------------------------------------------------------
	-- Add the INVRCPT-XXXXX2
	-- It has only non-lot items on it 
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'INVRCPT-XXXXX2'
		SET @dtmDate = '01/11/2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @ReceiptType_PurchaseOrder
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
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
			,intNoPackages
			,intPackageTypeId
			,dblExpPackageWeight
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
		)
		-- intInventoryReceiptItemId: 8
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= ''
				,intItemId				= @WetGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @WetGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 1.00
				,dblLineTotal			= 10.00
				,intSort				= 1
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 9
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 2
				,intSourceId			= ''
				,intItemId				= @StickyGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @StickyGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 2.00
				,dblLineTotal			= 20.00
				,intSort				= 2
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 10
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 3
				,intSourceId			= ''
				,intItemId				= @PremiumGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @PremiumGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 3.00
				,dblLineTotal			= 30.00
				,intSort				= 3
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 11
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 4
				,intSourceId			= ''
				,intItemId				= @ColdGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @ColdGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 4.00
				,dblLineTotal			= 40.00
				,intSort				= 4
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 12
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 5
				,intSourceId			= ''
				,intItemId				= @HotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @HotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 5.00
				,dblLineTotal			= 50.00
				,intSort				= 5
				,intConcurrencyId		= 1
	
	END

	--------------------------------------------------------
	-- Add the INVRCPT-XXXXX3
	-- It has only lot items on it 
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'INVRCPT-XXXXX3'
		SET @dtmDate = '01/15/2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @ReceiptType_PurchaseOrder
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
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
			,intNoPackages
			,intPackageTypeId
			,dblExpPackageWeight
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
		)
		-- intInventoryReceiptItemId: 13
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 6
				,intSourceId			= ''
				,intItemId				= @ManualLotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @ManualLotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 6.00
				,dblLineTotal			= 60.00
				,intSort				= 6
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 14
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 7
				,intSourceId			= ''
				,intItemId				= @SerializedLotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @SerializedLotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 7.00
				,dblLineTotal			= 70.00
				,intSort				= 7
				,intConcurrencyId		= 1

		INSERT INTO dbo.tblICInventoryReceiptItemLot (
				intInventoryReceiptItemId
				,dblQuantity
				,intSort
				,intConcurrencyId
		)
		-- Manual Lot Grains
		-- intInventoryReceiptItemLotId: 1
		SELECT	intInventoryReceiptItemId	= 13
				,dblQuantity				= 7
				,intSort					= 1
				,intConcurrencyId			= 1
		-- intInventoryReceiptItemLotId: 2
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 13
				,dblQuantity				= 3
				,intSort					= 2
				,intConcurrencyId			= 1

		-- Serial Lot Grains
		-- intInventoryReceiptItemLotId: 3
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 14
				,dblQuantity				= 2
				,intSort					= 1
				,intConcurrencyId			= 1

		-- intInventoryReceiptItemLotId: 4
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 14
				,dblQuantity				= 8
				,intSort					= 2
				,intConcurrencyId			= 1
	
	END

	--------------------------------------------------------
	-- Add the INVRCPT-XXXXX4
	-- It has NO items on it. 
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'INVRCPT-XXXXX4'
		SET @dtmDate = '01/17/2014'

				-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @ReceiptType_PurchaseOrder
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
		SET @intReceiptNumber = SCOPE_IDENTITY();
	END

	--------------------------------------------------------
	-- Add the INVRCPT-XXXXX5
	-- It has MANUAL lot items on it. 
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'INVRCPT-XXXXX5'
		SET @dtmDate = '01/15/2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @ReceiptType_PurchaseOrder
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
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
			,intNoPackages
			,intPackageTypeId
			,dblExpPackageWeight
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
		)
		-- intInventoryReceiptItemId: 15
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= ''
				,intItemId				= @ManualLotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @ManualLotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 6.00
				,dblLineTotal			= 60.00
				,intSort				= 1
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 16
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 2
				,intSourceId			= ''
				,intItemId				= @ManualLotGrains
				,dblOrderQty			= 20
				,dblOpenReceive			= 20
				,dblReceived			= 0
				,intUnitMeasureId		= @ManualLotGrains_PoundUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 7.00
				,dblLineTotal			= 70.00
				,intSort				= 2
				,intConcurrencyId		= 1

		INSERT INTO dbo.tblICInventoryReceiptItemLot (
				intInventoryReceiptItemId
				,strLotId 
				,dblQuantity
				,dblCost
				,intSort
				,intConcurrencyId
		)
		-- Manual Lot Grains
		-- intInventoryReceiptItemLotId: 1
		SELECT	intInventoryReceiptItemId	= 15
				,strLotId					= 'MANUAL-22X-10000'
				,dblQuantity				= 7
				,dblCost					= 6.10
				,intSort					= 1
				,intConcurrencyId			= 1
		-- intInventoryReceiptItemLotId: 2
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 15
				,strLotId					= 'MANUAL-22X-10000'
				,dblQuantity				= 3
				,dblCost					= 5.90
				,intSort					= 2
				,intConcurrencyId			= 1
		-- intInventoryReceiptItemLotId: 3
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 16
				,strLotId					= 'LOT DE MANUAL X 113-133.108985'
				,dblQuantity				= 20
				,dblCost					= 7.00
				,intSort					= 1
				,intConcurrencyId			= 1
	
	END
	--------------------------------------------------------
	-- Add the INVRCPT-XXXXX6
	-- It has SERIAL lot items on it. 
	--------------------------------------------------------
	BEGIN
		SET @strReceiptNumber = 'INVRCPT-XXXXX6'
		SET @dtmDate = '01/15/2014'

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strReceiptType
				,intLocationId
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strAllocateFreight
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	strReceiptNumber		= @strReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(@dtmDate)
				,strReceiptType			= @ReceiptType_PurchaseOrder
				,intLocationId			= @Default_Location
				,intShipViaId			= @Default_Location
				,intShipFromId			= @Default_Location
				,intReceiverId			= @Default_Location
				,intCurrencyId			= @BaseCurrencyId
				,strAllocateFreight		= 'No' -- Default is No
				,intConcurrencyId		= 1
				,intEntityId			= @intEntityId
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
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
			,intNoPackages
			,intPackageTypeId
			,dblExpPackageWeight
			,dblUnitCost
			,dblLineTotal
			,intSort
			,intConcurrencyId
		)
		-- intInventoryReceiptItemId: 17
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 1
				,intSourceId			= ''
				,intItemId				= @SerializedLotGrains
				,dblOrderQty			= 10
				,dblOpenReceive			= 10
				,dblReceived			= 0
				,intUnitMeasureId		= @SerializedLotGrains_BushelUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 6.00
				,dblLineTotal			= 60.00
				,intSort				= 1
				,intConcurrencyId		= 1
		-- intInventoryReceiptItemId: 18
		UNION ALL 
		SELECT	intInventoryReceiptId	= @intReceiptNumber
				,intLineNo				= 2
				,intSourceId			= ''
				,intItemId				= @SerializedLotGrains
				,dblOrderQty			= 20
				,dblOpenReceive			= 20
				,dblReceived			= 0
				,intUnitMeasureId		= @SerializedLotGrains_PoundUOMId
				,intNoPackages			= 0 -- None found from Purchase Order
				,intPackageTypeId		= NULL -- None found from Purchase Order
				,dblExpPackageWeight	= 0 -- None found from Purchase Order
				,dblUnitCost			= 7.00
				,dblLineTotal			= 70.00
				,intSort				= 2
				,intConcurrencyId		= 1

		INSERT INTO dbo.tblICInventoryReceiptItemLot (
				intInventoryReceiptItemId
				,dblQuantity
				,dblCost
				,intSort
				,intConcurrencyId
		)
		-- Manual Lot Grains
		-- intInventoryReceiptItemLotId: 1
		SELECT	intInventoryReceiptItemId	= 17
				,dblQuantity				= 7
				,dblCost					= 6.10
				,intSort					= 1
				,intConcurrencyId			= 1
		-- intInventoryReceiptItemLotId: 2
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 17
				,dblQuantity				= 3
				,dblCost					= 5.90
				,intSort					= 2
				,intConcurrencyId			= 1
		-- intInventoryReceiptItemLotId: 3
		UNION ALL 
		SELECT	intInventoryReceiptItemId	= 18
				,dblQuantity				= 20
				,dblCost					= 7.00
				,intSort					= 1
				,intConcurrencyId			= 1
	
	END
END 
