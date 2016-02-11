CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLotStorage for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionStorage', @Identity = 1;	

		CREATE TABLE expected (
			[intInventoryLotStorageId] INT, 
			[intItemId] INT, 
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[dtmDate] DATETIME,
			[intLotId] INT, 
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[dblStockIn] NUMERIC(18, 6), 
			[dblStockOut] NUMERIC(18, 6), 
			[dblCost] NUMERIC(38, 20), 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intTransactionId] INT,
			[dtmCreated] DATETIME, 
			[ysnIsUnposted] BIT, 
			[intCreatedEntityId] INT, 
			[intConcurrencyId] INT, 
		)

		CREATE TABLE actual (
			[intInventoryLotStorageId] INT, 
			[intItemId] INT, 
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[dtmDate] DATETIME,
			[intLotId] INT, 
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[dblStockIn] NUMERIC(18, 6), 
			[dblStockOut] NUMERIC(18, 6), 
			[dblCost] NUMERIC(38, 20), 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intTransactionId] INT,
			[dtmCreated] DATETIME, 
			[ysnIsUnposted] BIT, 
			[intCreatedEntityId] INT, 
			[intConcurrencyId] INT, 
		)

		-- Create the variables 
		DECLARE @intItemId AS INT
				,@intItemLocationId AS INT
				,@intItemUOMId AS INT
				,@intLotId AS INT
				,@intSubLocationId INT 
				,@intStorageLocationId INT 
				,@dtmDate AS DATETIME
				,@dblSoldQty NUMERIC(18,6)
				,@dblCost AS NUMERIC(38,20)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intTransactionDetailId AS INT
				,@intEntityUserSecurityId AS INT
				,@dblReduceQty AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6)
				,@QtyOffset AS NUMERIC(18,6)
				,@LotStorageId AS INT
	END 

	-- Act
	BEGIN 
		EXEC [dbo].[uspICReduceStockInLotStorage]
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
				,@intTransactionDetailId
				,@intEntityUserSecurityId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@LotStorageId OUTPUT 

		INSERT INTO actual (
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblStockIn]
				,[dblStockOut]
				,[dblCost]
				,[strTransactionId]
				,[intTransactionId] 
				,[dtmCreated]
				,[ysnIsUnposted]
				,[intCreatedEntityId]
				,[intConcurrencyId]
		)
		SELECT
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblStockIn]
				,[dblStockOut]
				,[dblCost]
				,[strTransactionId]
				,[intTransactionId] 
				,[dtmCreated]
				,[ysnIsUnposted]
				,[intCreatedEntityId]
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryLotStorage
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
				AND intLotId = @intLotId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END