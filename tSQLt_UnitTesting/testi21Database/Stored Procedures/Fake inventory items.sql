CREATE PROCEDURE [testi21Database].[Fake inventory items]
AS
BEGIN
	EXEC testi21Database.[Fake COA used for fake inventory items]

	-- Create the fake table and data for the items
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocation';
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocationAccount', @Identity = 1;

	DROP VIEW vyuAPRptPurchase	
	EXEC tSQLt.FakeTable 'dbo.tblICItem';
	EXEC tSQLt.FakeTable 'dbo.tblICItemLocation', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemAccount', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICCategory';
	EXEC tSQLt.FakeTable 'dbo.tblICCategoryAccount', @Identity = 1;		
	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;		
	EXEC tSQLt.FakeTable 'dbo.tblICUnitMeasure';
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM', @Identity = 1;
	
		
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

	DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
	DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
	DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102

	-- Declare Account descriptions
	DECLARE @Account_Inventory AS NVARCHAR(100) = 'Inventory'
	DECLARE @Account_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
	DECLARE @Account_APClearing AS NVARCHAR(100) = 'AP Clearing'
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

	-- Negative stock options
	DECLARE @AllowNegativeStock AS INT = 1
	DECLARE @AllowNegativeStockWithWriteOff AS INT = 2
	DECLARE @DoNotAllowNegativeStock AS INT = 3

	-- Fake company locations 
	BEGIN 
		INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@Default_Location, 'DEFAULT', @SegmentId_DEFAULT_LOCATION)
		INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@NewHaven, 'NEW HAVEN', @SegmentId_NEW_HAVEN_LOCATION)
		INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@BetterHaven, 'BETTER HAVEN', @SegmentId_BETTER_HAVEN_LOCATION)
	END

	-- Fake data for Company-Location-Account
	BEGIN 
		-- G/L Accounts for Company Location 1 ('Default')
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_Inventory, @Inventory_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_CostOfGoods, @CostOfGoods_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_APClearing, @APClearing_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_WriteOffSold, @WriteOffSold_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_RevalueSold, @RevalueSold_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@Default_Location, @Account_AutoNegative, @AutoNegative_Default);

		-- Use tblSMCompanyLocation to store the GL Accounts. This will change in 15.2 where GL accounts will be retrieved in tblSMCompanyLocationAccount
		UPDATE	tblSMCompanyLocation 
		SET		intInventory = @Inventory_Default
				,intCostofGoodsSold = @CostOfGoods_Default
				,intAPClearing = @APClearing_Default
				,intWriteOffSold = @WriteOffSold_Default
				,intRevalueSold = @RevalueSold_Default
				,intAutoNegativeSold = @AutoNegative_Default
		FROM	tblSMCompanyLocation 
		WHERE	intCompanyLocationId = @Default_Location

		-- G/L Accounts for Company Location 2 ('NEW HAVEN')
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_Inventory, @Inventory_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_CostOfGoods, @CostOfGoods_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_APClearing, @APClearing_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_WriteOffSold, @WriteOffSold_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_RevalueSold, @RevalueSold_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@NewHaven, @Account_AutoNegative, @AutoNegative_NewHaven);

		-- Use tblSMCompanyLocation to store the GL Accounts. This will change in 15.2 where GL accounts will be retrieved in tblSMCompanyLocationAccount
		UPDATE	tblSMCompanyLocation 
		SET		intInventory = @Inventory_NewHaven
				,intCostofGoodsSold = @CostOfGoods_NewHaven
				,intAPClearing = @APClearing_NewHaven
				,intWriteOffSold = @WriteOffSold_NewHaven
				,intRevalueSold = @RevalueSold_NewHaven
				,intAutoNegativeSold = @AutoNegative_NewHaven
		FROM	tblSMCompanyLocation 
		WHERE	intCompanyLocationId = @NewHaven

		-- G/L Accounts for Company Location 3 ('BETTER HAVEN')
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_Inventory, @Inventory_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_CostOfGoods, @CostOfGoods_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_APClearing, @APClearing_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_WriteOffSold, @WriteOffSold_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_RevalueSold, @RevalueSold_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (@BetterHaven, @Account_AutoNegative, @AutoNegative_BetterHaven);

		-- Use tblSMCompanyLocation to store the GL Accounts. This will change in 15.2 where GL accounts will be retrieved in tblSMCompanyLocationAccount
		UPDATE	tblSMCompanyLocation 
		SET		intInventory = @Inventory_BetterHaven
				,intCostofGoodsSold = @CostOfGoods_BetterHaven
				,intAPClearing = @APClearing_BetterHaven
				,intWriteOffSold = @WriteOffSold_BetterHaven
				,intRevalueSold = @RevalueSold_BetterHaven
				,intAutoNegativeSold = @AutoNegative_BetterHaven
		FROM	tblSMCompanyLocation 
		WHERE	intCompanyLocationId = @BetterHaven
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
		INSERT INTO dbo.tblICItem (intItemId, strDescription) VALUES (@ColdGrains, 'COLD GRAINS')
		INSERT INTO dbo.tblICItem (intItemId, strDescription) VALUES (@HotGrains, 'HOT GRAINS')
	END

	-- Fake data for Item-Location
	BEGIN 
		-- Add items for location 1 ('Default')
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod, intCategoryId) VALUES (@HotGrains, @Default_Location, @AllowNegativeStock, @AverageCosting, @HotItems)

		-- Add items for location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod, intCategoryId) VALUES (@HotGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO, @HotItems)

		-- Add items for location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod, intCategoryId) VALUES (@HotGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO, @HotItems)
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
	
	-- Create the fake table and data for the unit of measure
	BEGIN 
		DECLARE @UOMBushel AS INT = 1
		DECLARE @UOMPound AS INT = 2

		-- Unit of measure master table
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure) VALUES (@UOMBushel, 'Bushel')
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure) VALUES (@UOMPound, 'Pound')
		
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains, @UOMBushel, 1)
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains, @UOMBushel, 1)
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains, @UOMBushel, 1)
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains, @UOMBushel, 1)
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains, @UOMBushel, 1)	
	END 
END 
