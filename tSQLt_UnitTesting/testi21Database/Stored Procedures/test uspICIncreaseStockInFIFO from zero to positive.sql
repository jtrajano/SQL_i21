﻿CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInFIFO from zero to positive]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;		

		-- Re-add the clustered index. This is critical for the FIFO table because this arranged the data physically in the order specified. 
		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryFIFO]
			ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOId] ASC);

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

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables used by uspICIncreaseStockInFIFO
		DECLARE @intItemId AS INT				= @PremiumGrains
				,@intItemLocationId AS INT		= @BetterHaven
				,@dtmDate AS DATETIME			= 'January 2, 2014'
				,@dblPurchaseQty NUMERIC(18,6)	= 40
				,@dblCost AS NUMERIC(18,6)		= 88.77
				,@intUserId AS INT				= 1
				,@NegativeOffSetQty AS NUMERIC(18,6)					
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@dblIncreaseQty AS NUMERIC(18,6)

		-- Setup the expected values 
		INSERT INTO expected (
				[intItemId] 
				,[intItemLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT	[intItemId] = @PremiumGrains
				,[intItemLocationId] = @BetterHaven
				,[dtmDate] = 'January 2, 2014'
				,[dblStockIn] = 40
				,[dblStockOut] = 0
				,[dblCost] = 88.77
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1
	END 
	
	-- Act
	BEGIN 
		SET @dblIncreaseQty = @dblPurchaseQty;
		SET @NegativeOffSetQty = 0;
		
		DECLARE @intIterationCounter AS INT = 0;	

		-- Repeat call on uspICReduceStockInFIFO until @dblIncreaseQty is completely distributed to all the available fifo buckets
		WHILE (ISNULL(@dblIncreaseQty, 0) > 0)
		BEGIN 	
			SET @intIterationCounter += 1;				
						
			EXEC dbo.uspICIncreaseStockInFIFO
				@intItemId
				,@intItemLocationId
				,@dtmDate
				,@dblIncreaseQty
				,@dblCost
				,@intUserId
				,@dblPurchaseQty
				,@NegativeOffSetQty
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				
			SET @dblIncreaseQty = @RemainingQty;
			SET @NegativeOffSetQty = ISNULL(@dblPurchaseQty - @RemainingQty, @NegativeOffSetQty);

			-- Assert that the cost used must be NULL because we are adding a new fifo cost bucket
			EXEC tSQLt.AssertEquals NULL, @CostUsed;

			-- Assert that the remaining qty is NULL
			EXEC tSQLt.AssertEquals NULL, @RemainingQty;
		END 

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT
				[intItemId] 
				,[intItemLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryFIFO
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