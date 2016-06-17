CREATE PROCEDURE [testi21Database].[test uspICPostCosting for multiple incoming and outgoing stock and GL entries are correct]
AS  
BEGIN  
	-- Arrange   
	BEGIN   
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for FIFO or Ave costing]

		-- Flag all item to allow negative stock 
		UPDATE dbo.tblICItemLocation
		SET intAllowNegativeInventory = 1
		
		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @AUTO_NEGATIVE AS INT = 1
		DECLARE @WRITE_OFF_SOLD AS INT = 2
		DECLARE @REVALUE_SOLD AS INT = 3
		DECLARE @AUTO_VARIANCE_ON_NEGATIVELY_SOLD_OR_USED_STOCKS AS INT = 35
				
		DECLARE @PurchaseType AS INT = 4
		DECLARE @SalesType AS INT = 5

		-- Declare the variables for grains (item)  
		DECLARE @WetGrains AS INT = 1  
		,@StickyGrains AS INT = 2  
		,@PremiumGrains AS INT = 3  
		,@ColdGrains AS INT = 4  
		,@HotGrains AS INT = 5  
				
		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5
				
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

		DECLARE @MODULENAME AS NVARCHAR(50) = 'Inventory'  
		DECLARE @INVENTORY_AUTONEGATIVE_NAME AS NVARCHAR(50) = 'Inventory Auto Variance'  
		DECLARE @INVENTORY_REVALUESOLD_NAME AS NVARCHAR(50) = 'Inventory Revalue Sold'  
		DECLARE @INVENTORY_WRITEOFFSOLD_NAME AS NVARCHAR(50) = 'Inventory Write-Off Sold'  
		DECLARE @INVENTORY_AUTO_VARIANCE_ON_NEGATIVELY_SOLD_OR_USED_STOCK_NAME AS NVARCHAR(200) = 'Inventory Auto Variance on Negatively Sold or Used Stock'  

		-- Create the expected and actual tables.   
		DECLARE @recap AS dbo.RecapTableType    

		SELECT *  
		INTO expected   
		FROM @recap    

		SELECT *  
		INTO actual   
		FROM @recap  

		-- Remove the column dtmDateEntered. We don't need to assert it.   
		ALTER TABLE expected  
		DROP COLUMN dtmDateEntered  

		-- Declare the variables used by uspICPostCosting  
		DECLARE @ItemsToPost AS ItemCostingTableType;  
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';  
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';  
		DECLARE @intEntityUserSecurityId AS INT = 1;  

		-- Setup the items to post  
		INSERT INTO @ItemsToPost (
				intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblSalesPrice 
				,dblValue 
				,intCurrencyId 
				,dblExchangeRate 
				,intTransactionId 
				,intTransactionDetailId
				,strTransactionId 
				,intTransactionTypeId 
				,intLotId 
				,intSubLocationId 
				,intStorageLocationId 
		) 
		-- in (Stock goes up to 200)  
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation 
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'  
				,dblQty = 100  
				,dblUOMQty = 1  
				,dblCost = 14.00  
				,dblValue = 0
				,dblSalesPrice = 0  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1  
				,intTransactionDetailId = 1
				,strTransactionId = 'PURCHASE-000001'  
				,intTransactionTypeId = @PurchaseType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- out (Stock goes down to 170)  
		UNION ALL  
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation 
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'  
				,dblQty = -30  
				,dblUOMQty = 1  
				,dblCost = 14.00  
				,dblValue = 0
				,dblSalesPrice = 25.00  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1  
				,intTransactionDetailId = 2
				,strTransactionId = 'SALE-000001'  
				,intTransactionTypeId = @SalesType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- out (Stock goes down to 135)  
		UNION ALL  
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation  
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'  
				,dblQty = -35  
				,dblUOMQty = 1  
				,dblCost = 14.00  
				,dblValue = 0
				,dblSalesPrice = 25.00  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1  
				,intTransactionDetailId = 3
				,strTransactionId = 'SALE-000002'  
				,intTransactionTypeId = @SalesType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- out (Stock goes down to 90)  
		UNION ALL  
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation  
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'  
				,dblQty = -45  
				,dblUOMQty = 1  
				,dblCost = 14.00  
				,dblValue = 0
				,dblSalesPrice = 25.00  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1  
				,intTransactionDetailId = 4
				,strTransactionId = 'SALE-000003'  
				,intTransactionTypeId = @SalesType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- out (Stock goes down to -42)  
		UNION ALL  
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation  
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'  
				,dblQty = -132  
				,dblUOMQty = 1  
				,dblCost = 14.00
				,dblValue = 0  
				,dblSalesPrice = 27.00  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1  
				,intTransactionDetailId = 5
				,strTransactionId = 'SALE-000004'  
				,intTransactionTypeId = @SalesType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- in (Stock goes up to -22)  
		UNION ALL    
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation 
				,intItemUOMId = @WetGrains_BushelUOMId 
				,dtmDate = 'November 17, 2014'  
				,dblQty = 20  
				,dblUOMQty = 1  
				,dblCost = 15.50  
				,dblValue = 0
				,dblSalesPrice = 0  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1 
				,intTransactionDetailId = 6 
				,strTransactionId = 'PURCHASE-000002'  
				,intTransactionTypeId = @PurchaseType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- in (Stock goes up to 0)  
		UNION ALL      
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation 
				,intItemUOMId = @WetGrains_BushelUOMId 
				,dtmDate = 'November 17, 2014'  
				,dblQty = 22  
				,dblUOMQty = 1  
				,dblCost = 16.50  
				,dblValue = 0
				,dblSalesPrice = 0  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1 
				,intTransactionDetailId = 7 
				,strTransactionId = 'PURCHASE-000003'  
				,intTransactionTypeId = @PurchaseType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL
		-- in (Stock goes up to 100)  
		UNION ALL      
		SELECT  intItemId = @WetGrains  
				,intItemLocationId = @WetGrains_DefaultLocation  
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'  
				,dblQty = 100  
				,dblUOMQty = 1  
				,dblCost = 18.00
				,dblValue = 0  
				,dblSalesPrice = 0  
				,intCurrencyId = @USD  
				,dblExchangeRate = 1  
				,intTransactionId = 1  
				,intTransactionDetailId = 8
				,strTransactionId = 'PURCHASE-000004'  
				,intTransactionTypeId = @PurchaseType  
				,intLotId = NULL  
				,intSubLocationId = NULL
				,intStorageLocationId  = NULL

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
				dtmDate	= 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 1400.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC'  
				,strReference = ''  
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = ''  
				,intJournalLineNo  = 6
				,ysnIsUnposted = 0  
				,intEntityId = 1
				,strTransactionId  = 'PURCHASE-000001'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  

		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 0  
				,dblCredit = 1400.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC'
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 6
				,ysnIsUnposted = 0  
				,intEntityId = 1
				,strTransactionId  = 'PURCHASE-000001'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'
				,strTransactionForm  = 'Inventory Receipt'
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default     

		-- 30 stock out (18.00 ave cost x 30)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 0  
				,dblCredit = 540.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 7
				,ysnIsUnposted = 0  
				,intEntityId = 1
				,strTransactionId  = 'SALE-000001'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default     
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 540.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = ''
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 7
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000001'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default        
		 
		-- 35 stock out (18.00 ave cost x 35)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 0  
				,dblCredit = 630.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 8
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  

		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 630.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = ''
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = ''
				,intJournalLineNo  = 8
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default  
		 
		-- 45 stock out (18.00 ave cost x 45)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 0  
				,dblCredit = 810.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 9
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000003'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 810.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 9
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000003'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default  
		 
		-- 132 stock out (18.00 ave cost x 132)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 0  
				,dblCredit = 2376.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 10
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000004'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 2376.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 10
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'SALE-000004'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Shipment'  
				,strTransactionForm  = 'Inventory Shipment'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default     
		 
		-- 20 stock in for $15.50  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 310.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1   
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = ''  
				,intJournalLineNo  = 11
				,ysnIsUnposted = 0  
				,intEntityId = 1   
				,strTransactionId  = 'PURCHASE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'  
				,strTransactionForm  = 'Inventory Receipt'   
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default     
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 0  
				,dblCredit = 310.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 11
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default     

		-- 20 stock in for $15.50 (Revalue sold)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 50.00  
				,dblCredit = 0
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IAV'
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1   
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 12
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = @INVENTORY_AUTO_VARIANCE_ON_NEGATIVELY_SOLD_OR_USED_STOCK_NAME  
				,strTransactionForm  = 'Inventory Receipt'
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default    

		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @AutoNegative_Default  
				,dblDebit = 0
				,dblCredit = 50  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IAV' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 12
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = @INVENTORY_AUTO_VARIANCE_ON_NEGATIVELY_SOLD_OR_USED_STOCK_NAME  
				,strTransactionForm  = 'Inventory Receipt'
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @AutoNegative_Default    

		 
		-- 20 stock in for $15.50 (Auto-Negative)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 55.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IAN' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1   
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 13
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = @INVENTORY_AUTONEGATIVE_NAME
				,strTransactionForm  = 'Inventory Receipt'
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default     
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @AutoNegative_Default  
				,dblDebit = 0  
				,dblCredit = 55.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IAN' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 13
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000002'  
				,intTransactionId  = 1  
				,strTransactionType  = @INVENTORY_AUTONEGATIVE_NAME  
				,strTransactionForm  = 'Inventory Receipt'
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1     
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @AutoNegative_Default  
		    
		-- 22 stock in for $16.50  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 363.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC'
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 14
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000003'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 0  
				,dblCredit = 363.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 14
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000003'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default     

		-- 22 stock in for $18.00 (Write-off sold)  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 33
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IAV' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1   
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 15
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000003'  
				,intTransactionId  = 1  
				,strTransactionType  = @INVENTORY_AUTO_VARIANCE_ON_NEGATIVELY_SOLD_OR_USED_STOCK_NAME
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default     
		 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @AutoNegative_Default  
				,dblDebit = 0 
				,dblCredit = 33
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IAV' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 15
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000003'  
				,intTransactionId  = 1  
				,strTransactionType  = @INVENTORY_AUTO_VARIANCE_ON_NEGATIVELY_SOLD_OR_USED_STOCK_NAME  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @AutoNegative_Default  
		 
		-- Nothing to auto-negative since stock is zero.   
		 
		-- 100 stock in for $18.00  
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 1800.00  
				,dblCredit = 0  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 16
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000004'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  

		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @CostOfGoods_Default  
				,dblDebit = 0  
				,dblCredit = 1800.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = tblGLAccount.strDescription  
				,strCode = 'IC' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 16
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000004'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Receipt'  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @CostOfGoods_Default  

		-- Auto Variance. 
		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @Inventory_Default  
				,dblDebit = 0.00  
				,dblCredit = 55.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = 'Inventory variance is created. The current item valuation is 1855.0000. The new valuation is (Qty x New Average Cost) 100.00 x 18.0000 = 1800.0000.'
				,strCode = 'IAN' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 17
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000001'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Auto Variance'
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @Inventory_Default  

		UNION ALL   
		SELECT   
				dtmDate  = 'November 17, 2014'  
				,strBatchId = 'BATCH-000001'  
				,intAccountId = @AutoNegative_Default  
				,dblDebit = 55.00
				,dblCredit = 0.00  
				,dblDebitUnit = 0  
				,dblCreditUnit = 0  
				,strDescription = 'Inventory variance is created. The current item valuation is 1855.0000. The new valuation is (Qty x New Average Cost) 100.00 x 18.0000 = 1800.0000.'
				,strCode = 'IAN' 
				,strReference = '' 
				,intCurrencyId = @USD  
				,dblExchangeRate  = 1  
				,dtmTransactionDate  = 'November 17, 2014'  
				,strJournalLineDescription = '' 
				,intJournalLineNo  = 17
				,ysnIsUnposted = 0  
				,intEntityId = 1 
				,strTransactionId  = 'PURCHASE-000001'  
				,intTransactionId  = 1  
				,strTransactionType  = 'Inventory Auto Variance'  
				,strTransactionForm  = 'Inventory Receipt'  
				,strModuleName = @MODULENAME  
				,intConcurrencyId  = 1  
		FROM dbo.tblGLAccount   
		WHERE tblGLAccount.intAccountId = @AutoNegative_Default  
	END   

	-- Act  
	BEGIN    
		-- Call uspICPostCosting to post the costing and generate the g/l entries   
		INSERT INTO actual   
		EXEC dbo.uspICPostCosting  
		@ItemsToPost  
		,@strBatchId   
		,@strAccountToCounterInventory  
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