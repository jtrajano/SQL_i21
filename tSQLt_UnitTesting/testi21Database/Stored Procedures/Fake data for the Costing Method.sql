CREATE PROCEDURE [testi21Database].[Fake data for the Costing Method]
AS
BEGIN
	EXEC testi21Database.[Fake COA used for fake inventory items]

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
			,@ManualLotGrains AS INT = 6
			,@SerialLotGrains AS INT = 7

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

	DECLARE @AccountCategoryName_InventoryInTransit AS NVARCHAR(100) = 'Inventory In Transit'
	DECLARE @AccountCategoryId_InventoryInTransit AS INT = 46

	-- Add fake data for SM Company Location
	INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (@Default_Location, 'DEFAULT LOCATION')
	INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (@NewHaven, 'NEW HAVEN')
	INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@BetterHaven, 'BETTER HAVEN', 100)

	-- G/L Accounts for DEFAULT LOCATION
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_Inventory, 1000);
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_CostOfGoods, 2000);
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_APClearing, 3000);

	UPDATE	tblSMCompanyLocation 
	SET		intInventory = 1000
			,intCostofGoodsSold = 2000
			,intAPAccount = 3000
	FROM	tblSMCompanyLocation 
	WHERE	intCompanyLocationId = @Default_Location

	-- G/L Accounts for NEW HAVEN
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_Inventory, 1001);
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_CostOfGoods, 2001);
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_APClearing, 3001);

	UPDATE	tblSMCompanyLocation 
	SET		intInventory = 1001
			,intCostofGoodsSold = 2001
			,intAPAccount = 3001
	FROM	tblSMCompanyLocation 
	WHERE	intCompanyLocationId = @NewHaven

	-- G/L Accounts for BETTER HAVEN
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_Inventory, 1002);
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_CostOfGoods, 2002);
	--INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, intAccountCategoryId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_APClearing, 3002);

	UPDATE	tblSMCompanyLocation 
	SET		intInventory = 1002
			,intCostofGoodsSold = 2002
			,intAPAccount = 3002
	FROM	tblSMCompanyLocation 
	WHERE	intCompanyLocationId = @BetterHaven

	-- Category
	INSERT INTO tblICCategory (intCategoryId, strDescription, intCostingMethod) VALUES (@HotItems, 'Hot Items', @FIFO);
	INSERT INTO tblICCategory (intCategoryId, strDescription, intCostingMethod) VALUES (@ColdItems, 'Cold Items', @LIFO);

	-- Category Account
	-- Add G/L setup for Hot items
	INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, 1001, @AccountCategoryId_Inventory)
	INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, 2001, @AccountCategoryId_CostOfGoods)
	INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, 3001, @AccountCategoryId_APClearing)

	-- Add G/L setup for Cold items
	-- No category-level g/l account overrides for Cold items. Use default g/l account from Location. 
		
	-- Items 
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@WetGrains, 'WET GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@StickyGrains, 'STICKY GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@PremiumGrains, 'PREMIUM GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@ColdGrains, 'COLD GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription) VALUES (@HotGrains, 'HOT GRAINS')
	INSERT INTO tblICItem (intItemId, strDescription, strLotTracking) VALUES (@ManualLotGrains, 'MANUAL LOT GRAINS', 'Yes, Manual')
	INSERT INTO tblICItem (intItemId, strDescription, strLotTracking) VALUES (@SerialLotGrains, 'SERIAL LOT GRAINS', 'Yes, Serial Number')

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
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, 1,	100)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, 2, 150)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, 3, 200)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, 4, 250)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, 5, 300)

	-- Add stock information for all items under NEW HAVEN
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, 6, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, 7, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, 8, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, 9, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, 10, 0)

	-- Add stock information for all items under BETTER HAVEN
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, 11, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, 12, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, 13, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, 14, 0)
	INSERT INTO tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, 15, 0)

	-- Add the G/L accounts for WET GRAINS
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_Inventory, 1000);
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_CostOfGoods, 2000);
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_APClearing, 3000);

	-- Add the G/L accounts for STICKY GRAINS
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_Inventory, 1001);
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_CostOfGoods, 2001);
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_APClearing, 3001);

	-- Add the G/L accounts for PREMIUM GRAINS 
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_Inventory, 1002);
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_CostOfGoods, 2002);
	INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_APClearing, 3002);

	-- Add the G/L accounts for COLD GRAINS 
	-- No item level g/l account overrides for cold grains. Use g/l from category
		
	-- Add the G/L accounts for HOT GRAINS
	-- No item level g/l account overrides for hot grains. Use g/l from category

END