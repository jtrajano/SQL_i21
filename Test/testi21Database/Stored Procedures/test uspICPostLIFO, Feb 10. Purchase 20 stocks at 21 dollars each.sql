﻿CREATE PROCEDURE [testi21Database].[test uspICPostLIFO, Feb 10. Purchase 20 stocks at 21 dollars each]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Generate the fake data for the item stock table
		EXEC [testi21Database].[Fake data for item stock table]

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOOut', @Identity = 1;

		CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLIFO]
			ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOId] DESC);
				
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
				,@InvalidLocation AS INT = -1

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Declare the variables for the Unit of Measure
		DECLARE @EACH AS INT = 1;

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

		-- Declare the variables for the transaction types
		DECLARE @PurchaseTransactionType AS INT = 1;

		-- Declare the variables used in uspICPostLIFO
		DECLARE 
			@intItemId AS INT
			,@intItemLocationId AS INT
			,@intItemUOMId AS INT 
			,@intSubLocationId AS INT
			,@intStorageLocationId AS INT
			,@dtmDate AS DATETIME
			,@dblQty AS NUMERIC(18,6)
			,@dblUOMQty AS NUMERIC(18,6)
			,@dblCost AS NUMERIC(18,6)
			,@dblSalesPrice AS NUMERIC(18,6)
			,@intCurrencyId AS INT
			,@dblExchangeRate AS NUMERIC(18,6)
			,@intTransactionId AS INT
			,@strTransactionId AS NVARCHAR(20)
			,@strBatchId AS NVARCHAR(20)
			,@intTransactionTypeId AS INT
			,@intUserId AS INT

		CREATE TABLE expected (
			[intInventoryTransactionId] INT NOT NULL, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[intItemUOMId] INT NOT NULL,
			[intSubLocationId] INT NULL,
			[intStorageLocationId] INT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblValue] NUMERIC(18, 6) NULL, 
			[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[intCurrencyId] INT NULL,
			[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
			[intTransactionId] INT NOT NULL, 
			[strTransactionId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intTransactionTypeId] INT NOT NULL, 
			[intLotId] INT NULL, 
			[intCreatedUserId] INT NULL, 
			[intConcurrencyId] INT NOT NULL DEFAULT 1, 		
		)

		CREATE TABLE actual (
			[intInventoryTransactionId] INT NOT NULL, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[intItemUOMId] INT NOT NULL,
			[intSubLocationId] INT NULL,
			[intStorageLocationId] INT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[dblValue] NUMERIC(18, 6) NULL, 
			[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
			[intCurrencyId] INT NULL,
			[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
			[intTransactionId] INT NOT NULL, 
			[strTransactionId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intTransactionTypeId] INT NOT NULL, 
			[intLotId] INT NULL, 
			[intCreatedUserId] INT NULL, 
			[intConcurrencyId] INT NOT NULL DEFAULT 1, 	
		)

		CREATE TABLE ExpectedInventoryLIFOOut (
			intId INT
			,intInventoryLIFOId INT 
			,intInventoryTransactionId INT
			,dblQty NUMERIC(18,6)
		)

		-- 1. Expected data from Jan 1. Purchase 20 stocks @ 20 dollars each
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'January 1, 2014'
			SET @dblQty = 20
			SET @dblUOMQty = @EACH 
			SET @dblCost = 20.00
			SET @dblSalesPrice = 0
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'PURCHASE-00001'
			SET @strBatchId = 'BATCH-00001'
			SET @intTransactionTypeId = @PurchaseTransactionType
			SET @intUserId = 1

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[intItemUOMId] 
					,[intSubLocationId] 
					,[intStorageLocationId] 
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty] 
					,[dblCost]
					,[dblValue]
					,[dblSalesPrice]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[intTransactionId]
					,[strTransactionId]
					,[strBatchId]
					,[intTransactionTypeId]
					,[intLotId]
					,[intCreatedUserId]
					,[intConcurrencyId]
			)
			SELECT	[intInventoryTransactionId] = 1
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = @dblQty 
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = @dblCost
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @PurchaseTransactionType
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			
			-- Re-insert the expected data in tblICInventoryTransaction
			INSERT INTO tblICInventoryTransaction (
					[intItemId]
					,[intItemLocationId]
					,[intItemUOMId] 
					,[intSubLocationId] 
					,[intStorageLocationId] 
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty] 
					,[dblCost]
					,[dblValue]
					,[dblSalesPrice]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[intTransactionId]
					,[strTransactionId]
					,[strBatchId]
					,[intTransactionTypeId]
					,[intLotId]
					,[intCreatedUserId]
					,[intConcurrencyId]
			)
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = @dblQty 
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = @dblCost
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @PurchaseTransactionType
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			
			-- Update expected data in tblICItemStock
			UPDATE	tblICItemStock
			SET		dblUnitOnHand = 20
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing 
			UPDATE	tblICItemPricing 
			SET		dblAverageCost = 20					
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryLIFO
			INSERT INTO tblICInventoryLIFO (
					intItemId
					,intItemLocationId
					,intItemUOMId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
					,intItemUOMId = @WetGrains_BushelUOMId
					,dtmDate = 'January 1, 2014'
					,dblStockIn = 20
					,dblStockOut = 0
					,dblCost = 20 
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1
			
		END 

		-- 2. Feb 10. Purchase 20 stocks at 21 dollars each
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'February 10, 2014'
			SET @dblQty = 20
			SET @dblUOMQty = @EACH 
			SET @dblCost = 21.00
			SET @dblSalesPrice = 0
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'PURCHASE-00002'
			SET @strBatchId = 'BATCH-00002'
			SET @intTransactionTypeId = @PurchaseTransactionType
			SET @intUserId = 2

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[intItemUOMId] 
					,[intSubLocationId] 
					,[intStorageLocationId] 
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty] 
					,[dblCost]
					,[dblValue]
					,[dblSalesPrice]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[intTransactionId]
					,[strTransactionId]
					,[strBatchId]
					,[intTransactionTypeId]
					,[intLotId]
					,[intCreatedUserId]
					,[intConcurrencyId]
			)
			SELECT	[intInventoryTransactionId] = 2
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = @dblQty 
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = @dblCost
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @PurchaseTransactionType
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
		END 
	END 
	
	-- Act 
	BEGIN 
		EXEC dbo.uspICPostLIFO
			@intItemId
			,@intItemLocationId
			,@intItemUOMId 
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intUserId
	END 

	-- Assert
	BEGIN
		-- Check the transaction table 
		INSERT INTO actual (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty] 
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCreatedUserId]
				,[intConcurrencyId]
		)
		SELECT	[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty] 
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCreatedUserId]
				,[intConcurrencyId]	
		FROM	tblICInventoryTransaction
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId

		-- Assert the expected data for tblICInventoryTransaction is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
		
		-- Assert the expected data for tblICInventoryLIFOOut is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'ExpectedInventoryLIFOOut', 'tblICInventoryLIFOOut'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

	IF OBJECT_ID('ExpectedInventoryLIFOOut') IS NOT NULL 
		DROP TABLE dbo.ExpectedInventoryLIFOOut
END
