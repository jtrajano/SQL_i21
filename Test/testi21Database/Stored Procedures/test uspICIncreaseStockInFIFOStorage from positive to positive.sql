CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInFIFOStorage from positive to positive]
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

		-- Declare the account ids
		DECLARE	 @Inventory_Default AS INT = 1000
				,@CostOfGoods_Default AS INT = 2000
				,@APClearing_Default AS INT = 3000
				,@WriteOffSold_Default AS INT = 4000
				,@RevalueSold_Default AS INT = 5000 
				,@AutoNegative_Default AS INT = 6000
				,@InventoryInTransit_Default AS INT = 7000
				,@AccountReceivable_Default AS INT = 8000
				,@InventoryAdjustment_Default AS INT = 9000
				,@OtherChargeExpense_Default AS INT = 10000
				,@OtherChargeIncome_Default AS INT = 11000
				,@OtherChargeAsset_Default AS INT = 12000
				,@CostAdjustment_Default AS INT = 13000
				,@WorkInProgress_Default AS INT = 14000

				,@Inventory_NewHaven AS INT = 1001
				,@CostOfGoods_NewHaven AS INT = 2001
				,@APClearing_NewHaven AS INT = 3001
				,@WriteOffSold_NewHaven AS INT = 4001
				,@RevalueSold_NewHaven AS INT = 5001
				,@AutoNegative_NewHaven AS INT = 6001
				,@InventoryInTransit_NewHaven AS INT = 7001
				,@AccountReceivable_NewHaven AS INT = 8001
				,@InventoryAdjustment_NewHaven AS INT = 9001
				,@OtherChargeExpense_NewHaven AS INT = 10001
				,@OtherChargeIncome_NewHaven AS INT = 11001
				,@OtherChargeAsset_NewHaven AS INT = 12001
				,@CostAdjustment_NewHaven AS INT = 13001
				,@WorkInProgress_NewHaven AS INT = 14001

				,@Inventory_BetterHaven AS INT = 1002
				,@CostOfGoods_BetterHaven AS INT = 2002
				,@APClearing_BetterHaven AS INT = 3002
				,@WriteOffSold_BetterHaven AS INT = 4002
				,@RevalueSold_BetterHaven AS INT = 5002
				,@AutoNegative_BetterHaven AS INT = 6002
				,@InventoryInTransit_BetterHaven AS INT = 7002
				,@AccountReceivable_BetterHaven AS INT = 8002
				,@InventoryAdjustment_BetterHaven AS INT = 9002
				,@OtherChargeExpense_BetterHaven AS INT = 10002
				,@OtherChargeIncome_BetterHaven AS INT = 11002
				,@OtherChargeAsset_BetterHaven AS INT = 12002
				,@CostAdjustment_BetterHaven AS INT = 13002
				,@WorkInProgress_BetterHaven AS INT = 14002

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOStorage', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the FIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryFIFOStorage]
			ON [dbo].[tblICInventoryFIFOStorage]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOStorageId] ASC);

		-- Create a fake data for tblICInventoryFIFOStorage
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryFIFOStorage
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			3           3                 2014-01-13 00:00:00.000 100.000000                              0.000000                               13.000000                               1                1
			3           3                 2014-01-14 00:00:00.000 100.000000							  0.000000                               14.000000                               1                1
			3           3                 2014-01-15 00:00:00.000 100.000000                              0.000000                               15.000000                               1                1
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryFIFOStorage (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedEntityId]
			,[intConcurrencyId]
		)
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(38, 20)
			,[intCreatedEntityId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(38, 20)
			,[intCreatedEntityId] INT 
			,[intConcurrencyId]	INT
		)
		
		-- Create the variables 
		DECLARE @intItemId AS INT						= @PremiumGrains
				,@intItemLocationId AS INT				= @PremiumGrains_BetterHaven
				,@intItemUOMId AS INT					= @PremiumGrains_BushelUOM
				,@dtmDate AS DATETIME					= 'January 2, 2014'
				,@dblQty NUMERIC(38,20)					= 40 
				,@dblCost AS NUMERIC(38, 20)			= 88.77
				,@intEntityUserSecurityId AS INT		= 1
				,@FullQty AS NUMERIC(38,20)				= 40 
				,@TotalQtyOffset AS NUMERIC(38,20)		= 0 
				,@strTransactionId AS NVARCHAR(40)		= 'newstock-0001'
				,@intTransactionId AS INT				= 1
				,@intTransactionDetailId AS INT			= 1
				,@RemainingQty AS NUMERIC(38,20)		= 40
				,@CostUsed AS NUMERIC(38,20)			
				,@QtyOffset AS NUMERIC(38,20)  
				,@NewFIFOStorageId AS INT  
				,@UpdatedFIFOStorageId AS INT  
				,@strRelatedTransactionId AS NVARCHAR(40) 
				,@intRelatedTransactionId AS INT 
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICIncreaseStockInFIFOStorage
				@intItemId
				,@intItemLocationId 
				,@intItemUOMId 
				,@dtmDate 
				,@dblQty 
				,@dblCost 
				,@intEntityUserSecurityId 
				,@FullQty 
				,@TotalQtyOffset 
				,@strTransactionId 
				,@intTransactionId 
				,@intTransactionDetailId 
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@NewFIFOStorageId OUTPUT 
				,@UpdatedFIFOStorageId OUTPUT 
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT
	END 

	-- Assert
	BEGIN 
		-- Setup the expected values 
		INSERT INTO expected (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedEntityId] 
				,[intConcurrencyId]
		)
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 2, 2014'
				,[dblStockIn] = 40
				,[dblStockOut] = 0
				,[dblCost] = 88.77
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @PremiumGrains_BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOM
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		new		3           3                 2014-01-02 00:00:00.000 40.000000                               0.000000                                88.770000                               1                1
				3           3                 2014-01-13 00:00:00.000 100.000000                              0.000000                                13.000000                               1                1
				3           3                 2014-01-14 00:00:00.000 100.000000                              0.000000                                14.000000                               1                1
				3           3                 2014-01-15 00:00:00.000 100.000000                              0.000000                                15.000000                               1                1
				***************************************************************************************************************************************************************************************************************/							

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedEntityId] 
				,[intConcurrencyId]
		)
		SELECT
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedEntityId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryFIFOStorage
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected

END