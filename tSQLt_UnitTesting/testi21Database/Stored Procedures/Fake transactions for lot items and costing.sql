CREATE PROCEDURE [testi21Database].[Fake transactions for lot items and costing]
AS
BEGIN	
	EXEC testi21Database.[Fake inventory items];
	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

	-- Re-create the index
	CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLot]
		ON [dbo].[tblICInventoryLot]([intInventoryLotId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC, [intItemUOMId] ASC);

	-- Declare the variables for the transaction types
	DECLARE @PurchaseType AS INT = 4
	DECLARE @SalesType AS INT = 5

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

	DECLARE @SubLocationId AS INT = 1
	DECLARE @StorageLocationId AS INT = 2

	-- Fake data for tblICLot
	BEGIN 
		INSERT INTO dbo.tblICLot (
			intItemId
			,intLocationId
			,intItemLocationId
			,intItemUOMId
			,strLotNumber
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,dblLastCost
			,dtmExpiryDate
			,strLotAlias
			,intLotStatusId
			,intParentLotId
			,intSplitFromLotId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerQty
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intVendorId
			,strVendorLotNo
			,intVendorLocationId
			,strVendorLocation
			,strContractNo
			,dtmManufacturedDate
			,ysnReleasedToWarehouse
			,ysnProduced
		)
		SELECT 
			intItemId					= @ManualLotGrains
			,intLocationId				= @Default_Location
			,intItemLocationId			= @ManualLotGrains_DefaultLocation
			,intItemUOMId				= @ManualLotGrains_BushelUOMId
			,strLotNumber				= 'LOT019911'
			,intSubLocationId			= @SubLocationId
			,intStorageLocationId		= @StorageLocationId
			,dblQty						= 100
			,dblLastCost				= 2.50
			,dtmExpiryDate				= '01/14/2024'
			,strLotAlias				= 'lot alias LOT019911'
			,intLotStatusId				= 1
			,intParentLotId				= NULL
			,intSplitFromLotId			= NULL
			,dblWeight					= 250
			,intWeightUOMId				= @ManualLotGrains_PoundUOMId
			,dblWeightPerQty			= (250.00 / 100.00)			
			,strBOLNo					= 'bill of lading'
			,strVessel					= 'vessel'
			,strReceiptNumber			= 'INVRCT-10009'
			,strMarkings				= 'Markings'
			,strNotes					= 'Notes'
			,intVendorId				= NULL
			,strVendorLotNo				= 'Vendor Lot No'
			,intVendorLocationId		= NULL
			,strVendorLocation			= 'Vendor Location'
			,strContractNo				= 'Contract No'
			,dtmManufacturedDate		= GETDATE()
			,ysnReleasedToWarehouse		= 0
			,ysnProduced				= 0
	END


	-- Fake data for tblICInventoryLot
	BEGIN
		INSERT INTO dbo.tblICInventoryLot (
				intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,intLotId 
				,intSubLocationId 
				,intStorageLocationId 
				,dblStockIn 
				,dblStockOut 
				,dblCost 
				,strTransactionId 
				,intTransactionId 
				,dtmCreated 
				,ysnIsUnposted 
				,intCreatedUserId 
				,intConcurrencyId 		
		) 
		SELECT	intItemId				= @ManualLotGrains
				,intItemLocationId		= @ManualLotGrains_DefaultLocation
				,intItemUOMId			= @ManualLotGrains_PoundUOMId
				,intLotId				= 1
				,intSubLocationId		= @SubLocationId
				,intStorageLocationId	= @StorageLocationId
				,dblStockIn				= 250
				,dblStockOut			= 0
				,dblCost				= (100 * 2.50 / 250)
				,strTransactionId		= 'INVRCT-10009'
				,intTransactionId		= 1
				,dtmCreated				= GETDATE()
				,ysnIsUnposted			= 0
				,intCreatedUserId		= 1
				,intConcurrencyId		= 1
	END 

	-- Fake data for item stock table
	BEGIN 
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ManualLotGrains, @ManualLotGrains_DefaultLocation, 250)
	END

	-- Fake data for item stock UOM table
	BEGIN 
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId, dblOnHand) VALUES (@ManualLotGrains,	@ManualLotGrains_DefaultLocation, @SubLocationId, @StorageLocationId, @ManualLotGrains_PoundUOMId, 250)
	END

	-- Fake data for item pricing table
	BEGIN 
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ManualLotGrains, @ManualLotGrains_DefaultLocation, (100 * 2.50 / 250))
	END

	-- Fake data for tblICInventoryTransaction
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (
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
				,intConcurrencyId		
		) 
		SELECT	intItemId				= @ManualLotGrains
				,intItemLocationId		= @ManualLotGrains_DefaultLocation
				,intItemUOMId			= @ManualLotGrains_PoundUOMId
				,dtmDate				= '01/01/2014'
				,dblQty					= 250
				,dblUOMQty				= 1
				,dblCost				= 2.5
				,dblValue				= NULL 
				,dblSalesPrice			= 0
				,intCurrencyId			= NULL 
				,dblExchangeRate		= 1
				,intTransactionId		= 1
				,strTransactionId		= 'INVRCT-10009'
				,strBatchId				= 'BATCH-1'
				,intTransactionTypeId	= 4
				,intLotId				= 1
				,intConcurrencyId		= 1
	END 
END 
