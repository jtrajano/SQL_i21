﻿CREATE PROCEDURE [testi21Database].[test uspICPostLotInCustody for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustodyTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
		
		DECLARE 
			@intItemId AS INT
			,@intItemLocationId AS INT
			,@intItemUOMId AS INT
			,@intSubLocationId AS INT
			,@intStorageLocationId AS INT
			,@dtmDate AS DATETIME
			,@intLotId AS INT
			,@dblQty AS NUMERIC(18,6)
			,@dblUOMQty AS NUMERIC(18,6)
			,@dblCost AS NUMERIC(18,6)
			,@dblSalesPrice AS NUMERIC(18,6)
			,@intCurrencyId AS INT
			,@dblExchangeRate AS NUMERIC(18,6)
			,@intTransactionId AS INT
			,@intTransactionDetailId AS INT
			,@strTransactionId AS NVARCHAR(20)
			,@strBatchId AS NVARCHAR(20)
			,@intTransactionTypeId AS INT
			,@intUserId AS INT

		CREATE TABLE expected (
			[intInventoryTransactionId] INT NOT NULL, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[intSubLocationId] INT NULL,
			[intStorageLocationId] INT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblValue] NUMERIC(18, 6) NULL, 
			[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[intCurrencyId] INT NULL,
			[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
			[intTransactionId] INT NOT NULL, 
			[intTransactionDetailId] INT NULL, 
			[strTransactionId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intTransactionTypeId] INT NOT NULL, 
			[intLotId] INT NULL, 
			[dtmCreated] DATETIME NULL, 
			[intCreatedUserId] INT NULL, 
			[intConcurrencyId] INT NOT NULL DEFAULT 1, 		
		)

		CREATE TABLE actual (
			[intInventoryTransactionId] INT NOT NULL, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[intSubLocationId] INT NULL,
			[intStorageLocationId] INT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblValue] NUMERIC(18, 6) NULL, 
			[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[intCurrencyId] INT NULL,
			[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
			[intTransactionId] INT NOT NULL, 
			[intTransactionDetailId] INT NULL, 
			[strTransactionId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intTransactionTypeId] INT NOT NULL, 
			[intLotId] INT NULL, 
			[dtmCreated] DATETIME NULL, 
			[intCreatedUserId] INT NULL, 
			[intConcurrencyId] INT NOT NULL DEFAULT 1, 		
		)
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostLotInCustody
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@intLotId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intUserId

		INSERT INTO actual (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[dtmCreated]
				,[intCreatedUserId]
				,[intConcurrencyId]
		)
		SELECT	[intInventoryLotInCustodyTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[dtmCreated]
				,[intCreatedUserId]
				,[intConcurrencyId]		
		FROM	dbo.tblICInventoryLotInCustodyTransaction
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
				AND intLotId = @intLotId
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
		EXEC tSQLt.AssertEmptyTable 'tblICInventoryLotInCustodyTransaction';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 