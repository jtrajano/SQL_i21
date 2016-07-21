CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntriesOnCostAdjustment for missing Revalue Sold]
AS
--BEGIN
--	-- Arrange 
--	BEGIN 
--		EXEC [testi21Database].[Fake inventory items]; 

--		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
--		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

--	-- Create the variables used by fnGetItemGLAccount
--	DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
--			,@AccountCategory_Write_Off_Sold AS NVARCHAR(30) = 'Write-Off Sold'
--			,@AccountCategory_Revalue_Sold AS NVARCHAR(30) = 'Revalue Sold'
--			,@AccountCategory_Auto_Negative AS NVARCHAR(30) = 'Auto-Variance'

--			,@AccountCategory_Cost_Adjustment AS NVARCHAR(30) = 'Cost Adjustment'
--			,@AccountCategory_Revalue_WIP AS NVARCHAR(30) = 'Revalue WIP'
--			,@AccountCategory_Revalue_Produced AS NVARCHAR(30) = 'Revalue Produced'
--			,@AccountCategory_Revalue_Transfer AS NVARCHAR(30) = 'Revalue Inventory Transfer'
--			,@AccountCategory_Revalue_Build_Assembly AS NVARCHAR(30) = 'Revalue Build Assembly'		

--	-- Create the variables for the internal transaction types used by costing. 
--	DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
--			,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
--			,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

--			,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
--			,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
--			,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
--			,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
--			,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

--		-- Declare the variables for grains (item)
--		DECLARE @WetGrains AS INT = 1
--				,@StickyGrains AS INT = 2
--				,@PremiumGrains AS INT = 3
--				,@ColdGrains AS INT = 4
--				,@HotGrains AS INT = 5
--				,@InvalidItem AS INT = -1

--		-- Declare the variables for location
--		DECLARE @Default_Location AS INT = 1
--				,@NewHaven AS INT = 2
--				,@BetterHaven AS INT = 3
--				,@InvalidLocation AS INT = -1

--		-- Declare the variables for the Item UOM Ids
--		DECLARE @WetGrains_BushelUOMId AS INT = 1
--				,@StickyGrains_BushelUOMId AS INT = 2
--				,@PremiumGrains_BushelUOMId AS INT = 3
--				,@ColdGrains_BushelUOMId AS INT = 4
--				,@HotGrains_BushelUOMId AS INT = 5				

--		-- Declare the variables for the currencies
--		DECLARE @USD AS INT = 1;
		
--		DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'  
--		DECLARE @Inventory_AutoNegative_Name AS NVARCHAR(50) = 'Inventory Auto Variance'  
--		DECLARE @Inventory_RevalueSold_Name AS NVARCHAR(50) = 'Inventory Revalue Sold'  
--		DECLARE @Inventory_WriteOffSold_Name AS NVARCHAR(50) = 'Inventory Write-Off Sold'  
		
--		-- Declare the account ids
--		DECLARE @Inventory_Default AS INT = 1000
--		DECLARE @CostOfGoods_Default AS INT = 2000
--		DECLARE @APClearing_Default AS INT = 3000
--		DECLARE @WriteOffSold_Default AS INT = 4000
--		DECLARE @RevalueSold_Default AS INT = 5000 
--		DECLARE @AutoNegative_Default AS INT = 6000

--		DECLARE @Inventory_NewHaven AS INT = 1001
--		DECLARE @CostOfGoods_NewHaven AS INT = 2001
--		DECLARE @APClearing_NewHaven AS INT = 3001
--		DECLARE @WriteOffSold_NewHaven AS INT = 4001
--		DECLARE @RevalueSold_NewHaven AS INT = 5001
--		DECLARE @AutoNegative_NewHaven AS INT = 6001

--		DECLARE @Inventory_BetterHaven AS INT = 1002
--		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
--		DECLARE @APClearing_BetterHaven AS INT = 3002
--		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
--		DECLARE @RevalueSold_BetterHaven AS INT = 5002
--		DECLARE @AutoNegative_BetterHaven AS INT = 6002
		
--		-- Declare the variables for the Unit of Measure
--		DECLARE @EACH AS INT = 1;		

--		-- Insert a fake data in the Inventory transaction table 
--		INSERT INTO tblICInventoryTransaction (
--				intItemId
--				,intItemLocationId
--				,intItemUOMId
--				,dtmDate
--				,dblQty
--				,dblUOMQty
--				,dblCost
--				,dblValue
--				,dblSalesPrice
--				,intCurrencyId
--				,dblExchangeRate
--				,intTransactionId
--				,strTransactionId
--				,strBatchId
--				,intTransactionTypeId
--				,intLotId
--				,strTransactionForm
--				,dtmCreated
--				,intCreatedUserId
--				,intConcurrencyId
--		)
--		SELECT 	intItemId = @StickyGrains
--				,intItemLocationId = @Default_Location
--				,intItemUOMId = @StickyGrains_BushelUOMId
--				,dtmDate = 'January 17, 2014'
--				,dblQty = -11
--				,dblUOMQty = 1
--				,dblCost = 1.50
--				,dblValue = 0
--				,dblSalesPrice = 0
--				,intCurrencyId = @USD
--				,dblExchangeRate = 1
--				,intTransactionId = 1
--				,strTransactionId = 'BL-00001'
--				,strBatchId = 'BATCH-000001'
--				,intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold
--				,intLotId = NULL 
--				,strTransactionForm = 'Bill'
--				,dtmCreated = GETDATE()
--				,intCreatedUserId = 1
--				,intConcurrencyId = 1

--		-- Delete Revalue Sold from the G/L account setup to simulate a missing account id
--		DELETE	ItemAccount
--		FROM	dbo.tblICItemAccount ItemAccount INNER JOIN dbo.tblGLAccountCategory GLAccountCategory
--					ON ItemAccount.intAccountCategoryId = GLAccountCategory.intAccountCategoryId
--		WHERE	GLAccountCategory.strAccountCategory = @AccountCategory_Revalue_Sold
--	END 

--	-- Assert
--	BEGIN 
--		-- {Item} is missing a GL account setup for {Account Category} account category.
--		EXEC tSQLt.ExpectException 
--			@ExpectedMessagePattern = 'STICKY GRAINS is missing a GL account setup for Revalue Sold account category.'
--			,@ExpectedErrorNumber = 80008 
--	END

--	-- Act
--	BEGIN 

--		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
--				,@intEntityUserSecurityId AS INT = 1		

--		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment
--			@strBatchId
--			,@intEntityUserSecurityId
--			,NULL
--	END 
--END