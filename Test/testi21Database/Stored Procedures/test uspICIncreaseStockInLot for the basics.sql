CREATE PROCEDURE [testi21Database].[test uspICIncreaseStockInLot for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;		

		CREATE TABLE expected (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[dtmCreated] DATETIME 
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
		)

		CREATE TABLE actual (
			[intItemId] INT 
			,[intItemLocationId] INT 
			,[intLotId] INT
			,[dblStockIn] NUMERIC(18,6)
			,[dblStockOut] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[dtmCreated] DATETIME 
			,[intCreatedUserId] INT 
			,[intConcurrencyId]	INT
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
				,@intUserId AS INT
				,@strTransactionId AS NVARCHAR(40)
				,@intTransactionId AS INT
				,@TotalQtyOffset AS NUMERIC(18,6)					
				,@RemainingQty AS NUMERIC(18,6) 
				,@CostUsed AS NUMERIC(18,6) 
				,@FullQty AS NUMERIC(18,6)
				,@QtyOffset AS NUMERIC(18,6)
				,@NewLotId AS INT 
				,@UpdatedLotId AS INT 
				,@strRelatedTransactionId AS NVARCHAR(40)
				,@intRelatedTransactionId AS INT 
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICIncreaseStockInLot
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intLotId
			,@intSubLocationId
			,@intStorageLocationId
			,@dblQty
			,@dblCost
			,@intUserId
			,@FullQty
			,@strTransactionId
			,@intTransactionId
			,@TotalQtyOffset
			,@RemainingQty OUTPUT
			,@CostUsed OUTPUT
			,@QtyOffset OUTPUT 
			,@NewLotId OUTPUT 
			,@UpdatedLotId OUTPUT 
			,@strRelatedTransactionId OUTPUT 
			,@intRelatedTransactionId OUTPUT 

		INSERT INTO actual (
				[intItemId] 
				,[intItemLocationId] 
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		)
		SELECT
				[intItemId] 
				,[intItemLocationId] 
				,[intLotId] 
				,[dblStockIn] 
				,[dblStockOut]
				,[dblCost] 
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
		FROM	tblICInventoryLot
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
