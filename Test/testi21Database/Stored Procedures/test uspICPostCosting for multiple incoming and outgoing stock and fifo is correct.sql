﻿CREATE PROCEDURE testi21Database.[test uspICPostCosting for multiple incoming and outgoing stock and fifo is correct]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC testi21Database.[Fake transactions for item costing]

		-- Flag all item to allow negative stock 
		UPDATE dbo.tblICItemLocation
		SET intAllowNegativeInventory = 1

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
		DECLARE @Inventory_Default AS INT = 1000;
		DECLARE @CostOfGoods_Default AS INT = 2000;
		DECLARE @APClearing_Default AS INT = 3000;
		DECLARE @WriteOffSold_Default AS INT = 4000;
		DECLARE @RevalueSold_Default AS INT = 5000;
		DECLARE @AutoNegative_Default AS INT = 6000;

		DECLARE @Inventory_NewHaven AS INT = 1001;
		DECLARE @CostOfGoods_NewHaven AS INT = 2001;
		DECLARE @APClearing_NewHaven AS INT = 3001;
		DECLARE @WriteOffSold_NewHaven AS INT = 4001;
		DECLARE @RevalueSold_NewHaven AS INT = 5001;
		DECLARE @AutoNegative_NewHaven AS INT = 6001;

		DECLARE @Inventory_BetterHaven AS INT = 1002;
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002;
		DECLARE @APClearing_BetterHaven AS INT = 3002;
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002;
		DECLARE @RevalueSold_BetterHaven AS INT = 5002;
		DECLARE @AutoNegative_BetterHaven AS INT = 6002;

		-- Create the expected and actual tables. 
		SELECT intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost INTO expected FROM dbo.tblICInventoryFIFO WHERE 1 = 0;
		SELECT intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost INTO actual FROM dbo.tblICInventoryFIFO WHERE 1 = 0;

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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to 170)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to 135)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to 90)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- out (Stock goes down to -42)
		UNION ALL
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- in (Stock goes up to -22)
		UNION ALL		
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- in (Stock goes up to 0)
		UNION ALL				
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL
		-- in (Stock goes up to 100)
		UNION ALL				
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
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
				,intSubLocationId		= NULL
				,intStorageLocationId   = NULL

		-- Setup the expected (for tblICInventoryFIFO)
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'January 1, 2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 22.00
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 14.00
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 42
				,dblStockOut = 42
				,dblCost = 18.00
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 20
				,dblStockOut = 20
				,dblCost = 15.50
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 22
				,dblStockOut = 22
				,dblCost = 16.50
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = 'November 17, 2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 18.00
	END 	
	
	-- Act
	BEGIN 	
		-- Call uspICPostCosting to post the costing and generate the g/l entries  
		EXEC dbo.uspICPostCosting
			@ItemsToPost
			,@strBatchId 
			,@strAccountToCounterInventory
			,@intUserId

		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
		)
		SELECT	intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
		FROM	dbo.tblICInventoryFIFO
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