CREATE PROCEDURE [testi21Database].[test uspICPostCostAdjustmentOnActualCosting for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
			-- Generate the fake data for the item stock table
		EXEC [testi21Database].[Fake data for cost adjustment]

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryActualCostAdjustmentLog', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3

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

		-- Declare the variables to check the average cost. 
		DECLARE @dblAverageCost_Expected AS NUMERIC(18,6)
		DECLARE @dblAverageCost_Actual AS NUMERIC(18,6)
		
		-- Declare the variables used in uspICPostCostAdjustmentOnActualCosting
		DECLARE @dtmDate AS DATETIME
				,@intItemId AS INT
				,@intItemLocationId AS INT
				,@intSubLocationId AS INT
				,@intStorageLocationId AS INT 
				,@intItemUOMId AS INT	
				,@dblQty AS NUMERIC(18,6)
				,@intCostUOMId AS INT	
				,@dblNewCost AS NUMERIC(38,20)
				,@intTransactionId AS INT
				,@intTransactionDetailId AS INT
				,@strTransactionId AS NVARCHAR(20)
				,@intSourceTransactionId AS INT
				,@intSourceTransactionDetailId AS INT
				,@strSourceTransactionId AS NVARCHAR(20)
				,@strBatchId AS NVARCHAR(20)
				,@intTransactionTypeId AS INT
				,@intCurrencyId AS INT
				,@dblExchangeRate AS NUMERIC(38,20)
				,@intEntityUserSecurityId AS INT
				,@strActualCostId AS NVARCHAR(50) 

		CREATE TABLE expected (
			[intInventoryTransactionId] INT NOT NULL
			,[intItemId] INT NOT NULL
			,[intItemLocationId] INT NOT NULL
			,[intItemUOMId] INT NULL
			,[intSubLocationId] INT NULL
			,[intStorageLocationId] INT NULL
			,[dtmDate] DATETIME NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
			,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dblValue] NUMERIC(18, 6) NULL
			,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[intCurrencyId] INT NULL
			,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL
			,[intTransactionId] INT NOT NULL
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionDetailId] INT NULL
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionTypeId] INT NOT NULL
			,[intLotId] INT NULL
			,[ysnIsUnposted] BIT NULL
			,[intRelatedInventoryTransactionId] INT NULL
			,[intRelatedTransactionId] INT NULL
			,[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
			,[intCostingMethod] INT NULL
			,[dtmCreated] DATETIME NULL
			,[intCreatedUserId] INT NULL
			,[intConcurrencyId] INT NOT NULL DEFAULT 1
		)

		CREATE TABLE actual (
			[intInventoryTransactionId] INT NOT NULL
			,[intItemId] INT NOT NULL
			,[intItemLocationId] INT NOT NULL
			,[intItemUOMId] INT NULL
			,[intSubLocationId] INT NULL
			,[intStorageLocationId] INT NULL
			,[dtmDate] DATETIME NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
			,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dblValue] NUMERIC(18, 6) NULL
			,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[intCurrencyId] INT NULL
			,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL
			,[intTransactionId] INT NOT NULL
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionDetailId] INT NULL
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionTypeId] INT NOT NULL
			,[intLotId] INT NULL
			,[ysnIsUnposted] BIT NULL
			,[intRelatedInventoryTransactionId] INT NULL
			,[intRelatedTransactionId] INT NULL
			,[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
			,[intCostingMethod] INT NULL
			,[dtmCreated] DATETIME NULL
			,[intCreatedUserId] INT NULL
			,[intConcurrencyId] INT NOT NULL DEFAULT 1	
		)

		CREATE TABLE expectedInventoryActualCostAdjustmentLog (
			[intInventoryActualCostId] INT NOT NULL 
			,[intInventoryCostAdjustmentTypeId] INT NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dtmCreated] DATETIME NULL 
			,[intCreatedUserId] INT NULL 
			,[intConcurrencyId] INT NOT NULL DEFAULT 1 
		)
	END 
	
	-- Setup the costing method
	BEGIN 
		DECLARE @AVERAGECOST AS INT = 1
				,@ActualCost AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4 	
				,@ACTUALCOST AS INT = 5	

		UPDATE dbo.tblICItemLocation
		SET intCostingMethod = @ActualCost
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedMessage = 'Cost adjustment cannot continue. Unable to find the cost bucket for (null).'
	END 

	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostCostAdjustmentOnActualCosting
			@dtmDate
			,@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,@dblQty
			,@intCostUOMId 
			,@dblNewCost
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@intSourceTransactionId
			,@intSourceTransactionDetailId
			,@strSourceTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intCurrencyId
			,@dblExchangeRate
			,@intEntityUserSecurityId
			,@strActualCostId

		INSERT INTO actual (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
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
		SELECT	[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
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
		FROM	tblICInventoryTransaction
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
	END 

	-- Assert
	BEGIN
		-- Assert the expected data for tblICInventoryTransaction is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
		
		-- Assert the expected data for tblICInventoryActualCostAdjustmentLog is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expectedInventoryActualCostAdjustmentLog', 'tblICInventoryActualCostAdjustmentLog'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
		
	IF OBJECT_ID('expectedInventoryActualCostAdjustmentLog') IS NOT NULL 
		DROP TABLE dbo.expectedInventoryActualCostAdjustmentLog
END