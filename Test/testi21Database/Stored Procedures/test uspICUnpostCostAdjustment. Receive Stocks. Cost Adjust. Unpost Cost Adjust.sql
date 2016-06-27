CREATE PROCEDURE [testi21Database].[test uspICUnpostCostAdjustment. Receive Stocks. Cost Adjust. Unpost Cost Adjust]
AS
BEGIN
	-- Create the fake data
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
				,@CostAdjustment_Default AS INT = 13000
				,@WorkInProgress_Default AS INT = 14000

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
				,@CostAdjustment_NewHaven AS INT = 13001
				,@WorkInProgress_NewHaven AS INT = 14001

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
				,@CostAdjustment_BetterHaven AS INT = 13002
				,@WorkInProgress_BetterHaven AS INT = 14002

		-- Create the fake data
		EXEC [testi21Database].[Fake data for cost adjustment]
	END 

	-- Arrange 
	BEGIN 
		-- Create the CONSTANT variables for the costing methods
		DECLARE @AVERAGECOST AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4 	
				,@ACTUALCOST AS INT = 5	

		-- Declare the variables for the transaction types
		DECLARE @PurchaseType AS INT = 4
				,@SalesType AS INT = 5
				,@CostAdjustmentType AS INT = 26
				,@BillType AS INT = 23

		-- Declare the cost types
		DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
				,@COST_ADJ_TYPE_New_Cost AS INT = 2

		-- Declare the variables to check the average cost and last cost. 
		DECLARE @expected_AverageCost AS NUMERIC(38, 20) 
				,@actual_AverageCost AS NUMERIC(38, 20)
				,@expected_LastCost AS NUMERIC(38, 20)
				,@actual_LastCost AS NUMERIC(38, 20)

		CREATE TABLE expectedInventoryTransaction (
			[intInventoryTransactionId] INT NOT NULL
			,[intItemId] INT NOT NULL
			,[intItemLocationId] INT NOT NULL
			,[intItemUOMId] INT NULL
			,[intSubLocationId] INT NULL
			,[intStorageLocationId] INT NULL
			,[dtmDate] DATETIME NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
			,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dblValue] NUMERIC(18, 6) NULL
			,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[intCurrencyId] INT NULL
			,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL
			,[intTransactionId] INT NOT NULL
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionDetailId] INT NULL
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionTypeId] INT NOT NULL
			,[intLotId] INT NULL
			,[ysnIsUnposted] BIT NULL
			,[intRelatedInventoryTransactionId] INT NULL
			,[intRelatedTransactionId] INT NULL
			,[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
			,[intCostingMethod] INT NULL
		)

		CREATE TABLE actualInventoryTransaction (
			[intInventoryTransactionId] INT NOT NULL
			,[intItemId] INT NOT NULL
			,[intItemLocationId] INT NOT NULL
			,[intItemUOMId] INT NULL
			,[intSubLocationId] INT NULL
			,[intStorageLocationId] INT NULL
			,[dtmDate] DATETIME NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
			,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dblValue] NUMERIC(18, 6) NULL
			,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[intCurrencyId] INT NULL
			,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL
			,[intTransactionId] INT NOT NULL
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionDetailId] INT NULL
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,[intTransactionTypeId] INT NOT NULL
			,[intLotId] INT NULL
			,[ysnIsUnposted] BIT NULL
			,[intRelatedInventoryTransactionId] INT NULL
			,[intRelatedTransactionId] INT NULL
			,[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
			,[intCostingMethod] INT NULL
		)

		CREATE TABLE expectedInventoryFIFOCostAdjustmentLog (
			[intInventoryFIFOId] INT NOT NULL 
			,[intInventoryCostAdjustmentTypeId] INT NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dtmCreated] DATETIME NULL 
			,[intCreatedUserId] INT NULL 
			,[intConcurrencyId] INT NOT NULL DEFAULT 1 
		)

		CREATE TABLE actualInventoryFIFOCostAdjustmentLog (
			[intInventoryFIFOId] INT NOT NULL 
			,[intInventoryCostAdjustmentTypeId] INT NOT NULL 
			,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0
			,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
			,[dtmCreated] DATETIME NULL 
			,[intCreatedUserId] INT NULL 
			,[intConcurrencyId] INT NOT NULL DEFAULT 1 
		)

		CREATE TABLE expectedGLDetail (
			[dtmDate]			DATETIME
			,[strBatchId]		NVARCHAR(20) COLLATE Latin1_General_CI_AS 
			,[intAccountId]		INT
			,[dblDebit]			NUMERIC(18, 6)
			,[dblCredit]		NUMERIC (18, 6)
			,[dblDebitUnit]		NUMERIC (18, 6)
			,[dblCreditUnit]	NUMERIC (18, 6)
			,[strDescription]	NVARCHAR (255) COLLATE Latin1_General_CI_AS
			,[strCode]			NVARCHAR(40) COLLATE Latin1_General_CI_AS 
			,[strReference]		NVARCHAR(255) COLLATE Latin1_General_CI_AS 
			,[intCurrencyId]	INT
			,[dblExchangeRate]	NUMERIC(38, 20) 
			,[dtmDateEntered]	DATETIME
			,[dtmTransactionDate] DATETIME
			,[strJournalLineDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS
			,[intJournalLineNo]		INT
			,[ysnIsUnposted]		BIT
			,[intUserId]			INT
			,[intEntityId]			INT
			,[strTransactionId]		NVARCHAR(40) COLLATE Latin1_General_CI_AS
			,[intTransactionId]		INT
			,[strTransactionType]	NVARCHAR(255) COLLATE Latin1_General_CI_AS
			,[strTransactionForm]	NVARCHAR(255) COLLATE Latin1_General_CI_AS
			,[strModuleName]		NVARCHAR (255)   COLLATE Latin1_General_CI_AS
			,[intConcurrencyId]		INT
			,[dblDebitForeign]		NUMERIC (18, 9) NULL
			,[dblDebitReport]		NUMERIC (18, 9) NULL
			,[dblCreditForeign]		NUMERIC (18, 9) NULL
			,[dblCreditReport]		NUMERIC (18, 9) NULL
			,[dblReportingRate]		NUMERIC (18, 9) NULL
			,[dblForeignRate]		NUMERIC (18, 9) NULL
		)

		CREATE TABLE actualGLDetail (
			[dtmDate]			DATETIME
			,[strBatchId]		NVARCHAR(20) COLLATE Latin1_General_CI_AS 
			,[intAccountId]		INT
			,[dblDebit]			NUMERIC(18, 6)
			,[dblCredit]		NUMERIC (18, 6)
			,[dblDebitUnit]		NUMERIC (18, 6)
			,[dblCreditUnit]	NUMERIC (18, 6)
			,[strDescription]	NVARCHAR (255) COLLATE Latin1_General_CI_AS
			,[strCode]			NVARCHAR(40) COLLATE Latin1_General_CI_AS 
			,[strReference]		NVARCHAR(255) COLLATE Latin1_General_CI_AS 
			,[intCurrencyId]	INT
			,[dblExchangeRate]	NUMERIC(38, 20) 
			,[dtmDateEntered]	DATETIME
			,[dtmTransactionDate] DATETIME
			,[strJournalLineDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS
			,[intJournalLineNo]		INT
			,[ysnIsUnposted]		BIT
			,[intUserId]			INT
			,[intEntityId]			INT
			,[strTransactionId]		NVARCHAR(40) COLLATE Latin1_General_CI_AS
			,[intTransactionId]		INT
			,[strTransactionType]	NVARCHAR(255) COLLATE Latin1_General_CI_AS
			,[strTransactionForm]	NVARCHAR(255) COLLATE Latin1_General_CI_AS
			,[strModuleName]		NVARCHAR (255)   COLLATE Latin1_General_CI_AS
			,[intConcurrencyId]		INT
			,[dblDebitForeign]		NUMERIC (18, 9) NULL
			,[dblDebitReport]		NUMERIC (18, 9) NULL
			,[dblCreditForeign]		NUMERIC (18, 9) NULL
			,[dblCreditReport]		NUMERIC (18, 9) NULL
			,[dblReportingRate]		NUMERIC (18, 9) NULL
			,[dblForeignRate]		NUMERIC (18, 9) NULL
		)
	END 
	
	-- Act 1: Post the Cost adjustment. 
	BEGIN 
		DECLARE @ItemsToAdjust AS ItemCostAdjustmentTableType
		DECLARE @GLEntries AS RecapTableType 

		-- Declare the variables used in uspICPostCostAdjustmentOnAverageCosting
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-10293'
				,@intEntityUserSecurityId AS INT = 1 
				,@CurrencyId_USD AS INT = 1

		INSERT INTO @ItemsToAdjust (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblQty] 
				,[dblUOMQty] 
				,[intCostUOMId]
				,[dblVoucherCost] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intLotId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[ysnIsStorage] 
				,[strActualCostId] 
				,[intSourceTransactionId] 
				,[intSourceTransactionDetailId] 
				,[strSourceTransactionId] 		
		)
		SELECT	[intItemId]					= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 10, 2014'
				,[dblQty]					= 40
				,[dblUOMQty]				= @BushelUnitQty
				,[intCostUOMId]				= @WetGrains_BushelUOM
				,[dblVoucherCost]			= 37.261
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'BL-10001'
				,[intTransactionTypeId]		= @CostAdjustmentType
				,[intLotId]					= NULL 
				,[intSubLocationId]			= NULL 
				,[intStorageLocationId]		= NULL 
				,[ysnIsStorage]				= 0 
				,[strActualCostId]			= NULL 
				,[intSourceTransactionId]	= 1
				,[intSourceTransactionDetailId] = 1
				,[strSourceTransactionId]	= 'PURCHASE-100000'

		INSERT INTO @GLEntries (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
		)
		EXEC dbo.uspICPostCostAdjustment
				@ItemsToAdjust
				,@strBatchId
				,@intEntityUserSecurityId

		INSERT INTO actualGLDetail (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId		
		)
		SELECT
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId
		FROM @GLEntries

		EXEC dbo.uspGLBookEntries 
			@GLEntries, 
			1
	END 
	
	-- Act 2: Unpost the Cost adjustment. 
	BEGIN 
		-- Declare the variables used in uspICPostCostAdjustmentOnAverageCosting
		SELECT	@strBatchId = 'BATCH-10294'
				,@intEntityUserSecurityId = 1 
				,@CurrencyId_USD = 1

		UPDATE actualGLDetail
		SET ysnIsUnposted = 1

		INSERT INTO actualGLDetail (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
		)
		EXEC dbo.uspICUnpostCostAdjustment
			@intTransactionId = 1
			,@strTransactionId = 'BL-10001'
			,@strBatchId = 'BATCH-10294'
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@ysnRecap = 0 
	END 
		
	-- Get the actual data 
	BEGIN 
		INSERT INTO actualInventoryTransaction (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCostingMethod]
				,[ysnIsUnposted]
		)
		SELECT	[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCostingMethod]
				,[ysnIsUnposted]
		FROM	tblICInventoryTransaction
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @WetGrains_DefaultLocation

		INSERT INTO actualInventoryFIFOCostAdjustmentLog (
				[intInventoryFIFOId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty] 
				,[dblCost]
		)
		SELECT [intInventoryFIFOId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty] 
				,[dblCost]
		FROM	dbo.tblICInventoryFIFOCostAdjustmentLog

		-- Get the actual average cost. 
		SELECT	@actual_AverageCost = dblAverageCost
				,@actual_LastCost = dblLastCost
		FROM	tblICItemPricing
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @WetGrains_DefaultLocation
	END

	-- Setup the expected data. 
	BEGIN 
		INSERT INTO expectedInventoryTransaction (
				[intInventoryTransactionId]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intCostingMethod] 
				,[ysnIsUnposted]
		)
		SELECT	[intInventoryTransactionId] = 1
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 1, 2014'
				,[dblQty]					= 100
				,[dblCost]					= 22.00
				,[dblValue]					= 0 
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'PURCHASE-100000'
				,[strBatchId]				= 'BATCH-100000'
				,[intTransactionTypeId]		= @PurchaseType
				,[intLotId]					= NULL 
				,[intCostingMethod]			= @AVERAGECOST
				,[ysnIsUnposted]			= 0
		UNION ALL 
		SELECT	[intInventoryTransactionId] = 6
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 10, 2014'
				,[dblQty]					= 0
				,[dblCost]					= 0
				,[dblValue]					= 40 * (37.261 - 22.00)
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'BL-10001'
				,[strBatchId]				= 'BATCH-10293'
				,[intTransactionTypeId]		= @CostAdjustmentType
				,[intLotId]					= NULL 
				,[intCostingMethod]			= @AVERAGECOST
				,[ysnIsUnposted]			= 1
		UNION ALL 
		SELECT	[intInventoryTransactionId] = 7
				,[intItemId]				= @WetGrains
				,[intItemLocationId]		= @WetGrains_DefaultLocation
				,[intItemUOMId]				= @WetGrains_BushelUOM
				,[dtmDate]					= 'January 10, 2014'
				,[dblQty]					= 0
				,[dblCost]					= 0
				,[dblValue]					= -1 * 40 * (37.261 - 22.00)
				,[dblSalesPrice]			= 0 
				,[intCurrencyId]			= 1
				,[dblExchangeRate]			= 1
				,[intTransactionId]			= 1
				,[intTransactionDetailId]	= 1
				,[strTransactionId]			= 'BL-10001'
				,[strBatchId]				= 'BATCH-10294'
				,[intTransactionTypeId]		= @CostAdjustmentType
				,[intLotId]					= NULL 
				,[intCostingMethod]			= @AVERAGECOST
				,[ysnIsUnposted]			= 1

		INSERT INTO expectedInventoryFIFOCostAdjustmentLog (
				[intInventoryFIFOId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty] 
				,[dblCost]
		)
		SELECT 			
				[intInventoryFIFOId] = 1
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Original_Cost
				,[dblQty] = 100
				,[dblCost] = 22.00
		UNION ALL 
		SELECT 			
				[intInventoryFIFOId] = 1
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_New_Cost
				,[dblQty] = 40.00
				,[dblCost] = 37.261

		-- Setup the expected GL Detail 
		INSERT INTO expectedGLDetail (
				[dtmDate] 
				,[strBatchId] 
				,[intAccountId] 
				,[dblDebit] 
				,[dblCredit] 
				,[dblDebitUnit] 
				,[dblCreditUnit] 
				,[strDescription]
				,[strCode] 
				,[strReference] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[dtmDateEntered] 
				,[dtmTransactionDate] 
				,[strJournalLineDescription] 
				,[intJournalLineNo] 
				,[ysnIsUnposted] 
				,[intUserId] 
				,[intEntityId] 
				,[strTransactionId] 
				,[intTransactionId] 
				,[strTransactionType] 
				,[strTransactionForm] 
				,[strModuleName] 
				,[intConcurrencyId] 
		)
		-- Original posted G/L entries:
		SELECT	[dtmDate]						= 'January 10, 2014'
				,[strBatchId]					= 'BATCH-10293'
				,[intAccountId]					= @Inventory_Default
				,[dblDebit]						= 610.44
				,[dblCredit]					= 0 
				,[dblDebitUnit]					= 0 
				,[dblCreditUnit]				= 0 
				,[strDescription]				= 'INVENTORY WHEAT-DEFAULT'
				,[strCode]						= 'ICA'
				,[strReference]					= ''
				,[intCurrencyId]				= @CurrencyId_USD
				,[dblExchangeRate]				= 1
				,[dtmDateEntered]				= NULL 
				,[dtmTransactionDate]			= 'January 10, 2014'
				,[strJournalLineDescription]	= ''
				,[intJournalLineNo]				= 6
				,[ysnIsUnposted]				= 1 
				,[intUserId]					= NULL 
				,[intEntityId]					= @intEntityUserSecurityId
				,[strTransactionId]				= 'BL-10001'
				,[intTransactionId]				= 1
				,[strTransactionType]			= 'Cost Adjustment'
				,[strTransactionForm]			= 'Bill'
				,[strModuleName]				= 'Inventory'
				,[intConcurrencyId]				= 1
		UNION ALL 
		SELECT	[dtmDate]						= 'January 10, 2014'
				,[strBatchId]					= 'BATCH-10293'
				,[intAccountId]					= @AutoNegative_Default
				,[dblDebit]						= 0
				,[dblCredit]					= 610.44 
				,[dblDebitUnit]					= 0 
				,[dblCreditUnit]				= 0 
				,[strDescription]				= 'Auto Variance WHEAT-DEFAULT'
				,[strCode]						= 'ICA'
				,[strReference]					= ''
				,[intCurrencyId]				= @CurrencyId_USD
				,[dblExchangeRate]				= 1
				,[dtmDateEntered]				= NULL 
				,[dtmTransactionDate]			= 'January 10, 2014'
				,[strJournalLineDescription]	= ''
				,[intJournalLineNo]				= 6
				,[ysnIsUnposted]				= 1
				,[intUserId]					= NULL 
				,[intEntityId]					= @intEntityUserSecurityId
				,[strTransactionId]				= 'BL-10001'
				,[intTransactionId]				= 1
				,[strTransactionType]			= 'Cost Adjustment'
				,[strTransactionForm]			= 'Bill'
				,[strModuleName]				= 'Inventory'
				,[intConcurrencyId]				= 1

		-- Unpost G/L entries: 
		UNION ALL 
		SELECT	[dtmDate]						= 'January 10, 2014'
				,[strBatchId]					= @strBatchId
				,[intAccountId]					= @Inventory_Default
				,[dblDebit]						= 0
				,[dblCredit]					= 610.44 
				,[dblDebitUnit]					= 0 
				,[dblCreditUnit]				= 0 
				,[strDescription]				= 'INVENTORY WHEAT-DEFAULT'
				,[strCode]						= 'ICA'
				,[strReference]					= ''
				,[intCurrencyId]				= @CurrencyId_USD
				,[dblExchangeRate]				= 1
				,[dtmDateEntered]				= NULL 
				,[dtmTransactionDate]			= 'January 10, 2014'
				,[strJournalLineDescription]	= ''
				,[intJournalLineNo]				= 7
				,[ysnIsUnposted]				= 1 
				,[intUserId]					= NULL 
				,[intEntityId]					= @intEntityUserSecurityId
				,[strTransactionId]				= 'BL-10001'
				,[intTransactionId]				= 1
				,[strTransactionType]			= 'Cost Adjustment'
				,[strTransactionForm]			= 'Bill'
				,[strModuleName]				= 'Inventory'
				,[intConcurrencyId]				= 1
		UNION ALL 
		SELECT	[dtmDate]						= 'January 10, 2014'
				,[strBatchId]					= @strBatchId
				,[intAccountId]					= @AutoNegative_Default
				,[dblDebit]						= 610.44 
				,[dblCredit]					= 0
				,[dblDebitUnit]					= 0 
				,[dblCreditUnit]				= 0 
				,[strDescription]				= 'Auto Variance WHEAT-DEFAULT'
				,[strCode]						= 'ICA'
				,[strReference]					= ''
				,[intCurrencyId]				= @CurrencyId_USD
				,[dblExchangeRate]				= 1
				,[dtmDateEntered]				= NULL 
				,[dtmTransactionDate]			= 'January 10, 2014'
				,[strJournalLineDescription]	= ''
				,[intJournalLineNo]				= 7
				,[ysnIsUnposted]				= 1
				,[intUserId]					= NULL
				,[intEntityId]					= @intEntityUserSecurityId
				,[strTransactionId]				= 'BL-10001'
				,[intTransactionId]				= 1
				,[strTransactionType]			= 'Cost Adjustment'
				,[strTransactionForm]			= 'Bill'
				,[strModuleName]				= 'Inventory'
				,[intConcurrencyId]				= 1

		-- Compute the expected Average Cost and Last Cost. 
		SET @expected_AverageCost = 22.00
		SET @expected_LastCost = 22.00
	END 

	-- Assert
	BEGIN		
		-- Assert the expectedInventoryTransaction data for tblICInventoryTransaction is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction', 'Failed to get the expected Inventory transaction records.';
		
		-- Assert the expectedInventoryTransaction data for tblICInventoryFIFOCostAdjustmentLog is built correctly. 
		EXEC tSQLt.AssertEqualsTable 'expectedInventoryFIFOCostAdjustmentLog', 'actualInventoryFIFOCostAdjustmentLog', 'Failed to get the expected FIFO Cost Adjustment Log record.'
				
		-- Clean the data we don't need to test in GL Detail
		UPDATE expectedGLDetail 
		SET dtmDateEntered = NULL 

		UPDATE actualGLDetail 
		SET dtmDateEntered = NULL 
		
		-- Assert the G/L entries 
		EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail', 'Failed to get the expected GL Detail records.'

		-- Assert the average cost
		EXEC tSQLt.AssertEquals @expected_AverageCost, @actual_AverageCost, 'Failed to compute the expected average cost.'

		-- Assert the last cost. 
		EXEC tSQLt.AssertEquals @expected_LastCost, @actual_LastCost, 'Failed to retain the same last cost. It should not change.'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actualInventoryTransaction') IS NOT NULL 
		DROP TABLE actualInventoryTransaction

	IF OBJECT_ID('expectedInventoryTransaction') IS NOT NULL 
		DROP TABLE dbo.expectedInventoryTransaction
		
	IF OBJECT_ID('expectedInventoryFIFOCostAdjustmentLog') IS NOT NULL 
		DROP TABLE dbo.expectedInventoryFIFOCostAdjustmentLog

	IF OBJECT_ID('actualInventoryFIFOCostAdjustmentLog') IS NOT NULL 
		DROP TABLE dbo.actualInventoryFIFOCostAdjustmentLog

	IF OBJECT_ID('expectedGLDetail') IS NOT NULL 
		DROP TABLE dbo.expectedGLDetail

	IF OBJECT_ID('actualGLDetail') IS NOT NULL 
		DROP TABLE dbo.actualGLDetail
END