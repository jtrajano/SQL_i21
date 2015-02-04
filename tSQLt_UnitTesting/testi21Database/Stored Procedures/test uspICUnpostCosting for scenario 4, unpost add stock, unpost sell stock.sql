CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting for scenario 4, unpost add stock, unpost sell stock]
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
		
	DECLARE @UseGLAccount_Inventory AS NVARCHAR(30) = 'Inventory';
	DECLARE @UseGLAccount_AutoNegative AS NVARCHAR(30) = 'Auto-Negative';
	
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
		,intLocationId INT
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
		,intLocationId INT
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
		,intLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)

	CREATE TABLE actualItemStock (
		intItemId INT
		,intLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)
	
	CREATE TABLE expectedFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intLocationId INT
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
		,intLocationId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)	
END 

-- Act
-- Unpost Add Stock 
BEGIN
	SET @strBatchId = 'BATCH-0000003'
	SET @intTransactionId = 1
	SET @strTransactionId = 'InvRcpt-00001'
	SET @intUserId = 1

	-- Setup the expected data. 
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
	-------------------------------------------------------------
	-- Expect AUTO NEGATIVE G/L entries
	UNION ALL 
	SELECT	dtmDate = '01/16/2014'
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = 0
			,dblCredit = ABS((-75 * 2.15) - (-75 * 2.00))
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = GLAccount.strDescription
			,strCode = 'IAN'
			,intJournalLineNo = 
				CASE	WHEN  InventoryAccountSetup.intItemId = @WetGrains THEN 36
						WHEN  InventoryAccountSetup.intItemId = @StickyGrains THEN 37
						WHEN  InventoryAccountSetup.intItemId = @PremiumGrains THEN 38
						WHEN  InventoryAccountSetup.intItemId = @ColdGrains THEN 39
						WHEN  InventoryAccountSetup.intItemId = @HotGrains THEN 40
				END 
			,ysnIsUnposted = 0
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
			,strModuleName = 'Inventory'
	FROM	(
				SELECT Stock.intItemId, Stock.intLocationId, Inventory.intAccountId FROM dbo.tblICItemStock Stock
				OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intLocationId, @UseGLAccount_Inventory) Inventory
			) InventoryAccountSetup
			INNER JOIN dbo.tblGLAccount GLAccount
				ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId				
	WHERE	InventoryAccountSetup.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			AND InventoryAccountSetup.intLocationId = @Default_Location
			
	UNION ALL 
	SELECT	dtmDate = '01/16/2014'
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = ABS((-75 * 2.15) - (-75 * 2.00))
			,dblCredit = 0
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = GLAccount.strDescription
			,strCode = 'IAN'
			,intJournalLineNo = 
				CASE	WHEN  InventoryAccountSetup.intItemId = @WetGrains THEN 36
						WHEN  InventoryAccountSetup.intItemId = @StickyGrains THEN 37
						WHEN  InventoryAccountSetup.intItemId = @PremiumGrains THEN 38
						WHEN  InventoryAccountSetup.intItemId = @ColdGrains THEN 39
						WHEN  InventoryAccountSetup.intItemId = @HotGrains THEN 40
				END 
			,ysnIsUnposted = 0
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
			,strModuleName = 'Inventory'
	FROM	(
				SELECT	Stock.intItemId, Stock.intLocationId, AutoNegative.intAccountId 
				FROM	dbo.tblICItemStock Stock
						OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intLocationId, @UseGLAccount_AutoNegative) AutoNegative
			) InventoryAccountSetup
			INNER JOIN dbo.tblGLAccount GLAccount
				ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId
	WHERE	InventoryAccountSetup.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			AND InventoryAccountSetup.intLocationId = @Default_Location					
	-- END Reverse the posted GL entries	
	
	-- BEGIN Reverse of the inventory transactions
	INSERT INTO expectedInventoryTransaction (
			intItemId 
			,intLocationId 
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
			,intLocationId 
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
	-- Expect new inventory transactions are created to reverse the original receipt
	UNION ALL 
	SELECT	intItemId 
			,intLocationId 
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
	-----------------------------------------------------------------------------------
	-- Expect the auto negative transactions
	UNION ALL 
	SELECT	intItemId 
			,intLocationId 
			,dtmDate = '01/16/2014'
			,dblUnitQty = 0
			,dblCost = 0
			,dblValue = (-75 * 2.15) - (-75 * 2.00)
			,dblSalesPrice = 0
			,intTransactionId = @intTransactionId
			,strTransactionId = @strTransactionId
			,strBatchId = @strBatchId
			,intTransactionTypeId = @AUTO_NEGATIVE
			,ysnIsUnposted = 0
			,intRelatedInventoryTransactionId = NULL
			,intRelatedTransactionId = NULL
			,strRelatedTransactionId = NULL
			,strTransactionForm = NULL
	FROM	(
				SELECT	Stock.intItemId, Stock.intLocationId, AutoNegative.intAccountId 
				FROM	dbo.tblICItemStock Stock
						OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intLocationId, @UseGLAccount_AutoNegative) AutoNegative
			) InventoryAccountSetup
			INNER JOIN dbo.tblGLAccount GLAccount
				ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId
	WHERE	InventoryAccountSetup.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			AND InventoryAccountSetup.intLocationId = @Default_Location	
	-- END Reverse of the inventory transactions

	-- BEGIN Setup the expected Item Stock
	-- Expect the stock to go down to negative. 
	INSERT INTO expectedItemStock (
			intItemId
			,intLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @StickyGrains
			,intLocationId = @Default_Location
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @PremiumGrains
			,intLocationId = @Default_Location
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @ColdGrains
			,intLocationId = @Default_Location
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	UNION ALL
	SELECT	intItemId = @HotGrains
			,intLocationId = @Default_Location
			,dblAverageCost = 2.15
			,dblUnitOnHand = -75
	-- END Setup the expected Item Stock

	-- BEGIN Setup the expected FIFO data
	INSERT INTO dbo.expectedFIFO (
			intInventoryFIFOId
			,intItemId
			,intLocationId
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
			,intLocationId = @Default_Location
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 2
			,intItemId = @StickyGrains
			,intLocationId = @Default_Location
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 3
			,intItemId = @PremiumGrains
			,intLocationId = @Default_Location
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 4
			,intItemId = @ColdGrains
			,intLocationId = @Default_Location
			,dtmDate = '01/01/2014'
			,dblStockIn = 0
			,dblStockOut = 75
			,dblCost = 2.00
			,strTransactionId = 'InvShip-00001'
			,intTransactionId = 1						
	UNION ALL 
	SELECT	intInventoryFIFOId = 5
			,intItemId = @HotGrains
			,intLocationId = @Default_Location
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
			,intLocationId = @Default_Location
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 7
			,intItemId = @StickyGrains
			,intLocationId = @Default_Location
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 8
			,intItemId = @PremiumGrains
			,intLocationId = @Default_Location
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1
	UNION ALL 
	SELECT	intInventoryFIFOId = 9
			,intItemId = @ColdGrains
			,intLocationId = @Default_Location
			,dtmDate = '01/16/2014'
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.15
			,strTransactionId = 'InvRcpt-00001'
			,intTransactionId = 1						
	UNION ALL 
	SELECT	intInventoryFIFOId = 10
			,intItemId = @HotGrains
			,intLocationId = @Default_Location
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
	)
	EXEC dbo.uspICUnpostCosting
		@intTransactionId
		,@strTransactionId
		,@strBatchId
		,@intUserId
END 

-- Act
-- Unpost Sell Stock
BEGIN 
	SET @strBatchId = 'BATCH-0000004'
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
			,intJournalLineNo = intJournalLineNo + 40
			,ysnIsUnposted = 1
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	dbo.tblGLDetail
	WHERE	tblGLDetail.intTransactionId = @intTransactionId
			AND tblGLDetail.strTransactionId = @strTransactionId
	-------------------------------------------------------------
	-- Expect AUTO NEGATIVE G/L entries
	UNION ALL 
	SELECT	dtmDate = '01/01/2014'
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = ABS((-75 * 2.15) - (-75 * 2.00))
			,dblCredit = 0
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = GLAccount.strDescription
			,strCode = 'IAN'
			,intJournalLineNo = 
				CASE	WHEN  InventoryAccountSetup.intItemId = @WetGrains THEN 46
						WHEN  InventoryAccountSetup.intItemId = @StickyGrains THEN 47
						WHEN  InventoryAccountSetup.intItemId = @PremiumGrains THEN 48
						WHEN  InventoryAccountSetup.intItemId = @ColdGrains THEN 49
						WHEN  InventoryAccountSetup.intItemId = @HotGrains THEN 50
				END 
			,ysnIsUnposted = 0
			,strTransactionId = @strTransactionId
			,intTransactionId = @intTransactionId
			,strModuleName = 'Inventory'
	FROM	(
				SELECT Stock.intItemId, Stock.intLocationId, Inventory.intAccountId FROM dbo.tblICItemStock Stock
				OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intLocationId, @UseGLAccount_Inventory) Inventory
			) InventoryAccountSetup
			INNER JOIN dbo.tblGLAccount GLAccount
				ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId				
	WHERE	InventoryAccountSetup.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			AND InventoryAccountSetup.intLocationId = @Default_Location
			
	UNION ALL 
	SELECT	dtmDate = '01/01/2014'
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = 0
			,dblCredit = ABS((-75 * 2.15) - (-75 * 2.00))
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = GLAccount.strDescription
			,strCode = 'IAN'
			,intJournalLineNo = 
				CASE	WHEN  InventoryAccountSetup.intItemId = @WetGrains THEN 46
						WHEN  InventoryAccountSetup.intItemId = @StickyGrains THEN 47
						WHEN  InventoryAccountSetup.intItemId = @PremiumGrains THEN 48
						WHEN  InventoryAccountSetup.intItemId = @ColdGrains THEN 49
						WHEN  InventoryAccountSetup.intItemId = @HotGrains THEN 50
				END 
			,ysnIsUnposted = 0
			,strTransactionId = @strTransactionId
			,intTransactionId = @intTransactionId
			,strModuleName = 'Inventory'
	FROM	(
				SELECT	Stock.intItemId, Stock.intLocationId, AutoNegative.intAccountId 
				FROM	dbo.tblICItemStock Stock
						OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intLocationId, @UseGLAccount_AutoNegative) AutoNegative
			) InventoryAccountSetup
			INNER JOIN dbo.tblGLAccount GLAccount
				ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId
	WHERE	InventoryAccountSetup.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			AND InventoryAccountSetup.intLocationId = @Default_Location				

	-- Reverse of the inventory transactions
	INSERT INTO expectedInventoryTransaction (
			intItemId 
			,intLocationId 
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
			,intLocationId 
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
			,intLocationId 
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
	-----------------------------------------------------------------------------------
	-- Expect the auto negative transactions
	UNION ALL 
	SELECT	intItemId 
			,intLocationId 
			,dtmDate = '01/01/2014'
			,dblUnitQty = 0
			,dblCost = 0
			,dblValue = ABS((-75 * 2.15) - (-75 * 2.00))
			,dblSalesPrice = 0
			,intTransactionId = @intTransactionId
			,strTransactionId = @strTransactionId
			,strBatchId = @strBatchId
			,intTransactionTypeId = @AUTO_NEGATIVE
			,ysnIsUnposted = 0
			,intRelatedInventoryTransactionId = NULL
			,intRelatedTransactionId = NULL
			,strRelatedTransactionId = NULL
			,strTransactionForm = NULL
	FROM	(
				SELECT	Stock.intItemId, Stock.intLocationId, AutoNegative.intAccountId 
				FROM	dbo.tblICItemStock Stock
						OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intLocationId, @UseGLAccount_AutoNegative) AutoNegative
			) InventoryAccountSetup
			INNER JOIN dbo.tblGLAccount GLAccount
				ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId
	WHERE	InventoryAccountSetup.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			AND InventoryAccountSetup.intLocationId = @Default_Location
			
	-- BEGIN Setup the expected Item Stock
	-- Return 75 stocks back into the system. 
	-- Expect the stock qty to be zero. Average cost should remain at 2.15
	UPDATE	expectedItemStock
	SET		dblUnitOnHand += 75
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
			,intLocationId 
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
			,intLocationId 
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
			,intLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	intItemId 
			,intLocationId 
			,dblAverageCost 
			,dblUnitOnHand 
	FROM dbo.tblICItemStock		
	
	-- Actual fifo data 
	INSERT INTO dbo.actualFIFO (
			intInventoryFIFOId
			,intItemId
			,intLocationId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
	)	
	SELECT	intInventoryFIFOId
			,intItemId
			,intLocationId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId		
	FROM	dbo.tblICInventoryFIFO
	WHERE	intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @HotGrains, @ColdGrains)
			AND intLocationId IN (@Default_Location)
				
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