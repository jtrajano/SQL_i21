CREATE PROCEDURE [testi21Database].[Fake inventory items]
AS
BEGIN
	EXEC testi21Database.[Fake COA used for fake inventory items]

	-- Create the fake table and data for the items
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocation';
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocationAccount', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocationSubLocation'; -- For sub Location
	EXEC tSQLt.FakeTable 'dbo.tblICItem';
	EXEC tSQLt.FakeTable 'dbo.tblICItemLocation';
	EXEC tSQLt.FakeTable 'dbo.tblICItemAccount', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICCategory';
	EXEC tSQLt.FakeTable 'dbo.tblICCategoryAccount', @Identity = 1;		
	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemStockUOM', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemPricing', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICUnitMeasure';
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
	EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICStockReservation', @Identity = 1;		
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICStorageLocation';
	EXEC tSQLt.FakeTable 'dbo.tblICCommodity';
	EXEC tSQLt.FakeTable 'dbo.tblICCommodityAccount', @Identity = 1;		
		
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@CornCommodity AS INT = 8
			,@OtherCharges AS INT = 9
			,@SurchargeOtherCharges AS INT = 10
			,@SurchargeOnSurcharge AS INT = 11
			,@SurchargeOnSurchargeOnSurcharge AS INT = 12
			,@InvalidItem AS INT = -1

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1

	-- Declare the variables for sub-locations
	DECLARE @Raw_Materials_SubLocation_DefaultLocation AS INT = 1
			,@FinishedGoods_SubLocation_DefaultLocation AS INT = 2
			,@Raw_Materials_SubLocation_NewHaven AS INT = 3
			,@FinishedGoods_SubLocation_NewHaven AS INT = 4
			,@Raw_Materials_SubLocation_BetterHaven AS INT = 5
			,@FinishedGoods_SubLocation_BetterHaven AS INT = 6

	-- Declare the variables for storage locations
	DECLARE @StorageSilo_RM_DL AS INT = 1
			,@StorageSilo_FG_DL AS INT = 2
			,@StorageSilo_RM_NH AS INT = 3
			,@StorageSilo_FG_NH AS INT = 4
			,@StorageSilo_RM_BH AS INT = 5
			,@StorageSilo_FG_BH AS INT = 6

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

	-- Declare the account ids
	DECLARE	 @Inventory_Default AS INT = 1000
			,@CostOfGoods_Default AS INT = 2000
			,@APClearing_Default AS INT = 3000
			,@WriteOffSold_Default AS INT = 4000
			,@RevalueSold_Default AS INT = 5000 
			,@AutoNegative_Default AS INT = 6000
			,@InventoryInTransit_Default AS INT = 7000
			,@AccountReceivable_Default AS INT = 8000
			,@InventoryAdjustment_Default AS INT = 9000
			,@OtherChargeExpense_Default AS INT = 10000
			,@OtherChargeIncome_Default AS INT = 11000
			,@OtherChargeAsset_Default AS INT = 12000

			,@Inventory_NewHaven AS INT = 1001
			,@CostOfGoods_NewHaven AS INT = 2001
			,@APClearing_NewHaven AS INT = 3001
			,@WriteOffSold_NewHaven AS INT = 4001
			,@RevalueSold_NewHaven AS INT = 5001
			,@AutoNegative_NewHaven AS INT = 6001
			,@InventoryInTransit_NewHaven AS INT = 7001
			,@AccountReceivable_NewHaven AS INT = 8001
			,@InventoryAdjustment_NewHaven AS INT = 9001
			,@OtherChargeExpense_NewHaven AS INT = 10001
			,@OtherChargeIncome_NewHaven AS INT = 11001
			,@OtherChargeAsset_NewHaven AS INT = 12001

			,@Inventory_BetterHaven AS INT = 1002
			,@CostOfGoods_BetterHaven AS INT = 2002
			,@APClearing_BetterHaven AS INT = 3002
			,@WriteOffSold_BetterHaven AS INT = 4002
			,@RevalueSold_BetterHaven AS INT = 5002
			,@AutoNegative_BetterHaven AS INT = 6002
			,@InventoryInTransit_BetterHaven AS INT = 7002
			,@AccountReceivable_BetterHaven AS INT = 8002
			,@InventoryAdjustment_BetterHaven AS INT = 9002
			,@OtherChargeExpense_BetterHaven AS INT = 10002
			,@OtherChargeIncome_BetterHaven AS INT = 11002
			,@OtherChargeAsset_BetterHaven AS INT = 12002

	DECLARE @SEGMENT_ID_DefaultLocation AS INT = 100
			,@SEGMENT_ID_NewHavenLocation AS INT = 101
			,@SEGMENT_ID_BetterHavenLocation AS INT = 102

	-- Declare Account Categories
	DECLARE @ACCOUNT_CATEGORY_NAME_Inventory AS NVARCHAR(100) = 'Inventory'
	DECLARE @ACCOUNT_CATEGORY_ID_Inventory AS INT -- = 27

	SELECT @ACCOUNT_CATEGORY_ID_Inventory = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_Inventory

	DECLARE @ACCOUNT_CATEGORY_NAME_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
	DECLARE @ACCOUNT_CATEGORY_ID_CostOfGoods AS INT -- = 10

	SELECT @ACCOUNT_CATEGORY_ID_CostOfGoods = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_CostOfGoods

	DECLARE @ACCOUNT_CATEGORY_NAME_APClearing AS NVARCHAR(100) = 'AP Clearing'
	DECLARE @ACCOUNT_CATEGORY_ID_APClearing AS INT --= 45

	SELECT @ACCOUNT_CATEGORY_ID_APClearing = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_APClearing
	
	DECLARE @ACCOUNT_CATEGORY_NAME_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
	DECLARE @ACCOUNT_CATEGORY_ID_WriteOffSold AS INT -- = 42

	SELECT @ACCOUNT_CATEGORY_ID_WriteOffSold = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_WriteOffSold

	DECLARE @ACCOUNT_CATEGORY_NAME_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
	DECLARE @ACCOUNT_CATEGORY_ID_RevalueSold AS INT -- = 43

	SELECT @ACCOUNT_CATEGORY_ID_RevalueSold = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_RevalueSold

	DECLARE @ACCOUNT_CATEGORY_NAME_AutoNegative AS NVARCHAR(100) = 'Auto Negative'
	DECLARE @ACCOUNT_CATEGORY_ID_AutoNegative AS INT -- = 44

	SELECT @ACCOUNT_CATEGORY_ID_AutoNegative = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_AutoNegative

	DECLARE @ACCOUNT_CATEGORY_NAME_InventoryInTransit AS NVARCHAR(100) = 'Inventory In Transit'
	DECLARE @ACCOUNT_CATEGORY_ID_InventoryInTransit AS INT -- = 46

	SELECT @ACCOUNT_CATEGORY_ID_InventoryInTransit = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_InventoryInTransit

	DECLARE @ACCOUNT_CATEGORY_NAME_InventoryAdjustment AS NVARCHAR(100) = 'Inventory Adjustment'	
	DECLARE @ACCOUNT_CATEGORY_ID_InventoryAdjustment AS INT -- = 50
	SELECT @ACCOUNT_CATEGORY_ID_InventoryAdjustment = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_InventoryAdjustment

	DECLARE @ACCOUNT_CATEGORY_NAME_OtherChargeExpense AS NVARCHAR(100) = 'Other Charge Expense'	
	DECLARE @ACCOUNT_CATEGORY_ID_OtherChargeExpense AS INT
	SELECT @ACCOUNT_CATEGORY_ID_OtherChargeExpense = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_OtherChargeExpense
	
	DECLARE @ACCOUNT_CATEGORY_NAME_OtherChargeIncome AS NVARCHAR(100) = 'Other Charge Income'	
	DECLARE @ACCOUNT_CATEGORY_ID_OtherChargeIncome AS INT
	SELECT @ACCOUNT_CATEGORY_ID_OtherChargeIncome = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_OtherChargeIncome
	
	DECLARE @ACCOUNT_CATEGORY_NAME_OtherChargeAsset AS NVARCHAR(100) = 'Other Charge (Asset)'	
	DECLARE @ACCOUNT_CATEGORY_ID_OtherChargeAsset AS INT
	SELECT @ACCOUNT_CATEGORY_ID_OtherChargeAsset = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @ACCOUNT_CATEGORY_NAME_OtherChargeAsset
	
	-- Declare the item categories
	DECLARE @HotItems AS INT = 1
	DECLARE @ColdItems AS INT = 2

	-- Declare the commodities
	DECLARE @Commodity_Corn AS INT = 999

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
		INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@Default_Location, 'DEFAULT', @SEGMENT_ID_DefaultLocation)
		INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@NewHaven, 'NEW HAVEN', @SEGMENT_ID_NewHavenLocation)
		INSERT INTO dbo.tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (@BetterHaven, 'BETTER HAVEN', @SEGMENT_ID_BetterHavenLocation)
	END

	-- Fake data for Company-Location-Account
	BEGIN 
		-- G/L Accounts for Company Location 1 ('Default')
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_Default);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@Default_Location, @@ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_Default);

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
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_NewHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@NewHaven, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_NewHaven);

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
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_BetterHaven);
		--INSERT INTO dbo.tblSMCompanyLocationAccount (intCompanyLocationId, intCategoryAccountId, intAccountId) VALUES (@BetterHaven, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_BetterHaven);

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

	-- Fake data for sub location 
	BEGIN 
		INSERT INTO dbo.tblSMCompanyLocationSubLocation(
			intCompanyLocationSubLocationId
			,intCompanyLocationId
			,strSubLocationName
			,strSubLocationDescription
			,strClassification
			,intNewLotBin
			,intAuditBin
			,strAddress
			,intConcurrencyId
		)
		SELECT 
			intCompanyLocationSubLocationId	= @Raw_Materials_SubLocation_DefaultLocation
			,intCompanyLocationId			= @Default_Location
			,strSubLocationName				= 'DL-Raw Materials'
			,strSubLocationDescription		= 'Default Location Raw Materials'
			,strClassification				= ''
			,intNewLotBin					= NULL 
			,intAuditBin					= NULL 
			,strAddress					= NULL 
			,intConcurrencyId				= 1
		UNION ALL 
		SELECT 
			intCompanyLocationSubLocationId	= @FinishedGoods_SubLocation_DefaultLocation
			,intCompanyLocationId			= @Default_Location
			,strSubLocationName				= 'DL-Finished Goods'
			,strSubLocationDescription		= 'Default Location Finished Goods'
			,strClassification				= ''
			,intNewLotBin					= NULL 
			,intAuditBin					= NULL 
			,strAddress					= NULL 
			,intConcurrencyId				= 1
		UNION ALL 
		SELECT 
			intCompanyLocationSubLocationId	= @Raw_Materials_SubLocation_NewHaven
			,intCompanyLocationId			= @NewHaven
			,strSubLocationName				= 'NH-Raw Materials'
			,strSubLocationDescription		= 'New Haven Raw Materials'
			,strClassification				= ''
			,intNewLotBin					= NULL 
			,intAuditBin					= NULL 
			,strAddress					= NULL 
			,intConcurrencyId				= 1
		UNION ALL 
		SELECT 
			intCompanyLocationSubLocationId	= @FinishedGoods_SubLocation_NewHaven
			,intCompanyLocationId			= @NewHaven
			,strSubLocationName				= 'NH-Finished Goods'
			,strSubLocationDescription		= 'New Haven Finished Goods'
			,strClassification				= ''
			,intNewLotBin					= NULL 
			,intAuditBin					= NULL 
			,strAddress					= NULL 
			,intConcurrencyId				= 1
		UNION ALL 
		SELECT 
			intCompanyLocationSubLocationId	= @Raw_Materials_SubLocation_BetterHaven
			,intCompanyLocationId			= @BetterHaven
			,strSubLocationName				= 'BH-Raw Materials'
			,strSubLocationDescription		= 'Better Haven Raw Materials'
			,strClassification				= ''
			,intNewLotBin					= NULL 
			,intAuditBin					= NULL 
			,strAddress					= NULL 
			,intConcurrencyId				= 1
		UNION ALL 
		SELECT 
			intCompanyLocationSubLocationId	= @FinishedGoods_SubLocation_BetterHaven
			,intCompanyLocationId			= @BetterHaven
			,strSubLocationName				= 'BH-Finished Goods'
			,strSubLocationDescription		= 'Better Haven Finished Goods'
			,strClassification				= ''
			,intNewLotBin					= NULL 
			,intAuditBin					= NULL 
			,strAddress					= NULL 
			,intConcurrencyId				= 1
	END 

	-- Fake data for Storage Locations 
	BEGIN 
		INSERT INTO dbo.tblICStorageLocation (
				intStorageLocationId
				,strName
				,strDescription
		)
		SELECT	intStorageLocationId		= @StorageSilo_RM_DL
				,strName					= 'Storage Silo RM DL'
				,strDescription				= 'Silo for Raw Materials in Default Location'
		UNION ALL
		SELECT	intStorageLocationId		= @StorageSilo_FG_DL
				,strName					= 'Storage Silo FG DL'
				,strDescription				= 'Silo for Finished Goods in Default Location'
		UNION ALL 
		SELECT	intStorageLocationId		= @StorageSilo_RM_NH
				,strName					= 'Storage Silo RM NH'
				,strDescription				= 'Silo for Raw Materials in New Haven'
		UNION ALL
		SELECT	intStorageLocationId		= @StorageSilo_FG_NH
				,strName					= 'Storage Silo FG NH'
				,strDescription				= 'Silo for Finished Goods in New Haven'
		UNION ALL 
		SELECT	intStorageLocationId		= @StorageSilo_RM_BH
				,strName					= 'Storage Silo RM BH'
				,strDescription				= 'Silo for Raw Materials in Better Haven'
		UNION ALL
		SELECT	intStorageLocationId		= @StorageSilo_FG_BH
				,strName					= 'Storage Silo FG BH'
				,strDescription				= 'Silo for Finished Goods in Better Haven'
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
		INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, @Inventory_NewHaven, @ACCOUNT_CATEGORY_ID_Inventory)
		INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, @CostOfGoods_NewHaven, @ACCOUNT_CATEGORY_ID_CostOfGoods)
		INSERT INTO dbo.tblICCategoryAccount (intCategoryId, intAccountId, intAccountCategoryId) VALUES (@HotItems, @APClearing_NewHaven, @ACCOUNT_CATEGORY_ID_APClearing)

		-- Add G/L setup for Cold items
		-- No category-level g/l account overrides for Cold items. Use default g/l account from Location. 
	END


	-- Fake Commodity 
	BEGIN 
		INSERT INTO dbo.tblICCommodity (intCommodityId, strDescription) VALUES (@Commodity_Corn, 'Commodity record for corn.');
		INSERT INTO dbo.tblICCommodityAccount (intCommodityId, intAccountId, intAccountCategoryId) VALUES (@Commodity_Corn, @Inventory_Default, @ACCOUNT_CATEGORY_ID_Inventory)
		INSERT INTO dbo.tblICCommodityAccount (intCommodityId, intAccountId, intAccountCategoryId) VALUES (@Commodity_Corn, @CostOfGoods_Default, @ACCOUNT_CATEGORY_ID_CostOfGoods)
		INSERT INTO dbo.tblICCommodityAccount (intCommodityId, intAccountId, intAccountCategoryId) VALUES (@Commodity_Corn, @APClearing_Default, @ACCOUNT_CATEGORY_ID_APClearing)
	END 
		
	-- Fake data for Items 
	BEGIN 
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo) VALUES (@WetGrains, 'WET GRAINS DESCRIPTION', 'WET GRAINS')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo) VALUES (@StickyGrains, 'STICKY GRAINS DESCRIPTION', 'STICKY GRAINS')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo) VALUES (@PremiumGrains, 'PREMIUM GRAINS DESCRIPTION', 'PREMIUM GRAINS')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, intCategoryId) VALUES (@ColdGrains, 'COLD GRAINS DESCRIPTION', 'COLD GRAINS', @ColdItems)
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, intCategoryId) VALUES (@HotGrains, 'HOT GRAINS DESCRIPTION', 'HOT GRAINS', @HotItems)
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strLotTracking) VALUES (@ManualLotGrains, 'MANUAL LOT GRAINS DESCRIPTION', 'MANUAL LOT GRAINS', 'Yes - Manual')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strLotTracking) VALUES (@SerializedLotGrains, 'SERIALIZED LOT GRAINS DESCRIPTION', 'SERIALIZED LOT GRAINS', 'Yes - Serial Number')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strType, intCommodityId) VALUES (@CornCommodity, 'CORN - A COMMODITY ITEM', 'CORN', 'Commodity', @Commodity_Corn)

		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strType) VALUES (@OtherCharges, 'OTHER CHARGES', 'Other Charges', 'Other Charge')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strType) VALUES (@SurchargeOtherCharges, 'SURCHARGE OTHER CHARGES', 'Surcharge Other Charges', 'Other Charge')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strType) VALUES (@SurchargeOnSurcharge, 'SURCHARGE ON SURCHARGE', 'Surcharge on Surcharge', 'Other Charge')
		INSERT INTO dbo.tblICItem (intItemId, strDescription, strItemNo, strType) VALUES (@SurchargeOnSurchargeOnSurcharge, 'SURCHARGE ON SURCHARGE ON SURCHARGE', 'Surcharge on Surcharge on Surcharge', 'Other Charge')
	END

	-- Fake data for Item-Location
	/*
		intItemLocationId		intItemId				intLocationId		Costing Method
		------------------		-------------			------------------	--------------
		1						Wet Grains				Default Location	Average Cost
		2						Sticky Grains			Default Location	Average Cost
		3						Premium Grains			Default Location	Average Cost
		4						Cold Grains				Default Location	Average Cost
		5						Hot Grains				Default Location	Average Cost
		6						Wet Grains				New Haven			FIFO
		7						Sticky Grains			New Haven			FIFO
		8						Premium Grains			New Haven			FIFO
		9						Cold Grains				New Haven			FIFO
		10						Hot Grains				New Haven			FIFO
		11						Wet Grains				Better Haven		LIFO
		12						Sticky Grains			Better Haven		LIFO
		13						Premium Grains			Better Haven		LIFO
		14						Cold Grains				Better Haven		LIFO
		15						Hot Grains				Better Haven		LIFO
		16						Manual Lot Grains		Default Location	LOT COST
		17						Serialized Lot Grains	Default Location	LOT COST 
		18						Corn					Default Location	Average Cost
		19						Corn					New Haven			FIFO
		20						Corn					Better Haven		LIFO
	*/

	BEGIN 
		-- Add items for location 1 ('Default')
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains_DefaultLocation,  @WetGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains_DefaultLocation, @StickyGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains_DefaultLocation, @PremiumGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains_DefaultLocation, @ColdGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@HotGrains_DefaultLocation, @HotGrains, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@CornCommodity_DefaultLocation, @CornCommodity, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@OtherCharges_DefaultLocation, @OtherCharges, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOtherCharges_DefaultLocation, @SurchargeOtherCharges, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOnSurcharge_DefaultLocation, @SurchargeOnSurcharge, @Default_Location, @AllowNegativeStock, @AverageCosting)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOnSurchargeOnSurcharge_DefaultLocation, @SurchargeOnSurchargeOnSurcharge, @Default_Location, @AllowNegativeStock, @AverageCosting)

		-- Add items for location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains_NewHaven, @WetGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains_NewHaven, @StickyGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains_NewHaven, @PremiumGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains_NewHaven, @ColdGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@HotGrains_NewHaven, @HotGrains, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@CornCommodity_NewHaven, @CornCommodity, @NewHaven, @AllowNegativeStockWithWriteOff, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@OtherCharges_NewHaven, @OtherCharges, @NewHaven, @AllowNegativeStock, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOtherCharges_NewHaven, @SurchargeOtherCharges, @NewHaven, @AllowNegativeStock, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOnSurcharge_NewHaven, @SurchargeOnSurcharge, @NewHaven, @AllowNegativeStock, @FIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOnSurchargeOnSurcharge_NewHaven, @SurchargeOnSurchargeOnSurcharge, @NewHaven, @AllowNegativeStock, @FIFO)

		-- Add items for location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@WetGrains_BetterHaven, @WetGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@StickyGrains_BetterHaven, @StickyGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@PremiumGrains_BetterHaven, @PremiumGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ColdGrains_BetterHaven, @ColdGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@HotGrains_BetterHaven, @HotGrains, @BetterHaven, @DoNotAllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@CornCommodity_BetterHaven, @CornCommodity, @BetterHaven, @AllowNegativeStockWithWriteOff, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@OtherCharges_BetterHaven, @OtherCharges, @BetterHaven, @AllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOtherCharges_BetterHaven, @SurchargeOtherCharges, @BetterHaven, @AllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOnSurcharge_BetterHaven, @SurchargeOnSurcharge, @BetterHaven, @AllowNegativeStock, @LIFO)
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SurchargeOnSurchargeOnSurcharge_BetterHaven, @SurchargeOnSurchargeOnSurcharge, @BetterHaven, @AllowNegativeStock, @LIFO)

		-- Add lot items for location 1 ('Default')
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ManualLotGrains_DefaultLocation, @ManualLotGrains , @Default_Location, @AllowNegativeStock, @AverageCosting) -- Since item is a lot, ignore average costing 
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SerializedLotGrains_DefaultLocation, @SerializedLotGrains, @Default_Location, @AllowNegativeStock, @FIFO) -- Since item is a lot, ignore FIFO costing

		-- Add lot items for location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@ManualLotGrains_NewHaven, @ManualLotGrains , @NewHaven, @AllowNegativeStock, @AverageCosting) -- Since item is a lot, ignore average costing 
		INSERT INTO dbo.tblICItemLocation (intItemLocationId, intItemId, intLocationId, intAllowNegativeInventory, intCostingMethod) VALUES (@SerializedLotGrains_NewHaven, @SerializedLotGrains, @NewHaven, @AllowNegativeStock, @FIFO) -- Since item is a lot, ignore FIFO costing

	END 

	-- Fake data for Item-Account
	BEGIN 
		-- Add the G/L accounts for WET GRAINS
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@WetGrains, @ACCOUNT_CATEGORY_ID_InventoryAdjustment, @InventoryAdjustment_Default);

		-- Add the G/L accounts for STICKY GRAINS
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_NewHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@StickyGrains, @ACCOUNT_CATEGORY_ID_InventoryAdjustment, @InventoryAdjustment_NewHaven);

		-- Add the G/L accounts for PREMIUM GRAINS 
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_BetterHaven);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@PremiumGrains, @ACCOUNT_CATEGORY_ID_InventoryAdjustment, @InventoryAdjustment_BetterHaven);

		-- Add the G/L accounts for COLD GRAINS 
		-- No item level g/l account overrides for cold grains. Use g/l from category
		
		-- Add the G/L accounts for HOT GRAINS
		-- No item level g/l account overrides for hot grains. Use g/l from category

		-- Add the G/L accounts for Manual Lot Item 
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@ManualLotGrains, @ACCOUNT_CATEGORY_ID_InventoryAdjustment, @InventoryAdjustment_Default);

		-- Add the G/L Account for Commodity items. 
		-- Corn
		--INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_Inventory, @Inventory_Default); -- This account id is retrieved from the Commodity > GL Account setup. 
		--INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_CostOfGoods, @CostOfGoods_Default); -- This account id is retrieved from the Commodity > GL Account setup. 
		--INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_APClearing, @APClearing_Default); -- This account id is retrieved from the Commodity > GL Account setup. 
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_WriteOffSold, @WriteOffSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_RevalueSold, @RevalueSold_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_AutoNegative, @AutoNegative_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_InventoryInTransit, @InventoryInTransit_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@CornCommodity, @ACCOUNT_CATEGORY_ID_InventoryAdjustment, @InventoryAdjustment_Default);

		-- Add the G/L Account for Other Charges
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@OtherCharges, @ACCOUNT_CATEGORY_ID_OtherChargeExpense, @OtherChargeExpense_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@OtherCharges, @ACCOUNT_CATEGORY_ID_OtherChargeIncome, @OtherChargeIncome_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@OtherCharges, @ACCOUNT_CATEGORY_ID_OtherChargeAsset, @OtherChargeAsset_Default);

		-- Add the G/L Account for Surcharges Other Charges
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@SurchargeOtherCharges, @ACCOUNT_CATEGORY_ID_OtherChargeExpense, @OtherChargeExpense_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@SurchargeOtherCharges, @ACCOUNT_CATEGORY_ID_OtherChargeIncome, @OtherChargeIncome_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@SurchargeOtherCharges, @ACCOUNT_CATEGORY_ID_OtherChargeAsset, @OtherChargeAsset_Default);

		-- Add the G/L Account for Surcharge On Surcharge
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@SurchargeOnSurcharge, @ACCOUNT_CATEGORY_ID_OtherChargeExpense, @OtherChargeExpense_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@SurchargeOnSurcharge, @ACCOUNT_CATEGORY_ID_OtherChargeIncome, @OtherChargeIncome_Default);
		INSERT INTO tblICItemAccount (intItemId, intAccountCategoryId, intAccountId) VALUES (@SurchargeOnSurcharge, @ACCOUNT_CATEGORY_ID_OtherChargeAsset, @OtherChargeAsset_Default);
	END
	
	-- Create the fake table and data for the unit of measure
	BEGIN 
		DECLARE	@UOM_Bushel AS INT = 1
				,@UOM_Pound AS INT = 2
				,@UOM_Kg AS INT = 3
				,@UOM_25KgBag AS INT = 4
				,@UOM_10LbBag AS INT = 5
				,@UOM_Ton AS INT = 6

		DECLARE @BushelUnitQty AS NUMERIC(18,6) = 1
				,@PoundUnitQty AS NUMERIC(18,6) = 1
				,@KgUnitQty AS NUMERIC(18,6) = 2.20462
				,@25KgBagUnitQty AS NUMERIC(18,6) = 55.1155
				,@10LbBagUnitQty AS NUMERIC(18,6) = 10
				,@TonUnitQty AS NUMERIC(18,6) = 2204.62

		DECLARE @WetGrains_BushelUOM AS INT = 1,		@StickyGrains_BushelUOM AS INT = 2,		@PremiumGrains_BushelUOM AS INT = 3,
				@ColdGrains_BushelUOM AS INT = 4,		@HotGrains_BushelUOM AS INT = 5,		@ManualGrains_BushelUOM AS INT = 6,
				@SerializedGrains_BushelUOM AS INT = 7	

		DECLARE @WetGrains_PoundUOM AS INT = 8,			@StickyGrains_PoundUOM AS INT = 9,		@PremiumGrains_PoundUOM AS INT = 10,
				@ColdGrains_PoundUOM AS INT = 11,		@HotGrains_PoundUOM AS INT = 12,		@ManualGrains_PoundUOM AS INT = 13,
				@SerializedGrains_PoundUOM AS INT = 14	

		DECLARE @WetGrains_KgUOM AS INT = 15,			@StickyGrains_KgUOM AS INT = 16,		@PremiumGrains_KgUOM AS INT = 17,
				@ColdGrains_KgUOM AS INT = 18,			@HotGrains_KgUOM AS INT = 19,			@ManualGrains_KgUOM AS INT = 20,
				@SerializedGrains_KgUOM AS INT = 21

		DECLARE @WetGrains_25KgBagUOM AS INT = 22,		@StickyGrains_25KgBagUOM AS INT = 23,	@PremiumGrains_25KgBagUOM AS INT = 24,
				@ColdGrains_25KgBagUOM AS INT = 25,		@HotGrains_25KgBagUOM AS INT = 26,		@ManualGrains_25KgBagUOM AS INT = 27,
				@SerializedGrains_25KgBagUOM AS INT = 28

		DECLARE @WetGrains_10LbBagUOM AS INT = 29,		@StickyGrains_10LbBagUOM AS INT = 30,	@PremiumGrains_10LbBagUOM AS INT = 31,
				@ColdGrains_10LbBagUOM AS INT = 32,		@HotGrains_10LbBagUOM AS INT = 33,		@ManualGrains_10LbBagUOM AS INT = 34,
				@SerializedGrains_10LbBagUOM AS INT = 35

		DECLARE @WetGrains_TonUOM AS INT = 36,			@StickyGrains_TonUOM AS INT = 37,		@PremiumGrains_TonUOM AS INT = 38,
				@ColdGrains_TonUOM AS INT = 39,			@HotGrains_TonUOM AS INT = 40,			@ManualGrains_TonUOM AS INT = 41,
				@SerializedGrains_TonUOM AS INT = 42

		DECLARE @Corn_BushelUOM AS INT = 43,			@Corn_PoundUOM AS INT = 44,				@Corn_KgUOM AS INT = 45, 
				@Corn_25KgBagUOM AS INT = 46,			@Corn_10LbBagUOM AS INT = 47,			@Corn_TonUOM AS INT = 48

		DECLARE @OtherCharges_PoundUOM AS INT = 49
		DECLARE @SurchargeOtherCharges_PoundUOM AS INT = 50
		DECLARE @SurchargeOnSurcharge_PoundUOM AS INT = 51
		DECLARE @SurchargeOnSurchargeOnSurcharge_PoundUOM AS INT = 52

		DECLARE @UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'
				,@UNIT_TYPE_Packed AS NVARCHAR(50) = 'Packed'

		-- Unit of measure master table
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure, strUnitType) VALUES (@UOM_Bushel, 'Bushel', @UNIT_TYPE_Weight)
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure, strUnitType) VALUES (@UOM_Pound, 'Pound', @UNIT_TYPE_Weight)
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure, strUnitType) VALUES (@UOM_Kg, 'Kilogram', @UNIT_TYPE_Weight)
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure, strUnitType) VALUES (@UOM_25KgBag, '25 Kg Bag', @UNIT_TYPE_Packed)
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure, strUnitType) VALUES (@UOM_10LbBag, '10 Lb Bag', @UNIT_TYPE_Packed)
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure, strUnitType) VALUES (@UOM_Ton, 'Ton', @UNIT_TYPE_Weight)
		
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains_BushelUOM, @WetGrains, @UOM_Bushel, @BushelUnitQty)			
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains_BushelUOM, @StickyGrains, @UOM_Bushel, @BushelUnitQty)		
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains_BushelUOM, @PremiumGrains, @UOM_Bushel, @BushelUnitQty)		
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains_BushelUOM, @ColdGrains, @UOM_Bushel, @BushelUnitQty)			
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains_BushelUOM, @HotGrains, @UOM_Bushel, @BushelUnitQty)			
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ManualGrains_BushelUOM, @ManualLotGrains, @UOM_Bushel, @BushelUnitQty)	
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SerializedGrains_BushelUOM, @SerializedLotGrains, @UOM_Bushel, @BushelUnitQty)

		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@WetGrains_PoundUOM, @WetGrains, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@StickyGrains_PoundUOM, @StickyGrains, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@PremiumGrains_PoundUOM, @PremiumGrains, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@ColdGrains_PoundUOM, @ColdGrains, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@HotGrains_PoundUOM, @HotGrains, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@ManualGrains_PoundUOM, @ManualLotGrains, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@SerializedGrains_PoundUOM, @SerializedLotGrains, @UOM_Pound, @PoundUnitQty, 1)
		
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains_KgUOM, @WetGrains, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains_KgUOM, @StickyGrains, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains_KgUOM, @PremiumGrains, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains_KgUOM, @ColdGrains, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains_KgUOM, @HotGrains, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ManualGrains_KgUOM, @ManualLotGrains, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SerializedGrains_KgUOM, @SerializedLotGrains, @UOM_Kg, @KgUnitQty)

		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains_25KgBagUOM, @WetGrains, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains_25KgBagUOM, @StickyGrains, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains_25KgBagUOM, @PremiumGrains, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains_25KgBagUOM, @ColdGrains, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains_25KgBagUOM, @HotGrains, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ManualGrains_25KgBagUOM, @ManualLotGrains, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SerializedGrains_25KgBagUOM, @SerializedLotGrains, @UOM_25KgBag, @25KgBagUnitQty)

		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains_10LbBagUOM, @WetGrains, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains_10LbBagUOM, @StickyGrains, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains_10LbBagUOM, @PremiumGrains, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains_10LbBagUOM, @ColdGrains, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains_10LbBagUOM, @HotGrains, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ManualGrains_10LbBagUOM, @ManualLotGrains, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SerializedGrains_10LbBagUOM, @SerializedLotGrains, @UOM_10LbBag, @10LbBagUnitQty)

		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains_TonUOM, @WetGrains, @UOM_Ton, @TonUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains_TonUOM, @StickyGrains, @UOM_Ton, @TonUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains_TonUOM, @PremiumGrains, @UOM_Ton, @TonUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains_TonUOM, @ColdGrains, @UOM_Ton, @TonUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains_TonUOM, @HotGrains, @UOM_Ton, @TonUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ManualGrains_TonUOM, @ManualLotGrains, @UOM_Ton, @TonUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SerializedGrains_TonUOM, @SerializedLotGrains, @UOM_Ton, @TonUnitQty)

		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@Corn_BushelUOM, @CornCommodity, @UOM_Bushel, @BushelUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit) VALUES (@Corn_PoundUOM, @CornCommodity, @UOM_Pound, @PoundUnitQty, 1)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@Corn_KgUOM, @CornCommodity, @UOM_Kg, @KgUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@Corn_25KgBagUOM, @CornCommodity, @UOM_25KgBag, @25KgBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@Corn_10LbBagUOM, @CornCommodity, @UOM_10LbBag, @10LbBagUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@Corn_TonUOM, @CornCommodity, @UOM_Ton, @TonUnitQty)

		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@OtherCharges_PoundUOM, @OtherCharges, @UOM_Pound, @PoundUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SurchargeOtherCharges_PoundUOM, @SurchargeOtherCharges, @UOM_Pound, @PoundUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SurchargeOnSurcharge_PoundUOM, @SurchargeOnSurcharge, @UOM_Pound, @PoundUnitQty)
		INSERT INTO dbo.tblICItemUOM (intItemUOMId, intItemId, intUnitMeasureId, dblUnitQty) VALUES (@SurchargeOnSurchargeOnSurcharge_PoundUOM, @SurchargeOnSurchargeOnSurcharge, @UOM_Pound, @PoundUnitQty)
	END 
END