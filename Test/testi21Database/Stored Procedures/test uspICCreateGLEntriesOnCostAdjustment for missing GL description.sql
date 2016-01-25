CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntriesOnCostAdjustment for missing GL description]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]; 

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 	
		DECLARE @Inventory_Auto_Negative AS INT = 1;
		DECLARE @Inventory_Write_Off_Sold AS INT = 2;
		DECLARE @Inventory_Revalue_Sold AS INT = 3;
		
		DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
				,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
				,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

				,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 24
				,@INV_TRANS_TYPE_Revalue_WIP AS INT = 26
				,@INV_TRANS_TYPE_Revalue_Produced AS INT = 27
				,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 28
				,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 29

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

		-- Declare Item-Locations
		DECLARE @WetGrains_DefaultLocation AS INT = 1
				,@StickyGrains_DefaultLocation AS INT = 2
				,@PremiumGrains_DefaultLocation AS INT = 3
				,@ColdGrains_DefaultLocation AS INT = 4
				,@HotGrains_DefaultLocation AS INT = 5

				,@WetGrains_NewHaven AS INT = 6
				,@StickyGrains_NewHaven AS INT = 7
				,@PremiumGrains_NewHaven AS INT = 8
				,@ColdGrains_NewHaven AS INT = 9
				,@HotGrains_NewHaven AS INT = 10

				,@WetGrains_BetterHaven AS INT = 11
				,@StickyGrains_BetterHaven AS INT = 12
				,@PremiumGrains_BetterHaven AS INT = 13
				,@ColdGrains_BetterHaven AS INT = 14
				,@HotGrains_BetterHaven AS INT = 15

				,@ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17

				,@CornCommodity_DefaultLocation AS INT = 18
				,@CornCommodity_NewHaven AS INT = 19
				,@CornCommodity_BetterHaven AS INT = 20

				,@ManualLotGrains_NewHaven AS INT = 21
				,@SerializedLotGrains_NewHaven AS INT = 22

				,@OtherCharges_DefaultLocation AS INT = 23
				,@SurchargeOtherCharges_DefaultLocation AS INT = 24
				,@SurchargeOnSurcharge_DefaultLocation AS INT = 25
				,@SurchargeOnSurchargeOnSurcharge_DefaultLocation AS INT = 26

				,@OtherCharges_NewHaven AS INT = 27
				,@SurchargeOtherCharges_NewHaven AS INT = 28
				,@SurchargeOnSurcharge_NewHaven AS INT = 29
				,@SurchargeOnSurchargeOnSurcharge_NewHaven AS INT = 30

				,@OtherCharges_BetterHaven AS INT = 31
				,@SurchargeOtherCharges_BetterHaven AS INT = 32
				,@SurchargeOnSurcharge_BetterHaven AS INT = 33
				,@SurchargeOnSurchargeOnSurcharge_BetterHaven AS INT = 34

		
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
				,strTransactionForm
				,intLotId
				,dtmCreated
				,intCreatedUserId
				,intConcurrencyId
		)
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_DefaultLocation
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dtmDate = 'January 12, 2014'
				,dblQty = 1
				,dblUOMQty = 1
				,dblCost = 12.00
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'BL-00001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
				,strTransactionForm = 'Bill'
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
			dtmDate						= 'January 12, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @Inventory_Default
			,dblDebit					= 12.00
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= 'INVENTORY WHEAT-DEFAULT'
			,strCode					= 'ICA'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 12, 2014'
			,strJournalLineDescription	= ''
			,intJournalLineNo			= 1
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= 1
			,strTransactionId			= 'BL-00001'
			,intTransactionId			= 1
			,strTransactionType			= 'Cost Adjustment'
			,strTransactionForm			= 'Bill'
			,strModuleName				= 'Inventory'
			,intConcurrencyId			= 1
		UNION ALL 
		SELECT	
			dtmDate						= 'January 12, 2014'
			,strBatchId					= 'BATCH-000001'
			,intAccountId				= @AutoNegative_Default
			,dblDebit					= 0
			,dblCredit					= 12.00
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= 'AUTO NEGATIVE WHEAT-DEFAULT'
			,strCode					= 'ICA'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 12, 2014'
			,strJournalLineDescription	= ''
			,intJournalLineNo			= 1
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= 1
			,strTransactionId			= 'BL-00001'
			,intTransactionId			= 1
			,strTransactionType			= 'Cost Adjustment'
			,strTransactionForm			= 'Bill'
			,strModuleName				= 'Inventory'
			,intConcurrencyId			= 1		

	END 
	
	-- Act
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
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