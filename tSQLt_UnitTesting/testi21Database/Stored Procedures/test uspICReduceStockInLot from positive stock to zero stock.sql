CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLot from positive stock to zero stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
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
		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		1           1                 12345		100.000000		0.000000		11.440000	1                1
		***************************************************************************************************************************************************************************************************************/

		INSERT INTO dbo.tblICInventoryLot (
			[intItemId]
			,[intItemLocationId]
			,[intLotId]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT	[intItemId]				= @WetGrains
				,[intItemLocationId]	= @Default_Location
				,[intLotId]				= @LotId
				,[dblStockIn]			= 100
				,[dblStockOut]			= 0
				,[dblCost]				= 11.44
				,[intCreatedUserId]		= 1
				,[intConcurrencyId]		= 1

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

		-- Create the variables used by uspICReduceStockInLot
		DECLARE @intItemId AS INT						= @WetGrains
				,@intItemLocationId AS INT				= @Default_Location
				,@intLotId AS INT						= @LotId
				,@dblSoldQty NUMERIC(18,6)				= -100
				,@dblCost AS NUMERIC(18,6) 
				,@strTransactionId AS NVARCHAR(40)		= 'NEWSTOCK-00001'
				,@intTransactionId AS INT				= 1
				,@intUserId AS INT						= 1
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
		SELECT	[intItemId]					= @WetGrains
				,[intItemLocationId]		= @Default_Location
				,[intLotId]					= @LotId
				,[dblStockIn]				= 100
				,[dblStockOut]				= 100
				,[dblCost]					= 11.44
				,[intCreatedUserId]			= 1
				,[intConcurrencyId]			= 2

		/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		upt		1           1                 12345		100.000000		100.000000		11.44000	1                2
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

			-- Assert that the cost used is 11.44
			EXEC tSQLt.AssertEquals 11.44, @CostUsed;

			-- Assert the qty offset is 100
			EXEC tSQLt.AssertEquals 100, @QtyOffset;

			-- Assert the Lot id is 1
			EXEC tSQLt.AssertEquals 1, @InventoryLotId;
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