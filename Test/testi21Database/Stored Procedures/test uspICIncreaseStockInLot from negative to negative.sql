﻿CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLot from negative to negative]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the Lot table because it arranges the data physically by that order. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLot]
			ON [dbo].[tblICInventoryLot]([dtmDate] ASC, [intInventoryLotId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC);

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
			intItemId   intItemLocationId intLotId	dblStockIn	dblStockOut		dblCost		intCreatedUserId intConcurrencyId
			----------- ----------------- ---------	-----------	------------	---------	---------------- ----------------
			3           3                 12345		0.000000	30.000000		15.000000	1                1
			3           3                 12345		0.000000	56.000000		14.000000	1                1
			3           3                 12345		0.000000	77.000000		13.000000	1                1					
			***************************************************************************************************************************************************************************************************************/
		INSERT INTO dbo.tblICInventoryLot (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[intLotId]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
			,[strTransactionId]
			,[intTransactionId]
		)
		-- Sold to negative
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/01/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 0
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				,[strTransactionId] = 'JanuaryStock-00015'
				,[intTransactionId] = 1

		-- Sold to negative
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/02/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 0
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				,[strTransactionId] = 'JanuaryStock-00014'
				,[intTransactionId] = 2
		-- Sold to negative
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/03/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 0
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				,[strTransactionId] = 'JanuaryStock-00013'
				,[intTransactionId] = 3

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[dtmDate] DATETIME
			,[intLotId] INT
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
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(38,20)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables used by uspICIncreaseStockInLot
		DECLARE @intItemId AS INT = @PremiumGrains
				,@intItemLocationId AS INT = @BetterHaven
				,@intItemUOMId AS INT = @PremiumGrains_BushelUOMId
				,@dtmDate AS DATETIME = '01/04/2014'
				,@intLotId AS INT = @LotId
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT
				,@dblQty NUMERIC(18,6) = 100
				,@dblCost AS NUMERIC(38,20) = 22
				,@intUserId AS INT = 1
				,@FullQty AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40) = 'IncomingStock-00001'
				,@intTransactionId AS INT = 4
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
				,[intItemUOMId]
				,[dtmDate]
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		-- There is an offset to the negative stock
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/01/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 30
				,[dblStockOut] = 30
				,[dblCost] = 15.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- There is a partial offset to the negative stock
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/02/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 56
				,[dblStockOut] = 56
				,[dblCost] = 14.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- Incoming stock can't offset this negative stock
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/03/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 14
				,[dblStockOut] = 77
				,[dblCost] = 13.00
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
		-- Incoming stock is fully consumed by the negative stocks
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[intItemUOMId] = @PremiumGrains_BushelUOMId
				,[dtmDate] = '01/04/2014'
				,[intLotId] = @LotId
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 22
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
				
				/***************************************************************************************************************************************************************************************************************
				The following are the expected records to be affected. Here is how it should look like:  
		_m_		intItemId   intItemLocationId intLotId	dblStockIn	dblStockOut		dblCost		intCreatedUserId intConcurrencyId
		-----	----------- ----------------- ---------	-----------	------------	----------	---------------- ----------------
		upt		3           3                 12345		30.000000	30.000000		15.000000	1                2
		upt		3           3                 12345		56.000000	56.000000		14.000000	1                2
		upt		3           3                 12345		14.000000	77.000000		13.000000	1                2					
		new		3           3                 12345		100.000000	100.000000		22.000000	1                1
				***************************************************************************************************************************************************************************************************************/								
	END 
	
	-- Act
	BEGIN 
		-- Initialize the full qty. 
		SET @FullQty = @dblQty

		DECLARE @intIterationCounter AS INT = 0;

		-- Repeat call on uspICReduceStockInLot until @dblQty is completely distributed to all the negative Lot buckets
		WHILE (ISNULL(@dblQty, 0) > 0)
		BEGIN 		
			SET @intIterationCounter += 1;
								
			EXEC dbo.uspICIncreaseStockInLot
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@intLotId
				,@intSubLocationId
				,@intStorageLocationId
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

			-- Assert on first pass:
			-- the cost to offset is $15
			-- qty offset is 30
			IF (@intIterationCounter = 1) 
			BEGIN 
				EXEC tSQLt.AssertEquals 15.00, @CostUsed
				EXEC tSQLt.AssertEquals 30, @QtyOffset
				EXEC tSQLt.AssertEquals 1, @UpdatedLotId
				EXEC tSQLt.AssertEquals 'JanuaryStock-00015', @strRelatedTransactionId
				EXEC tSQLt.AssertEquals 1, @intRelatedTransactionId
			END 
				
			-- Assert on 2nd pass
			-- the cost to offset is $14
			-- qty offset is 56
			IF (@intIterationCounter = 2) 
			BEGIN 
				EXEC tSQLt.AssertEquals 14.00, @CostUsed
				EXEC tSQLt.AssertEquals 56, @QtyOffset
				EXEC tSQLt.AssertEquals 2, @UpdatedLotId			
				EXEC tSQLt.AssertEquals 'JanuaryStock-00014', @strRelatedTransactionId
				EXEC tSQLt.AssertEquals 2, @intRelatedTransactionId

			END 

			-- Assert on 3RD pass
			-- the cost to offset is $13
			-- qty offset is 23
			IF (@intIterationCounter = 3) 
			BEGIN 
				EXEC tSQLt.AssertEquals 13.00, @CostUsed
				EXEC tSQLt.AssertEquals 14, @QtyOffset
				EXEC tSQLt.AssertEquals 3, @UpdatedLotId			
				EXEC tSQLt.AssertEquals 'JanuaryStock-00013', @strRelatedTransactionId
				EXEC tSQLt.AssertEquals 3, @intRelatedTransactionId
			END 

			SET @dblQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)
		END 

		-- Assert that the new id generated for Lot is 4
		EXEC tSQLt.AssertEquals 4, @NewLotId

		-- Assert that it takes 3 iterations to complete the stock increase 
		EXEC tSQLt.AssertEquals 3, @intIterationCounter;

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate]
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
				,[dtmDate]
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryLot
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
				AND intLotId = @LotId
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