CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLIFO from zero to negative stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;

		-- Re-add the clustered index. This is critical for the LIFO table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLIFO]
			ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intLocationId] ASC, [intInventoryLIFOId] DESC);

		-- Create the expected and actual tables 
		CREATE TABLE expected (
			[intItemId] INT 
			,[intLocationId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intLocationId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create a fake data for tblICInventoryLIFO
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLIFO
		intItemId   intLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
		----------- ----------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- ---------------- ----------------
		No record.
		***************************************************************************************************************************************************************************************************************/

		-- Create the variables used by uspICReduceStockInLIFO
		DECLARE @intItemId AS INT = 1
				,@intLocationId AS INT = 1
				,@dtmDate AS DATETIME = 'January 3, 2014'
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
				,@LIFOId AS INT 

		-- Setup the expected values 
		INSERT INTO expected (
				[intItemId] 
				,[intLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT	[intItemId] = @intItemId
				,[intLocationId] = @intLocationId
				,[dtmDate] = @dtmDate
				,[dblStockIn] = 0
				,[dblStockOut] = ABS(@dblSoldQty)
				,[dblCost] = @dblCost
				,[intCreatedUserId] = @intUserId
				,[intConcurrencyId] = 1

				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intLocationId dtmDate                 dblStockIn                              dblStockOut                             dblCost                                 intCreatedUserId intConcurrencyId
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
				,@intLocationId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
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
				,[intLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT
				[intItemId] 
				,[intLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryLIFO
		WHERE	intItemId = @intItemId
				AND intLocationId = @intLocationId
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
