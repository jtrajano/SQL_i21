﻿CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntries for missing Contra Account on Inventory Transfer with Shipment required]
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
		
		DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
				,@INVENTORY_TRANSACTION_TYPE_CONSUME AS INT = 8
				,@INVENTORY_TRANSACTION_TYPE_PRODUCE AS INT = 9
				,@INVENTORY_TRANSACTION_TYPE_BUILD_ASSEMBLY AS INT = 11
				,@INVENTORY_TRANSACTION_TYPE_INVENTORY_TRANSFER AS INT = 12
				,@INVENTORY_TRANSACTION_TYPE_INVENTORY_TRANSFER_with_SHIPMENT AS INT = 13

		-- Declare Account Categories
		DECLARE @AccountCategoryName_Inventory AS NVARCHAR(100) = 'Inventory'
		DECLARE @AccountCategoryId_Inventory AS INT = 27

		DECLARE @AccountCategoryName_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
		DECLARE @AccountCategoryId_CostOfGoods AS INT = 10

		DECLARE @AccountCategoryName_APClearing AS NVARCHAR(100) = 'AP Clearing'
		DECLARE @AccountCategoryId_APClearing AS INT = 45
	
		DECLARE @AccountCategoryName_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
		DECLARE @AccountCategoryId_WriteOffSold AS INT = 42

		DECLARE @AccountCategoryName_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
		DECLARE @AccountCategoryId_RevalueSold AS INT = 43

		DECLARE @AccountCategoryName_AutoNegative AS NVARCHAR(100) = 'Auto Negative'
		DECLARE @AccountCategoryId_AutoNegative AS INT = 44

		DECLARE @AccountCategoryName_InventoryInTransit AS NVARCHAR(100) = 'Inventory In-Transit'
		DECLARE @AccountCategoryId_InventoryInTransit AS INT = 46

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
		
		DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'  
		DECLARE @Inventory_AutoNegative_Name AS NVARCHAR(50) = 'Inventory Auto Negative'  
		DECLARE @Inventory_RevalueSold_Name AS NVARCHAR(50) = 'Inventory Revalue Sold'  
		DECLARE @Inventory_WriteOffSold_Name AS NVARCHAR(50) = 'Inventory Write-Off Sold'  
		
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
				,intItemLocationId = @Default_Location
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
				,strTransactionId = 'INVTRN-10001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @INVENTORY_TRANSACTION_TYPE_INVENTORY_TRANSFER_with_SHIPMENT
				,strTransactionForm = 'Inventory Transfer'
				,intLotId = NULL 
				,dtmCreated = GETDATE()
				,intCreatedUserId = 1
				,intConcurrencyId = 1

		-- Delete Inventory In-Transit from the G/L account setup to simulate a missing contra account id
		DELETE FROM dbo.tblICItemAccount
		WHERE intAccountCategoryId = @AccountCategoryId_InventoryInTransit
	END 

	-- Assert
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		EXEC tSQLt.ExpectException 
			@ExpectedMessagePattern = 'STICKY GRAINS is missing a GL account setup for Inventory In-Transit account category.'
			,@ExpectedErrorNumber = 80008 
	END

	-- Act
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@intUserId AS INT = 1		

		EXEC dbo.uspICCreateGLEntries
			@strBatchId
			,@AccountCategoryName_InventoryInTransit
			,@intUserId
			,NULL
	END 
END