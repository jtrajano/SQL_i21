﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting on FIFO for scenario 4, unpost add stock, unpost sell stock]
AS
-- Arrange 
BEGIN 
	EXEC [testi21Database].[Fake posted transactions using FIFO, scenario 4];
	
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

	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @intTransactionId AS INT
	DECLARE @strTransactionId AS NVARCHAR(40)
	DECLARE @intEntityUserSecurityId AS INT

	DECLARE @GLDetail AS dbo.RecapTableType
		
	DECLARE @UseGLAccount_Inventory AS NVARCHAR(30) = 'Inventory';
	DECLARE @UseGLAccount_AutoNegative AS NVARCHAR(30) = 'Auto-Variance';
	
	DECLARE @AUTO_NEGATIVE AS INT = 1

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
		,dblCost NUMERIC(38, 20)
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
		,dblCost NUMERIC(38, 20)
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
	
	CREATE TABLE expectedFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(38, 20)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)
	
	CREATE TABLE actualFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(38, 20)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)	
END 

-- Act 1
-- Unpost Add Stock 
BEGIN
	SET @strBatchId = 'BATCH-0000003'
	SET @intTransactionId = 1
	SET @strTransactionId = 'InvRcpt-00001'
	SET @intEntityUserSecurityId = 1

	-- Setup the expected data. 
	-- BEGIN Reverse the posted GL entries
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
	-- Expect the g/l entries from the receipt to be reversed
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
				CASE	WHEN intJournalLineNo = 6 THEN 21
						WHEN intJournalLineNo = 7 THEN 22
						WHEN intJournalLineNo = 8 THEN 23						
						WHEN intJournalLineNo = 9 THEN 24
						WHEN intJournalLineNo = 10 THEN 25
						WHEN intJournalLineNo = 11 THEN 26						
						WHEN intJournalLineNo = 12 THEN 27
						WHEN intJournalLineNo = 13 THEN 28
						WHEN intJournalLineNo = 14 THEN 29
						WHEN intJournalLineNo = 15 THEN 30
						WHEN intJournalLineNo = 16 THEN 31
						WHEN intJournalLineNo = 17 THEN 32
						WHEN intJournalLineNo = 18 THEN 33
						WHEN intJournalLineNo = 19 THEN 34
						WHEN intJournalLineNo = 20 THEN 35
				END 
			,ysnIsUnposted = 1
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	dbo.tblGLDetail
	WHERE	tblGLDetail.intTransactionId = @intTransactionId
			AND tblGLDetail.strTransactionId = @strTransactionId
	-- END Reverse the posted GL entries	
	
	-- BEGIN Reverse of the inventory transactions
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
	-- Expect the original receipt to be marked as unposted
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
	-- Expect new inventory transactions are created to reverse the original receipt
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
			-- Reverse the value
			-- {
				,dblValue = dblValue * -1
			-- {
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId = @strBatchId
			,Trans.intTransactionTypeId 
			,ysnIsUnposted = 1
			,intRelatedInventoryTransactionId = intInventoryTransactionId
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,Trans.strTransactionForm 
	FROM	dbo.tblICInventoryTransaction Trans INNER JOIN dbo.tblICInventoryTransactionType ICType
				ON Trans.intTransactionTypeId = ICType.intTransactionTypeId
	WHERE	Trans.intTransactionId = @intTransactionId
			AND Trans.strTransactionId = @strTransactionId
			AND ICType.strName <> 'Inventory Auto Variance'				
	-- END Reverse of the inventory transactions

	-- BEGIN Setup the expected Item Stock
	-- Expect the stock to go down to negative. 
	INSERT INTO expectedItemStock (
			intItemId
			,intItemLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = 1
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @StickyGrains
			,intItemLocationId = 2
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @ColdGrains
			,intItemLocationId = 4
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @HotGrains
			,intItemLocationId = 5
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	-- END Setup the expected Item Stock

	-- BEGIN Setup the expected FIFO data
	INSERT INTO expectedFIFO (
			intInventoryFIFOId
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
	-------------------------------------------------
	-- Return the stock to the negative cost bucket
	SELECT	intInventoryFIFOId = 1
			,intItemId = @WetGrains
			,intItemLocationId = 1
			,intItemUOMId = @WetGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 2
			,intItemId = @StickyGrains			
			,intItemLocationId = 2
			,intItemUOMId = @StickyGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 3
			,intItemId = @PremiumGrains
			,intItemLocationId = 3
			,intItemUOMId = @PremiumGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 4
			,intItemId = @ColdGrains
			,intItemLocationId = 4
			,intItemUOMId = @ColdGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1						
	UNION ALL 
	SELECT	intInventoryFIFOId = 5
			,intItemId = @HotGrains
			,intItemLocationId = 5
			,intItemUOMId = @HotGrains_BushelUOMId
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	--------------------------------------------------------
	-- Plug the following cost bucket because of the unpost
	UNION ALL 
	SELECT	intInventoryFIFOId = 6
			,intItemId = @WetGrains
			,intItemLocationId = 1
			,intItemUOMId = @WetGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 7
			,intItemId = @StickyGrains
			,intItemLocationId = 2
			,intItemUOMId = @StickyGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 8
			,intItemId = @PremiumGrains
			,intItemLocationId = 3
			,intItemUOMId = @PremiumGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 9
			,intItemId = @ColdGrains
			,intItemLocationId = 4
			,intItemUOMId = @ColdGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1						
	UNION ALL 
	SELECT	intInventoryFIFOId = 10
			,intItemId = @HotGrains
			,intItemLocationId = 5
			,intItemUOMId = @HotGrains_BushelUOMId
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1		
	-- END Setup the expected FIFO data

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

-- Act
-- Unpost Sell Stock
BEGIN 
	SET @strBatchId = 'BATCH-0000004'
	SET @intTransactionId = 1
	SET @strTransactionId = 'InvShip-00001'
	SET @intEntityUserSecurityId = 1

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
			,intJournalLineNo = intJournalLineNo + 35
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

			
	-- BEGIN Setup the expected Item Stock
	-- Return 75 stocks back into the system. 
	-- Expect the stock qty to be zero. Average cost should remain at 2.15
	UPDATE	expectedItemStock
	SET		dblUnitOnHand += 75
			,dblAverageCost = 2.0 
	-- END Setup the expected Item Stock

	-- BEGIN Setup the expected FIFO data
	UPDATE	expectedFIFO
	SET		dblStockIn = 75
			,dblStockOut = 75
	FROM	expectedFIFO
	WHERE	strTransactionId = 'InvShip-00001'

	UPDATE	expectedFIFO
	SET		dblStockIn = 100
			,dblStockOut = 100
	FROM	expectedFIFO
	WHERE	strTransactionId = 'InvRcpt-00001'
	-- END Setup the expected FIFO data			

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
			,strTransactionForm 
	FROM	dbo.tblICInventoryTransaction Trans 
	
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

	-- Actual fifo data 
	INSERT INTO actualFIFO (
			intInventoryFIFOId
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
	SELECT	intInventoryFIFOId
			,fifo.intItemId
			,fifo.intItemLocationId
			,fifo.intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId		
	FROM	dbo.tblICInventoryFIFO fifo INNER JOIN dbo.tblICItemLocation ItemLocation
				ON fifo.intItemId = ItemLocation.intItemId
				AND fifo.intItemLocationId = ItemLocation.intItemLocationId
	WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @HotGrains, @ColdGrains)
			AND ItemLocation.intLocationId = @Default_Location
				
	EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail', 'Failed to meet the expected GL Detail.';
	EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction', 'Failed to meet the expected Inventory Transaction records.';
	EXEC tSQLt.AssertEqualsTable 'expectedItemStock', 'actualItemStock', 'Failed to meet the expected Item Stock records.';
	EXEC tSQLt.AssertEqualsTable 'expectedFIFO', 'actualFIFO', 'Failed to meet the expected FIFO records.';
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
	
IF OBJECT_ID('expectedFIFO') IS NOT NULL 
	DROP TABLE expectedFIFO

IF OBJECT_ID('actualFIFO') IS NOT NULL 
	DROP TABLE actualFIFO
