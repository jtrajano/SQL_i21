CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceiptOtherCharges for test case 4]
AS

-- Variables from [testi21Database].[Fake inventory items]
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

	-- Other charges constant variables. 
	DECLARE @COST_METHOD_PER_Unit AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_Amount AS NVARCHAR(50) = 'Amount'

			,@INVENTORY_COST_Yes AS BIT = 1
			,@INVENTORY_COST_No AS BIT = 0

			,@COST_BILLED_BY_Vendor AS NVARCHAR(50) = 'Vendor'
			,@COST_BILLED_BY_ThirdParty AS NVARCHAR(50) = 'Third Party'
			,@COST_BILLED_BY_None AS NVARCHAR(50) = 'None'

			,@ALLOCATE_COST_BY_Unit AS NVARCHAR(50) = 'Unit'
			,@ALLOCATE_COST_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
			,@ALLOCATE_COST_BY_Weight AS NVARCHAR(50) = 'Weight'
			,@ALLOCATE_COST_BY_Cost AS NVARCHAR(50) = 'Cost'

	DECLARE -- Receipt Types
			@RECEIPT_TYPE_PurchaseContract AS NVARCHAR(50) = 'Purchase Contract'
			,@RECEIPT_TYPE_PurchaseOrder AS NVARCHAR(50) = 'Purchase Order'
			,@RECEIPT_TYPE_TransferOrder AS NVARCHAR(50) = 'Transfer Order'
			,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'

			-- Source Types
			,@SOURCE_TYPE_None AS INT = 1
			,@SOURCE_TYPE_Scale AS INT = 2
			,@SOURCE_TYPE_InboundShipment AS INT = 3

			-- Ownership Types
			,@OWNERSHIP_TYPE_Own AS INT = 1
			,@OWNERSHIP_TYPE_Storage AS INT = 2
			,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
			,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

	DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
			,@STARTING_NUMBER_BATCH AS INT = 3  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'

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
END 

