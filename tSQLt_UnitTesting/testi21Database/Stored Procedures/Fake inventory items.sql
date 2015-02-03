﻿CREATE PROCEDURE [testi21Database].[Fake inventory items]
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
	DECLARE @InventoryInTransit_Default AS INT = 7000

	DECLARE @Inventory_NewHaven AS INT = 1001
	DECLARE @CostOfGoods_NewHaven AS INT = 2001
	DECLARE @APClearing_NewHaven AS INT = 3001
	DECLARE @WriteOffSold_NewHaven AS INT = 4001
	DECLARE @RevalueSold_NewHaven AS INT = 5001
	DECLARE @AutoNegative_NewHaven AS INT = 6001
	DECLARE @InventoryInTransit_NewHaven AS INT = 7001

	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002
	DECLARE @InventoryInTransit_BetterHaven AS INT = 7002

	DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
	DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
	DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102

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

	-- Declare the item categories
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
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_Inventory, @Inventory_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_CostOfGoods, @CostOfGoods_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_APClearing, @APClearing_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_WriteOffSold, @WriteOffSold_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_RevalueSold, @RevalueSold_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @AccountCategoryId_AutoNegative, @AutoNegative_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @@AccountCategoryId_InventoryInTransit, @InventoryInTransit_Default);

		-- Use tblSMCompanyLocation to store the GL Accounts. This will change in 15.2 where GL accounts will be retrieved in tblSMCompanyLocationAccount
		UPDATE	tblSMCompanyLocation 
		SET		intInventory = @Inventory_Default
				,intCostofGoodsSold = @CostOfGoods_Default
				,intAPClearing = @APClearing_Default
				,intWriteOffSold = @WriteOffSold_Default
				,intRevalueSold = @RevalueSold_Default
				,intAutoNegativeSold = @AutoNegative_Default
				,intInventoryInTransit = @InventoryInTransit_Default
		FROM	tblSMCompanyLocation 
		WHERE	intCompanyLocationId = @Default_Location

		-- G/L Accounts for Company Location 2 ('NEW HAVEN')
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_Inventory, @Inventory_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_CostOfGoods, @CostOfGoods_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_APClearing, @APClearing_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_WriteOffSold, @WriteOffSold_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_RevalueSold, @RevalueSold_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_AutoNegative, @AutoNegative_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @AccountCategoryId_InventoryInTransit, @InventoryInTransit_NewHaven);

		-- Use tblSMCompanyLocation to store the GL Accounts. This will change in 15.2 where GL accounts will be retrieved in tblSMCompanyLocationAccount
		UPDATE	tblSMCompanyLocation 
		SET		intInventory = @Inventory_NewHaven
				,intCostofGoodsSold = @CostOfGoods_NewHaven
				,intAPClearing = @APClearing_NewHaven
				,intWriteOffSold = @WriteOffSold_NewHaven
				,intRevalueSold = @RevalueSold_NewHaven
				,intAutoNegativeSold = @AutoNegative_NewHaven
				,intInventoryInTransit = @InventoryInTransit_NewHaven
		FROM	tblSMCompanyLocation 
		WHERE	intCompanyLocationId = @NewHaven

		-- G/L Accounts for Company Location 3 ('BETTER HAVEN')
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_Inventory, @Inventory_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_CostOfGoods, @CostOfGoods_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_APClearing, @APClearing_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_WriteOffSold, @WriteOffSold_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_RevalueSold, @RevalueSold_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_AutoNegative, @AutoNegative_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @AccountCategoryId_InventoryInTransit, @InventoryInTransit_BetterHaven);

		-- Use tblSMCompanyLocation to store the GL Accounts. This will change in 15.2 where GL accounts will be retrieved in tblSMCompanyLocationAccount
		UPDATE	tblSMCompanyLocation 
		SET		intInventory = @Inventory_BetterHaven
				,intCostofGoodsSold = @CostOfGoods_BetterHaven
				,intAPClearing = @APClearing_BetterHaven
				,intWriteOffSold = @WriteOffSold_BetterHaven
				,intRevalueSold = @RevalueSold_BetterHaven
				,intAutoNegativeSold = @AutoNegative_BetterHaven
				,intInventoryInTransit = @InventoryInTransit_BetterHaven
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
		INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, @Inventory_NewHaven, @AccountCategoryId_Inventory)
		INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, @CostOfGoods_NewHaven, @AccountCategoryId_CostOfGoods)
		INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, @APClearing_NewHaven, @AccountCategoryId_APClearing)

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
	/*
		intItemLocationId		intItemId		intLocationId
		------------------		-------------	---------------------------
		1						Wet Grains		Default Location
		2						Sticky Grains	Default Location
		3						Premium Grains	Default Location
		4						Cold Grains		Default Location
		5						Hot Grains		Default Location
		6						Wet Grains		New Haven
		7						Sticky Grains	New Haven
		8						Premium Grains	New Haven
		9						Cold Grains		New Haven
		10						Hot Grains		New Haven
		11						Wet Grains		Better Haven
		12						Sticky Grains	Better Haven
		13						Premium Grains	Better Haven
		14						Cold Grains		Better Haven
		15						Hot Grains		Better Haven	
	*/

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
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_Inventory, @Inventory_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_CostOfGoods, @CostOfGoods_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_APClearing, @APClearing_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_WriteOffSold, @WriteOffSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_RevalueSold, @RevalueSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_AutoNegative, @AutoNegative_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @AccountCategoryId_InventoryInTransit, @InventoryInTransit_Default);

		-- Add the G/L accounts for STICKY GRAINS
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_Inventory, @Inventory_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_CostOfGoods, @CostOfGoods_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_APClearing, @APClearing_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_WriteOffSold, @WriteOffSold_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_RevalueSold, @RevalueSold_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_AutoNegative, @AutoNegative_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @AccountCategoryId_InventoryInTransit, @InventoryInTransit_NewHaven);

		-- Add the G/L accounts for PREMIUM GRAINS 
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_Inventory, @Inventory_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_CostOfGoods, @CostOfGoods_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_APClearing, @APClearing_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_WriteOffSold, @WriteOffSold_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_RevalueSold, @RevalueSold_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_AutoNegative, @AutoNegative_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @AccountCategoryId_InventoryInTransit, @InventoryInTransit_BetterHaven);

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
