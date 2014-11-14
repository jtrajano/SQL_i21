CREATE PROCEDURE [testi21Database].[Fake data for item costing]
AS
BEGIN
		-- Use the 'fake data for simple COA' for the simple items
		EXEC testi21Database.[Fake data for COA used in costing]

		-- Create the fake table and data for the items
		EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocation';
		EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocationAccount', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICItem';
		EXEC tSQLt.FakeTable 'dbo.tblICItemLocation', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblICItemAccount', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICCategory';
		EXEC tSQLt.FakeTable 'dbo.tblICCategoryAccount', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		
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

		-- Declare Account descriptions
		DECLARE @Account_Inventory AS NVARCHAR(100) = 'Inventory'
		DECLARE @Account_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
		DECLARE @Account_APClearing AS NVARCHAR(100) = 'A/P Clearing'
		DECLARE @Account_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
		DECLARE @Account_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
		DECLARE @Account_AutoNegative AS NVARCHAR(100) = 'Auto Negative'

		-- Declare the categories
		DECLARE @HotItems AS INT = 1
		DECLARE @ColdItems AS INT = 2

		-- Declare the costing methods
		DECLARE @AverageCosting AS INT = 1
		DECLARE @FIFO AS INT = 2
		DECLARE @LIFO AS INT = 3

		-- Declare the profit centers
		DECLARE @ProfitCenter_Default AS INT = 100
		DECLARE @ProfitCenter_NewHaven AS INT = 101
		DECLARE @ProfitCenter_BetterHaven AS INT = 102

		-- Declare the variables for the Unit of Measure
		DECLARE @EACH AS INT = 1;

		-- Fake company locations 
		BEGIN 
			INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@Default_Location, 'DEFAULT', @ProfitCenter_Default)
			INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@NewHaven, 'NEW HAVEN', @ProfitCenter_NewHaven)
			INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@BetterHaven, 'BETTER HAVEN', @ProfitCenter_BetterHaven)
		END

		-- Fake data for Company-Location-Account
		BEGIN 
			-- G/L Accounts for Company Location 1 ('Default')
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_Inventory, @Inventory_Default);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_CostOfGoods, @CostOfGoods_Default);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_APClearing, @APClearing_Default);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_WriteOffSold, @WriteOffSold_Default);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_RevalueSold, @RevalueSold_Default);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_AutoNegative, @AutoNegative_Default);

			-- G/L Accounts for Company Location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_Inventory, @Inventory_NewHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_CostOfGoods, @CostOfGoods_NewHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_APClearing, @APClearing_NewHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_WriteOffSold, @WriteOffSold_NewHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_RevalueSold, @RevalueSold_NewHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_AutoNegative, @AutoNegative_NewHaven);

			-- G/L Accounts for Company Location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_Inventory, @Inventory_BetterHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_CostOfGoods, @CostOfGoods_BetterHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_APClearing, @APClearing_BetterHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_WriteOffSold, @WriteOffSold_BetterHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_RevalueSold, @RevalueSold_BetterHaven);
			INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_AutoNegative, @AutoNegative_BetterHaven);
		END

		-- Fake data for Category
		BEGIN 
			-- Category
			INSERT INTO dbo.tblICCategory (intCategoryId, strDescription) VALUES (@HotItems, 'Hot Items');
			INSERT INTO dbo.tblICCategory (intCategoryId, strDescription) VALUES (@ColdItems, 'Cold Items');
		END

		-- Fake data Category Account
		BEGIN 
			-- Add G/L setup for Hot items
			INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (@HotItems, @Inventory_NewHaven, @Account_Inventory)
			INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (@HotItems, @CostOfGoods_NewHaven, @Account_CostOfGoods)
			INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (@HotItems, @APClearing_NewHaven, @Account_APClearing)

			-- Add G/L setup for Cold items
			-- No category-level g/l account overrides for Cold items. Use default g/l account from Location. 
		END
		
		-- Fake data for Items 
		BEGIN 
			INSERT INTO dbo.tblICItem (intItemId, strDescription) VALUES (@WetGrains, 'WET GRAINS')
			INSERT INTO dbo.tblICItem (intItemId, strDescription) VALUES (@StickyGrains, 'STICKY GRAINS')
			INSERT INTO dbo.tblICItem (intItemId, strDescription) VALUES (@PremiumGrains, 'PREMIUM GRAINS')
			INSERT INTO dbo.tblICItem (intItemId, strDescription, intTrackingId) VALUES (@ColdGrains, 'COLD GRAINS', @ColdItems)
			INSERT INTO dbo.tblICItem (intItemId, strDescription, intTrackingId) VALUES (@HotGrains, 'HOT GRAINS', @HotItems)
		END

		-- Fake data for Item-Location
		BEGIN 
			-- Add items for location 1 ('Default')
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @Default_Location, 1, @AverageCosting)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @Default_Location, 1, @AverageCosting)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @Default_Location, 1, @AverageCosting)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains, @Default_Location, 1, @AverageCosting)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@HotGrains, @Default_Location, 1, @AverageCosting)

			-- Add items for location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @NewHaven, 2, @FIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @NewHaven, 2, @FIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @NewHaven, 2, @FIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains, @NewHaven, 2, @FIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@HotGrains, @NewHaven, 2, @FIFO)

			-- Add items for location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @BetterHaven, 3, @LIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @BetterHaven, 3, @LIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @BetterHaven, 3, @LIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains, @BetterHaven, 3, @LIFO)
			INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@HotGrains, @BetterHaven, 3, @LIFO)
		END 

		-- Fake data for Item Stock
		BEGIN 
			-- Add stock information for items under location 1 ('Default')
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@WetGrains, @Default_Location, 100, @EACH, 22)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@StickyGrains, @Default_Location, 150, @EACH, 33)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@PremiumGrains, @Default_Location, 200, @EACH, 44)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@ColdGrains, @Default_Location, 250, @EACH, 55)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@HotGrains, @Default_Location, 300, @EACH, 66)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@WetGrains, @NewHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@StickyGrains, @NewHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@PremiumGrains, @NewHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@ColdGrains, @NewHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@HotGrains, @NewHaven, 0, @EACH, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@WetGrains, @BetterHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@StickyGrains, @BetterHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@PremiumGrains, @BetterHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@ColdGrains, @BetterHaven, 0, @EACH, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, intUnitMeasureId, dblAverageCost) VALUES (@HotGrains, @BetterHaven, 0, @EACH, 0)
		END

		-- Fake data for tblICInventoryFIFO
		BEGIN
			INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 100, 0, 22.00, 1)
			INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@StickyGrains, @Default_Location, 'January 1, 2014', 150, 0, 33.00, 1)
			INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@PremiumGrains, @Default_Location, 'January 1, 2014', 200, 0, 44.00, 1)
			INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@ColdGrains, @Default_Location, 'January 1, 2014', 250, 0, 55.00, 1)
			INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@HotGrains, @Default_Location, 'January 1, 2014', 300, 0, 66.00, 1)
		END 

		-- Fake data for Item-Account
		BEGIN 
			-- Add the G/L accounts for WET GRAINS
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, @Account_Inventory, @Inventory_Default);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, @Account_CostOfGoods, @CostOfGoods_Default);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, @Account_APClearing, @APClearing_Default);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, @Account_WriteOffSold, @WriteOffSold_Default);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, @Account_RevalueSold, @RevalueSold_Default);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, @Account_AutoNegative, @AutoNegative_Default);

			-- Add the G/L accounts for STICKY GRAINS
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, @Account_Inventory, @Inventory_NewHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, @Account_CostOfGoods, @CostOfGoods_NewHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, @Account_APClearing, @APClearing_NewHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, @Account_WriteOffSold, @WriteOffSold_NewHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, @Account_RevalueSold, @RevalueSold_NewHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, @Account_AutoNegative, @AutoNegative_NewHaven);

			-- Add the G/L accounts for PREMIUM GRAINS 
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, @Account_Inventory, @Inventory_BetterHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, @Account_CostOfGoods, @CostOfGoods_BetterHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, @Account_APClearing, @APClearing_BetterHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, @Account_WriteOffSold, @WriteOffSold_BetterHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, @Account_RevalueSold, @RevalueSold_BetterHaven);
			INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, @Account_AutoNegative, @AutoNegative_BetterHaven);

			-- Add the G/L accounts for COLD GRAINS 
			-- No item level g/l account overrides for cold grains. Use g/l from category
		
			-- Add the G/L accounts for HOT GRAINS
			-- No item level g/l account overrides for hot grains. Use g/l from category
		END
END 
