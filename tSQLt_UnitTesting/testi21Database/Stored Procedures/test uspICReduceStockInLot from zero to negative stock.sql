CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLot from zero to negative stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;

		-- Re-add the clustered index. This is critical for the Lot table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLot]
			ON [dbo].[tblICInventoryLot]([intInventoryLotId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC);

		-- Create the expected and actual tables 
		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		DECLARE @LotId AS INT = 12345

		-- Create a fake data for tblICInventoryLot
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLot
		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		* No Record 
		***************************************************************************************************************************************************************************************************************/

		-- Create the variables used by uspICReduceStockInLot
		DECLARE @intItemId AS INT					= 1
				,@intItemLocationId AS INT			= 1
				,@intLotId AS INT					= @LotId
				,@dblSoldQty NUMERIC(18,6)			= -10
				,@dblCost AS NUMERIC(18,6)			= 33.19
				,@strTransactionId AS NVARCHAR(40)	= 'NEWSTOCK-00001'
				,@intTransactionId AS INT			= 1
				,@intUserId AS INT = 1
				,@dtmCreated AS DATETIME
				,@dblReduceQty AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6)
				,@QtyOffset AS NUMERIC(18,6)
				,@InventoryLotId AS INT 

		-- Setup the expected values 
		INSERT INTO expected (
				[intItemId] 
				,[intItemLocationId] 
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT	[intItemId]					= @intItemId
				,[intItemLocationId]		= @intItemLocationId
				,[intLotId]					= @intLotId
				,[dblStockIn]				= 0
				,[dblStockOut]				= ABS(@dblSoldQty)
				,[dblCost]					= @dblCost
				,[intCreatedUserId]			= @intUserId
				,[intConcurrencyId]				= 1

		/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		upt		1           1                 12345		0.000000		10.000000		33.19000	1                2
		***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Act
	BEGIN 
		SET @dblReduceQty = @dblSoldQty

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all the available Lot buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 					
			EXEC [dbo].[uspICReduceStockInLot]
				@intItemId
				,@intItemLocationId
				,@intLotId
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@InventoryLotId OUTPUT 

			SET @dblReduceQty = @RemainingQty;

			-- Assert that no cost was used (NULL)
			EXEC tSQLt.AssertEquals NULL, @CostUsed;

			-- Assert Qty offset is NULL
			EXEC tSQLt.AssertEquals NULL, @QtyOffset;

			-- Assert Lot Id is NULL
			EXEC tSQLt.AssertEquals NULL, @InventoryLotId;
		END 

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT
				[intItemId] 
				,[intItemLocationId] 
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryLot
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
