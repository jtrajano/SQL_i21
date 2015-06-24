CREATE PROCEDURE [testi21Database].[test uspICReduceStockInLotCustody for the basics]
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
				,@dblQty NUMERIC(18,6) 
				,@dblCost AS NUMERIC(18,6)
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT 
				,@intUserId AS INT
				,@RemainingQty AS NUMERIC(18,6)
				,@CostUsed AS NUMERIC(18,6)
				,@InventoryLotInCustodyId AS INT
	END 
	
	-- Assert
	BEGIN
		EXEC tSQLt.ExpectException
				@ExpectedMessage = 'Negative stock quantity is not allowed.',
				@ExpectedErrorNumber = 50029			
	END 

	-- Act
	BEGIN 
		EXEC [dbo].[uspICReduceStockInLotCustody]
			@intItemId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@intLotId 
			,@intSubLocationId 
			,@intStorageLocationId 
			,@dblQty 
			,@dblCost 
			,@strTransactionId 
			,@intTransactionId 
			,@intUserId 
			,@RemainingQty OUTPUT  
			,@CostUsed OUTPUT
			,@InventoryLotInCustodyId OUTPUT

		INSERT INTO actual (
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
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
				,[intCreatedUserId]
				,[intConcurrencyId]
		)
		SELECT
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
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
				,[intCreatedUserId]
				,[intConcurrencyId]
		FROM	dbo.tblICInventoryLotInCustody
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
				AND intLotId = @intLotId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END