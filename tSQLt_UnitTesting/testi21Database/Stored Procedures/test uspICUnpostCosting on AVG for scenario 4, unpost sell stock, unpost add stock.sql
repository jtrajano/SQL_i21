CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting for scenario 4, unpost sell stock, unpost add stock]
AS
-- Arrange 
BEGIN 
	EXEC [testi21Database].[Fake posted transactions using AVG, scenario 4];
	
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

	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @intTransactionId AS INT
	DECLARE @strTransactionId AS NVARCHAR(40)
	DECLARE @intUserId AS INT

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
		,dtmDate DATETIME
		,dblUnitQty NUMERIC(18,6)
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
		,dtmDate DATETIME
		,dblUnitQty NUMERIC(18,6)
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
	
	CREATE TABLE expectedFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)
	
	CREATE TABLE actualFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)	
END 

-- Act
-- Unpost Sell stock
BEGIN
	SET @strBatchId = 'BATCH-0000003'
	SET @intTransactionId = 1
	SET @strTransactionId = 'InvShip-00001'
	SET @intUserId = 1

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
			,dtmDate 
			,dblUnitQty 
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
			,dtmDate 
			,dblUnitQty 
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
			,dtmDate 
			-- Reverse the unit qty
			--{
				,dblUnitQty = dblUnitQty * -1
			--}
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
	SELECT	intItemId 
			,intItemLocationId 
			,dtmDate 
			,dblUnitQty 
			,dblCost 
			,dblValue 
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId
			,tblICInventoryTransaction.intTransactionTypeId 
			,ysnIsUnposted = 1
			,intRelatedInventoryTransactionId 
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,strTransactionForm 
	FROM	dbo.tblICInventoryTransaction INNER JOIN dbo.tblICInventoryTransactionType ICType
				ON tblICInventoryTransaction.intTransactionTypeId = ICType.intTransactionTypeId
	WHERE	intRelatedTransactionId = @intTransactionId
			AND strRelatedTransactionId = @strTransactionId
			AND ICType.strName <> 'Inventory Auto Negative'			
	---------------------------------------------------------------------------------
	-- Expect new transactions that reverses the revalue and write-off transactions 		
	UNION ALL 
	SELECT	intItemId 
			,intItemLocationId 
			,dtmDate 
			-- Reverse the unit qty
			--{
				,dblUnitQty = dblUnitQty * -1
			--}
			,dblCost 
			,dblValue = dblValue * -1
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId = @strBatchId
			,tblICInventoryTransaction.intTransactionTypeId 
			,ysnIsUnposted = 1
			,intRelatedInventoryTransactionId = intInventoryTransactionId
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,strTransactionForm 
	FROM	dbo.tblICInventoryTransaction INNER JOIN dbo.tblICInventoryTransactionType ICType
				ON tblICInventoryTransaction.intTransactionTypeId = ICType.intTransactionTypeId
	WHERE	intRelatedTransactionId = @intTransactionId
			AND strRelatedTransactionId = @strTransactionId
			AND ICType.strName <> 'Inventory Auto Negative'
			
	-- Setup the expected Item Stock
	-- Expect the stock to be back at 100. The average cost should remain the same. 
	INSERT INTO expectedItemStock (
			intItemId
			,intItemLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = 1
			,dblAverageCost = 2.15
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @StickyGrains
			,intItemLocationId = 2
			,dblAverageCost = 2.15
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dblAverageCost = 2.15
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @ColdGrains
			,intItemLocationId = 4
			,dblAverageCost = 2.15
			,dblUnitOnHand = 100
	UNION ALL
	SELECT	intItemId = @HotGrains
			,intItemLocationId = 5
			,dblAverageCost = 2.15
			,dblUnitOnHand = 100
			
	-- Setup the expected FIFO data
	INSERT INTO dbo.expectedFIFO (
			intInventoryFIFOId
			,intItemId
			,intItemLocationId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
	)	
	--------------------------------------------
	-- Plug-out the negative cost bucket. 
	SELECT	intInventoryFIFOId = 1
			,intItemId = @WetGrains
			,intItemLocationId = 1
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 2
			,intItemId = @StickyGrains
			,intItemLocationId = 2
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 3
			,intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 4
			,intItemId = @ColdGrains
			,intItemLocationId = 4
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1						
	UNION ALL 
	SELECT	intInventoryFIFOId = 5
			,intItemId = @HotGrains
			,intItemLocationId = 5
			,dtmDate = '01/01/2014'
			,dblStockIn = 75
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	--------------------------------------------
	-- Return the stock to right fifo cost bucket. 	
	UNION ALL 
	SELECT	intInventoryFIFOId = 6
			,intItemId = @WetGrains
			,intItemLocationId = 1
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 7
			,intItemId = @StickyGrains
			,intItemLocationId = 2
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 8
			,intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 9
			,intItemId = @ColdGrains
			,intItemLocationId = 4
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1						
	UNION ALL 
	SELECT	intInventoryFIFOId = 10
			,intItemId = @HotGrains
			,intItemLocationId = 5
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 0
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
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

-- Act
-- Unpost the add stock 
BEGIN 
	SET @strBatchId = 'BATCH-0000004'
	SET @intTransactionId = 1
	SET @strTransactionId = 'InvRcpt-00001'
	SET @intUserId = 1

	-- BEGIN Reverse the posted GL entries
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
				CASE	WHEN intJournalLineNo = 6 THEN 36
						WHEN intJournalLineNo = 9 THEN 37
						WHEN intJournalLineNo = 12 THEN 38						
						WHEN intJournalLineNo = 15 THEN 39
						WHEN intJournalLineNo = 18 THEN 40
				END 
			,ysnIsUnposted = 1
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	dbo.tblGLDetail
	WHERE	tblGLDetail.intTransactionId = @intTransactionId
			AND tblGLDetail.strTransactionId = @strTransactionId
			AND intJournalLineNo IN (6, 9, 12, 15, 18)
	
	-- BEGIN Reverse of the inventory transactions
	INSERT INTO expectedInventoryTransaction (
			intItemId 
			,intItemLocationId 
			,dtmDate 
			,dblUnitQty 
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
			,dtmDate 
			,dblUnitQty 
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
			AND intInventoryTransactionId IN (6, 9, 12, 15, 18)
	---------------------------------------------------------------------------------
	-- Expect new inventory transactions are created to reverse the original receipt
	UNION ALL 
	SELECT	intItemId 
			,intItemLocationId 
			,dtmDate 
			-- Reverse the unit qty
			--{
				,dblUnitQty = dblUnitQty * -1
			--}
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
			,strTransactionForm 
	FROM	dbo.tblICInventoryTransaction Trans INNER JOIN dbo.tblICInventoryTransactionType IType
				ON Trans.intTransactionTypeId = IType.intTransactionTypeId
	WHERE	Trans.intTransactionId = @intTransactionId
			AND Trans.strTransactionId = @strTransactionId
			AND IType.strName <> 'Inventory Auto Negative'
			AND intInventoryTransactionId IN (6, 9, 12, 15, 18)	

	-- BEGIN Setup the expected Item Stock
	-- Expect the stock qty to be zero. Average cost should remain at 2.15
	UPDATE	expectedItemStock
	SET		dblUnitOnHand -= 100
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
	)
	EXEC dbo.uspICUnpostCosting
		@intTransactionId
		,@strTransactionId
		,@strBatchId
		,@intUserId
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
			,dtmDate 
			,dblUnitQty 
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
			,dtmDate 
			,dblUnitQty 
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
	INSERT INTO dbo.actualFIFO (
			intInventoryFIFOId
			,intItemId
			,intItemLocationId
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
				
	EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail';
	EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction';
	EXEC tSQLt.AssertEqualsTable 'expectedItemStock', 'actualItemStock';
	EXEC tSQLt.AssertEqualsTable 'expectedFIFO', 'actualFIFO';
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
	
IF OBJECT_ID('expectedFIFO') IS NOT NULL 
	DROP TABLE expectedFIFO

IF OBJECT_ID('actualFIFO') IS NOT NULL 
	DROP TABLE dbo.actualFIFO