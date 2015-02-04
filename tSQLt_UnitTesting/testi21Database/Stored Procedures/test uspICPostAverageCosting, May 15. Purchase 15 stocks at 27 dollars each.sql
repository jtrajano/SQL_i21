CREATE PROCEDURE [testi21Database].[test uspICPostAverageCosting, May 15. Purchase 15 stocks at 27 dollars each]
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

		-- Declare the variables for the Unit of Measure
		DECLARE @EACH AS INT = 1;

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

		-- Declare the variables for the transaction types
		DECLARE @PurchaseTransactionType AS INT = 1;
		DECLARE @SalesTransactionType AS INT = 2;

		-- Declare the variables used in uspICPostAverageCosting
		DECLARE 
			@intItemId AS INT
			,@intItemLocationId AS INT
			,@dtmDate AS DATETIME
			,@dblUnitQty AS NUMERIC(18,6)
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

		-- Declare the variables to check the average cost. 
		DECLARE @dblAverageCost_Expected AS NUMERIC(18,6)
		DECLARE @dblAverageCost_Actual AS NUMERIC(18,6)

		CREATE TABLE expected (
			[intInventoryTransactionId] INT NOT NULL, 
			[intItemId] INT NOT NULL,
			[intItemLocationId] INT NOT NULL,
			[dtmDate] DATETIME NOT NULL, 
			[dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
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
			[dtmDate] DATETIME NOT NULL, 
			[dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
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
			SET @dtmDate = 'January 1, 2014'
			SET @dblUnitQty = 20
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

			SET @dblAverageCost_Expected = @dblCost

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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
			SET		dblAverageCost = 20
					,dblUnitOnHand = 20
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					
			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
					intItemId
					,intItemLocationId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
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
			SET @dtmDate = 'February 10, 2014'
			SET @dblUnitQty = 20
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

			SET @dblAverageCost_Expected = 20.50

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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
			SET		dblAverageCost = 20.50
					,dblUnitOnHand = 40
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					
			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
					intItemId
					,intItemLocationId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
					,dtmDate = 'February 10, 2014'
					,dblStockIn = 20
					,dblStockOut = 0
					,dblCost = 21 
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1				
		END 

		-- 3. Feb 15. Purchase 20 stocks at $21.75 each
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @dtmDate = 'February 15, 2014'
			SET @dblUnitQty = 20
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

			SET @dblAverageCost_Expected = 20.916667

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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
			SET		dblAverageCost = 20.916667
					,dblUnitOnHand = 60
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId					
					
			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
					intItemId
					,intItemLocationId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
					,dtmDate = 'February 15, 2014'
					,dblStockIn = 20
					,dblStockOut = 0
					,dblCost = 21.75 
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1				
		END

		-- 4. Mar 1. Sold 40 stocks. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @dtmDate = 'March 1, 2014'
			SET @dblUnitQty = -40
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

			SET @dblAverageCost_Expected = 20.916667

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblAverageCost_Expected
					,[dblValue] = NULL 
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
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblAverageCost_Expected
					,[dblValue] = NULL 
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
			SET		dblAverageCost = @dblAverageCost_Expected
					,dblUnitOnHand = 20
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					
			-- Update the fake data in tblICInventoryFIFO
			UPDATE	tblICInventoryFIFO
			SET		dblStockOut += 20 
					,intConcurrencyId += 1
			WHERE	intInventoryFIFOId IN (1, 2)
					AND intItemId = @intItemId
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
			SELECT	intInventoryTransactionId = 4
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
			SELECT	intInventoryTransactionId = 4
					,intInventoryFIFOId = 2
					,dblQty = 20				
		END

		-- 5. Mar 15. Sold 50 stocks. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @dtmDate = 'March 15, 2014'
			SET @dblUnitQty = -50
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

			SET @dblAverageCost_Expected = 20.916667

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
			SELECT	[intInventoryTransactionId] = 5
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblAverageCost_Expected
					,[dblValue] = NULL 
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
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblAverageCost_Expected
					,[dblValue] = NULL 
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
			SET		dblAverageCost = @dblAverageCost_Expected
					,dblUnitOnHand = -30
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					
			-- Update the fake data in tblICInventoryFIFO
			UPDATE	tblICInventoryFIFO
			SET		dblStockOut += 20 
					,intConcurrencyId += 1			
			WHERE	intInventoryFIFOId IN (3)
					AND intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId							

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
					intItemId
					,intItemLocationId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
					,dtmDate = 'March 15, 2014'
					,dblStockIn = 0
					,dblStockOut = 30
					,dblCost = 20.50
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 2

			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO ExpectedInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 5
					,intInventoryFIFOId = 3
					,dblQty = 20

			-- Re-insert the fake data to tblICInventoryFIFOOut
			INSERT INTO dbo.tblICInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 5
					,intInventoryFIFOId = 3
					,dblQty = 20				
		END

		-- 6. Apr 7. Sold 60 stocks
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @dtmDate = 'April 7, 2014'
			SET @dblUnitQty = -60
			SET @dblUOMQty = @EACH 
			SET @dblCost = 0
			SET @dblSalesPrice = 55.75
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'SALES-00003'
			SET @strBatchId = 'BATCH-00006'
			SET @intTransactionTypeId = @SalesTransactionType
			SET @intUserId = 3

			SET @dblAverageCost_Expected = 20.916667

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblAverageCost_Expected
					,[dblValue] = NULL 
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
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblAverageCost_Expected
					,[dblValue] = NULL 
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
			SET		dblAverageCost = @dblAverageCost_Expected
					,dblUnitOnHand = -90
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId

			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
					intItemId
					,intItemLocationId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
					,dtmDate = 'April 7, 2014'
					,dblStockIn = 0
					,dblStockOut = 60
					,dblCost = @dblCost
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1					
		END

		-- 7. Apr 12. Purchase 75 stocks at $19 each. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @dtmDate = 'April 12, 2014'
			SET @dblUnitQty = 75
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

			SET @dblAverageCost_Expected = @dblCost

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
			SELECT	[intInventoryTransactionId] = 7
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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

			-- 2nd Expected: Write-Off Sold 
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 8
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = (@dblUnitQty * @dblUOMQty) * 20.916667
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

			-- 3rd Expected: Revalue Sold 
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 9
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = -(@dblUnitQty * @dblUOMQty) * @dblCost
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

			-- 4th Expected: The Auto Negative
			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
			SELECT	[intInventoryTransactionId] = 10
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = (-15 * @dblCost) - (SELECT CAST( SUM(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) AS NUMERIC(18,6)) FROM expected WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId) -- Expected value is 28.750025
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @AUTO_NEGATIVE
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1

			-- Re-insert the expected data in tblICInventoryTransaction
			INSERT INTO tblICInventoryTransaction (
					[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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

			-- 2nd Expected: Write-Off Sold
			UNION ALL 
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = (@dblUnitQty * @dblUOMQty) * 20.916667 
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

			-- 3rd Expected: Revalue Sold
			UNION ALL 
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = -(@dblUnitQty * @dblUOMQty) * @dblCost
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

			-- 4th Expected: The Auto Negative
			INSERT INTO tblICInventoryTransaction (
					[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = (-15 * @dblCost) - (SELECT CAST( SUM(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) AS NUMERIC(18,6)) FROM tblICInventoryTransaction WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId) -- Expected value is 28.750025
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @USD
					,[dblExchangeRate] = 1
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @AUTO_NEGATIVE
					,[intLotId] = NULL 
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId]	= 1			

			-- Update expected data in tblICItemStock
			UPDATE	tblICItemStock
			SET		dblAverageCost = @dblAverageCost_Expected
					,dblUnitOnHand = -15
					,intConcurrencyId += 1
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					
			-- Update the fake data in tblICInventoryFIFO
			UPDATE	tblICInventoryFIFO
			SET		dblStockIn += 30 
					,intConcurrencyId += 1			
			WHERE	intInventoryFIFOId IN (4)
					AND intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId	
					
			-- Update the fake data in tblICInventoryFIFO
			UPDATE	tblICInventoryFIFO
			SET		dblStockIn += 45
					,intConcurrencyId += 1			
			WHERE	intInventoryFIFOId IN (5)
					AND intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId											
					
			-- Add the fake data for tblICInventoryFIFO
			INSERT INTO tblICInventoryFIFO (
					intItemId
					,intItemLocationId
					,dtmDate
					,dblStockIn
					,dblStockOut
					,dblCost
					,intCreatedUserId
					,intConcurrencyId
			)
			SELECT	intItemId = @WetGrains
					,intItemLocationId = @NewHaven
					,dtmDate = 'April 12, 2014'
					,dblStockIn = 75
					,dblStockOut = 75
					,dblCost = @dblCost
					,intCreatedUserId = @intUserId
					,intConcurrencyId = 1							
					
			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO ExpectedInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 9
					,intInventoryFIFOId = 6
					,dblQty = 30
			UNION ALL 
			SELECT	intInventoryTransactionId = 11
					,intInventoryFIFOId = 6
					,dblQty = 45	

			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO dbo.tblICInventoryFIFOOut(
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 9
					,intInventoryFIFOId = 6
					,dblQty = 30
			UNION ALL 
			SELECT	intInventoryTransactionId = 11
					,intInventoryFIFOId = 6
					,dblQty = 45				
		END

		-- 8. May 15. Purchase 15 stocks at $27 each. 
		BEGIN 
			SET	@intItemId = @WetGrains
			SET @intItemLocationId = @NewHaven
			SET @dtmDate = 'May 15, 2014'
			SET @dblUnitQty = 15
			SET @dblUOMQty = @EACH 
			SET @dblCost = 27.00
			SET @dblSalesPrice = 0
			SET @intCurrencyId = @USD
			SET @dblExchangeRate = 1
			SET @intTransactionId = 1
			SET @strTransactionId = 'PURCHASE-00005'
			SET @strBatchId = 'BATCH-00008'
			SET @intTransactionTypeId = @PurchaseTransactionType
			SET @intUserId = 3

			SET @dblAverageCost_Expected = @dblCost

			INSERT INTO expected (
					[intInventoryTransactionId]
					,[intItemId]
					,[intItemLocationId]
					,[dtmDate]
					,[dblUnitQty]
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
			SELECT	[intInventoryTransactionId] = 11
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = (@dblUnitQty * @dblUOMQty)
					,[dblCost] = @dblCost
					,[dblValue] = NULL 
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

			-- 2nd Expected: Write-Off Sold
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 12
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = 15 * dbo.fnGetItemAverageCost(@intItemId, @intItemLocationId)
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

			-- 3rd Expected: Revalue Sold
			UNION ALL 
			SELECT	[intInventoryTransactionId] = 13
					,[intItemId] = @intItemId
					,[intItemLocationId] = @NewHaven
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = -(15) * @dblCost
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

			-- 4th Expected: None, no Auto Negative record expected. 
			-- Record not expected for auto-negative since the stock is zero (zero x $27 is still zero). 			
					
			-- Insert expected data for tblICInventoryFIFOOut
			INSERT INTO ExpectedInventoryFIFOOut (
				intInventoryTransactionId 
				,intInventoryFIFOId
				,dblQty
			)
			SELECT	intInventoryTransactionId = 13
					,intInventoryFIFOId = 7
					,dblQty = 15					
		END
	END 
	
	-- Act 
	BEGIN 
		EXEC dbo.uspICPostAverageCosting
			@intItemId
			,@intItemLocationId
			,@dtmDate
			,@dblUnitQty
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
				,[dtmDate]
				,[dblUnitQty]
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
				,[dtmDate]
				,[dblUnitQty]
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