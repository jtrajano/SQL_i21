﻿CREATE PROCEDURE [testi21Database].[test uspICReduceStockInFIFOStorage for the basics]
AS
BEGIN 
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOStorage', @Identity = 1;		

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(38, 20)
			,[dtmCreated] DATETIME 
			,[intCreatedEntityId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[dtmDate] DATETIME
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(38, 20)
			,[dtmCreated] DATETIME 
			,[intCreatedEntityId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables 
		DECLARE @intItemId AS INT
				,@intItemLocationId AS INT
				,@intItemUOMId AS INT 
				,@dtmDate AS DATETIME
				,@dblQty NUMERIC(38,20) 
				,@dblCost AS NUMERIC(38,20)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intTransactionDetailId AS INT
				,@intEntityUserSecurityId AS INT
				,@RemainingQty AS NUMERIC(38,20) 
				,@CostUsed AS NUMERIC(38,20) 
				,@QtyOffset AS NUMERIC(38,20)
				,@FIFOStorageId AS INT 
	END 

	-- Act
	BEGIN 
		EXEC [dbo].[uspICReduceStockInFIFOStorage]
			@intItemId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@dtmDate 
			,@dblQty 
			,@dblCost 
			,@strTransactionId 
			,@intTransactionId 
			,@intTransactionDetailId 
			,@intEntityUserSecurityId 
			,@RemainingQty OUTPUT
			,@CostUsed OUTPUT 
			,@QtyOffset OUTPUT 
			,@FIFOStorageId OUTPUT
	END 

	-- Assert
	BEGIN 
		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[dtmCreated] 
				,[intCreatedEntityId] 
				,[intConcurrencyId]
		)
		SELECT
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[dtmCreated] 
				,[intCreatedEntityId] 
				,[intConcurrencyId]
		FROM	tblICInventoryFIFO
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END