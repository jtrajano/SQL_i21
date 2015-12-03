CREATE PROCEDURE [testi21Database].[test uspICReduceStockInFIFOStorage to failed for negative stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]

		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOStorage', @Identity = 1;
		
		-- Re-add the clustered index. This is critical for the FIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryFIFOStorage]
			ON [dbo].[tblICInventoryFIFOStorage]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOStorageId] ASC);

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Create a fake data for tblICInventoryFIFOStorage
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryFIFOStorage
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			1           1                 2014-01-10 00:00:00.000 100.000000                              0.000000                                10.000000                               1                1
			1           1                 2014-01-11 00:00:00.000 100.000000                              0.000000                                11.000000                               1                1
			1           1                 2014-01-12 00:00:00.000 100.000000                              0.000000                                12.000000                               1                1
			1           1                 2014-01-13 00:00:00.000 100.000000                              0.000000                                13.000000                               1                1
			1           1                 2014-01-14 00:00:00.000 100.000000                              0.000000                                14.000000                               1                1
			1           1                 2014-01-15 00:00:00.000 100.000000                              0.000000                                15.000000                               1                1
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
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @WetGrains_BushelUOMId
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
				,[intItemUOMId] = @WetGrains_BushelUOMId
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
				,[intItemUOMId] = @WetGrains_BushelUOMId
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
				,[intItemUOMId] = @WetGrains_BushelUOMId
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
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 10, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 10.00
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
		DECLARE @intItemId AS INT							= @WetGrains
				,@intItemLocationId AS INT					= @WetGrains_DefaultLocation 
				,@intItemUOMId AS INT						= @WetGrains_BushelUOMId
				,@dtmDate AS DATETIME						= 'January 17, 2014'
				,@dblQty NUMERIC(18,6)						=  -650
				,@dblCost AS NUMERIC(38,20)					= 9.50
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intEntityUserSecurityId AS INT
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@SourceInventoryFIFOStorageId AS INT 

				,@dblReduceQty AS NUMERIC(18,6)

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
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 10, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 10.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 11, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 11.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 12, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 12.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 13.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 14.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @WetGrains_DefaultLocation
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 15.00
				,[intCreatedEntityId] = 1
				,[intConcurrencyId] = 2

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		upt		1           1                 2014-01-10 00:00:00.000 100.000000                              100.000000                              10.000000                               1                2
		upt		1           1                 2014-01-11 00:00:00.000 100.000000                              100.000000                              11.000000                               1                2
		upt		1           1                 2014-01-12 00:00:00.000 100.000000                              100.000000                              12.000000                               1                2
		upt		1           1                 2014-01-13 00:00:00.000 100.000000                              100.000000                              13.000000                               1                2
		upt		1           1                 2014-01-14 00:00:00.000 100.000000                              100.000000                              14.000000                               1                2
		upt 	1           1                 2014-01-15 00:00:00.000 100.000000                              50.000000                               15.000000                               1                1
				***************************************************************************************************************************************************************************************************************/
	END 

	-- Assert for an exception thrown towards the end of the process
	BEGIN 
		EXEC tSQLt.ExpectException
			--@ExpectedMessage = 'Negative stock quantity is not allowed.'
			@ExpectedErrorNumber = 80003
	END

	-- Act
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 
		DECLARE @intIterationCounter AS INT = 0;
		DECLARE @QtyOffset AS NUMERIC(18,6) 

		-- Repeat call on uspICReduceStockInFIFOStorage until @dblReduceQty is completely distributed to all the available fifo buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN
			SET @intIterationCounter += 1;

			EXEC [dbo].[uspICReduceStockInFIFOStorage]
				@intItemId 
				,@intItemLocationId 
				,@intItemUOMId 
				,@dtmDate 
				,@dblReduceQty 
				,@dblCost
				,@strTransactionId 
				,@intTransactionId 
				,@intEntityUserSecurityId 
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@SourceInventoryFIFOStorageId OUTPUT 

			SET @QtyOffset = @dblReduceQty - ISNULL(@RemainingQty, 0) 			

			-- Assert on 1st pass
			IF @intIterationCounter = 1 
			BEGIN 
				-- remaining qty is 550
				EXEC tSQLt.AssertEquals -550, @RemainingQty; 

				-- the cost used is 10.00 
				EXEC tSQLt.AssertEquals 10.00, @CostUsed; 

				-- qty offset is -100 
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 1
				EXEC tSQLt.AssertEquals 6, @SourceInventoryFIFOStorageId; 
			END

			-- Assert on 2nd pass
			IF @intIterationCounter = 2
			BEGIN 
				--EXEC tSQLt.AssertEquals 11.00, @CostUsed; 
				--EXEC tSQLt.AssertEquals -350, @RemainingQty; 

				-- remaining qty is -450
				EXEC tSQLt.AssertEquals -450, @RemainingQty; 

				-- the cost used is 11.00
				EXEC tSQLt.AssertEquals 11.00, @CostUsed; 

				-- qty offset is -100 
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 2
				EXEC tSQLt.AssertEquals 5, @SourceInventoryFIFOStorageId; 
			END

			-- Assert on 3rd pass
			IF @intIterationCounter = 3 
			BEGIN 
				-- remaining qty is -350
				EXEC tSQLt.AssertEquals -350, @RemainingQty; 

				-- the cost used is 12.00
				EXEC tSQLt.AssertEquals 12.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 3
				EXEC tSQLt.AssertEquals 4, @SourceInventoryFIFOStorageId; 
			END

			-- Assert on 4th pass
			IF @intIterationCounter = 4 
			BEGIN 
				-- remaining qty is -250
				EXEC tSQLt.AssertEquals -250, @RemainingQty; 

				-- the cost used is 13.00
				EXEC tSQLt.AssertEquals 13.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 4
				EXEC tSQLt.AssertEquals 3, @SourceInventoryFIFOStorageId; 
			END

			-- Assert on 5th pass
			IF @intIterationCounter = 5 
			BEGIN 
				-- remaining qty is -150
				EXEC tSQLt.AssertEquals -150, @RemainingQty; 

				-- the cost used is 14.00
				EXEC tSQLt.AssertEquals 14.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 5
				EXEC tSQLt.AssertEquals 2, @SourceInventoryFIFOStorageId; 
			END

			-- Assert on 6th pass, the cost used is 15.00 and remaining qty is 0
			IF @intIterationCounter = 6 
			BEGIN 
				-- remaining qty is -50
				EXEC tSQLt.AssertEquals -50, @RemainingQty; 

				-- the cost used is 15.00
				EXEC tSQLt.AssertEquals 15.00, @CostUsed; 

				-- qty offset is -50
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 6
				EXEC tSQLt.AssertEquals 1, @SourceInventoryFIFOStorageId;
			END

			SET @dblReduceQty = @RemainingQty;
		END 

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