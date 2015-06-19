CREATE PROCEDURE [testi21Database].[test uspICUnpostLIFOOutFromCustody for the basics]
AS
BEGIN 
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@CornCommodity AS INT = 8
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

	-- Declare the account ids
	DECLARE @Inventory_Default AS INT = 1000
	DECLARE @CostOfGoods_Default AS INT = 2000
	DECLARE @APClearing_Default AS INT = 3000
	DECLARE @WriteOffSold_Default AS INT = 4000
	DECLARE @RevalueSold_Default AS INT = 5000 
	DECLARE @AutoNegative_Default AS INT = 6000
	DECLARE @InventoryInTransit_Default AS INT = 7000
	DECLARE @AccountReceivable_Default AS INT = 8000
	DECLARE @InventoryAdjustment_Default AS INT = 9000

	DECLARE @Inventory_NewHaven AS INT = 1001
	DECLARE @CostOfGoods_NewHaven AS INT = 2001
	DECLARE @APClearing_NewHaven AS INT = 3001
	DECLARE @WriteOffSold_NewHaven AS INT = 4001
	DECLARE @RevalueSold_NewHaven AS INT = 5001
	DECLARE @AutoNegative_NewHaven AS INT = 6001
	DECLARE @InventoryInTransit_NewHaven AS INT = 7001
	DECLARE @AccountReceivable_NewHaven AS INT = 8001
	DECLARE @InventoryAdjustment_NewHaven AS INT = 9001

	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002
	DECLARE @InventoryInTransit_BetterHaven AS INT = 7002
	DECLARE @AccountReceivable_BetterHaven AS INT = 8002
	DECLARE @InventoryAdjustment_BetterHaven AS INT = 9002

	DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
	DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
	DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102

	-- Declare Account Categories
	DECLARE @AccountCategoryName_Inventory AS NVARCHAR(100) = 'Inventory'
	DECLARE @AccountCategoryId_Inventory AS INT -- = 27

	SELECT @AccountCategoryId_Inventory = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_Inventory

	DECLARE @AccountCategoryName_CostOfGoods AS NVARCHAR(100) = 'Cost of Goods'
	DECLARE @AccountCategoryId_CostOfGoods AS INT -- = 10

	SELECT @AccountCategoryId_CostOfGoods = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_CostOfGoods

	DECLARE @AccountCategoryName_APClearing AS NVARCHAR(100) = 'AP Clearing'
	DECLARE @AccountCategoryId_APClearing AS INT --= 45

	SELECT @AccountCategoryId_APClearing = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_APClearing
	
	DECLARE @AccountCategoryName_WriteOffSold AS NVARCHAR(100) = 'Write-Off Sold'
	DECLARE @AccountCategoryId_WriteOffSold AS INT -- = 42

	SELECT @AccountCategoryId_WriteOffSold = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_WriteOffSold

	DECLARE @AccountCategoryName_RevalueSold AS NVARCHAR(100) = 'Revalue Sold'
	DECLARE @AccountCategoryId_RevalueSold AS INT -- = 43

	SELECT @AccountCategoryId_RevalueSold = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_RevalueSold

	DECLARE @AccountCategoryName_AutoNegative AS NVARCHAR(100) = 'Auto Negative'
	DECLARE @AccountCategoryId_AutoNegative AS INT -- = 44

	SELECT @AccountCategoryId_AutoNegative = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_AutoNegative

	DECLARE @AccountCategoryName_InventoryInTransit AS NVARCHAR(100) = 'Inventory In Transit'
	DECLARE @AccountCategoryId_InventoryInTransit AS INT -- = 46

	SELECT @AccountCategoryId_InventoryInTransit = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_InventoryInTransit

	DECLARE @AccountCategoryName_InventoryAdjustment AS NVARCHAR(100) = 'Inventory Adjustment'
	DECLARE @AccountCategoryId_InventoryAdjustment AS INT -- = 50

	SELECT @AccountCategoryId_InventoryAdjustment = intAccountCategoryId
	FROM dbo.tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategoryName_InventoryAdjustment

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
END

BEGIN
	-- Arrange 
	BEGIN 
		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @InventoryReceipt AS INT = 4
		DECLARE @InventoryShipment AS INT = 5;

		CREATE TABLE actualLIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
			,ysnIsUnposted BIT 
		)

		CREATE TABLE expectedLIFO (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
			,ysnIsUnposted BIT 
		)

		CREATE TABLE actualTransactionToReverse (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryCostBucketInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		CREATE TABLE expectedTransactionToReverse (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryCostBucketInCustodyId INT 
			,dblQty NUMERIC(38,20) 
		)

		-- Create the temp table 
		CREATE TABLE #tmpInventoryTransactionStockToReverse (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,intInventoryCostBucketInCustodyId INT 
			,dblQty NUMERIC(38,20)
		)

		-- Call the fake data stored procedure
		EXEC testi21Database.[Fake inventory items]
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOInCustody', @Identity = 1;
	END 
	
	-- Act
	BEGIN 
		-- Call the uspICUnpostLIFOOutFromCustody
		DECLARE @strTransactionId AS NVARCHAR(20) 
		DECLARE @intTransactionId AS INT 
				
		EXEC dbo.uspICUnpostLIFOOutFromCustody @strTransactionId, @intTransactionId

		INSERT INTO actualTransactionToReverse 
		SELECT * FROM #tmpInventoryTransactionStockToReverse
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedLIFO', 'actualLIFO';
		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualLIFO') IS NOT NULL 
		DROP TABLE actualLIFO

	IF OBJECT_ID('expectedLIFO') IS NOT NULL 
		DROP TABLE dbo.expectedLIFO

	IF OBJECT_ID('actualTransactionToReverse') IS NOT NULL 
		DROP TABLE actualTransactionToReverse

	IF OBJECT_ID('expectedTransactionToReverse') IS NOT NULL 
		DROP TABLE dbo.expectedTransactionToReverse
END