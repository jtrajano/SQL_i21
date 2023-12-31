﻿CREATE PROCEDURE [testi21Database].[test uspICCreateReversalGLEntries for reversing GL entries]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';
		DECLARE @AUTO_NEGATIVE_Name AS NVARCHAR(50) = 'Inventory Auto Variance';
		DECLARE @WRITEOFF_SOLD_Name AS NVARCHAR(50) = 'Inventory Write-Off Sold';
		DECLARE @REVALUE_SOLD_Name AS NVARCHAR(50) = 'Inventory Revalue Sold';
		
		-- Fake data
		EXEC [testi21Database].[Fake posted transactions for testing the unposting]

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
		DECLARE @WRITE_OFF_SOLD AS INT = 2
		DECLARE @REVALUE_SOLD AS INT = 3
		DECLARE @PurchaseType AS INT = 4
		DECLARE @SaleType AS INT = 4

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

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;
		
		-- Add fake data that reverses the Purchase transaction
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedInventoryTransactionId, ysnIsUnposted) VALUES (@WetGrains, @Default_Location, @WetGrains_BushelUOMId, 'January 1, 2014', -100, 1, 22.00, NULL, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100001', @PurchaseType, NULL, 1, 2, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, intRelatedInventoryTransactionId, ysnIsUnposted) VALUES (@WetGrains, @Default_Location, NULL, 'January 1, 2014', 0, 1, 0.00, 2200.00, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100001', @WRITE_OFF_SOLD, NULL, 1, 1, 'SALE-100000', 3, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, intRelatedInventoryTransactionId, ysnIsUnposted) VALUES (@WetGrains, @Default_Location, NULL, 'January 1, 2014', 0, 1, 0.00, -2000.00, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100001', @REVALUE_SOLD, NULL, 1, 1, 'SALE-100000', 4, 1)
		--INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId, intRelatedTransactionId, strRelatedTransactionId, intRelatedInventoryTransactionId, ysnIsUnposted) VALUES (@WetGrains, @Default_Location, NULL, 'January 1, 2014', 0, 1, 0.00, 0, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100001', @AUTO_NEGATIVE, NULL, 1, NULL, NULL, 5, 1)
		
		-- Create the expected and actual tables. 
		DECLARE @recap AS dbo.RecapTableType		
		SELECT * INTO expected FROM @recap		
		SELECT * INTO actual FROM @recap

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE expected
		DROP COLUMN dtmDateEntered	
		
		-- Setup the expected data
		INSERT INTO expected (
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
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
		)
		-- PURCHASE-100000
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100001'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = (100 * 22)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = 10
				,ysnIsUnposted = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = 1 
				,strTransactionType = 'Inventory Receipt'
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100001'
				,intAccountId = @CostOfGoods_Default
				,dblDebit = (100 * 22)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IC'
				,strReference = ''
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = 10
				,ysnIsUnposted = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = 1
				,strTransactionType = 'Inventory Receipt'
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @CostOfGoods_Default
		-- WRITE-OFF SOLD
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100001'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = (100 * 20)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IWS'
				,strReference = ''
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = 11
				,ysnIsUnposted = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = 1 
				,strTransactionType = 'Inventory Write-Off Sold'
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100001'
				,intAccountId = @WriteOffSold_Default
				,dblDebit = (100 * 20)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IWS'
				,strReference = ''
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = 11
				,ysnIsUnposted = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = 1 
				,strTransactionType = 'Inventory Write-Off Sold'
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @WriteOffSold_Default
		-- REVALUE SOLD
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100001'
				,intAccountId = @Inventory_Default
				,dblDebit = (100 * 22)
				,dblCredit = 0
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IRS'
				,strReference = ''
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = 12
				,ysnIsUnposted = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = 1 
				,strTransactionType = 'Inventory Revalue Sold'
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,strBatchId = 'BATCH-100001'
				,intAccountId = @WriteOffSold_Default
				,dblDebit = 0
				,dblCredit = (100 * 22)
				,dblDebitUnit = 0 
				,dblCreditUnit = 0 
				,strDescription = GLAccount.strDescription
				,strCode = 'IRS'
				,strReference = ''
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,dtmTransactionDate = '01/01/2014'
				,strJournalLineDescription = ''
				,intJournalLineNo = 12
				,ysnIsUnposted = 1
				,intEntityId = 1
				,strTransactionId = 'PURCHASE-100000'
				,intTransactionId = 1 
				,strTransactionType = 'Inventory Revalue Sold'
				,strTransactionForm = 'Inventory Receipt'
				,strModuleName = 'Inventory'
				,intConcurrencyId = 1
		FROM	dbo.tblGLAccount GLAccount
		WHERE	GLAccount.intAccountId = @RevalueSold_Default
	END 
	
	-- Act
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-100001'
				,@intTransactionId AS INT = 1
				,@strTransactionId AS NVARCHAR(40) = 'PURCHASE-100000'
				,@intEntityUserSecurityId AS INT = 1

		INSERT INTO actual 
		EXEC dbo.uspICCreateReversalGLEntries
			@strBatchId
			,@intTransactionId
			,@strTransactionId
			,@intEntityUserSecurityId

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE actual 
		DROP COLUMN dtmDateEntered
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END