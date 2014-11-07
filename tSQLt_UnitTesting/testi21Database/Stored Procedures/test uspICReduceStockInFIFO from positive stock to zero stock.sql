﻿CREATE PROCEDURE [testi21Database].[test uspICReduceStockInFIFO from positive stock to zero stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;		

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

		-- Create a fake data for tblICInventoryFIFO
		INSERT INTO dbo.tblICInventoryFIFO (
			[intItemId]
			,[intItemLocationId]
			,[dtmDate]
			,[dblStockIn]
			,[dblStockOut]
			,[dblCost]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[dtmDate] = 'January 1, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 0
				,[dblCost] = 11.44
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 1

		-- Create the expected and actual tables 
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

		-- Create the variables used by uspICReduceStockInFIFO
		DECLARE @intItemId AS INT = @WetGrains
				,@intItemLocationId AS INT = @Default_Location
				,@dtmDate AS DATETIME = 'January 1, 2014'
				,@dblSoldQty NUMERIC(18,6) = -100
				,@dblCost AS NUMERIC(18,6) 
				,@intUserId AS INT = 1
				,@dtmCreated AS DATETIME
				,@dblReduceQty AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6)

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
		SELECT	[intItemId] = @WetGrains
				,[intItemLocationId] = @Default_Location
				,[dtmDate] = 'January 1, 2014'
				,[dblStockIn] = 100
				,[dblStockOut] = 100
				,[dblCost] = 11.44
				,[intCreatedUserId] = 1
				,[intConcurrencyId] = 2
	END 
	
	-- Act
	BEGIN 
		SET @dblReduceQty = @dblSoldQty

		-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completely distributed to all the available fifo buckets
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 					
			EXEC [dbo].[uspICReduceStockInFIFO]
				@intItemId
				,@intItemLocationId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT

			SET @dblReduceQty = @RemainingQty;

			-- Assert that the cost used is 11.44
			EXEC tSQLt.AssertEquals 11.44, @CostUsed;
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