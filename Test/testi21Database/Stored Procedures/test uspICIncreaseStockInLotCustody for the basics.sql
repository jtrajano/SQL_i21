CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLotCustody for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionInCustody', @Identity = 1;	

		CREATE TABLE expected (
			[intInventoryLotInCustodyId] INT, 
			[intItemId] INT, 
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[intLotId] INT, 
			[dtmDate] DATETIME,
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[dblStockIn] NUMERIC(18, 6), 
			[dblStockOut] NUMERIC(18, 6), 
			[dblCost] NUMERIC(18, 6), 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intTransactionId] INT,
			[dtmCreated] DATETIME, 
			[ysnIsUnposted] BIT, 
			[intCreatedUserId] INT, 
			[intConcurrencyId] INT, 
		)

		CREATE TABLE actual (
			[intInventoryLotInCustodyId] INT, 
			[intItemId] INT, 
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[intLotId] INT, 
			[dtmDate] DATETIME,
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[dblStockIn] NUMERIC(18, 6), 
			[dblStockOut] NUMERIC(18, 6), 
			[dblCost] NUMERIC(18, 6), 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intTransactionId] INT,
			[dtmCreated] DATETIME, 
			[ysnIsUnposted] BIT, 
			[intCreatedUserId] INT, 
			[intConcurrencyId] INT, 
		)

		-- Create the variables 
		DECLARE @intItemId AS INT
				,@intItemLocationId AS INT
				,@intItemUOMId AS INT 
				,@intLotId AS INT
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT
				,@dtmDate AS DATETIME 
				,@dblQty NUMERIC(18,6) 
				,@dblCost AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT 
				,@intUserId AS INT
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6)
				,@NewInventoryLotInCustodyId AS INT
	END 
	
	-- Act
	BEGIN 
		EXEC [dbo].[uspICIncreaseStockInLotCustody]
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intLotId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
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
				,[intCreatedUserId]
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
				,[intCreatedUserId]
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryLotInCustody
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
				AND intLotId = @intLotId
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