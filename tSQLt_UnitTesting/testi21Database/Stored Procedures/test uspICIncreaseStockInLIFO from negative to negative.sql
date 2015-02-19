CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLIFO from negative to negative]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the LIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLIFO]
			ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOId] DESC);

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

		-- Create a fake data for tblICInventoryLIFO
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryLIFO
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			3           3                 2014-01-15 00:00:00.000 0.000000                                30.000000                               15.000000                               1                1
			3           3                 2014-01-14 00:00:00.000 0.000000                                56.000000                               14.000000                               1                1
			3           3                 2014-01-13 00:00:00.000 0.000000                                77.000000                               13.000000                               1                1				
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryLIFO (
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
		-- Sold to negative
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
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
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
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
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
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

		-- Create the variables used by uspICIncreaseStockInLIFO
		DECLARE @intItemId AS INT				= @PremiumGrains
				,@intItemLocationId AS INT		= @BetterHaven
				,@intItemUOMId AS INT			= @PremiumGrains_BushelUOMId
				,@dtmDate AS DATETIME			= 'January 16, 2014'
				,@dblQty NUMERIC(18,6)			= 100
				,@dblCost AS NUMERIC(18,6)		= 22
				,@intUserId AS INT				= 1
				,@FullQty AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@TotalQtyOffset AS NUMERIC(18,6) = 0			
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@QtyOffset AS NUMERIC(18,6)
				,@NewLIFOId AS INT 
				,@UpdatedLIFOId AS INT 
				,@strRelatedTransactionId AS NVARCHAR(40)
				,@intRelatedTransactionId AS INT 

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
		-- Incoming stock is fully consumed by the negative stocks
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 16, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 22
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		-- There is a full offset to the negative stock
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 30
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- There is a full offset to the negative stock
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 56
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- There is a partial offset to the negative stock
		UNION ALL 		
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 14
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
				
				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId     dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		new		3           3                 2014-01-16 00:00:00.000 100.000000                              100.000000                              22.000000                               1                1
		upt		3           3                 2014-01-15 00:00:00.000 30.000000                               30.000000                               15.000000                               1                1
		upt		3           3                 2014-01-14 00:00:00.000 56.000000                               56.000000                               14.000000                               1                1
		upt		3           3                 2014-01-13 00:00:00.000 14.000000                               77.000000                               13.000000                               1                1				
				***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Act
	BEGIN 
		-- Initialize the full qty. 
		SET @FullQty = @dblQty

		DECLARE @intIterationCounter AS INT = 0;

		-- Repeat call on uspICReduceStockInLIFO until @dblQty is completely distributed to all the negative LIFO buckets
		WHILE (ISNULL(@dblQty, 0) > 0)
		BEGIN 		
			SET @intIterationCounter += 1;
								
			EXEC dbo.uspICIncreaseStockInLIFO
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblQty
				,@dblCost
				,@intUserId
				,@FullQty
				,@TotalQtyOffset
				,@strTransactionId
				,@intTransactionId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@NewLIFOId OUTPUT 
				,@UpdatedLIFOId OUTPUT 
				,@strRelatedTransactionId OUTPUT 
				,@intRelatedTransactionId OUTPUT 

			-- Assert on first pass:
			-- the cost to offset is $15
			-- qty offset is 30
			IF (@intIterationCounter = 1) 
			BEGIN 
				EXEC tSQLt.AssertEquals 15.00, @CostUsed
				EXEC tSQLt.AssertEquals 30, @QtyOffset
				EXEC tSQLt.AssertEquals 1, @UpdatedLIFOId
			END 
				
			-- Assert on 2nd pass
			-- the cost to offset is $14
			-- qty offset is 56
			IF (@intIterationCounter = 2) 
			BEGIN 
				EXEC tSQLt.AssertEquals 14.00, @CostUsed
				EXEC tSQLt.AssertEquals 56, @QtyOffset
				EXEC tSQLt.AssertEquals 2, @UpdatedLIFOId			
			END 

			-- Assert on 3rd pass
			-- the cost to offset is $13
			-- qty offset is 14
			IF (@intIterationCounter = 3) 
			BEGIN 
				EXEC tSQLt.AssertEquals 13.00, @CostUsed
				EXEC tSQLt.AssertEquals 14, @QtyOffset
				EXEC tSQLt.AssertEquals 3, @UpdatedLIFOId			
			END 

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)
		END 

		-- Assert that the new id generated for LIFO is 4
		EXEC tSQLt.AssertEquals 4, @NewLIFOId

		-- Assert that it only takes 2 iterations to complete the stock increase 
		EXEC tSQLt.AssertEquals 3, @intIterationCounter;

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
		FROM	dbo.tblICInventoryLIFO
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