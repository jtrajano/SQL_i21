﻿CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLIFO from positive to positive]
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
			3           3                 2014-01-15 00:00:00.000 100.000000                              0.000000                               15.000000                               1                1
			3           3                 2014-01-14 00:00:00.000 100.000000							  0.000000                               14.000000                               1                1
			3           3                 2014-01-13 00:00:00.000 100.000000                              0.000000                               13.000000                               1                1
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
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
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
			,[dblCost] NUMERIC(38,20)
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
			,[dblCost] NUMERIC(38,20)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables used by uspICIncreaseStockInLIFO
		DECLARE @intItemId AS INT				= @PremiumGrains
				,@intItemLocationId AS INT		= @BetterHaven
				,@intItemUOMId AS INT			= @PremiumGrains_BushelUOMId
				,@dtmDate AS DATETIME			= 'January 2, 2014'
				,@dblQty NUMERIC(18,6)			= 40
				,@dblCost AS NUMERIC(38,20)		= 88.77
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
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 14, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = 'January 13, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
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
		_m_		intItemId   intItemLocationId     dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
				3           3                 2014-01-15 00:00:00.000 100.000000                              0.000000                                15.000000                               1                1
				3           3                 2014-01-14 00:00:00.000 100.000000                              0.000000                                14.000000                               1                1
				3           3                 2014-01-13 00:00:00.000 100.000000                              0.000000                                13.000000                               1                1
		new		3           3                 2014-01-02 00:00:00.000 40.000000                               0.000000                                88.770000                               1                1
				***************************************************************************************************************************************************************************************************************/							
	END 
	
	-- Act
	BEGIN 
		-- Initialize the qty that is reduced in each loop inside the while statement 
		SET @FullQty = @dblQty

		DECLARE @intIterationCounter AS INT = 0;	

		-- Repeat call on uspICReduceStockInLIFO until @dblIncreaseQty is completely distributed to all the available LIFO buckets
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

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Assert that the cost used must be NULL because we are adding a new LIFO cost bucket
			EXEC tSQLt.AssertEquals NULL, @CostUsed;

			-- Assert that the remaining qty is NULL
			EXEC tSQLt.AssertEquals NULL, @RemainingQty;

			-- Assert that the LIFO id is NULL 
			EXEC tSQLt.AssertEquals NULL, @UpdatedLIFOId;
			EXEC tSQLt.AssertEquals 4, @NewLIFOId;
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