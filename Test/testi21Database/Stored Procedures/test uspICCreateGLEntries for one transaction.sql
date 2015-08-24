CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntries for one transaction]
AS
BEGIN
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

	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@InvalidItem AS INT = -1

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

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1

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

	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items]
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @PurchaseType AS INT = 1

		SELECT	@PurchaseType = intTransactionTypeId
		FROM	tblICInventoryTransactionType
		WHERE	strName = 'Inventory Receipt'

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

		DECLARE @intItemId AS INT = @StickyGrains
				,@intItemLocationId AS INT = @NewHaven 
				,@intTransactionId AS INT = 1
				,@strTransactionId AS NVARCHAR(40) = 'PURCHASE-00001'
				,@strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
				,@intUserId AS INT = 1

		INSERT INTO tblICInventoryTransaction (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,dtmCreated
				,intCreatedUserId
				,intConcurrencyId
				,strTransactionForm
		)
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_NewHaven
				,intItemUOMId = @StickyGrains_PoundUOM
				,dtmDate = 'January 12, 2014'
				,dblQty = 1
				,dblUOMQty = @PoundUnitQty
				,dblCost = 12.00
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = @strTransactionId
				,strBatchId = @strBatchId
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL 
				,dtmCreated = GETDATE()
				,intCreatedUserId = 1
				,intConcurrencyId = 1
				,strTransactionForm = 'Inventory Receipt'

		CREATE TABLE expected (
			dtmDate DATETIME
			,strBatchId NVARCHAR(50)
			,intAccountId INT
			,dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
			,dblDebitUnit NUMERIC(18,6)
			,dblCreditUnit NUMERIC(18,6)
			,strDescription NVARCHAR(255)
			,strCode NVARCHAR(5)
			,strReference NVARCHAR(50)
			,intCurrencyId INT
			,dblExchangeRate NUMERIC(18,6)
			,dtmTransactionDate DATETIME 
			,strJournalLineDescription NVARCHAR(50)
			,intJournalLineNo INT
			,ysnIsUnposted BIT
			,intUserId INT 
			,intEntityId INT 
			,strTransactionId NVARCHAR(50)
			,intTransactionId INT 
			,strTransactionType NVARCHAR(50)
			,strTransactionForm NVARCHAR(50)
			,strModuleName NVARCHAR(50)
			,intConcurrencyId INT 
		)

		CREATE TABLE actual (
			dtmDate DATETIME
			,strBatchId NVARCHAR(50)
			,intAccountId INT
			,dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
			,dblDebitUnit NUMERIC(18,6)
			,dblCreditUnit NUMERIC(18,6)
			,strDescription NVARCHAR(255)
			,strCode NVARCHAR(5)
			,strReference NVARCHAR(50)
			,intCurrencyId INT
			,dblExchangeRate NUMERIC(18,6)
			,dtmDateEntered DATETIME 
			,dtmTransactionDate DATETIME 
			,strJournalLineDescription NVARCHAR(50)
			,intJournalLineNo INT
			,ysnIsUnposted BIT
			,intUserId INT 
			,intEntityId INT 
			,strTransactionId NVARCHAR(50)
			,intTransactionId INT 
			,strTransactionType NVARCHAR(50)
			,strTransactionForm NVARCHAR(50)
			,strModuleName NVARCHAR(50)
			,intConcurrencyId INT 
		)


		INSERT INTO expected (
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
			dtmDate						= 'January 12, 2014'
			,strBatchId					= @strBatchId
			,intAccountId				= @Inventory_NewHaven
			,dblDebit					= 12.00
			,dblCredit					= 0.00
			,dblDebitUnit				= 0.00
			,dblCreditUnit				= 0.00
			,strDescription				= 'INVENTORY WHEAT-NEW HAVEN'
			,strCode					= 'IC'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			,dtmTransactionDate			= 'January 12, 2014'
			,strJournalLineDescription	= ''
			,intJournalLineNo			= 1
			,ysnIsUnposted				= 0
			,intUserId					= 1
			,intEntityId				= 1
			,strTransactionId			= @strTransactionId
			,intTransactionId			= 1
			,strTransactionType			= 'Inventory Receipt'
			,strTransactionForm			= 'Inventory Receipt'
			,strModuleName				= 'Inventory'
			,intConcurrencyId			= 1
		UNION ALL
		SELECT 
			dtmDate						= 'January 12, 2014'
			,strBatchId					= @strBatchId
			,intAccountId				= @CostOfGoods_NewHaven
			,dblDebit					= 0.00
			,dblCredit					= 12.00
			,dblDebitUnit				= 0.00
			,dblCreditUnit				= 0.00
			,strDescription				= 'COST OF GOODS WHEAT-NEW HAVEN'
			,strCode					= 'IC'
			,strReference				= ''
			,intCurrencyId				= @USD
			,dblExchangeRate			= 1
			-- ,dtmDateEntered				= NULL 
			,dtmTransactionDate			= 'January 12, 2014'
			,strJournalLineDescription	= ''
			,intJournalLineNo			= 1
			,ysnIsUnposted				= 0
			,intUserId					= 1
			,intEntityId				= 1
			,strTransactionId			= @strTransactionId
			,intTransactionId			= 1
			,strTransactionType			= 'Inventory Receipt'
			,strTransactionForm			= 'Inventory Receipt'
			,strModuleName				= 'Inventory'
			,intConcurrencyId			= 1

	END 

	-- Act
	BEGIN 
		INSERT INTO actual 
		EXEC dbo.uspICCreateGLEntries
			@strBatchId
			,@UseGLAccount_ContraInventory
			,@intUserId
			,NULL
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