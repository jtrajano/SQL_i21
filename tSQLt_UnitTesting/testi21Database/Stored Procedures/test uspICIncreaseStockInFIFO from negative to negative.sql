CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInFIFO from negative to negative]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the FIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryFIFO]
			ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOId] ASC);

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

		-- Create a fake data for tblICInventoryFIFO
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryFIFO
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			3           3                 2014-01-13 00:00:00.000 0.000000                                77.000000                               13.000000                               1                1
			3           3                 2014-01-14 00:00:00.000 0.000000                                56.000000                               14.000000                               1                1
			3           3                 2014-01-15 00:00:00.000 0.000000                                30.000000                               15.000000                               1                1
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryFIFO (
			[intItemId]
			,[intItemLocationId]
			,[dtmDate]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		-- Sold to negative
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		-- Sold to negative
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		-- Sold to negative
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
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
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables used by uspICIncreaseStockInFIFO
		DECLARE @intItemId AS INT				= @PremiumGrains
				,@intItemLocationId AS INT		= @BetterHaven
				,@dtmDate AS DATETIME			= 'January 16, 2014'
				,@dblQty NUMERIC(18,6)			= 100
				,@dblCost AS NUMERIC(18,6)		= 22
				,@intUserId AS INT				= 1
				,@FullQty AS NUMERIC(18,6)
				,@TotalQtyOffset AS NUMERIC(18,6) = 0			
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@QtyOffset AS NUMERIC(18,6)
				,@NewFifoId AS INT 
				,@UpdatedFifoId AS INT 

		-- Setup the expected values 
		INSERT INTO expected (
				[intItemId] 
				,[intItemLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		-- There is an offset to the negative stock
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 77
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- There is a partial offset to the negative stock
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 23
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- Incoming stock can't offset this negative stock
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		-- Incoming stock is fully consumed by the negative stocks
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 16, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 22
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				
				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		upt		3           3                 2014-01-13 00:00:00.000 77.000000                               77.000000                               13.000000                               1                2
		upt		3           3                 2014-01-14 00:00:00.000 23.000000                               56.000000                               14.000000                               1                2
				3           3                 2014-01-15 00:00:00.000 0.000000                                30.000000                               15.000000                               1                1
		new		3           3                 2014-01-16 00:00:00.000 100.000000                              100.000000                              22.000000                               1                1
				***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Act
	BEGIN 
		-- Initialize the full qty. 
		SET @FullQty = @dblQty

		DECLARE @intIterationCounter AS INT = 0;

		-- Repeat call on uspICReduceStockInFIFO until @dblQty is completely distributed to all the negative fifo buckets
		WHILE (ISNULL(@dblQty, 0) > 0)
		BEGIN 		
			SET @intIterationCounter += 1;
								
			EXEC dbo.uspICIncreaseStockInFIFO
				@intItemId
				,@intItemLocationId
				,@dtmDate
				,@dblQty
				,@dblCost
				,@intUserId
				,@FullQty
				,@TotalQtyOffset
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@NewFifoId OUTPUT 
				,@UpdatedFifoId OUTPUT 

			-- Assert on first pass:
			-- the cost to offset is $13
			-- qty offset is 77
			IF (@intIterationCounter = 1) 
			BEGIN 
				EXEC tSQLt.AssertEquals 13.00, @CostUsed
				EXEC tSQLt.AssertEquals 77, @QtyOffset
				EXEC tSQLt.AssertEquals 3, @UpdatedFifoId
			END 
				
			-- Assert on 2nd pass
			-- the cost to offset is $14
			-- qty offset is 23
			IF (@intIterationCounter = 2) 
			BEGIN 
				EXEC tSQLt.AssertEquals 14.00, @CostUsed
				EXEC tSQLt.AssertEquals 23, @QtyOffset
				EXEC tSQLt.AssertEquals 2, @UpdatedFifoId			
			END 

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)
		END 

		-- Assert that the new id generated for fifo is 4
		EXEC tSQLt.AssertEquals 4, @NewFifoId

		-- Assert that it only takes 2 iterations to complete the stock increase 
		EXEC tSQLt.AssertEquals 2, @intIterationCounter;

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
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
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryFIFO
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