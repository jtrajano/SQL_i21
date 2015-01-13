CREATE PROCEDURE [testi21Database].[Fake posted transactions for testing the unposting]
AS
BEGIN
	EXEC testi21Database.[Fake inventory items]

	-- Define the additional tables to fake
	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;
	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

	-- Declare the account ids
	DECLARE @Inventory_Default AS INT = 1000
	DECLARE @CostOfGoods_Default AS INT = 2000
	DECLARE @APClearing_Default AS INT = 3000
	DECLARE @WriteOffSold_Default AS INT = 4000
	DECLARE @RevalueSold_Default AS INT = 5000 
	DECLARE @AutoNegative_Default AS INT = 6000

	DECLARE @Inventory_NewHaven AS INT = 1001
	DECLARE @CostOfGoods_NewHaven AS INT = 2001
	DECLARE @APClearing_NewHaven AS INT = 3001
	DECLARE @WriteOffSold_NewHaven AS INT = 4001
	DECLARE @RevalueSold_NewHaven AS INT = 5001
	DECLARE @AutoNegative_NewHaven AS INT = 6001

	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002

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
	
	-- Declare the transaction types
	DECLARE @AUTO_NEGATIVE AS INT = 1
	DECLARE @WRITE_OFF_SOLD AS INT = 2
	DECLARE @REVALUE_SOLD AS INT = 3
	DECLARE @PurchaseType AS INT = 4
	DECLARE @SalesType AS INT = 5

	
	DECLARE @AUTO_NEGATIVE_NAME AS NVARCHAR(255) = 'Inventory Auto Negative'
	DECLARE @WRITE_OFF_SOLD_NAME AS NVARCHAR(255) = 'Inventory Write-Off Sold'
	DECLARE @REVALUE_SOLD_NAME AS NVARCHAR(255) = 'Inventory Revalue Sold'	
	DECLARE @PURCHASE_TYPE_NAME AS NVARCHAR(255) = 'Inventory Receipt'
	DECLARE @SALES_TYPE_NAME AS NVARCHAR(255) = 'Inventory Shipment'
	--1	Inventory Auto Negative
	--2	Inventory Write-Off Sold
	--3	Inventory Revalue Sold
	--4	Inventory Receipt
	--5	Inventory Shipment


	DECLARE @TransactionId AS INT 
	DECLARE @JournalId AS INT 

	-- Fake data for item stock table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @Default_Location, 100, 22)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @Default_Location, 150, 33)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @Default_Location, 200, 44)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @Default_Location, 250, 55)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @Default_Location, 300, 66)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @NewHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @NewHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @NewHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @NewHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @NewHaven, 0, 0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @BetterHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @BetterHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @BetterHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @BetterHaven, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @BetterHaven, 0, 0)
	END

	-- Fake data for tblICInventoryFIFO
	BEGIN
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 100, 0, 22.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@StickyGrains, @Default_Location, 'January 1, 2014', 150, 0, 33.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@PremiumGrains, @Default_Location, 'January 1, 2014', 200, 0, 44.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@ColdGrains, @Default_Location, 'January 1, 2014', 250, 0, 55.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@HotGrains, @Default_Location, 'January 1, 2014', 300, 0, 66.00, 1)
	END 

	-- Fake data for tblICInventoryTransaction
	BEGIN 
		-- Sale Transaction (Negative stock)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', -100, 20.00, NULL, 0, 1, 1, 1, 'SALE-100000', 'BATCH-100000', @SalesType, NULL, 1, NULL, NULL, 'Inventory Shipment')
		
		-- Purchase Transaction (To Offset the negative stock)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 100, 22.00, NULL, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-200000', @PurchaseType, NULL, 1, NULL, NULL, 'Inventory Receipt')
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 0, 0.00, -2200.00, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-200000', @WRITE_OFF_SOLD, NULL, 1, 1, 'SALE-100000', 'Inventory Receipt')
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 0, 0.00, 2000.00, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-200000', @REVALUE_SOLD, NULL, 1, 1, 'SALE-100000', 'Inventory Receipt')
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 0, 0.00, 0, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-200000', @AUTO_NEGATIVE, NULL, 1, NULL, NULL, 'Inventory Receipt')

		-- Additional purchase transactions for other items (Positive stock)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@StickyGrains, @Default_Location, 'January 1, 2014', 150, 33.00, NULL, 0, 1, 1, 2, 'PURCHASE-200000', 'BATCH-300000', @PurchaseType, NULL, 1, NULL, NULL, 'Inventory Receipt')
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@PremiumGrains, @Default_Location, 'January 1, 2014', 200, 44.00, NULL, 0, 1, 1, 3, 'PURCHASE-300000', 'BATCH-400000', @PurchaseType, NULL, 1, NULL, NULL, 'Inventory Receipt')
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@ColdGrains, @Default_Location, 'January 1, 2014', 250, 55.00, NULL, 0, 1, 1, 4, 'PURCHASE-400000', 'BATCH-500000', @PurchaseType, NULL, 1, NULL, NULL, 'Inventory Receipt')
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, strTransactionForm) VALUES (@HotGrains, @Default_Location, 'January 1, 2014', 300, 66.00, NULL, 0, 1, 1, 5, 'PURCHASE-500000', 'BATCH-600000', @PurchaseType, NULL, 1, NULL, NULL, 'Inventory Receipt')
	END 

	-- Add fake data into tblGLDetail
	BEGIN 		
		SET @TransactionId = 1
		SET @JournalId = 1
		INSERT INTO tblGLDetail (
				dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)
		-- SALE-100000
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100000'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = (100 * 20)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'SALE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @SALES_TYPE_NAME
				,strTransactionForm = 'Inventory Shipment'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100000'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = (100 * 20)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'SALE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @SALES_TYPE_NAME
				,strTransactionForm = 'Inventory Shipment'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
		
		
		-- PURCHASE-100000
		SET @TransactionId = 1
		SET @JournalId = 2
		INSERT INTO tblGLDetail (
				dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)		
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @Inventory_Default
				,dblDebit = (100 * 22)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = 0
				,dblCredit = (100 * 22)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
		-- WRITE-OFF SOLD
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @Inventory_Default
				,dblDebit = (100 * 20)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IWS'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId + 1
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @WRITE_OFF_SOLD_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @WriteOffSold_Default
				,dblDebit = 0
				,dblCredit = (100 * 20)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IWS'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId + 1
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @WRITE_OFF_SOLD_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @WriteOffSold_Default
		-- REVALUE SOLD
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = (100 * 22)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IRS'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId + 2
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @REVALUE_SOLD_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @WriteOffSold_Default
				,dblDebit = (100 * 22)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IRS'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId + 2
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @REVALUE_SOLD_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @RevalueSold_Default

		-- AUTO NEGATIVE
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IRS'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId + 3
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @AUTO_NEGATIVE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-200000'
				,intAccountId = @AutoNegative_Default
				,dblDebit = 0
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IRS'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId + 3
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @AUTO_NEGATIVE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @AutoNegative_Default
	END 

	-- Add fake data for PURCHASE-200000
	BEGIN 	
		SET @TransactionId = 2
		SET @JournalId = 6
		INSERT INTO tblGLDetail (
				dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)		
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-300000'
				,intAccountId = @Inventory_Default
				,dblDebit = (150 * 33)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-200000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-300000'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = 0
				,dblCredit = (150 * 33)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-200000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
	END

	-- Add fake data for PURCHASE-300000
	BEGIN 
		SET @TransactionId = 3
		SET @JournalId = 7
		INSERT INTO tblGLDetail (
				dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)		
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-400000'
				,intAccountId = @Inventory_Default
				,dblDebit = (200 * 44)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-300000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-300000'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = 0
				,dblCredit = (200 * 44)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-300000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
	END

	-- Add fake data for PURCHASE-400000
	BEGIN 
		SET @TransactionId = 4
		SET @JournalId = 8
		INSERT INTO tblGLDetail (
				dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)		
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-500000'
				,intAccountId = @Inventory_Default
				,dblDebit = (250 * 55)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-400000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-500000'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = 0
				,dblCredit = (250 * 55)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-400000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
	END

	-- Add fake data for PURCHASE-500000
	BEGIN 
		SET @TransactionId = 5
		SET @JournalId = 9
		INSERT INTO tblGLDetail (
				dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)		
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-600000'
				,intAccountId = @Inventory_Default
				,dblDebit = (300 * 66)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-500000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-600000'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = 0
				,dblCredit = (300 * 66)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = 1
				,dblExchangeRate = 1
				,dtmDateEntered = GETDATE()
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = @JournalId
				,ysnIsUnposted = 0
				,intUserId = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-500000'
				,intTransactionId = @TransactionId 
				,strTransactionType = @PURCHASE_TYPE_NAME
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
	END
END