CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLotStorage by not allowing negative stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]

		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionStorage', @Identity = 1;	

		-- Re-add the clustered index. This is critical for the Lot table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLotStorage]
			ON [dbo].[tblICInventoryLotStorage]([intInventoryLotStorageId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC, [intItemUOMId] ASC);

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare Item-Locations
		DECLARE @WetGrains_DefaultLocation AS INT = 1
				,@StickyGrains_DefaultLocation AS INT = 2
				,@PremiumGrains_DefaultLocation AS INT = 3
				,@ColdGrains_DefaultLocation AS INT = 4
				,@HotGrains_DefaultLocation AS INT = 5

				,@WetGrains_NewHaven AS INT = 6
				,@StickyGrains_NewHaven AS INT = 7
				,@PremiumGrains_NewHaven AS INT = 8
				,@ColdGrains_NewHaven AS INT = 9
				,@HotGrains_NewHaven AS INT = 10

				,@WetGrains_BetterHaven AS INT = 11
				,@StickyGrains_BetterHaven AS INT = 12
				,@PremiumGrains_BetterHaven AS INT = 13
				,@ColdGrains_BetterHaven AS INT = 14
				,@HotGrains_BetterHaven AS INT = 15

				,@ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17

				,@CornCommodity_DefaultLocation AS INT = 18
				,@CornCommodity_NewHaven AS INT = 19
				,@CornCommodity_BetterHaven AS INT = 20

				,@ManualLotGrains_NewHaven AS INT = 21
				,@SerializedLotGrains_NewHaven AS INT = 22

				,@OtherCharges_DefaultLocation AS INT = 23
				,@SurchargeOtherCharges_DefaultLocation AS INT = 24
				,@SurchargeOnSurcharge_DefaultLocation AS INT = 25
				,@SurchargeOnSurchargeOnSurcharge_DefaultLocation AS INT = 26

				,@OtherCharges_NewHaven AS INT = 27
				,@SurchargeOtherCharges_NewHaven AS INT = 28
				,@SurchargeOnSurcharge_NewHaven AS INT = 29
				,@SurchargeOnSurchargeOnSurcharge_NewHaven AS INT = 30

				,@OtherCharges_BetterHaven AS INT = 31
				,@SurchargeOtherCharges_BetterHaven AS INT = 32
				,@SurchargeOnSurcharge_BetterHaven AS INT = 33
				,@SurchargeOnSurchargeOnSurcharge_BetterHaven AS INT = 34

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		DECLARE @LotId AS INT = 12345

		-- Create a fake data for tblICInventoryLotStorage
		/***************************************************************************************************************************************************************************************************************
		The initial data in tblICInventoryLotStorage
		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
		1           1                 12345		0.000000		60.000000		15.000000	1                1
		***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryLotStorage (
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
				,[intItemLocationId] = @WetGrains_DefaultLocation
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

		-- Create the variables used by uspICReduceStockInLotStorage
		DECLARE @intItemId AS INT					= @WetGrains
				,@intItemLocationId AS INT			= @WetGrains_DefaultLocation
				,@intItemUOMId AS INT				= @WetGrains_BushelUOMId
				,@dtmDate AS DATETIME				= '01/01/2014'
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
				,[intItemLocationId]	= @WetGrains_DefaultLocation
				,[intItemUOMId]			= @WetGrains_BushelUOMId 
				,[intLotId]				= @LotId
				,[dblStockIn]			= 0
				,[dblStockOut]			= 60
				,[dblCost]				= 15.00
				,[intCreatedUserId]		= @intUserId
				,[intConcurrencyId]		= 1


		/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like: 
		_m_		intItemId   intItemLocationId intLotId	dblStockIn		dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- --------	--------------	--------------	-----------	---------------- ----------------
				1           1                 12345		0.000000		60.000000		15.000000	1                2
		***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException
			--@ExpectedMessage = 'Negative stock quantity is not allowed.'
			@ExpectedErrorNumber = 80003
	END

	-- Act
	BEGIN 
		SET @dblReduceQty = @dblSoldQty

		-- Repeat call on uspICReduceStockInLotStorage until @dblReduceQty is completely distributed to all the available Lot buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 					
			EXEC dbo.uspICReduceStockInLotStorage
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
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
				,@InventoryLotId OUTPUT 

				-- Cost used must be NULL since stock is already negative
				EXEC tSQLt.AssertEquals NULL, @CostUsed;

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
		FROM	dbo.tblICInventoryLotStorage
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