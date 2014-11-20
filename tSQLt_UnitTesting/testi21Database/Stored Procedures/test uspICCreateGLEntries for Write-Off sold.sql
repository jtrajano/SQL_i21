CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntries for Write-Off Sold]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for item costing]; 

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3
		
		DECLARE @PurchaseType AS INT = 1
		DECLARE @SaleType AS INT = 2

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
		
		-- Declare the variables for the Unit of Measure
		DECLARE @EACH AS INT = 1;		

		-- Insert a fake data in the Inventory transaction table 
		INSERT INTO tblICInventoryTransaction (
				intItemId
				,intLocationId
				,dtmDate
				,dblUnitQty
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
				,dtmCreated
				,intCreatedUserId
				,intConcurrencyId
		)
		SELECT 	intItemId = @StickyGrains
				,intLocationId = @Default_Location
				,dtmDate = 'January 17, 2014'
				,dblUnitQty = -11
				,dblCost = 1.50
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'SALE-00001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @WRITE_OFF_SOLD
				,intLotId = NULL 
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
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-00001'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'January 17, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @WriteOffSold_Default
			,dblDebit					= 16.50
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= '' -- TODO 
			,strCode					= '' -- TODO
			,strReference				= '' -- TODO
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 17, 2014'
			,strJournalLineDescription	= '' -- TODO
			,intJournalLineNo			= NULL -- TODO
			,ysnIsUnposted				= 0
			,intUserId					= 1 -- TODO
			,intEntityId				= 1 -- TODO
			,strTransactionId			= 'SALE-00001'
			,intTransactionId			= 1
			,strTransactionType			= '' -- TODO 
			,strTransactionForm			= '' -- TODO
			,strModuleName				= '' -- TODO
			,intConcurrencyId			= 1		
	END 
	
	-- Act
	BEGIN 

		DECLARE	@strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
				,@intUserId AS INT = 1

		INSERT INTO actual 
		EXEC dbo.uspICCreateGLEntries
			@strBatchId
			,@UseGLAccount_ContraInventory
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