CREATE PROCEDURE [testi21Database].[test uspICReduceStockInFIFOCustody is successful up to zero stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOInCustody', @Identity = 1;
		
		-- Re-add the clustered index. This is critical for the FIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryFIFOInCustody]
			ON [dbo].[tblICInventoryFIFOInCustody]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOInCustodyId] ASC);

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Create a fake data for tblICInventoryFIFOInCustody
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryFIFOInCustody
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			1           1                 2014-01-10 00:00:00.000 100.000000                              0.000000                                10.000000                               1                1
			1           1                 2014-01-11 00:00:00.000 100.000000                              0.000000                                11.000000                               1                1
			1           1                 2014-01-12 00:00:00.000 100.000000                              0.000000                                12.000000                               1                1
			1           1                 2014-01-13 00:00:00.000 100.000000                              0.000000                                13.000000                               1                1
			1           1                 2014-01-14 00:00:00.000 100.000000                              0.000000                                14.000000                               1                1
			1           1                 2014-01-15 00:00:00.000 100.000000                              0.000000                                15.000000                               1                1
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryFIFOInCustody (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 12, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 12.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 11, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 11.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 10, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 10.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1


		-- Create the expected and actual tables 
		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables 
		DECLARE @intItemId AS INT							= @WetGrains
				,@intItemLocationId AS INT					= @Default_Location
				,@intItemUOMId AS INT						= @WetGrains_BushelUOMId
				,@dtmDate AS DATETIME						= 'January 17, 2014'
				,@dblQty NUMERIC(18,6)						=  -600
				,@dblCost AS NUMERIC(18,6)					= 9.50
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intUserId AS INT
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@SourceInventoryFIFOInCustodyId AS INT 

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
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 10, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 10.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 11, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 11.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 12, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 12.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		UNION ALL
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		upt		1           1                 2014-01-10 00:00:00.000 100.000000                              100.000000                              10.000000                               1                2
		upt		1           1                 2014-01-11 00:00:00.000 100.000000                              100.000000                              11.000000                               1                2
		upt		1           1                 2014-01-12 00:00:00.000 100.000000                              100.000000                              12.000000                               1                2
		upt		1           1                 2014-01-13 00:00:00.000 100.000000                              100.000000                              13.000000                               1                2
		upt		1           1                 2014-01-14 00:00:00.000 100.000000                              100.000000                              14.000000                               1                2
		upt 	1           1                 2014-01-15 00:00:00.000 100.000000                              50.000000                               15.000000                               1                1
				***************************************************************************************************************************************************************************************************************/
	END 

	-- Act
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 
		DECLARE @intIterationCounter AS INT = 0;
		DECLARE @QtyOffset AS NUMERIC(18,6) 

		-- Repeat call on uspICReduceStockInFIFOCustody until @dblReduceQty is completely distributed to all the available fifo buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN
			SET @intIterationCounter += 1;

			EXEC [dbo].[uspICReduceStockInFIFOCustody]
				@intItemId 
				,@intItemLocationId 
				,@intItemUOMId 
				,@dtmDate 
				,@dblReduceQty 
				,@dblCost
				,@strTransactionId 
				,@intTransactionId 
				,@intUserId 
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@SourceInventoryFIFOInCustodyId OUTPUT 

			SET @QtyOffset = @dblReduceQty - ISNULL(@RemainingQty, 0) 			

			-- Assert on 1st pass
			IF @intIterationCounter = 1 
			BEGIN 
				-- remaining qty is 500
				EXEC tSQLt.AssertEquals -500, @RemainingQty; 

				-- the cost used is 10.00 
				EXEC tSQLt.AssertEquals 10.00, @CostUsed; 

				-- qty offset is -100 
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 1
				EXEC tSQLt.AssertEquals 6, @SourceInventoryFIFOInCustodyId; 
			END

			-- Assert on 2nd pass
			IF @intIterationCounter = 2
			BEGIN 
				--EXEC tSQLt.AssertEquals 11.00, @CostUsed; 
				--EXEC tSQLt.AssertEquals -350, @RemainingQty; 

				-- remaining qty is -400
				EXEC tSQLt.AssertEquals -400, @RemainingQty; 

				-- the cost used is 11.00
				EXEC tSQLt.AssertEquals 11.00, @CostUsed; 

				-- qty offset is -100 
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 2
				EXEC tSQLt.AssertEquals 5, @SourceInventoryFIFOInCustodyId; 
			END

			-- Assert on 3rd pass
			IF @intIterationCounter = 3 
			BEGIN 
				-- remaining qty is -300
				EXEC tSQLt.AssertEquals -300, @RemainingQty; 

				-- the cost used is 12.00
				EXEC tSQLt.AssertEquals 12.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 3
				EXEC tSQLt.AssertEquals 4, @SourceInventoryFIFOInCustodyId; 
			END

			-- Assert on 4th pass
			IF @intIterationCounter = 4 
			BEGIN 
				-- remaining qty is -200
				EXEC tSQLt.AssertEquals -200, @RemainingQty; 

				-- the cost used is 13.00
				EXEC tSQLt.AssertEquals 13.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 4
				EXEC tSQLt.AssertEquals 3, @SourceInventoryFIFOInCustodyId; 
			END

			-- Assert on 5th pass
			IF @intIterationCounter = 5 
			BEGIN 
				-- remaining qty is -100
				EXEC tSQLt.AssertEquals -100, @RemainingQty; 

				-- the cost used is 14.00
				EXEC tSQLt.AssertEquals 14.00, @CostUsed; 

				-- qty offset is -100
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 5
				EXEC tSQLt.AssertEquals 2, @SourceInventoryFIFOInCustodyId; 
			END

			-- Assert on 6th pass, the cost used is 15.00 and remaining qty is 0
			IF @intIterationCounter = 6 
			BEGIN 
				-- remaining qty is 0
				EXEC tSQLt.AssertEquals 0, @RemainingQty; 

				-- the cost used is 15.00
				EXEC tSQLt.AssertEquals 15.00, @CostUsed; 

				-- qty offset is -50
				EXEC tSQLt.AssertEquals -100, @QtyOffset; 

				-- fifo id is 6
				EXEC tSQLt.AssertEquals 1, @SourceInventoryFIFOInCustodyId;
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
				,[intCreatedUserId] 
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
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryFIFOInCustody
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