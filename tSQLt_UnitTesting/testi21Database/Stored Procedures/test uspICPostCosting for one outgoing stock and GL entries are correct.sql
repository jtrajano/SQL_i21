﻿CREATE PROCEDURE [testi21Database].[test uspICPostCosting for one outgoing stock and GL entries are correct]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for item costing]

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
		DECLARE @WRITE_OFF_SOLD AS INT = 2
		DECLARE @REVALUE_SOLD AS INT = 3
		
		DECLARE @PurchaseType AS INT = 4
		DECLARE @SalesType AS INT = 5

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

		DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'  
		DECLARE @Inventory_AutoNegative AS NVARCHAR(50) = 'Inventory Auto Negative'  
		DECLARE @Inventory_RevalueSold AS NVARCHAR(50) = 'Inventory Revalue Sold'  
		DECLARE @Inventory_WriteOffSold AS NVARCHAR(50) = 'Inventory Write-Off Sold'  

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
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemOUMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblUnitQty = -100
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblValue = 0
				,dblSalesPrice = 25.00
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'SALE-000001'
				,intTransactionTypeId = @SalesType
				,intLotId = NULL
				,intSubLocationId = NULL
				,intStorageLocationId = NULL
				,intSourceTransactionId = NULL
				,strSourceTransactionId = NULL

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
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 0
			,dblCredit					= 2200.00 -- (22.00 x 100)
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= tblGLAccount.strDescription
			,strCode					= 'IC'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= ''
			,intJournalLineNo			= 6
			,ysnIsUnposted				= 0
			,intUserId					= 1
			,intEntityId				= 1
			,strTransactionId			= 'SALE-000001'
			,intTransactionId			= 1
			,strTransactionType			= 'Inventory Shipment'
			,strTransactionForm			= 'Inventory Shipment'
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  
			
		UNION ALL 
		SELECT	
			dtmDate						= 'November 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @CostOfGoods_Default
			,dblDebit					= 2200.00 -- (22.00 x 100)
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= tblGLAccount.strDescription
			,strCode					= 'IC'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'November 17, 2014'
			,strJournalLineDescription	= '' 
			,intJournalLineNo			= 6
			,ysnIsUnposted				= 0
			,intUserId					= 1
			,intEntityId				= 1
			,strTransactionId			= 'SALE-000001'
			,intTransactionId			= 1
			,strTransactionType			= 'Inventory Shipment'
			,strTransactionForm			= 'Inventory Shipment'
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default  
			
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