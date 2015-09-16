CREATE PROCEDURE [testi21Database].[test uspICReduceStockInActualCost from negative to negative stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
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
			intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
			----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
			1           1                 2014-01-15 00:00:00.000 0.000000                                60.000000                               15.000000                               1                1
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
		)
		SELECT	[strActualCostId] = 'ACTUAL COST ID'
				,[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 60
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

		-- Create the expected and actual tables 
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

		-- Create the variables used by uspICReduceStockInActualCost
		DECLARE @strActualCostId AS NVARCHAR(50) = 'ACTUAL COST ID'
				,@intItemId AS INT = @WetGrains
				,@intItemLocationId AS INT = @Default_Location
				,@intItemUOMId AS INT = @WetGrains_BushelUOMId
				,@dtmDate AS DATETIME = 'January 18, 2014'
				,@dblSoldQty NUMERIC(18,6) = -10
				,@dblCost AS NUMERIC(18,6) = 33.19
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intUserId AS INT = 1
				,@dtmCreated AS DATETIME
				,@dblReduceQty AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6) 
				,@QtyOffset AS NUMERIC(18,6)
				,@ActualCostId AS INT 

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
		SELECT	[strActualCostId] = 'ACTUAL COST ID'
				,[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = 'January 15, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 60
				,[dblCost] = 15.00
				,[intCreatedUserId] = @intUserId
				,[intConcurrencyId] = 1
		UNION ALL
		SELECT	[strActualCostId] = 'ACTUAL COST ID'
				,[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] =  'January 18, 2014'
				,[dblStockIn] = 0
				,[dblStockOut] = 10
				,[dblCost] =  33.19
				,[intCreatedUserId] = @intUserId
				,[intConcurrencyId] = 1

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
				1           1                 2014-01-15 00:00:00.000 0.000000                                60.000000                               15.000000                               1                2
		new		1           1                 2014-01-18 00:00:00.000 0.000000                                10.000000                               33.190000                               1                2
				***************************************************************************************************************************************************************************************************************/
	END 
	
	-- Act
	BEGIN 
		SET @dblReduceQty = @dblSoldQty

		-- Repeat call on uspICReduceStockInActualCost until @dblReduceQty is completely distributed to all the available ActualCost buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 					
			EXEC dbo.uspICReduceStockInActualCost
				@strActualCostId 
				,@intItemId
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
				,@QtyOffset OUTPUT 
				,@ActualCostId OUTPUT 

				-- Cost used must be NULL since stock is already negative
				EXEC tSQLt.AssertEquals NULL, @CostUsed;

				-- Qty offset must be NULL 
				EXEC tSQLt.AssertEquals NULL, @QtyOffset;

				-- ActualCost id must be NULL since stock is negative
				EXEC tSQLt.AssertEquals NULL, @ActualCostId;

			SET @dblReduceQty = @RemainingQty;
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