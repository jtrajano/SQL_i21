CREATE PROCEDURE [testi21Database].[test uspICPostCosting for multiple incoming and coming stock and GL entries are correct]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake the inventory transaction table 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

		-- Create the fake data
		EXEC testi21Database.[Fake data for item costing];

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3
		DECLARE @PurchaseType AS INT = 1
		DECLARE @SalesType AS INT = 2

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

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

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

		-- Create the expected and actual tables. 
		DECLARE @recap AS dbo.RecapTableType		
		SELECT * INTO expected FROM @recap		
		SELECT * INTO actual FROM @recap

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE expected
		DROP COLUMN dtmDateEntered

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';
		DECLARE @intUserId AS INT = 1;

		-- Setup the items to post
		INSERT INTO @ItemsToPost
		-- in (Stock goes up to 200)
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = 100
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
		-- out (Stock goes down to 170)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = -30
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'SALE-000001'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
		-- out (Stock goes down to 135)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = -35
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'SALE-000002'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
		-- out (Stock goes down to 90)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = -45
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'SALE-000003'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
		-- out (Stock goes down to -42)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = -132
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 27.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'SALE-000004'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
		-- in (Stock goes up to -22)
		UNION ALL		
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = 20
				,dblUOMQty = 1
				,dblCost = 15.50
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000002'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
		-- in (Stock goes up to 0)
		UNION ALL				
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = 22
				,dblUOMQty = 1
				,dblCost = 16.50
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000003'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
		-- in (Stock goes up to 100)
		UNION ALL				
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = 100
				,dblUOMQty = 1
				,dblCost = 18.00
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-000004'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL

		-- Setup the expected g/l entries 
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
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId		
		)
		-- 100 stock in for $14.00
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 1400.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000001'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 0
			,dblCredit					= 1400.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000001'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		-- 30 stock out (18.00 ave cost x 30)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 540.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000001'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 540.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000001'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		-- 35 stock out (18.00 ave cost x 35)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 630.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 630.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		-- 45 stock out (18.00 ave cost x 45)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 810.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 810.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		-- 132 stock out (18.00 ave cost x 132)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 2376.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000004'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 2376.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-000004'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1		
			
		-- 20 stock in for $15.50
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 310.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1 
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 0
			,dblCredit					= 310.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		
		-- 20 stock in for $15.50 (Write-off sold)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 360.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1 
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @WriteOffSold_Default
			,dblDebit					= 0
			,dblCredit					= 360.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
			
		-- 20 stock in for $15.50 (Revalue sold)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 310.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1 
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @RevalueSold_Default
			,dblDebit					= 310.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
			
		-- 20 stock in for $15.50 (Auto-Negative)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 55.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1 
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @AutoNegative_Default
			,dblDebit					= 0
			,dblCredit					= 55.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000002'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1			
						
		-- 22 stock in for $16.50
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 363.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 0
			,dblCredit					= 363.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
			
		-- 22 stock in for $16.50 (Write-off sold)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 341.00 -- (15.50 x 22)
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1 
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @WriteOffSold_Default
			,dblDebit					= 0
			,dblCredit					= 341.00 -- (15.50 x 22)
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
			
		-- 22 stock in for $16.50 (Revalue sold)
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 363.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1 
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @RevalueSold_Default
			,dblDebit					= 363.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000003'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
			
		-- Nothing to auto-negative since stock is zero. 
			
		-- 100 stock in for $18.00
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 1800.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000004'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 0
			,dblCredit					= 1800.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'PURCHASE-000004'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
	END 
	
	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries 
		INSERT INTO actual 
		EXEC dbo.uspICPostCosting
			@ItemsToPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intUserId

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
		DROP TABLE dbo.expected
END