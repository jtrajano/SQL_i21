CREATE PROCEDURE testi21Database.[test uspICPostCosting for one incoming stock and lot is correct]
AS
BEGIN
	-- Declare the variables for grains (item)
	DECLARE @ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			
	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			
	-- Declare the variables for the Item UOM Ids
	DECLARE @ManualLotGrains_BushelUOMId AS INT = 6
			,@SerializedLotGrains_BushelUOMId AS INT = 7
			,@ManualLotGrains_PoundUOMId AS INT = 13
			,@SerializedLotGrains_PoundUOMId AS INT = 14

	-- Declare Item-Locations
	DECLARE @ManualLotGrains_DefaultLocation AS INT = 16
			,@SerializedLotGrains_DefaultLocation AS INT = 17

	DECLARE @SubLocation AS INT = 1
	DECLARE @StorageLocation AS INT = 2

	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for lot items and costing]

		-- Create the expected and actual tables. 
		CREATE TABLE expected (
			[intLotId]					INT 
			,[intItemId]				INT 
			,[intLocationId]			INT 
			,[intItemLocationId]		INT 
			,[intItemUOMId]				INT 
			,[strLotNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intSubLocationId]			INT 
			,[intStorageLocationId]		INT 
			,[dblQty]					NUMERIC(18,6) 
			,[dblLastCost]				NUMERIC(18,6) 
			,[dtmExpiryDate]			DATETIME 
			,[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intLotStatusId]			INT 
			,[intParentLotId]			INT 
			,[intSplitFromLotId]		INT 
			,[dblWeight]				NUMERIC(18,6) 
			,[intWeightUOMId]			INT 
			,[dblWeightPerQty]			NUMERIC(18,6) 
			,[intOriginId]				INT 
			,[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strVessel]				NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[strMarkings]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS 
			,[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS 
			,[intVendorId]				INT 
			,[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intVendorLocationId]		INT NULL 
			,[strVendorLocation]		NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strContractNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,[dtmManufacturedDate]		DATETIME 
			,[ysnReleasedToWarehouse]	BIT 
			,[ysnProduced]				BIT 
			,[dtmDateCreated]			DATETIME 
			,[intCreatedUserId]			INT 
			,[intConcurrencyId]			INT 
		)

		SELECT * INTO actual FROM expected

		DECLARE @InventoryReceipt AS INT = 4	
		DECLARE @InventoryShipment AS INT = 5

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsForPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';
		DECLARE @intUserId AS INT = 1;

		-- Setup the items to post
		INSERT INTO @ItemsForPost (  
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
		SELECT	intItemId				= @ManualLotGrains
				,intItemLocationId		= @ManualLotGrains_DefaultLocation
				,intItemUOMId			= @ManualLotGrains_PoundUOMId
				,dtmDate				= '01/01/2015'
				,dblQty					= -20			
				,dblUOMQty				= 1
				,dblCost				= 0
				,dblSalesPrice			= 0  
				,intCurrencyId			= 1
				,dblExchangeRate		= 1  
				,intTransactionId		= ''
				,strTransactionId		= 'SHIPMENT-00001'
				,intTransactionTypeId	= @InventoryShipment  
				,intLotId				= 1
				,intSubLocationId		= @SubLocation
				,intStorageLocationId	= @StorageLocation

			-- Setup the expected lot data
			INSERT INTO expected 
			SELECT	*
			FROM	dbo.tblICLot

			UPDATE	expected
			SET		dblQty = dblQty - (20.00 / (250.00 / 100.00))
					,dblWeight = 230
	END 	
	
	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries  
		EXEC dbo.uspICPostCosting
			@ItemsForPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intUserId

		INSERT INTO actual 
		SELECT	*
		FROM	dbo.tblICLot
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
