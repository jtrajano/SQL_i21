CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLotCustody is successful with positive stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustodyTransaction', @Identity = 1;	

		-- Re-add the clustered index. This is critical for the Lot table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLotInCustody]
			ON [dbo].[tblICInventoryLotInCustody]([intInventoryLotInCustodyId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC, [intItemUOMId] ASC);

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

		-- Create a fake data for tblICInventoryLotInCustody
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLotInCustody
		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		1           1                 12345		60.000000		0.000000		15.000000	1                1
		***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryLotInCustody (
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
				,[dblStockIn] = 60
				,[dblStockOut] = 0
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

		-- Create the variables used by uspICIncreaseStockInLotCustody
		DECLARE @intItemId AS INT					= @WetGrains
				,@intItemLocationId AS INT			= @Default_Location
				,@intItemUOMId AS INT				= @WetGrains_BushelUOMId
				,@intLotId AS INT					= @LotId
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT
				,@dblQty NUMERIC(18,6)				= 10
				,@dblCost AS NUMERIC(18,6)			= 33.19
				,@strTransactionId AS NVARCHAR(40)	= 'NewStock-00001'
				,@intTransactionId AS INT			= 1
				,@intUserId AS INT					= 1
				,@dtmCreated AS DATETIME
				,@dblReduceQty AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6)
				,@NewInventoryLotInCustodyId AS INT 

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
				,[dblStockIn]			= 60
				,[dblStockOut]			= 0
				,[dblCost]				= 15.00
				,[intCreatedUserId]		= @intUserId
				,[intConcurrencyId]		= 1
		UNION ALL 
		SELECT	[intItemId]				= @WetGrains
				,[intItemLocationId]	= @Default_Location
				,[intItemUOMId]			= @WetGrains_BushelUOMId 
				,[intLotId]				= @LotId
				,[dblStockIn]			= 10
				,[dblStockOut]			= 0
				,[dblCost]				= 33.19
				,[intCreatedUserId]		= @intUserId
				,[intConcurrencyId]		= 1


		/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
				1           1                 12345		60.000000		0.000000		15.000000	1                1
				1           1                 12345		10.000000		0.000000		33.190000	1                1
		***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END

	-- Act
	BEGIN 
		-- Add stock into custody table. 
		EXEC [dbo].[uspICIncreaseStockInLotCustody]
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intLotId
			,@intSubLocationId
			,@intStorageLocationId
			,@dblQty
			,@dblCost
			,@strTransactionId
			,@intTransactionId
			,@intUserId
			,@NewInventoryLotInCustodyId OUTPUT 

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
		FROM	dbo.tblICInventoryLotInCustody
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