﻿CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLIFOStorage is successful with positive stock]
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

		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOStorage', @Identity = 1;
		
		-- Re-add the clustered index. This is critical for the LIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLIFOStorage]
			ON [dbo].[tblICInventoryLIFOStorage]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOStorageId] DESC);

		-- Create a fake data for tblICInventoryLIFOStorage
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryLIFOStorage
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			1           1                 2014-01-15 00:00:00.000 100.000000                              0.000000                                15.000000                               1                1
			1           1                 2014-01-14 00:00:00.000 100.000000                              0.000000                                14.000000                               1                1
			1           1                 2014-01-13 00:00:00.000 100.000000                              0.000000                                13.000000                               1                1
			1           1                 2014-01-12 00:00:00.000 100.000000                              0.000000                                12.000000                               1                1
			1           1                 2014-01-11 00:00:00.000 100.000000                              0.000000                                11.000000                               1                1
			1           1                 2014-01-10 00:00:00.000 100.000000                              0.000000                                10.000000                               1                1
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryLIFOStorage (
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
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 10, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 10.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 11, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 11.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 12, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 12.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1

		-- Create the expected and actual tables 
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
		DECLARE @intItemId AS INT					= @WetGrains
				,@intItemLocationId AS INT			= @WetGrains_DefaultLocation
				,@intItemUOMId AS INT				= @WetGrains_BushelUOM
				,@dtmDate AS DATETIME				= 'January 17, 2014'
				,@dblSoldQty NUMERIC(38,20)			= -550
				,@dblCost AS NUMERIC(38,20)			= 9.50
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intTransactionDetailId AS INT
				,@intEntityUserSecurityId AS INT	= 1
				,@dtmCreated AS DATETIME
				,@dblReduceQty AS NUMERIC(38,20)	= 0
				,@RemainingQty AS NUMERIC(38,20)	= 0
				,@CostUsed AS NUMERIC(18,6)			= 0
				,@QtyOffset AS NUMERIC(18,6)		= 0
				,@LIFOStorageId AS INT	

	END 

	-- Act
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblSoldQty, 0) 
		DECLARE @intIterationCounter AS INT = 0;

		-- Repeat call on uspICReduceStockInLIFOStorage until @dblReduceQty is completely distributed to all the available LIFO buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN
			SET @intIterationCounter += 1;

			EXEC [dbo].[uspICReduceStockInLIFOStorage]
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intTransactionDetailId
				,@intEntityUserSecurityId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@LIFOStorageId OUTPUT 

			SET @QtyOffset = @dblReduceQty - ISNULL(@RemainingQty, 0) 			

			-- Assert on 1st pass
			IF @intIterationCounter = 1 
			BEGIN 
				-- remaining qty is 450
				EXEC tSQLt.AssertEquals -450, @RemainingQty; 

				-- the cost used is 15.00 
				EXEC tSQLt.AssertEquals 15.00, @CostUsed; 

				-- qty offset is -100 
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 
			END

			-- Assert on 2nd pass
			IF @intIterationCounter = 2
			BEGIN 
				--EXEC tSQLt.AssertEquals 11.00, @CostUsed; 
				--EXEC tSQLt.AssertEquals -350, @RemainingQty; 

				-- remaining qty is -350
				EXEC tSQLt.AssertEquals -350, @RemainingQty; 

				-- the cost used is 14.00
				EXEC tSQLt.AssertEquals 14.00, @CostUsed; 

				-- qty offset is -100 
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 
			END

			-- Assert on 3rd pass
			IF @intIterationCounter = 3 
			BEGIN 
				-- remaining qty is -250
				EXEC tSQLt.AssertEquals -250, @RemainingQty; 

				-- the cost used is 13.00
				EXEC tSQLt.AssertEquals 13.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 
			END

			-- Assert on 4th pass
			IF @intIterationCounter = 4 
			BEGIN 
				-- remaining qty is -150
				EXEC tSQLt.AssertEquals -150, @RemainingQty; 

				-- the cost used is 12.00
				EXEC tSQLt.AssertEquals 12.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 
			END

			-- Assert on 5th pass
			IF @intIterationCounter = 5 
			BEGIN 
				-- remaining qty is -50
				EXEC tSQLt.AssertEquals -50, @RemainingQty; 

				-- the cost used is 11.00
				EXEC tSQLt.AssertEquals 11.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 
			END

			-- Assert on 6th pass, the cost used is 15.00 and remaining qty is 0
			IF @intIterationCounter = 6 
			BEGIN 
				-- remaining qty is 0
				EXEC tSQLt.AssertEquals 0, @RemainingQty; 

				-- the cost used is 10.00
				EXEC tSQLt.AssertEquals 10.00, @CostUsed; 

				-- qty offset is -50
				EXEC tSQLt.AssertEquals -50, @QtyOffset; 
			END

			SET @dblReduceQty = @RemainingQty;
		END 
	END 

	-- One more assert
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
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 15.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 14.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 13.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 12, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 12.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 11, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 11.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOM
				,[dtmDate] = 'January 10, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 50
				,[dblCost] = 10.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		upt 	1           1                 2014-01-15 00:00:00.000 100.000000                              100.000000                              15.000000                               1                2
		upt		1           1                 2014-01-14 00:00:00.000 100.000000                              100.000000                              14.000000                               1                2
		upt		1           1                 2014-01-13 00:00:00.000 100.000000                              100.000000                              13.000000                               1                2
		upt		1           1                 2014-01-12 00:00:00.000 100.000000                              100.000000                              12.000000                               1                2
		upt		1           1                 2014-01-11 00:00:00.000 100.000000                              100.000000                              11.000000                               1                2
		upt		1           1                 2014-01-10 00:00:00.000 100.000000                              50.000000                               10.000000                               1                2
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
		FROM	dbo.tblICInventoryLIFOStorage
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