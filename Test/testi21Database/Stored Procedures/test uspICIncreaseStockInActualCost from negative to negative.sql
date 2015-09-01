CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInActualCost from negative to negative]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryActualCost', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the ActualCost table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryActualCost]
			ON [dbo].[tblICInventoryActualCost]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [strActualCostId] ASC);

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

		-- Create a fake data for tblICInventoryActualCost
			/***************************************************************************************************************************************************************************************************************
			The initial data in tblICInventoryActualCost
			intItemId   intItemLocationId	  dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			3           3                 2014-01-13 00:00:00.000 0.000000                                77.000000                               13.000000                               1                1
			3           3                 2014-01-14 00:00:00.000 0.000000                                56.000000                               14.000000                               1                1
			3           3                 2014-01-15 00:00:00.000 0.000000                                30.000000                               15.000000                               1                1
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryActualCost (
			[strActualCostId]
			,[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
			,[strTransactionId]
			,[intTransactionId]
		)
		-- Sold to negative
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				,[strTransactionId] = 'JanuaryStock-00015'
				,[intTransactionId] = 1

		-- Sold to negative
		UNION ALL 
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				,[strTransactionId] = 'JanuaryStock-00014'
				,[intTransactionId] = 2
		-- Sold to negative
		UNION ALL 
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				,[strTransactionId] = 'JanuaryStock-00013'
				,[intTransactionId] = 3

		CREATE TABLE expected (
			[strActualCostId] NVARCHAR(50)
			,[intItemId] INT 
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
			[strActualCostId] NVARCHAR(50)
			,[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables used by uspICIncreaseStockInActualCost
		DECLARE @strActualCostId AS NVARCHAR(50) = 'ID TO BE SUPPLIED'
				,@intItemId AS INT = @PremiumGrains
				,@intItemLocationId AS INT = @BetterHaven
				,@intItemUOMId AS INT = @PremiumGrains_BushelUOMId
				,@dtmDate AS DATETIME = 'January 16, 2014'
				,@dblQty NUMERIC(18,6) = 100
				,@dblCost AS NUMERIC(18,6) = 22
				,@intUserId AS INT = 1
				,@FullQty AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@TotalQtyOffset AS NUMERIC(18,6) = 0			
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@QtyOffset AS NUMERIC(18,6)
				,@NewActualCostId AS INT 
				,@UpdatedActualCostId AS INT 
				,@strRelatedTransactionId AS NVARCHAR(40)
				,@intRelatedTransactionId AS INT 

		-- Setup the expected values 
		INSERT INTO expected (
				[strActualCostId]
				,[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		-- There is an offset to the negative stock
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 77
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- There is a partial offset to the negative stock
		UNION ALL 
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 23
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- Incoming stock can't offset this negative stock
		UNION ALL 
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		-- Incoming stock is fully consumed by the negative stocks
		UNION ALL 
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
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

		-- Repeat call on uspICReduceStockInActualCost until @dblQty is completely distributed to all the negative ActualCost buckets
		WHILE (ISNULL(@dblQty, 0) > 0)
		BEGIN 		
			SET @intIterationCounter += 1;
								
			EXEC dbo.uspICIncreaseStockInActualCost
				@strActualCostId
				,@intItemId
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
				,@NewActualCostId OUTPUT 
				,@UpdatedActualCostId OUTPUT 
				,@strRelatedTransactionId OUTPUT 
				,@intRelatedTransactionId OUTPUT 

			-- Assert on first pass:
			-- the cost to offset is $13
			-- qty offset is 77
			IF (@intIterationCounter = 1) 
			BEGIN 
				EXEC tSQLt.AssertEquals 13.00, @CostUsed
				EXEC tSQLt.AssertEquals 77, @QtyOffset
				EXEC tSQLt.AssertEquals 3, @UpdatedActualCostId
				EXEC tSQLt.AssertEquals 'JanuaryStock-00013', @strRelatedTransactionId
				EXEC tSQLt.AssertEquals 3, @intRelatedTransactionId
			END 
				
			-- Assert on 2nd pass
			-- the cost to offset is $14
			-- qty offset is 23
			IF (@intIterationCounter = 2) 
			BEGIN 
				EXEC tSQLt.AssertEquals 14.00, @CostUsed
				EXEC tSQLt.AssertEquals 23, @QtyOffset
				EXEC tSQLt.AssertEquals 2, @UpdatedActualCostId			
				EXEC tSQLt.AssertEquals 'JanuaryStock-00014', @strRelatedTransactionId
				EXEC tSQLt.AssertEquals 2, @intRelatedTransactionId

			END 

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)
		END 

		-- Assert that the new id generated for ActualCost is 4
		EXEC tSQLt.AssertEquals 4, @NewActualCostId

		-- Assert that it only takes 2 iterations to complete the stock increase 
		EXEC tSQLt.AssertEquals 2, @intIterationCounter;

		INSERT INTO actual (
				[strActualCostId]
				,[intItemId] 
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
				[strActualCostId]
				,[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryActualCost
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