-- Create expected and actual tables
BEGIN 
	CREATE TABLE expected (
		[dtmDate]                   DATETIME         NOT NULL,
		[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
		[intAccountId]              INT              NULL,
		[dblDebit]                  NUMERIC (18, 6)  NULL,
		[dblCredit]                 NUMERIC (18, 6)  NULL,
		[dblDebitUnit]              NUMERIC (18, 6)  NULL,
		[dblCreditUnit]             NUMERIC (18, 6)  NULL,
		[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
		[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[intCurrencyId]             INT              NULL,
		[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
		[dtmDateEntered]            DATETIME         NOT NULL,
		[dtmTransactionDate]        DATETIME         NULL,
		[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
		[intJournalLineNo]			INT              NULL,
		[ysnIsUnposted]             BIT              NOT NULL,    
		[intUserId]                 INT              NULL,
		[intEntityId]				INT              NULL,
		[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
		[intTransactionId]          INT              NULL,
		[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
	)

	CREATE TABLE actual (
		[dtmDate]                   DATETIME         NOT NULL,
		[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
		[intAccountId]              INT              NULL,
		[dblDebit]                  NUMERIC (18, 6)  NULL,
		[dblCredit]                 NUMERIC (18, 6)  NULL,
		[dblDebitUnit]              NUMERIC (18, 6)  NULL,
		[dblCreditUnit]             NUMERIC (18, 6)  NULL,
		[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
		[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[intCurrencyId]             INT              NULL,
		[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
		[dtmDateEntered]            DATETIME         NOT NULL,
		[dtmTransactionDate]        DATETIME         NULL,
		[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
		[intJournalLineNo]			INT              NULL,
		[ysnIsUnposted]             BIT              NOT NULL,    
		[intUserId]                 INT              NULL,
		[intEntityId]				INT              NULL,
		[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
		[intTransactionId]          INT              NULL,
		[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
	)
END 

BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for inventory receipt table];
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END 

	-- Act
	BEGIN 
		DECLARE @intInventoryReceiptId AS INT = 14 -- 'INVRCPT-XXXX14'
			,@strBatchId AS NVARCHAR(20) = 'BATCH-100001'
			,@intUserId AS INT = 1
			,@intTransactionTypeId AS INT = @INVENTORY_RECEIPT_TYPE
			,@GLEntries AS RecapTableType 

		INSERT INTO @GLEntries (
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
		EXEC dbo.uspICPostInventoryReceiptOtherCharges 
			@intInventoryReceiptId
			,@strBatchId
			,@intUserId
			,@intTransactionTypeId
	END 

	-- Setup the expected data
	BEGIN 
		INSERT INTO expected (
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
		SELECT 
			[dtmDate]					= '2014-01-22'
			,[strBatchId]				= @strBatchId
			,[intAccountId]				= @Inventory_Default
			,[dblDebit]					= 856.732500
			,[dblCredit]				= 0
			,[dblDebitUnit]				= 0
			,[dblCreditUnit]			= 0
			,[strDescription]			= 'INVENTORY WHEAT-DEFAULT'
			,[strCode]					= 'IC'
			,[strReference]				= ''
			,[intCurrencyId]			= 1
			,[dblExchangeRate]			= 1
			,[dtmDateEntered]			= dbo.fnRemoveTimeOnDate(GETDATE())
			,[dtmTransactionDate]		= '2014-01-22'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]			= 33
			,[ysnIsUnposted]			= 0
			,[intUserId]				= 1
			,[intEntityId]				= 1 
			,[strTransactionId]			= 'INVRCPT-XXXX14'
			,[intTransactionId]			= @intInventoryReceiptId
			,[strTransactionType]		= 'Inventory Receipt'
			,[strTransactionForm]		= 'Inventory Receipt'
			,[strModuleName]			= 'Inventory'
			,[intConcurrencyId]			= 1
		UNION ALL
		SELECT 
			[dtmDate]					= '2014-01-22'
			,[strBatchId]				= @strBatchId
			,[intAccountId]				= @APClearing_Default
			,[dblDebit]					= 0
			,[dblCredit]				= 856.732500
			,[dblDebitUnit]				= 0
			,[dblCreditUnit]			= 0
			,[strDescription]			= 'AP CLEARING WHEAT-DEFAULT'
			,[strCode]					= 'IC'
			,[strReference]				= ''
			,[intCurrencyId]			= 1
			,[dblExchangeRate]			= 1
			,[dtmDateEntered]			= dbo.fnRemoveTimeOnDate(GETDATE())
			,[dtmTransactionDate]		= '2014-01-22'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]			= 33
			,[ysnIsUnposted]			= 0
			,[intUserId]				= 1
			,[intEntityId]				= 1 
			,[strTransactionId]			= 'INVRCPT-XXXX14'
			,[intTransactionId]			= @intInventoryReceiptId
			,[strTransactionType]		= 'Inventory Receipt'
			,[strTransactionForm]		= 'Inventory Receipt'
			,[strModuleName]			= 'Inventory'
			,[intConcurrencyId]			= 1
		UNION ALL 
		SELECT 
			[dtmDate]					= '2014-01-22'
			,[strBatchId]				= @strBatchId
			,[intAccountId]				= @Inventory_Default
			,[dblDebit]					= 1999.042500
			,[dblCredit]				= 0
			,[dblDebitUnit]				= 0
			,[dblCreditUnit]			= 0
			,[strDescription]			= 'INVENTORY WHEAT-DEFAULT'
			,[strCode]					= 'IC'
			,[strReference]				= ''
			,[intCurrencyId]			= 1
			,[dblExchangeRate]			= 1
			,[dtmDateEntered]			= dbo.fnRemoveTimeOnDate(GETDATE())
			,[dtmTransactionDate]		= '2014-01-22'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]			= 34
			,[ysnIsUnposted]			= 0
			,[intUserId]				= 1
			,[intEntityId]				= 1 
			,[strTransactionId]			= 'INVRCPT-XXXX14'
			,[intTransactionId]			= @intInventoryReceiptId
			,[strTransactionType]		= 'Inventory Receipt'
			,[strTransactionForm]		= 'Inventory Receipt'
			,[strModuleName]			= 'Inventory'
			,[intConcurrencyId]			= 1
		UNION ALL
		SELECT 
			[dtmDate]					= '2014-01-22'
			,[strBatchId]				= @strBatchId
			,[intAccountId]				= @APClearing_Default
			,[dblDebit]					= 0
			,[dblCredit]				= 1999.042500
			,[dblDebitUnit]				= 0
			,[dblCreditUnit]			= 0
			,[strDescription]			= 'AP CLEARING WHEAT-DEFAULT'
			,[strCode]					= 'IC'
			,[strReference]				= ''
			,[intCurrencyId]			= 1
			,[dblExchangeRate]			= 1
			,[dtmDateEntered]			= dbo.fnRemoveTimeOnDate(GETDATE())
			,[dtmTransactionDate]		= '2014-01-22'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]			= 34
			,[ysnIsUnposted]			= 0
			,[intUserId]				= 1
			,[intEntityId]				= 1 
			,[strTransactionId]			= 'INVRCPT-XXXX14'
			,[intTransactionId]			= @intInventoryReceiptId
			,[strTransactionType]		= 'Inventory Receipt'
			,[strTransactionForm]		= 'Inventory Receipt'
			,[strModuleName]			= 'Inventory'
			,[intConcurrencyId]			= 1
	END 

	-- Get the actual data
	BEGIN 
		INSERT INTO actual (
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
		SELECT 
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
			,dbo.fnRemoveTimeOnDate([dtmDateEntered]) 
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
		FROM @GLEntries
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