CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLot from positive to positive]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the Lot table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLot]
			ON [dbo].[tblICInventoryLot]([intInventoryLotId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC);

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

		DECLARE @LotId AS INT = 12345

		-- Create a fake data for tblICInventoryLot
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLot
		intItemId   intItemLocationId intLotId	dblStockIn	dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		----------- ----------------- ---------	-----------	------------	---------	---------------- ----------------
		3           3                 12345		100.000000	0.000000		13.000000	1                1					
		3           3                 12345		100.000000	0.000000		14.000000	1                1
		3           3                 12345		100.000000	0.000000		15.000000	1                1
		***************************************************************************************************************************************************************************************************************/

		INSERT INTO dbo.tblICInventoryLot (
			[intItemId]
			,[intItemLocationId]
			,[intLotId]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

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

		-- Create the variables used by uspICIncreaseStockInLot
		DECLARE @intItemId AS INT				= @PremiumGrains
				,@intItemLocationId AS INT		= @BetterHaven
				,@intLotId AS INT				= @LotId
				,@dblQty NUMERIC(18,6)			= 40
				,@dblCost AS NUMERIC(18,6)		= 88.77
				,@intUserId AS INT				= 1
				,@FullQty AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@TotalQtyOffset AS NUMERIC(18,6) = 0			
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@QtyOffset AS NUMERIC(18,6)
				,@NewLotId AS INT 
				,@UpdatedLotId AS INT 
				,@strRelatedTransactionId AS NVARCHAR(40)
				,@intRelatedTransactionId AS INT 

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
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intLotId] = @LotId
				,[dblStockIn] = 40
				,[dblStockOut] = 0
				,[dblCost] = 88.77
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

		/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId intLotId	dblStockIn	dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ---------	-----------	------------	---------	---------------- ----------------
				3           3                 12345		100.000000	0.000000		13.000000	1                1					
				3           3                 12345		100.000000	0.000000		14.000000	1                1
				3           3                 12345		100.000000	0.000000		15.000000	1                1
		new		3           3                 12345		40.000000	0.000000		88.770000	1                1
		***************************************************************************************************************************************************************************************************************/							
	END 
	
	-- Act
	BEGIN 
		-- Initialize the qty that is reduced in each loop inside the while statement 
		SET @FullQty = @dblQty

		DECLARE @intIterationCounter AS INT = 0;	

		-- Repeat call on uspICReduceStockInLot until @dblIncreaseQty is completely distributed to all the available Lot buckets
		WHILE (ISNULL(@dblQty, 0) > 0)
		BEGIN
			SET @intIterationCounter += 1;			
		
			EXEC dbo.uspICIncreaseStockInLot
				@intItemId
				,@intItemLocationId
				,@intLotId
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
				,@NewLotId OUTPUT 
				,@UpdatedLotId OUTPUT 
				,@strRelatedTransactionId OUTPUT 
				,@intRelatedTransactionId OUTPUT 

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Assert that the cost used must be NULL because we are adding a new Lot cost bucket
			EXEC tSQLt.AssertEquals NULL, @CostUsed;

			-- Assert that the remaining qty is NULL
			EXEC tSQLt.AssertEquals NULL, @RemainingQty;

			-- Assert that the Lot id is NULL 
			EXEC tSQLt.AssertEquals NULL, @UpdatedLotId;
			EXEC tSQLt.AssertEquals 4, @NewLotId;
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