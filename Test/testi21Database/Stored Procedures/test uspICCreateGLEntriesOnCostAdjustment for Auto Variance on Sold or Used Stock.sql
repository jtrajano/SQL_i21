CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntriesOnCostAdjustment for Auto Variance on Sold or Used Stock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]; 

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 	
		DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
				--,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
				--,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3
				,@INV_TRANS_TYPE_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35

				,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
				,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
				,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
				,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
				,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31
		
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

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;
		
		DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
				--,@AccountCategory_Write_Off_Sold AS NVARCHAR(30) = 'Inventory Write-Off Sold'
				--,@AccountCategory_Revalue_Sold AS NVARCHAR(30) = 'Inventory Revalue Sold'
				,@AccountCategory_Auto_Negative AS NVARCHAR(30) = 'Inventory Auto-Negative'
				,@AccountCategory_Auto_Variance_On_Sold_Or_Used_Stock AS NVARCHAR(200) = 'Inventory Auto Variance on Negatively Sold or Used Stock'

				,@AccountCategory_Cost_Adjustment AS NVARCHAR(30) = 'Cost Adjustment'
				,@AccountCategory_Revalue_WIP AS NVARCHAR(30) = 'Revalue WIP'
				,@AccountCategory_Revalue_Produced AS NVARCHAR(30) = 'Revalue Produced'
				,@AccountCategory_Revalue_Transfer AS NVARCHAR(30) = 'Revalue Inventory Transfer'
				,@AccountCategory_Revalue_Build_Assembly AS NVARCHAR(30) = 'Revalue Build Assembly'		
					
		-- Declare the account ids
		DECLARE	 @Inventory_Default AS INT = 1000
				,@CostOfGoods_Default AS INT = 2000
				,@APClearing_Default AS INT = 3000
				,@WriteOffSold_Default AS INT = 4000
				,@RevalueSold_Default AS INT = 5000 
				,@AutoNegative_Default AS INT = 6000
				,@InventoryInTransit_Default AS INT = 7000
				,@AccountReceivable_Default AS INT = 8000
				,@InventoryAdjustment_Default AS INT = 9000
				,@OtherChargeExpense_Default AS INT = 10000
				,@OtherChargeIncome_Default AS INT = 11000
				,@OtherChargeAsset_Default AS INT = 12000
				,@CostAdjustment_Default AS INT = 13000
				,@WorkInProgress_Default AS INT = 14000

				,@Inventory_NewHaven AS INT = 1001
				,@CostOfGoods_NewHaven AS INT = 2001
				,@APClearing_NewHaven AS INT = 3001
				,@WriteOffSold_NewHaven AS INT = 4001
				,@RevalueSold_NewHaven AS INT = 5001
				,@AutoNegative_NewHaven AS INT = 6001
				,@InventoryInTransit_NewHaven AS INT = 7001
				,@AccountReceivable_NewHaven AS INT = 8001
				,@InventoryAdjustment_NewHaven AS INT = 9001
				,@OtherChargeExpense_NewHaven AS INT = 10001
				,@OtherChargeIncome_NewHaven AS INT = 11001
				,@OtherChargeAsset_NewHaven AS INT = 12001
				,@CostAdjustment_NewHaven AS INT = 13001
				,@WorkInProgress_NewHaven AS INT = 14001

				,@Inventory_BetterHaven AS INT = 1002
				,@CostOfGoods_BetterHaven AS INT = 2002
				,@APClearing_BetterHaven AS INT = 3002
				,@WriteOffSold_BetterHaven AS INT = 4002
				,@RevalueSold_BetterHaven AS INT = 5002
				,@AutoNegative_BetterHaven AS INT = 6002
				,@InventoryInTransit_BetterHaven AS INT = 7002
				,@AccountReceivable_BetterHaven AS INT = 8002
				,@InventoryAdjustment_BetterHaven AS INT = 9002
				,@OtherChargeExpense_BetterHaven AS INT = 10002
				,@OtherChargeIncome_BetterHaven AS INT = 11002
				,@OtherChargeAsset_BetterHaven AS INT = 12002
				,@CostAdjustment_BetterHaven AS INT = 13002
				,@WorkInProgress_BetterHaven AS INT = 14002

		-- Declare the variables for the Unit of Measure
		DECLARE @EACH AS INT = 1;		

		-- Insert a fake data in the Inventory transaction table 
		INSERT INTO tblICInventoryTransaction (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,strTransactionForm
				,dtmCreated
				,intCreatedUserId
				,intConcurrencyId
		)
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'January 17, 2014'
				,dblQty = -11
				,dblUOMQty = 1
				,dblCost = 1.50
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'BL-00001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance_On_Sold_Or_Used_Stock
				,intLotId = NULL 
				,strTransactionForm = 'Bill'
				,dtmCreated = GETDATE()
				,intCreatedUserId = 1
				,intConcurrencyId = 1

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
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId		
		)
		SELECT	
			dtmDate						= 'January 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 16.50
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= tblGLAccount.strDescription 
			,strCode					= 'IAV' 
			,strReference				= '' 
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 17, 2014'
			,strJournalLineDescription	= '' 
			,intJournalLineNo			= 1
			,ysnIsUnposted				= 0
			,intUserId					= NULL 
			,intEntityId				= 1 
			,strTransactionId			= 'BL-00001'
			,intTransactionId			= 1
			,strTransactionType			= @AccountCategory_Auto_Variance_On_Sold_Or_Used_Stock
			,strTransactionForm			= 'Bill'
			,strModuleName				= 'Inventory'
			,intConcurrencyId			= 1
		FROM dbo.tblGLAccount
		WHERE intAccountId = @Inventory_Default
					
		UNION ALL 
		SELECT	
			dtmDate						= 'January 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @AutoNegative_Default
			,dblDebit					= 16.50
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= tblGLAccount.strDescription
			,strCode					= 'IAV'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 17, 2014'
			,strJournalLineDescription	= ''
			,intJournalLineNo			= 1
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= 1
			,strTransactionId			= 'BL-00001'
			,intTransactionId			= 1
			,strTransactionType			= @AccountCategory_Auto_Variance_On_Sold_Or_Used_Stock
			,strTransactionForm			= 'Bill'
			,strModuleName				= 'Inventory'
			,intConcurrencyId			= 1		
		FROM dbo.tblGLAccount
		WHERE intAccountId = @AutoNegative_Default		
	END 

	-- Act
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@intEntityUserSecurityId AS INT = 1

		INSERT INTO actual 
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment
			@strBatchId
			,@intEntityUserSecurityId
			,NULL
			
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