CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting on LIFO for scenario 3, unpost add stock, unpost sell stock]
AS
-- Arrange 
BEGIN 
	EXEC [testi21Database].[Fake posted transactions using LIFO, scenario 3];
	
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5

	-- Declare the variables for location
	DECLARE @BetterHaven AS INT = 3	
			,@WetGrains_BetterHaven AS INT = 11
			,@StickyGrains_BetterHaven AS INT = 12
			,@PremiumGrains_BetterHaven AS INT = 13
			,@ColdGrains_BetterHaven AS INT = 14
			,@HotGrains_BetterHaven AS INT = 15

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5

	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @intTransactionId AS INT = 1
	DECLARE @strTransactionId AS NVARCHAR(40)
	DECLARE @intUserId AS INT = 1
	DECLARE @GLDetail AS dbo.RecapTableType 

	-- Create the tables used for assertion
	CREATE TABLE expectedGLDetail (
		dtmDate DATETIME
		,strBatchId NVARCHAR(20)
		,intAccountId INT
		,dblDebit NUMERIC(18,6)
		,dblCredit NUMERIC(18,6)
		,dblDebitUnit NUMERIC(18,6)
		,dblCreditUnit NUMERIC(18,6)
		,strDescription NVARCHAR(255)
		,strCode NVARCHAR(40)
		,intJournalLineNo INT
		,ysnIsUnposted BIT
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT
		,strModuleName NVARCHAR(255)
	)

	CREATE TABLE actualGLDetail (
		dtmDate DATETIME
		,strBatchId NVARCHAR(20)
		,intAccountId INT
		,dblDebit NUMERIC(18,6)
		,dblCredit NUMERIC(18,6)
		,dblDebitUnit NUMERIC(18,6)
		,dblCreditUnit NUMERIC(18,6)
		,strDescription NVARCHAR(255)
		,strCode NVARCHAR(40)
		,intJournalLineNo INT
		,ysnIsUnposted BIT
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT
		,strModuleName NVARCHAR(255)
	)

	CREATE TABLE expectedInventoryTransaction (
		intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblQty NUMERIC(18,6)
		,dblUOMQty NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,dblValue NUMERIC(18,6)
		,dblSalesPrice NUMERIC(18,6)
		,intTransactionId INT
		,strTransactionId NVARCHAR(40)
		,strBatchId NVARCHAR(20)
		,intTransactionTypeId INT
		,ysnIsUnposted BIT
		,intRelatedInventoryTransactionId INT
		,intRelatedTransactionId INT
		,strRelatedTransactionId NVARCHAR(40)
		,strTransactionForm NVARCHAR(255)	
	)

	CREATE TABLE actualInventoryTransaction (
		intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblQty NUMERIC(18,6)
		,dblUOMQty NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,dblValue NUMERIC(18,6)
		,dblSalesPrice NUMERIC(18,6)
		,intTransactionId INT
		,strTransactionId NVARCHAR(40)
		,strBatchId NVARCHAR(20)
		,intTransactionTypeId INT
		,ysnIsUnposted BIT
		,intRelatedInventoryTransactionId INT
		,intRelatedTransactionId INT
		,strRelatedTransactionId NVARCHAR(40)
		,strTransactionForm NVARCHAR(255)
	)
	
	CREATE TABLE expectedItemStock (
		intItemId INT
		,intItemLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)

	CREATE TABLE actualItemStock (
		intItemId INT
		,intItemLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)
	
	CREATE TABLE expectedLIFO (
		intInventoryLIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)
	
	CREATE TABLE actualLIFO (
		intInventoryLIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)	
END 

