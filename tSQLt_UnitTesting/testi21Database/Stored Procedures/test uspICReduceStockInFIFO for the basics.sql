﻿

CREATE PROCEDURE [testi21Database].[test uspICReduceStockInFIFO for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;		

		CREATE TABLE expected (
			[intItemId] INT 
			,[intLocationId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[dtmCreated] DATETIME 
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
			,[dtmCreated] DATETIME 
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables 
		DECLARE @intItemId AS INT
				,@intLocationId AS INT
				,@dtmDate AS DATETIME
				,@dblSoldQty NUMERIC(18,6) 
				,@dblCost AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intUserId AS INT
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6)
				,@QtyOffset AS NUMERIC(18,6)
				,@FifoId AS INT 
	END 
	
	-- Act
	BEGIN 
		EXEC [dbo].[uspICReduceStockInFIFO]
			@intItemId 
			,@intLocationId 
			,@dtmDate 
			,@dblSoldQty 
			,@dblCost
			,@strTransactionId
			,@intTransactionId			 
			,@intUserId 
			,@RemainingQty OUTPUT 
			,@CostUsed OUTPUT
			,@QtyOffset OUTPUT 
			,@FifoId OUTPUT 

		INSERT INTO actual (
				[intItemId] 
				,[intLocationId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[dtmCreated] 
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
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	tblICInventoryFIFO
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
