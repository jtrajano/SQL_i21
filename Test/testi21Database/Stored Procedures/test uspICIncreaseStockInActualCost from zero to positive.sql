﻿CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInActualCost from zero to positive]
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
				,@dtmDate AS DATETIME = 'January 2, 2014'
				,@dblQty NUMERIC(18,6) = 40
				,@dblCost AS NUMERIC(18,6) = 88.77
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
		SELECT	[strActualCostId] = 'ID TO BE SUPPLIED'
				,[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 2, 2014'
				,[dblStockIn] = 40
				,[dblStockOut] = 0
				,[dblCost] = 88.77
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		new		3           3                 2014-01-02 00:00:00.000 40.000000                               0.000000                                88.770000                               1                1
				***************************************************************************************************************************************************************************************************************/							
	END 
	
	-- Act
	BEGIN 
		-- Initialize the qty that is reduced in each loop inside the while statement 
		SET @FullQty = @dblQty

		DECLARE @intIterationCounter AS INT = 0;	

		-- Repeat call on uspICReduceStockInActualCost until @dblIncreaseQty is completely distributed to all the available ActualCost buckets
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

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Assert that the cost used must be NULL because we are adding a new ActualCost cost bucket
			EXEC tSQLt.AssertEquals NULL, @CostUsed;

			-- Assert that the remaining qty is NULL
			EXEC tSQLt.AssertEquals NULL, @RemainingQty;

			-- Assert the ActualCost ids
			EXEC tSQLt.AssertEquals 1, @NewActualCostId;
			EXEC tSQLt.AssertEquals NULL, @UpdatedActualCostId;
		END 

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
		SELECT	[strActualCostId]
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