-- Act
BEGIN
	-- Begin: Unpost Add Stock 
	BEGIN 
		SET @strBatchId = 'BATCH-0000003'
		SET @strTransactionId = 'InvRcpt-0001'
		SET @intTransactionId = 1

		-- Setup the expected data. 
		-- Reverse the posted GL entries
		INSERT INTO dbo.expectedGLDetail (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,intJournalLineNo
			,ysnIsUnposted
			,strTransactionId
			,intTransactionId 
			,strModuleName 
		)
		SELECT	dtmDate
				,strBatchId = @strBatchId
				,intAccountId
				-----------------------------------------------
				-- Reverse the debit and credit amounts
				-- { 
					,dblDebit = dblCredit 
					,dblCredit = dblDebit 
				-- }
				,ISNULL(dblDebitUnit, 0)
				,ISNULL(dblCreditUnit, 0)
				,strDescription
				,strCode
				,intJournalLineNo = intJournalLineNo + 10
				,ysnIsUnposted = 1
				,strTransactionId
				,intTransactionId 
				,strModuleName 
		FROM	dbo.tblGLDetail
		WHERE	tblGLDetail.intTransactionId = @intTransactionId
				AND tblGLDetail.strTransactionId = @strTransactionId

		-- Reverse of the inventory transactions
		INSERT INTO expectedInventoryTransaction (
				intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted 
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		)
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
		UNION ALL 
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				-- Reverse the unit qty
				--{
					,dblQty = dblQty * -1
				--}
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId = @strBatchId
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId = intInventoryTransactionId
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
			
		-- Setup the expected Item Stock
		-- Expect the stock goes back to zero. The average cost should remain the same. 
		INSERT INTO expectedItemStock (
				intItemId
				,intItemLocationId
				,dblAverageCost
				,dblUnitOnHand
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @PremiumGrains
				,intItemLocationId = @PremiumGrains_BetterHaven
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @ColdGrains
				,intItemLocationId = @ColdGrains_BetterHaven
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @HotGrains
				,intItemLocationId = @HotGrains_BetterHaven
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
			
		-- Setup the expected LIFO data
		INSERT INTO dbo.expectedLIFO (
				intInventoryLIFOId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
				,strTransactionId
				,intTransactionId
		)
		-- Plug the out-qty 
		SELECT	intInventoryLIFOId = 1
				,intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		UNION ALL 
		SELECT	intInventoryLIFOId = 2
				,intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		UNION ALL 
		SELECT	intInventoryLIFOId = 3
				,intItemId = @PremiumGrains
				,intItemLocationId = @PremiumGrains_BetterHaven
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		UNION ALL 
		SELECT	intInventoryLIFOId = 4
				,intItemId = @ColdGrains
				,intItemLocationId = @ColdGrains_BetterHaven
				,intItemUOMId = @ColdGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1							
		UNION ALL 
		SELECT	intInventoryLIFOId = 5
				,intItemId = @HotGrains
				,intItemLocationId = @HotGrains_BetterHaven
				,intItemUOMId = @HotGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		-- When add stock is removed, all the sold stocks from are converted into negative LIFO cost buckets.
		UNION ALL 
		SELECT	intInventoryLIFOId = 6
				,intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1			
		UNION ALL 
		SELECT	intInventoryLIFOId = 7
				,intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1	
		UNION ALL 
		SELECT	intInventoryLIFOId = 8
				,intItemId = @PremiumGrains
				,intItemLocationId = @PremiumGrains_BetterHaven
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1	
		UNION ALL 
		SELECT	intInventoryLIFOId = 9
				,intItemId = @ColdGrains
				,intItemLocationId = @ColdGrains_BetterHaven
				,intItemUOMId = @ColdGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1	
		UNION ALL 
		SELECT	intInventoryLIFOId = 10
				,intItemId = @HotGrains
				,intItemLocationId = @HotGrains_BetterHaven
				,intItemUOMId = @HotGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1					

		-- Do the act
		INSERT INTO @GLDetail (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]		
		)
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intUserId
	END 
	-- End: Unpost Add Stock 

	-- Begin: Unpost Sell Stock
	BEGIN 
		SET @strBatchId = 'BATCH-0000004'
		SET @strTransactionId = 'InvShip-0001'
		SET @intTransactionId = 1

		-- Setup the expected data. 
		-- Reverse the posted GL entries
		INSERT INTO dbo.expectedGLDetail (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,intJournalLineNo
			,ysnIsUnposted
			,strTransactionId
			,intTransactionId 
			,strModuleName 
		)
		SELECT	dtmDate
				,strBatchId = @strBatchId
				,intAccountId
				-----------------------------------------------
				-- Reverse the debit and credit amounts
				-- { 
					,dblDebit = dblCredit 
					,dblCredit = dblDebit 
				-- }
				,ISNULL(dblDebitUnit, 0)
				,ISNULL(dblCreditUnit, 0)
				,strDescription
				,strCode
				,intJournalLineNo = intJournalLineNo + 10
				,ysnIsUnposted = 1
				,strTransactionId
				,intTransactionId 
				,strModuleName 
		FROM	dbo.tblGLDetail
		WHERE	tblGLDetail.intTransactionId = @intTransactionId
				AND tblGLDetail.strTransactionId = @strTransactionId

		-- Reverse of the inventory transactions
		INSERT INTO expectedInventoryTransaction (
				intItemId 
				,intItemLocationId
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted 
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		)
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
		UNION ALL 
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				-- Reverse the unit qty
				--{
					,dblQty = dblQty * -1
				--}
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId = @strBatchId
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId = intInventoryTransactionId
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
			
		-- Setup the expected Item Stock
		-- Expect the stock goes back to zero. The average cost should remain the same. 
		UPDATE	expectedItemStock
		SET		dblUnitOnHand += 75
		FROM	expectedItemStock INNER JOIN dbo.tblICItemLocation ItemLocation
					ON expectedItemStock.intItemId = ItemLocation.intItemId
					AND expectedItemStock.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @BetterHaven
			
		-- Expect LIFO in records are plugged out to prevent further use in the future. 		
		UPDATE	expectedLIFO
		SET		dblStockIn += 75
		FROM	expectedLIFO INNER JOIN dbo.tblICItemLocation ItemLocation
					ON expectedLIFO.intItemId = ItemLocation.intItemId
					AND expectedLIFO.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @BetterHaven
				AND expectedLIFO.dblStockOut = 75
	
		-- Do the act
		INSERT INTO @GLDetail (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]		
		)
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intUserId
	END 
	-- End: Unpost Sell Stock
