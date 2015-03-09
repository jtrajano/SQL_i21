CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLot from negative to negative stock]
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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		DECLARE @LotId AS INT = 12345

		-- Create a fake data for tblICInventoryLot
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLot
		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		1           1                 12345		0.000000		60.000000		15.000000	1                1
		***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryLot (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intLotId]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[intItemUOMId] = @WetGrains_BushelUOMId
				,[intLotId] = @LotId
				,[dblStockIn] = 0
				,[dblStockOut] = 60
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

		-- Create the expected and actual tables 
		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
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
			,[intItemUOMId] INT 
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables used by uspICReduceStockInLot
		DECLARE @intItemId AS INT					= @WetGrains
				,@intItemLocationId AS INT			= @Default_Location
				,@intItemUOMId AS INT				= @WetGrains_BushelUOMId
				,@intLotId AS INT					= @LotId
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT
				,@dblSoldQty NUMERIC(18,6)			= -10
				,@dblCost AS NUMERIC(18,6)			= 33.19
				,@strTransactionId AS NVARCHAR(40)	= 'NewStock-00001'
				,@intTransactionId AS INT			= 1
				,@intUserId AS INT					= 1
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
				,[intItemUOMId] 
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT	[intItemId]				= @WetGrains
				,[intItemLocationId]	= @Default_Location
				,[intItemUOMId]			= @WetGrains_BushelUOMId 
				,[intLotId]				= @LotId
				,[dblStockIn]			= 0
				,[dblStockOut]			= 60
				,[dblCost]				= 15.00
				,[intCreatedUserId]		= @intUserId
				,[intConcurrencyId]		= 1
		UNION ALL
		SELECT	[intItemId]				= @WetGrains
				,[intItemLocationId]	= @Default_Location
				,[intItemUOMId]			= @WetGrains_BushelUOMId 
				,[intLotId]				= @LotId
				,[dblStockIn]			= 0
				,[dblStockOut]			= 10
				,[dblCost]				= 33.19
				,[intCreatedUserId]		= @intUserId
				,[intConcurrencyId]		= 1

		/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
				1           1                 12345		0.000000		60.000000		15.000000	1                2
		new		1           1                 12345		0.000000		10.000000		33.190000	1                2
		***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Act
	BEGIN 
		SET @dblReduceQty = @dblSoldQty

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all the available Lot buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 					
			EXEC dbo.uspICReduceStockInLot
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@intLotId
				,@intSubLocationId 
				,@intStorageLocationId 
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@InventoryLotId OUTPUT 

				-- Cost used must be NULL since stock is already negative
				EXEC tSQLt.AssertEquals NULL, @CostUsed;

				-- Qty offset must be NULL 
				EXEC tSQLt.AssertEquals NULL, @QtyOffset;

				-- Lot id must be NULL since stock is negative
				EXEC tSQLt.AssertEquals NULL, @InventoryLotId;

			SET @dblReduceQty = @RemainingQty;
		END 

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
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
				,[intItemUOMId] 
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