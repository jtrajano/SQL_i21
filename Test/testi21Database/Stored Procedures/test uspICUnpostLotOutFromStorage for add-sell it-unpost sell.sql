﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostLotOutFromStorage for add-sell it-unpost sell]
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
			,@CornCommodity AS INT = 8
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

			,@CornCommodity_DefaultLocation AS INT = 18
			,@CornCommodity_NewHaven AS INT = 19
			,@CornCommodity_BetterHaven AS INT = 20

			,@ManualLotGrains_NewHaven AS INT = 21
			,@SerializedLotGrains_NewHaven AS INT = 22

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

	DECLARE @Corn_BushelUOM AS INT = 43,			@Corn_PoundUOM AS INT = 44,				@Corn_KgUOM AS INT = 45, 
			@Corn_25KgBagUOM AS INT = 46,			@Corn_10LbBagUOM AS INT = 47,			@Corn_TonUOM AS INT = 48

	-- Create the variables for the internal transaction types used by costing. 
	DECLARE @AUTO_NEGATIVE AS INT = 1
	DECLARE @WRITE_OFF_SOLD AS INT = 2
	DECLARE @REVALUE_SOLD AS INT = 3		
	DECLARE @InventoryReceipt AS INT = 4
	DECLARE @InventoryShipment AS INT = 5;

	-- Arrange 
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(20)
		DECLARE @intTransactionId AS INT

		CREATE TABLE actualLotStorage (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(38, 20)
			,intLotId INT 
		)

		CREATE TABLE expectedLotStorage (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(38, 20)
			,intLotId INT 
		)

		CREATE TABLE actualTransactionToReverse (
			intInventoryTransactionStorageId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		CREATE TABLE expectedTransactionToReverse (
			intInventoryTransactionStorageId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		-- Create the temp table 
		CREATE TABLE #tmpInventoryTransactionStockToReverse (
			intInventoryTransactionStorageId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intRelatedTransactionId INT NULL 
			,intTransactionTypeId INT NOT NULL 
		)

		-- Call the fake data stored procedure
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotStorageOut', @Identity = 1;	

		-- Mark all item sa lot items
		UPDATE dbo.tblICItem
		SET strLotTracking = 'Yes - Manual'

		-- Add fake data for tblICInventoryLotStorage
		INSERT INTO dbo.tblICInventoryLotStorage (
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
				,ysnIsUnposted
		)
		SELECT	intItemId					= @WetGrains
				,intItemLocationId			= @WetGrains_DefaultLocation
				,intItemUOMId				= @WetGrains_BushelUOM
				,intLotId					= 12345
				,intSubLocationId			= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId		= @StorageSilo_RM_DL
				,dblStockIn					= 25
				,dblStockOut				= 20			
				,dblCost					= 3.00
				,strTransactionId			= 'InvRcpt-0000001'
				,intTransactionId			= 6
				,ysnIsUnposted				= 0
		UNION ALL 
		SELECT	intItemId					= @WetGrains
				,intItemLocationId			= @WetGrains_DefaultLocation
				,intItemUOMId				= @WetGrains_BushelUOM
				,intLotId					= 12345
				,intSubLocationId			= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId		= @StorageSilo_RM_DL
				,dblStockIn					= 100
				,dblStockOut				= 0
				,dblCost					= 2.75
				,strTransactionId			= 'InvRcpt-0000002'
				,intTransactionId			= 7
				,ysnIsUnposted				= 0

		-- Add fake data for tblICInventoryLotStorageOut
		INSERT INTO tblICInventoryLotStorageOut (
			[intInventoryLotStorageId] 
			,[intInventoryTransactionStorageId] 
			,[intRevalueLotId] 
			,[dblQty] 
			,[dblCostAdjustQty] 
		)
		SELECT 
			[intInventoryLotStorageId]				= 1
			,[intInventoryTransactionStorageId]		= 3
			,[intRevalueLotId]						= NULL 
			,[dblQty]								= 20
			,[dblCostAdjustQty]						= 0

		-- Add fake data for tblICInventoryTransactionStorage
		INSERT INTO dbo.tblICInventoryTransactionStorage (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,intLotId
				,dtmDate
				,dblQty
				,dblCost
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,strBatchId
				,intTransactionTypeId
				,ysnIsUnposted
				,strTransactionForm
		)
		SELECT
				intItemId						= @WetGrains
				,intItemLocationId				= @WetGrains_DefaultLocation
				,intItemUOMId					= @WetGrains_BushelUOM
				,intSubLocationId				= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId			= @StorageSilo_RM_DL
				,intLotId						= 12345
				,dtmDate						= '1/1/2014'
				,dblQty							= 25
				,dblCost						= 3.00
				,intTransactionId				= 6
				,intTransactionDetailId			= NULL 
				,strTransactionId				= 'InvRcpt-0000001'
				,strBatchId						= 'BATCH-0001'
				,intTransactionTypeId			= @InventoryReceipt
				,ysnIsUnposted					= 0
				,strTransactionForm				= 'Inventory Receipt'
		UNION ALL
		SELECT
				intItemId						= @WetGrains
				,intItemLocationId				= @WetGrains_DefaultLocation
				,intItemUOMId					= @WetGrains_BushelUOM
				,intSubLocationId				= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId			= @StorageSilo_RM_DL
				,intLotId						= 12345
				,dtmDate						= '1/2/2014'
				,dblQty							= 100
				,dblCost						= 2.75
				,intTransactionId				= 7
				,intTransactionDetailId			= NULL 
				,strTransactionId				= 'InvRcpt-0000002'
				,strBatchId						= 'BATCH-0002'
				,intTransactionTypeId			= @InventoryReceipt
				,ysnIsUnposted					= 0
				,strTransactionForm				= 'Inventory Receipt'
		UNION ALL
		SELECT
				intItemId						= @WetGrains
				,intItemLocationId				= @WetGrains_DefaultLocation
				,intItemUOMId					= @WetGrains_BushelUOM
				,intSubLocationId				= @Raw_Materials_SubLocation_DefaultLocation
				,intStorageLocationId			= @StorageSilo_RM_DL
				,intLotId						= 12345
				,dtmDate						= '1/10/2014'
				,dblQty							= -20
				,dblCost						= 3.00
				,intTransactionId				= 8
				,intTransactionDetailId			= NULL 
				,strTransactionId				= 'InvShip-0000002'
				,strBatchId						= 'BATCH-0003'
				,intTransactionTypeId			= @InventoryShipment
				,ysnIsUnposted					= 0
				,strTransactionForm				= 'Inventory Shipment'
	END 

	-- Act
	BEGIN 
		-- Call the uspICUnpostLotOutFromStorage
		SET @strTransactionId = 'InvShip-0000002'
		SET @intTransactionId = 8	

		EXEC dbo.uspICUnpostLotOutFromStorage @strTransactionId, @intTransactionId
	END 	

	-- Assert
	BEGIN 
		INSERT INTO expectedLotStorage (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
				,intLotId
		)
		SELECT	strTransactionId = 'InvRcpt-0000001'
				,intTransactionId = 6
				,dblStockIn = 25
				,dblStockOut = 0
				,dblCost = 3.00
				,intLotId = 12345
		UNION ALL 
		SELECT	strTransactionId = 'InvRcpt-0000002'
				,intTransactionId = 7
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.75
				,intLotId = 12345

		-- Setup the expected data for transactions to reverse 
		INSERT INTO expectedTransactionToReverse (
				intInventoryTransactionStorageId
				,intTransactionId
				,strTransactionId 
				,strRelatedTransactionId 
				,intRelatedTransactionId 
				,intTransactionTypeId 
		)
		SELECT 
				intInventoryTransactionStorageId	= 3
				,intTransactionId					= 8
				,strTransactionId					= 'InvShip-0000002'
				,strRelatedTransactionId			= NULL 
				,intRelatedTransactionId			= NULL 
				,intTransactionTypeId				= @InventoryShipment

		-- Get the date from the temporary table. 
		INSERT INTO actualTransactionToReverse (
				intInventoryTransactionStorageId
				,intTransactionId
				,strTransactionId 
				,strRelatedTransactionId 
				,intRelatedTransactionId 
				,intTransactionTypeId 
		)
		SELECT	
				intInventoryTransactionStorageId
				,intTransactionId
				,strTransactionId 
				,strRelatedTransactionId 
				,intRelatedTransactionId 
				,intTransactionTypeId ty
		FROM	#tmpInventoryTransactionStockToReverse
				
		-- Get actual Lot data
		INSERT INTO actualLotStorage (
				strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut
				,dblCost
				,intLotId
		)
		SELECT	strTransactionId
				,intTransactionId
				,dblStockIn
				,dblStockOut		
				,dblCost
				,intLotId
		FROM	dbo.tblICInventoryLotStorage

		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse', 'Failed data on #tmpInventoryTransactionStockToReverse.';
		EXEC tSQLt.AssertEqualsTable 'expectedLotStorage', 'actualLotStorage', 'failed data for lot cost bucket.';		
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualLotStorage') IS NOT NULL 
		DROP TABLE actualLotStorage

	IF OBJECT_ID('expectedLotStorage') IS NOT NULL 
		DROP TABLE expectedLotStorage

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE expectedTransactionToReverse
END