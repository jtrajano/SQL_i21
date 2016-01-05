﻿CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLIFO from zero to negative stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;

		-- Re-add the clustered index. This is critical for the LIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLIFO]
			ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOId] DESC);

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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Create a fake data for tblICInventoryLIFO
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLIFO
		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
		----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		No record.
		***************************************************************************************************************************************************************************************************************/

		-- Create the variables used by uspICReduceStockInLIFO
		DECLARE @intItemId AS INT = 1
				,@intItemLocationId AS INT = 1
				,@intItemUOMId AS INT = 1
				,@dtmDate AS DATETIME = 'January 3, 2014'
				,@dblSoldQty NUMERIC(18,6) = -10
				,@dblCost AS NUMERIC(38,20) = 33.19
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intEntityUserSecurityId AS INT = 1
				,@dtmCreated AS DATETIME
				,@dblReduceQty AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6)
				,@QtyOffset AS NUMERIC(18,6)
				,@LIFOId AS INT 

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
		SELECT	[intItemId] = @intItemId
				,[intItemLocationId] = @intItemLocationId
				,[intItemUOMId] = @intItemUOMId
				,[dtmDate] = @dtmDate
				,[dblStockIn] = 0
				,[dblStockOut] = ABS(@dblSoldQty)
				,[dblCost] = @dblCost
				,[intCreatedEntityId] = @intEntityUserSecurityId
				,[intConcurrencyId] = 1

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedEntityId intConcurrencyId
		-----	----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		new		1           1                 2014-01-03 00:00:00.000 0.000000                                10.000000                               33.190000                               1                1
				***************************************************************************************************************************************************************************************************************/
	END 
	
	-- Act
	BEGIN 
		SET @dblReduceQty = @dblSoldQty

		-- Repeat call on uspICReduceStockInLIFO until @dblReduceQty is completely distributed to all the available LIFO buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 					
			EXEC [dbo].[uspICReduceStockInLIFO]
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
				,@QtyOffset OUTPUT 
				,@LIFOId OUTPUT 

			SET @dblReduceQty = @RemainingQty;

			-- Assert that no cost was used (NULL)
			EXEC tSQLt.AssertEquals NULL, @CostUsed;

			-- Assert Qty offset is NULL
			EXEC tSQLt.AssertEquals NULL, @QtyOffset;

			-- Assert LIFO Id is NULL
			EXEC tSQLt.AssertEquals NULL, @LIFOId;
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
		DROP TABLE expected
END 