﻿CREATE PROCEDURE [testi21Database].[test insert on tblICItemStock]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake inventory items];
		EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		-- Declare the variables for the currencies and unit of measure
		DECLARE @USD AS INT = 1;
		
		DECLARE @Each AS INT = 1;

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
		SELECT intItemId, intItemLocationId, dblUnitOnHand INTO expected FROM dbo.tblICItemStock WHERE 1 = 0		
		SELECT intItemId, intItemLocationId, dblUnitOnHand INTO actual FROM dbo.tblICItemStock WHERE 1 = 0

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001';
		DECLARE @strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods';
		DECLARE @intUserId AS INT = 1;

		-- Setup the items to post
		INSERT INTO @ItemsToPost 
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblQty = 100
				,dblUOMQty = 1
				,dblCost = 14.00
				,dblSalesPrice = 20.00
				,dblValue = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'INVRCT-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL
				,intSubLocationId = null 
				,intStorageLocationId = null 
				,intSourceTransactionId = null
				,strSourceTransactionId = null 

		-- Setup the expected g/l entries 
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,dblUnitOnHand
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dblUnitOnHand = (0 + 100)  -- Reduce stock by 100
	END 

	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries  
		EXEC dbo.uspICPostCosting
			@ItemsToPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intUserId

		-- We expect a new Item Stock record is inserted since  record for Wet Grains and Default Location does not exists. 
		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,dblUnitOnHand	
		)
		SELECT	intItemId
				,intItemLocationId
				,dblUnitOnHand
		FROM	dbo.tblICItemStock
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @Default_Location
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