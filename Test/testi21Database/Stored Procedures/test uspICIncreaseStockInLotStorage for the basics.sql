CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLotStorage for the basics]
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
			[intLotId] INT, 
			[dtmDate] DATETIME,
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
			[intLotId] INT, 
			[dtmDate] DATETIME,
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
				,@dtmDate AS DATETIME
				,@intLotId AS INT
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT
				,@dblQty NUMERIC(18,6)
				,@dblCost AS NUMERIC(38,20)
				,@intEntityUserSecurityId AS INT
				,@FullQty AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@intTransactionDetailId AS INT
				,@TotalQtyOffset AS NUMERIC(18,6)
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@QtyOffset AS NUMERIC(18,6)
				,@NewLotId AS INT 
				,@UpdatedLotId AS INT 
				,@strRelatedTransactionId AS NVARCHAR(40)
				,@intRelatedTransactionId AS INT 
	END 
	
	-- Act
	BEGIN 
		EXEC [dbo].[uspICIncreaseStockInLotStorage]
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@intLotId
				,@intSubLocationId
				,@intStorageLocationId
				,@dblQty
				,@dblCost
				,@intEntityUserSecurityId
				,@FullQty
				,@TotalQtyOffset
				,@strTransactionId
				,@intTransactionId
				,@intTransactionDetailId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@NewLotId OUTPUT 
				,@UpdatedLotId OUTPUT 
				,@strRelatedTransactionId OUTPUT 
				,@intRelatedTransactionId OUTPUT 
	END 

	-- Assert
	BEGIN 
		INSERT INTO actual (
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[intLotId]
				,[dtmDate]
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
				,[intLotId]
				,[dtmDate]
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

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END