END 

-- Assert
BEGIN
	-- Get the data for assertion 
	-- Actual data from @GLDetail
	INSERT INTO dbo.actualGLDetail (
		dtmDate
		,strBatchId
		,intAccountId
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strDescription
		,strCode
		,intJournalLineNo
		,ysnIsUnposted
		,strTransactionId
		,intTransactionId 
		,strModuleName 
	)
	SELECT	dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,intJournalLineNo
			,ysnIsUnposted 
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	@GLDetail
		
	-- Actual data from tblICInventoryTransaction
	-- Reverse of the inventory transactions
	INSERT INTO actualInventoryTransaction (
			intItemId 
			,intItemLocationId 
			,intItemUOMId
			,dtmDate 
			,dblQty 
			,dblUOMQty
			,dblCost 
			,dblValue
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId 
			,intTransactionTypeId 
			,ysnIsUnposted 
			,intRelatedInventoryTransactionId 
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,strTransactionForm 
	)
	SELECT	intItemId 
			,intItemLocationId 
			,intItemUOMId
			,dtmDate 
			,dblQty 
			,dblUOMQty
			,dblCost 
			,dblValue
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId 
			,intTransactionTypeId 
			,ysnIsUnposted
			,intRelatedInventoryTransactionId 
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,strTransactionForm 
	FROM	dbo.tblICInventoryTransaction
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId IN ('InvRcpt-0001', 'InvShip-0001')
	
	-- Actual item stock data
	INSERT INTO actualItemStock (
			intItemId
			,intItemLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	ItemStock.intItemId 
			,ItemStock.intItemLocationId 
			,ItemPricing.dblAverageCost 
			,ItemStock.dblUnitOnHand 
	FROM	dbo.tblICItemStock ItemStock INNER JOIN dbo.tblICItemPricing ItemPricing
				ON ItemStock.intItemId = ItemPricing.intItemId
				AND ItemStock.intItemLocationId = ItemPricing.intItemLocationId	
	
	-- Actual LIFO data 
	INSERT INTO dbo.actualLIFO (
			intInventoryLIFOId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
	)	
	SELECT	intInventoryLIFOId
			,tblICInventoryLIFO.intItemId
			,tblICInventoryLIFO.intItemLocationId
			,tblICInventoryLIFO.intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId		
	FROM	dbo.tblICInventoryLIFO INNER JOIN dbo.tblICItemLocation ItemLocation
				ON tblICInventoryLIFO.intItemId = ItemLocation.intItemId
				AND tblICInventoryLIFO.intItemLocationId = ItemLocation.intItemLocationId
	WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @HotGrains, @ColdGrains)
			AND ItemLocation.intLocationId = @BetterHaven
			
	EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail';
	EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction';
	EXEC tSQLt.AssertEqualsTable 'expectedItemStock', 'actualItemStock';
	EXEC tSQLt.AssertEqualsTable 'expectedLIFO', 'actualLIFO';
END 

-- Clean-up: remove the tables used in the unit test
IF OBJECT_ID('expectedGLDetail') IS NOT NULL 
	DROP TABLE expectedGLDetail

IF OBJECT_ID('actualGLDetail') IS NOT NULL 
	DROP TABLE dbo.actualGLDetail

IF OBJECT_ID('expectedInventoryTransaction') IS NOT NULL 
	DROP TABLE expectedInventoryTransaction

IF OBJECT_ID('actualInventoryTransaction') IS NOT NULL 
	DROP TABLE dbo.actualInventoryTransaction
	
IF OBJECT_ID('expectedItemStock') IS NOT NULL 
	DROP TABLE expectedItemStock

IF OBJECT_ID('actualItemStock') IS NOT NULL 
	DROP TABLE dbo.actualItemStock	
	
IF OBJECT_ID('expectedLIFO') IS NOT NULL 
	DROP TABLE expectedLIFO

IF OBJECT_ID('actualLIFO') IS NOT NULL 
	DROP TABLE dbo.actualLIFO
