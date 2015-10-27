﻿CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLot for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;		

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[dtmCreated] DATETIME 
			,[intCreatedEntityId] INT 
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
			,[dtmCreated] DATETIME 
			,[intCreatedEntityId] INT 
			,[intConcurrencyId]	INT
		)

		-- Create the variables 
		DECLARE @intItemId AS INT
				,@intItemLocationId AS INT
				,@intItemUOMId AS INT
				,@dtmDate AS DATETIME 
				,@intLotId AS INT
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT
				,@dblSoldQty NUMERIC(18,6) 
				,@dblCost AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intEntityUserSecurityId AS INT
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6)
				,@QtyOffset AS NUMERIC(18,6)
				,@LotId AS INT 
	END 
	
	-- Act
	BEGIN 
		EXEC [dbo].[uspICReduceStockInLot]
			@intItemId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@dtmDate
			,@intLotId 
			,@intSubLocationId 
			,@intStorageLocationId 
			,@dblSoldQty 
			,@dblCost
			,@strTransactionId
			,@intTransactionId			 
			,@intEntityUserSecurityId 
			,@RemainingQty OUTPUT 
			,@CostUsed OUTPUT
			,@QtyOffset OUTPUT 
			,@LotId OUTPUT 

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[intLotId] 
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
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[dtmCreated] 
				,[intCreatedEntityId] 
				,[intConcurrencyId]
		FROM	tblICInventoryLot
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