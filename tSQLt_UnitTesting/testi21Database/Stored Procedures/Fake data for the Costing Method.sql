CREATE PROCEDURE [testi21Database].[Fake data for the Costing Method]
AS
BEGIN
	-- DECLARE CONSTANTS
	DECLARE @AllowNegativeStock AS INT = 1
	DECLARE @AllowNegativeStockWithWriteOff AS INT = 2
	DECLARE @DoNotAllowNegativeStock AS INT = 3

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

	-- Declare the categories
	DECLARE @HotItems AS INT = 1
			,@ColdItems AS INT = 2;

	-- Declare the costing methods
	DECLARE @AverageCost AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3

	-- Use the 'fake data for simple COA' for the simple items
	EXEC testi21Database.[Fake data for simple COA]

	-- Create the fake table and data for the items
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocation';
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocationAccount', @Identity = 1;

	DROP VIEW vyuAPRptPurchase
	EXEC tSQLt.FakeTable 'dbo.tblICItem';
	EXEC tSQLt.FakeTable 'dbo.tblICItemLocation', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICItemAccount', @Identity = 1;

	EXEC tSQLt.FakeTable 'dbo.tblICCategory';
	EXEC tSQLt.FakeTable 'dbo.tblICCategoryAccount', @Identity = 1;

	INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (@Default_Location, 'DEFAULT LOCATION')
	INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (@NewHaven, 'NEW HAVEN')
	INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@BetterHaven, 'BETTER HAVEN', 100)

	-- G/L Accounts for DEFAULT LOCATION
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, 'Inventory', 1000);
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, 'Cost of Goods', 2000);
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, 'Purchase Account', 3000);

	-- G/L Accounts for NEW HAVEN
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, 'Inventory', 1001);
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, 'Cost of Goods', 2001);
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, 'Purchase Account', 3001);

	-- G/L Accounts for BETTER HAVEN
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, 'Inventory', 1002);
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, 'Cost of Goods', 2002);
	INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, 'Purchase Account', 3002);

	-- Category
	INSERT INTO tblICCategory (intCategoryId, strDescription, intCostingMethod) VALUES (@HotItems, 'Hot Items', @FIFO);
	INSERT INTO tblICCategory (intCategoryId, strDescription, intCostingMethod) VALUES (@ColdItems, 'Cold Items', @LIFO);

	-- Category Account
	-- Add G/L setup for Hot items
	INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (@HotItems, 1001, 'Inventory')
	INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (@HotItems, 2001, 'Cost of Goods')
	INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (@HotItems, 3001, 'Purchase Account')

	-- Add G/L setup for Cold items
	-- No category-level g/l account overrides for Cold items. Use default g/l account from Location. 
		
	-- Items 
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@WetGrains, 'WET GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@StickyGrains, 'STICKY GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@PremiumGrains, 'PREMIUM GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@ColdGrains, 'COLD GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@HotGrains, 'HOT GRAINS')

	-- Add items for DEFAULT LOCATION 
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @Default_Location, @AllowNegativeStock, @AverageCost)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @Default_Location, @AllowNegativeStock, @AverageCost)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @Default_Location, @AllowNegativeStock, @AverageCost)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod, intCategoryId) VALUES (@ColdGrains, @Default_Location, @AllowNegativeStock, @AverageCost, @ColdItems)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod, intCategoryId) VALUES (@HotGrains, @Default_Location, @AllowNegativeStock, @AverageCost, @HotItems)

	-- Add items for NEW HAVEN
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @AverageCost)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @AverageCost)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @AverageCost)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCategoryId) VALUES (@ColdGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @ColdItems)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCategoryId) VALUES (@HotGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @HotItems)

	-- Add items for BETTER HAVEN
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (@WetGrains, @BetterHaven, @DoNotAllowNegativeStock)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (@StickyGrains, @BetterHaven, @DoNotAllowNegativeStock)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (@PremiumGrains, @BetterHaven, @DoNotAllowNegativeStock)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCategoryId) VALUES (@ColdGrains, @BetterHaven, @DoNotAllowNegativeStock, @ColdItems)
	INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCategoryId) VALUES (@HotGrains, @BetterHaven, @DoNotAllowNegativeStock, @HotItems)
		
	-- Add stock information for all items under the DEFAULT LOCATION 
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@WetGrains, @Default_Location,	100)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@StickyGrains, @Default_Location, 150)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @Default_Location, 200)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@ColdGrains, @Default_Location, 250)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@HotGrains, @Default_Location, 300)

	-- Add stock information for all items under NEW HAVEN
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@WetGrains, @NewHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@StickyGrains, @NewHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @NewHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@ColdGrains, @NewHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@HotGrains, @NewHaven, 0)

	-- Add stock information for all items under BETTER HAVEN
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@WetGrains, @BetterHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@StickyGrains, @BetterHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @BetterHaven, 0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@ColdGrains, @BetterHaven,	0)
	INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (@HotGrains, @BetterHaven,	0)

	-- Add the G/L accounts for WET GRAINS
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, 'Inventory', 1000);
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, 'Cost of Goods', 2000);
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@WetGrains, 'Purchase Account', 3000);

	-- Add the G/L accounts for STICKY GRAINS
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, 'Inventory', 1001);
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, 'Cost of Goods', 2001);
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@StickyGrains, 'Purchase Account', 3001);

	-- Add the G/L accounts for PREMIUM GRAINS 
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, 'Inventory', 1002);
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, 'Cost of Goods', 2002);
	INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (@PremiumGrains, 'Purchase Account', 3002);

	-- Add the G/L accounts for COLD GRAINS 
	-- No item level g/l account overrides for cold grains. Use g/l from category
		
	-- Add the G/L accounts for HOT GRAINS
	-- No item level g/l account overrides for hot grains. Use g/l from category

END