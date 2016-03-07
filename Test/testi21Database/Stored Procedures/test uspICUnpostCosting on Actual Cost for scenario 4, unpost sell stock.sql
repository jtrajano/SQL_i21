﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting on Actual Cost for scenario 4, unpost sell stock]
AS
-- Arrange 
BEGIN 
	EXEC [testi21Database].[Fake posted transactions using Actual Costing, scenario 4];
	
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			
	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5				

	DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-0000003'
	DECLARE @intTransactionId AS INT = 1
	DECLARE @strTransactionId AS NVARCHAR(40) = 'InvShip-00001'
	DECLARE @intEntityUserSecurityId AS INT = 1
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
		,dblCost NUMERIC(38,20)
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
		,dblCost NUMERIC(38,20)
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
	
	CREATE TABLE expectedActualCost (
		intInventoryActualCostId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(38,20)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
		,strActualCostId NVARCHAR(50)
	)
	
	CREATE TABLE actualActualCost (
		intInventoryActualCostId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(38,20)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
		,strActualCostId NVARCHAR(50)
	)	
END 

-- Act
BEGIN
	-- Setup the expected data. 
	-- Reverse the posted GL entries
	INSERT INTO expectedGLDetail (
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
	-------------------------------------------------------------
	-- Expect the g/l entries from the shipment to be reversed
	SELECT	dtmDate
			,strBatchId = @strBatchId
			,intAccountId
			-----------------------------------------------
			-- Reverse the debit and credit amounts
			-- { 
				,dblDebit = dblCredit 
				,dblCredit = dblDebit 				
				,dblDebitUnit = ISNULL(dblCreditUnit, 0)				
				,dblCreditUnit = ISNULL(dblDebitUnit, 0)
			-- }
			,strDescription
			,strCode
			,intJournalLineNo = intJournalLineNo + 20
			,ysnIsUnposted = 1
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	dbo.tblGLDetail
	WHERE	tblGLDetail.intTransactionId = @intTransactionId
			AND tblGLDetail.strTransactionId = @strTransactionId

	------------------------------------------------------------------------------
	-- Expect the g/l entries from the write-off and revalue sold to be reversed
	UNION ALL 
	SELECT	dtmDate
			,strBatchId = @strBatchId
			,intAccountId
			-----------------------------------------------
			-- Reverse the debit and credit amounts
			-- { 
				,dblDebit = dblCredit 
				,dblCredit = dblDebit 
				,dblDebitUnit = ISNULL(dblCreditUnit, 0)				
				,dblCreditUnit = ISNULL(dblDebitUnit, 0)				
			-- }
			,strDescription
			,strCode
			,intJournalLineNo = 
				CASE	WHEN intJournalLineNo = 7 THEN 26
						WHEN intJournalLineNo = 8 THEN 27
						WHEN intJournalLineNo = 10 THEN 28
						WHEN intJournalLineNo = 11 THEN 29
						WHEN intJournalLineNo = 13 THEN 30
						WHEN intJournalLineNo = 14 THEN 31
						WHEN intJournalLineNo = 16 THEN 32
						WHEN intJournalLineNo = 17 THEN 33
						WHEN intJournalLineNo = 19 THEN 34
						WHEN intJournalLineNo = 20 THEN 35
				END
			,ysnIsUnposted = 1
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	dbo.tblGLDetail
	WHERE	intJournalLineNo IN (7, 8, 10,11, 13, 14, 16, 17, 19, 20)			
			
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
	---------------------------------------------------------------------------------
	-- Expect the original shipment to be marked as unposted
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
	---------------------------------------------------------------------------------
	-- Expect new inventory transactions are created to reverse the original shipment
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
	---------------------------------------------------------------------------------
	-- Expect the original revalue and write-off transactions to be marked as unposted
	UNION ALL 
	SELECT	InvTrans.intItemId 
			,InvTrans.intItemLocationId 
			,InvTrans.intItemUOMId
			,InvTrans.dtmDate 
			,InvTrans.dblQty 
			,InvTrans.dblUOMQty
			,InvTrans.dblCost 
			,InvTrans.dblValue 
			,InvTrans.dblSalesPrice 
			,InvTrans.intTransactionId 
			,InvTrans.strTransactionId 
			,InvTrans.strBatchId
			,InvTrans.intTransactionTypeId 
			,ysnIsUnposted = 1
			,InvTrans.intRelatedInventoryTransactionId 
			,InvTrans.intRelatedTransactionId 
			,InvTrans.strRelatedTransactionId 
			,InvTrans.strTransactionForm
	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICInventoryTransactionType ICType
				ON InvTrans.intTransactionTypeId = ICType.intTransactionTypeId
	WHERE	intRelatedTransactionId = @intTransactionId
			AND strRelatedTransactionId = @strTransactionId
			AND ICType.strName <> 'Inventory Auto Negative'			
	---------------------------------------------------------------------------------
	-- Expect new transactions that reverses the revalue and write-off transactions 		
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
			,dblValue = dblValue * -1
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId = @strBatchId
			,InvTrans.intTransactionTypeId 
			,ysnIsUnposted = 1
			,intRelatedInventoryTransactionId = intInventoryTransactionId
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,InvTrans.strTransactionForm 
	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICInventoryTransactionType ICType
				ON InvTrans.intTransactionTypeId = ICType.intTransactionTypeId
	WHERE	intRelatedTransactionId = @intTransactionId
			AND strRelatedTransactionId = @strTransactionId
			AND ICType.strName <> 'Inventory Auto Negative'
			
	-- Setup the expected Item Stock
	-- Expect the stock goes back to 100. The average cost should remain the same. 
	INSERT INTO expectedItemStock (
			intItemId
			,intItemLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = 1
			,dblAverageCost = 0.00
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @StickyGrains
			,intItemLocationId = 2
			,dblAverageCost = 0.00
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dblAverageCost = 0.00
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @ColdGrains
			,intItemLocationId = 4
			,dblAverageCost = 0.00
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @HotGrains
			,intItemLocationId = 5
			,dblAverageCost = 0.00
			,dblUnitOnHand = 100
			
	-- Setup the expected ActualCost data
	INSERT INTO expectedActualCost (
			intInventoryActualCostId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
			,strActualCostId
	)	
	--------------------------------------------
	-- Plug-out the negative cost bucket. 
	SELECT	intInventoryActualCostId = 1
			,intItemId = @WetGrains
			,intItemLocationId = 1
			,intItemUOMId = @WetGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	UNION ALL 
	SELECT	intInventoryActualCostId = 2
			,intItemId = @StickyGrains
			,intItemLocationId = 2
			,intItemUOMId = @StickyGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	UNION ALL 
	SELECT	intInventoryActualCostId = 3
			,intItemId = @PremiumGrains
			,intItemLocationId = 3
			,intItemUOMId = @PremiumGrains_BushelUOMId
			,dtmDate = '01/01/2014'			
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	UNION ALL 
	SELECT	intInventoryActualCostId = 4
			,intItemId = @ColdGrains
			,intItemLocationId = 4
			,intItemUOMId = @ColdGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'				
	UNION ALL 
	SELECT	intInventoryActualCostId = 5
			,intItemId = @HotGrains
			,intItemLocationId = 5
			,intItemUOMId = @HotGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	--------------------------------------------
	-- Return the stock to right ActualCost cost bucket. 	
	UNION ALL 
	SELECT	intInventoryActualCostId = 6
			,intItemId = @WetGrains
			,intItemLocationId = 1
			,intItemUOMId = @WetGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	UNION ALL 
	SELECT	intInventoryActualCostId = 7
			,intItemId = @StickyGrains
			,intItemLocationId = 2
			,intItemUOMId = @StickyGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	UNION ALL 
	SELECT	intInventoryActualCostId = 8
			,intItemId = @PremiumGrains
			,intItemLocationId = 3
			,intItemUOMId = @PremiumGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
			,strActualCostId = 'ACTUAL COST ID'
	UNION ALL 
	SELECT	intInventoryActualCostId = 9
			,intItemId = @ColdGrains
			,intItemLocationId = 4
			,intItemUOMId = @ColdGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1		
			,strActualCostId = 'ACTUAL COST ID'				
	UNION ALL 
	SELECT	intInventoryActualCostId = 10
			,intItemId = @HotGrains
			,intItemLocationId = 5
			,intItemUOMId = @HotGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1		
			,strActualCostId = 'ACTUAL COST ID'

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
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
	)
	EXEC dbo.uspICUnpostCosting
		@intTransactionId
		,@strTransactionId
		,@strBatchId
		,@intEntityUserSecurityId
END 

-- Assert
BEGIN
	-- Get the data for assertion 
	-- Actual data from @GLDetail
	INSERT INTO actualGLDetail (
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
			,Trans.intTransactionTypeId 
			,ysnIsUnposted
			,intRelatedInventoryTransactionId 
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,Trans.strTransactionForm
	FROM	dbo.tblICInventoryTransaction Trans INNER JOIN dbo.tblICInventoryTransactionType ICType
				ON Trans.intTransactionTypeId = ICType.intTransactionTypeId
	WHERE	(
				intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
			)
			OR (
				intRelatedTransactionId = @intTransactionId
				AND strRelatedTransactionId = @strTransactionId
				AND ICType.strName <> 'Inventory Auto Negative'
			)
	
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
	
	-- Actual ActualCost data 
	INSERT INTO actualActualCost (
			intInventoryActualCostId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
			,strActualCostId
	)	
	SELECT	intInventoryActualCostId
			,ActualCost.intItemId
			,ActualCost.intItemLocationId
			,ActualCost.intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
			,strActualCostId
	FROM	dbo.tblICInventoryActualCost ActualCost INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ActualCost.intItemId = ItemLocation.intItemId
				AND ActualCost.intItemLocationId = ItemLocation.intItemLocationId
	WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @HotGrains, @ColdGrains)
			AND ItemLocation.intLocationId = @Default_Location				

	EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction', 'Failed to generate the expected Inventory Transaction records.';
	EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail', 'Failed to generate the expected GL Detail records.';
	EXEC tSQLt.AssertEqualsTable 'expectedItemStock', 'actualItemStock', 'Failed to generate the expected Item Stock records.';
	EXEC tSQLt.AssertEqualsTable 'expectedActualCost', 'actualActualCost', 'Failed to generate the expected Actual Stock records. ';

END 

-- Clean-up: remove the tables used in the unit test
IF OBJECT_ID('expectedGLDetail') IS NOT NULL 
	DROP TABLE expectedGLDetail

IF OBJECT_ID('actualGLDetail') IS NOT NULL 
	DROP TABLE actualGLDetail

IF OBJECT_ID('expectedInventoryTransaction') IS NOT NULL 
	DROP TABLE expectedInventoryTransaction

IF OBJECT_ID('actualInventoryTransaction') IS NOT NULL 
	DROP TABLE actualInventoryTransaction
	
IF OBJECT_ID('expectedItemStock') IS NOT NULL 
	DROP TABLE expectedItemStock

IF OBJECT_ID('actualItemStock') IS NOT NULL 
	DROP TABLE actualItemStock	
	
IF OBJECT_ID('expectedActualCost') IS NOT NULL 
	DROP TABLE expectedActualCost

IF OBJECT_ID('actualActualCost') IS NOT NULL 
	DROP TABLE actualActualCost