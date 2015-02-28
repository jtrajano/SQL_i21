CREATE PROCEDURE [testi21Database].[test uspICPostFIFO, Apr 12. Purchase 75 stocks at 19 dollars each]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Generate the fake data for the item stock table
		EXEC [testi21Database].[Fake data for item stock table]

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
				
		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
		DECLARE @WRITE_OFF_SOLD AS INT = 2
		DECLARE @REVALUE_SOLD AS INT = 3

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
		DECLARE @SalesTransactionType AS INT = 2;

		-- Declare the variables used in uspICPostFIFO
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
			[intItemUOMId] INT NULL,
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
			[intItemUOMId] INT NULL,
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

		CREATE TABLE ExpectedInventoryFIFOOut (
			intId INT IDENTITY 
			,intInventoryFIFOId INT 
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
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing
			UPDATE	tblICItemPricing
			SET		dblAverageCost = 20					
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
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
					,dblStockOut = 20
					,dblCost = 20 
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 2			
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
			SET		dblUnitOnHand = 40
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing
			UPDATE	tblICItemPricing
			SET		dblAverageCost = 20.50					
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
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
					,dtmDate = 'February 10, 2014'
					,dblStockIn = 20
					,dblStockOut = 20
					,dblCost = 21 
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 2
		END 

		-- 3. Feb 15. Purchase 20 stocks at $21.75 each
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'February 15, 2014'
			SET @dblQty = 20
			SET @dblUOMQty = @EACH 
			SET @dblCost = 21.75
			SET @dblSalesPrice = 0
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'PURCHASE-00003'
			SET @strBatchId = 'BATCH-00003'
			SET @intTransactionTypeId = @PurchaseTransactionType
			SET @intUserId = 3

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
			SELECT	[intInventoryTransactionId] = 3
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
			SET		dblUnitOnHand = 60
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing 
			UPDATE	tblICItemPricing
			SET		dblAverageCost = 20.916667					
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
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
					,dtmDate = 'February 15, 2014'
					,dblStockIn = 20
					,dblStockOut = 20
					,dblCost = 21.75 
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 2
		END

		-- 4. Mar 1. Sold 40 stocks. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'March 1, 2014'
			SET @dblQty = -40
			SET @dblUOMQty = @EACH 
			SET @dblCost = 0
			SET @dblSalesPrice = 50.00
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'SALES-00001'
			SET @strBatchId = 'BATCH-00004'
			SET @intTransactionTypeId = @SalesTransactionType
			SET @intUserId = 3

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
			SELECT	[intInventoryTransactionId] = 4
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMd] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -20
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 20
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 5
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMd] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -20
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 21
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
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
					,[dblQty] = -20
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 20
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			UNION ALL
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -20
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 21
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			
			-- Update expected data in tblICItemStock
			UPDATE	tblICItemStock
			SET		dblUnitOnHand = 20
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing
			UPDATE	tblICItemPricing 
			SET		dblAverageCost = 20.916667					
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO ExpectedInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 4
					,intInventoryFIFOId = 1
					,dblQty = 20
			UNION ALL 
			SELECT	intInventoryTransactionId = 5
					,intInventoryFIFOId = 2
					,dblQty = 20
					
			-- Re-insert the fake data totblICInventoryFIFOOut
			INSERT INTO dbo.tblICInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 4
					,intInventoryFIFOId = 1
					,dblQty = 20
			UNION ALL 
			SELECT	intInventoryTransactionId = 5
					,intInventoryFIFOId = 2
					,dblQty = 20
		END

		-- 5. Mar 15. Sold 50 stocks. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'March 15, 2014'
			SET @dblQty = -50
			SET @dblUOMQty = @EACH 
			SET @dblCost = 0
			SET @dblSalesPrice = 52.00
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'SALES-00002'
			SET @strBatchId = 'BATCH-00005'
			SET @intTransactionTypeId = @SalesTransactionType
			SET @intUserId = 3

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
			SELECT	[intInventoryTransactionId] = 6
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -20
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 21.75
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 7
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -30
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 20.50 -- Cost was provided by the sales transaction. 
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
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
					,[dblQty] = -20
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 21.75					
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			UNION ALL 
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -30
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 20.50 -- Cost was provided by the sales transaction. 
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			
			-- Update expected data in tblICItemStock
			UPDATE	tblICItemStock
			SET		dblUnitOnHand = -30
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing
			UPDATE	tblICItemPricing
			SET		dblAverageCost = 20.916667					
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
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
					,[intItemUOMId] = @intItemUOMId
					,dtmDate = 'March 15, 2014'
					,dblStockIn = 0
					,dblStockOut = 30
					,dblCost = 20.50
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1

			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO ExpectedInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 6
					,intInventoryFIFOId = 3
					,dblQty = 20

			-- Re-insert the fake data to tblICInventoryFIFOOut
			INSERT INTO dbo.tblICInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 6
					,intInventoryFIFOId = 3
					,dblQty = 20
		END

		-- 6. Apr 7. Sold 60 stocks
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'April 7, 2014'
			SET @dblQty = -60
			SET @dblUOMQty = @EACH 
			SET @dblCost = 20.50
			SET @dblSalesPrice = 55.75
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'SALES-00003'
			SET @strBatchId = 'BATCH-00006'
			SET @intTransactionTypeId = @SalesTransactionType
			SET @intUserId = 3

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
			SELECT	[intInventoryTransactionId] = 8
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = -60
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 20.50
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
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
					,[dblQty] = -60
					,[dblUOMQty] = @dblUOMQty
					,[dblCost] = 20.50
					,[dblValue] = 0 
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			
			-- Update expected data in tblICItemStock
			UPDATE	tblICItemStock
			SET		dblUnitOnHand = -90
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Update expected data in tblICItemPricing
			UPDATE	tblICItemPricing
			SET		dblAverageCost = 20.916667					
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
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
					,[intItemUOMId] = @intItemUOMId
					,dtmDate = 'April 7, 2014'
					,dblStockIn = 0
					,dblStockOut = 60
					,dblCost = 20.50
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1
		END

		-- 7. Apr 12. Purchase 75 stocks at $19 each. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @intItemUOMId = @WetGrains_BushelUOMId
			SET @dtmDate = 'April 12, 2014'
			SET @dblQty = 75
			SET @dblUOMQty = @EACH 
			SET @dblCost = 19.00
			SET @dblSalesPrice = 0
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'PURCHASE-00004'
			SET @strBatchId = 'BATCH-00007'
			SET @intTransactionTypeId = @PurchaseTransactionType
			SET @intUserId = 3

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
			-- 1st Expected: The normal purchase record. 
			SELECT	[intInventoryTransactionId] = 9
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
					,[intTransactionTypeId] = @intTransactionTypeId
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			-- 2ND Expected: Write-Off Sold
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 10
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = 0
					,[dblUOMQty] = 0
					,[dblCost] = 0
					,[dblValue] = 30 * 20.50
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @WRITE_OFF_SOLD
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			-- 3RD Expected: Revalue Sold
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 11
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = 0
					,[dblUOMQty] = 0
					,[dblCost] = 0
					,[dblValue] = -30 * @dblCost
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @REVALUE_SOLD
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1					
			-- 4TH Expected: Write-Off Sold
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 12
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = 0
					,[dblUOMQty] = 0
					,[dblCost] = 0
					,[dblValue] = 45 * 20.50
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @WRITE_OFF_SOLD
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1
			-- 5TH Expected: Revalue Sold 
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 13
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[intItemUOMId] = @intItemUOMId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[dtmDate] = @dtmDate
					,[dblQty] = 0
					,[dblUOMQty] = 0
					,[dblCost] = 0
					,[dblValue] = -45 * @dblCost
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @REVALUE_SOLD
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1

			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO ExpectedInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 11
					,intInventoryFIFOId = 6
					,dblQty = 30
			UNION ALL
			SELECT	intInventoryTransactionId = 13
					,intInventoryFIFOId = 6
					,dblQty = 45
		END
	END 
	
	-- Act 
	BEGIN 
		EXEC dbo.uspICPostFIFO
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
		
		-- Assert the expected data for tblICInventoryFIFOOut is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'ExpectedInventoryFIFOOut', 'tblICInventoryFIFOOut'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
		
	IF OBJECT_ID('ExpectedInventoryFIFOOut') IS NOT NULL 
		DROP TABLE dbo.ExpectedInventoryFIFOOut
END
