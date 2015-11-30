﻿CREATE PROCEDURE [testi21Database].[test uspICPostCostAdjustmentOnLotCosting, Receive Stocks, Cost Adjust]
AS
BEGIN
	-- Create the fake data
	BEGIN 
		-- Create the CONSTANT variables for the costing methods
		DECLARE @AVERAGECOST AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4 	
				,@ACTUALCOST AS INT = 5		
	
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7
				,@CornCommodity AS INT = 8
				,@OtherCharges AS INT = 9
				,@SurchargeOtherCharges AS INT = 10
				,@SurchargeOnSurcharge AS INT = 11
				,@SurchargeOnSurchargeOnSurcharge AS INT = 12
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

				,@OtherCharges_DefaultLocation AS INT = 23
				,@SurchargeOtherCharges_DefaultLocation AS INT = 24
				,@SurchargeOnSurcharge_DefaultLocation AS INT = 25
				,@SurchargeOnSurchargeOnSurcharge_DefaultLocation AS INT = 26

				,@OtherCharges_NewHaven AS INT = 27
				,@SurchargeOtherCharges_NewHaven AS INT = 28
				,@SurchargeOnSurcharge_NewHaven AS INT = 29
				,@SurchargeOnSurchargeOnSurcharge_NewHaven AS INT = 30

				,@OtherCharges_BetterHaven AS INT = 31
				,@SurchargeOtherCharges_BetterHaven AS INT = 32
				,@SurchargeOnSurcharge_BetterHaven AS INT = 33
				,@SurchargeOnSurchargeOnSurcharge_BetterHaven AS INT = 34

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

		DECLARE @OtherCharges_PoundUOM AS INT = 49
		DECLARE @SurchargeOtherCharges_PoundUOM AS INT = 50
		DECLARE @SurchargeOnSurcharge_PoundUOM AS INT = 51
		DECLARE @SurchargeOnSurchargeOnSurcharge_PoundUOM AS INT = 52

		DECLARE @UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'
				,@UNIT_TYPE_Packed AS NVARCHAR(50) = 'Packed'

		DECLARE @Lot_0001 AS INT = 1
				,@Lot_0002 AS INT = 2
				,@Lot_0003 AS INT = 3
				,@Lot_0004 AS INT = 4
				,@Lot_0005 AS INT = 5
				,@Lot_0006 AS INT = 6
				,@Lot_0007 AS INT = 7

		DECLARE @LotNumber_0001 AS NVARCHAR(50) = 'LOT-0001'
				,@LotNumber_0002 AS NVARCHAR(50) = 'LOT-0002'
				,@LotNumber_0003 AS NVARCHAR(50) = 'LOT-0003'
				,@LotNumber_0004 AS NVARCHAR(50) = 'LOT-0004'
				,@LotNumber_0005 AS NVARCHAR(50) = 'LOT-0005'
				,@LotNumber_0006 AS NVARCHAR(50) = 'LOT-0006'
				,@LotNumber_0007 AS NVARCHAR(50) = 'LOT-0007'

		-- Create the fake data
		EXEC [testi21Database].[Fake data for cost adjustment]
			@intCostingMethod = @LOTCOST
	END 

	-- Arrange 
	BEGIN 
		-- Declare the variables for the transaction types
		DECLARE @PurchaseType AS INT = 4
				,@SalesType AS INT = 5
				,@CostAdjustmentType AS INT = 22
				,@BillType AS INT = 23

		-- Declare the cost types
		DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
				,@COST_ADJ_TYPE_New_Cost AS INT = 2

		-- Declare the variables to check the average cost. 
		DECLARE @dblAverageCost_Expected AS NUMERIC(38,20)
		DECLARE @dblAverageCost_Actual AS NUMERIC(38,20)
		
		-- Declare the variables used in  uspICPostCostAdjustmentOnLotCosting
		DECLARE @dtmDate AS DATETIME						= 'January 10, 2014'
				,@intItemId AS INT							= @WetGrains
				,@intItemLocationId AS INT					= @WetGrains_DefaultLocation
				,@intSubLocationId AS INT					= NULL 
				,@intStorageLocationId AS INT				= NULL 
				,@intItemUOMId AS INT						= @WetGrains_BushelUOM
				,@dblQty AS NUMERIC(18,6)					= 40
				,@dblNewCost AS NUMERIC(38,20)				= 37.261
				,@intTransactionId AS INT					= 1
				,@intTransactionDetailId AS INT				= 1
				,@strTransactionId AS NVARCHAR(20)			= 'BILL-10001'
				,@intSourceTransactionId AS INT				= 1
				,@intSourceTransactionDetailId AS INT		= 1
				,@strSourceTransactionId AS NVARCHAR(20)	= 'PURCHASE-100000'
				,@strBatchId AS NVARCHAR(20)				= 'BATCH-10293'
				,@intTransactionTypeId AS INT				= @CostAdjustmentType
				,@intCurrencyId AS INT						= 1 
				,@dblExchangeRate AS NUMERIC(38,20)			= 1
				,@intUserId AS INT							= 1 

		CREATE TABLE expected (
			[intInventoryTransactionId] INT NOT NULL
			,[intItemId] INT NOT NULL
			,[intItemLocationId] INT NOT NULL
			,[intItemUOMId] INT NULL
			,[intSubLocationId] INT NULL
			,[intStorageLocationId] INT NULL
			,[dtmDate] DATETIME NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
			,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dblValue] NUMERIC(18, 6) NULL
			,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[intCurrencyId] INT NULL
			,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL
			,[intTransactionId] INT NOT NULL
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionDetailId] INT NULL
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionTypeId] INT NOT NULL
			,[intLotId] INT NULL
			,[ysnIsUnposted] BIT NULL
			,[intRelatedInventoryTransactionId] INT NULL
			,[intRelatedTransactionId] INT NULL
			,[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
			,[intCostingMethod] INT NULL
		)

		CREATE TABLE actual (
			[intInventoryTransactionId] INT NOT NULL
			,[intItemId] INT NOT NULL
			,[intItemLocationId] INT NOT NULL
			,[intItemUOMId] INT NULL
			,[intSubLocationId] INT NULL
			,[intStorageLocationId] INT NULL
			,[dtmDate] DATETIME NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
			,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dblValue] NUMERIC(18, 6) NULL
			,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[intCurrencyId] INT NULL
			,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL
			,[intTransactionId] INT NOT NULL
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionDetailId] INT NULL
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionTypeId] INT NOT NULL
			,[intLotId] INT NULL
			,[ysnIsUnposted] BIT NULL
			,[intRelatedInventoryTransactionId] INT NULL
			,[intRelatedTransactionId] INT NULL
			,[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
			,[intCostingMethod] INT NULL
		)

		CREATE TABLE expectedInventoryLotCostAdjustmentLog (
			[intInventoryLotId] INT NOT NULL 
			,[intInventoryCostAdjustmentTypeId] INT NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dtmCreated] DATETIME NULL 
			,[intCreatedUserId] INT NULL 
			,[intConcurrencyId] INT NOT NULL DEFAULT 1 
		)

		CREATE TABLE actualInventoryLotCostAdjustmentLog (
			[intInventoryLotId] INT NOT NULL 
			,[intInventoryCostAdjustmentTypeId] INT NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dtmCreated] DATETIME NULL 
			,[intCreatedUserId] INT NULL 
			,[intConcurrencyId] INT NOT NULL DEFAULT 1 
		)
	END 

	-- Arrange the costing method
	BEGIN 
		UPDATE dbo.tblICItemLocation
		SET intCostingMethod = @LOTCOST

		UPDATE dbo.tblICInventoryTransaction
		SET intCostingMethod = @LOTCOST
	END 

	-- Act 
	BEGIN 
		EXEC dbo.uspICPostCostAdjustmentOnLotCosting
			@dtmDate
			,@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,@dblQty
			,@dblNewCost
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@intSourceTransactionId
			,@intSourceTransactionDetailId
			,@strSourceTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intCurrencyId
			,@dblExchangeRate
			,@intUserId
	END 

	-- Get the actual data 
	BEGIN 
		INSERT INTO actual (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCostingMethod]
		)
		SELECT	[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCostingMethod]
		FROM	tblICInventoryTransaction
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId

		INSERT INTO actualInventoryLotCostAdjustmentLog (
				[intInventoryLotId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty] 
				,[dblCost]
		)
		SELECT [intInventoryLotId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty] 
				,[dblCost]
		FROM	dbo.tblICInventoryLotCostAdjustmentLog
	END

	-- Setup the expected data. 
	BEGIN 
		INSERT INTO expected (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCostingMethod] 
		)
		SELECT	[intInventoryTransactionId] = 1
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 1, 2014'
				,[dblQty]					= 30
				,[dblCost]					= 22.00
				,[dblValue]					= 0 
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'PURCHASE-100000'
				,[strBatchId]				= 'BATCH-100000'
				,[intTransactionTypeId]		= @PurchaseType
				,[intLotId]					= @Lot_0001 
				,[intCostingMethod]			= @LOTCOST
		UNION ALL
		SELECT	[intInventoryTransactionId] = 2
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 1, 2014'
				,[dblQty]					= 30
				,[dblCost]					= 22.00
				,[dblValue]					= 0 
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'PURCHASE-100000'
				,[strBatchId]				= 'BATCH-100000'
				,[intTransactionTypeId]		= @PurchaseType
				,[intLotId]					= @Lot_0002 
				,[intCostingMethod]			= @LOTCOST
		UNION ALL
		SELECT	[intInventoryTransactionId] = 3
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 1, 2014'
				,[dblQty]					= 40
				,[dblCost]					= 22.00
				,[dblValue]					= 0 
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'PURCHASE-100000'
				,[strBatchId]				= 'BATCH-100000'
				,[intTransactionTypeId]		= @PurchaseType
				,[intLotId]					= @Lot_0003 
				,[intCostingMethod]			= @LOTCOST
		UNION ALL 
		SELECT	[intInventoryTransactionId] = 8
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 10, 2014'
				,[dblQty]					= 0
				,[dblCost]					= 0
				,[dblValue]					= 30 * (37.261 - 22.00)
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'BILL-10001'
				,[strBatchId]				= 'BATCH-10293'
				,[intTransactionTypeId]		= @CostAdjustmentType
				,[intLotId]					= @Lot_0001 
				,[intCostingMethod]			= @LOTCOST
		UNION ALL 
		SELECT	[intInventoryTransactionId] = 9
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 10, 2014'
				,[dblQty]					= 0
				,[dblCost]					= 0
				,[dblValue]					= 10 * (37.261 - 22.00)
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'BILL-10001'
				,[strBatchId]				= 'BATCH-10293'
				,[intTransactionTypeId]		= @CostAdjustmentType
				,[intLotId]					= @Lot_0002 
				,[intCostingMethod]			= @LOTCOST

		INSERT INTO expectedInventoryLotCostAdjustmentLog (
				[intInventoryLotId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty] 
				,[dblCost]
		)
		-- Log for Original Cost:
		SELECT 			
				[intInventoryLotId] = 1
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Original_Cost
				,[dblQty] = 30
				,[dblCost] = 22.00
		UNION ALL 
		SELECT 			
				[intInventoryLotId] = 2
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Original_Cost
				,[dblQty] = 30
				,[dblCost] = 22.00
		-- Log for New Cost: 
		UNION ALL 
		SELECT 			
				[intInventoryLotId] = 1
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_New_Cost
				,[dblQty] = 30.00
				,[dblCost] = 37.261
		UNION ALL 
		SELECT 			
				[intInventoryLotId] = 2
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_New_Cost
				,[dblQty] = 10.00
				,[dblCost] = 37.261
	END 

	-- Assert
	BEGIN
		-- Assert the expected data for tblICInventoryTransaction is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual', 'Failed to create the expected Inventory Transaction.';
		
		-- Assert the expected data for tblICInventoryLotCostAdjustmentLog is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expectedInventoryLotCostAdjustmentLog', 'actualInventoryLotCostAdjustmentLog', 'Failed to create the expected Lot Cost Adjustment Lot.'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
		
	IF OBJECT_ID('expectedInventoryLotCostAdjustmentLog') IS NOT NULL 
		DROP TABLE dbo.expectedInventoryLotCostAdjustmentLog
		
	IF OBJECT_ID('actualInventoryLotCostAdjustmentLog') IS NOT NULL 
		DROP TABLE dbo.actualInventoryLotCostAdjustmentLog
END