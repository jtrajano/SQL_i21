---------------------------------------------------------------------------------------------------
/*
	Scenario 3: Add stock, Sell Stock 

	tblICInventoryFIFO
	-----------------------------------------------------------------
	Fifo Id	Date		In		Out		Cost	Inbound Transaction
	-------	---------	------	-----	------	---------------------
	1		1/1/2014	100		75		$2.15	InvRcpt-00001

	tblICInventoryFIFOOut
	-----------------------------------------------------------------
	Id		Fifo Id		Inventory Transaction Id	Revalue Id	Qty
	-----	---------	-------------------------	----------	-----
	1		1			InvShip-00001				NULL		75

	tblICInventoryTransaction
	-------------------------------------------------------------------------------------------------------------------
	Id	Date		Qty		Cost	Value Adj	Transaction Id	Related Transaction Id	Type				Is Unposted
	---	---------	------	------	----------	--------------	----------------------	-------------------	-----------
	1	1/1/2014	100		$2.150	NULL		InvRcpt-00001	NULL					Inventory Receipt	
	2	1/16/2014	-75		$2.150	NULL		InvShip-00001	NULL					Inventory Shipment	
	
	G/L Entries
	----------------------------------------------------------------------------------------
	Date		Account					Debit		Credit		Journal Id		Is Unposted
	----------	---------------------	-----------	----------	-------------	------------
	1/1/2014	Inventory				215.000					1					
				A/P Clearing						215.000		1
	1/16/2014	Inventory In-Transit	161.250					2
				Inventory							161.250		2
*/
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [testi21Database].[Fake posted transactions using FIFO, scenario 3]
AS

BEGIN
	EXEC testi21Database.[Fake inventory items]
	EXEC testi21Database.[Fake open fiscal year and accounting periods]

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

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5
				
	-- Declare the variables for the currencies
	DECLARE @USD AS INT = 1;	
	DECLARE @USD_ExchangeRate AS NUMERIC(18,6) = 1;

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

	-- Batch Id
	DECLARE @strBatchId AS NVARCHAR(40) = 'BATCH-0000001'

	-- Define the additional tables to fake
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;
	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

	CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryFIFO]
		ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOId] ASC);

	---------------------------------------------------------------------------------------------------------------
	-- Add stock (100 qty with $2.15) 
	---------------------------------------------------------------------------------------------------------------
	BEGIN 
		----------------------------------------------------------------
		-- Fake data for inventory receipt transaction 
		----------------------------------------------------------------
		INSERT INTO tblICInventoryReceipt (
				dtmReceiptDate
				,intEntityId
				,intCreatedUserId
				,strReceiptNumber
				,intLocationId	
				,ysnPosted
				,intCurrencyId
		)
		SELECT	dtmReceiptDate = '01/01/2014'
				,intEntityId = 1
				,intCreatedUserId = 1
				,strReceiptNumber = 'InvRcpt-0001'
				,intLocationId = @Default_Location
				,ysnPosted = 1
				,intCurrencyId = @USD

		INSERT INTO dbo.tblICInventoryReceiptItem (
				intItemId
				,dblOrderQty
				,dblReceived
				,dblUnitCost
				,intUnitMeasureId
				,intInventoryReceiptId
		)
		SELECT 	intItemId = @WetGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @WetGrains_BushelUOMId
				,intInventoryReceiptId = 1
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @StickyGrains_BushelUOMId
				,intInventoryReceiptId = 1
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @PremiumGrains_BushelUOMId
				,intInventoryReceiptId = 1
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @ColdGrains_BushelUOMId
				,intInventoryReceiptId = 1		
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @HotGrains_BushelUOMId
				,intInventoryReceiptId = 1				

		----------------------------------------------------------------
		-- Fake data for tblICItemStock
		----------------------------------------------------------------
		INSERT INTO dbo.tblICItemStock(
				intItemId
				,intItemLocationId
				,dblUnitOnHand	
		)
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = 1
				,dblUnitOnHand	= 100
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = 2
				,dblUnitOnHand	= 100	
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,intItemLocationId = 3
				,dblUnitOnHand	= 100		
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,intItemLocationId = 4
				,dblUnitOnHand	= 100	
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,intItemLocationId = 5
				,dblUnitOnHand	= 100

		----------------------------------------------------------------
		-- Fake data for tblICItemPricing
		----------------------------------------------------------------
		INSERT INTO dbo.tblICItemPricing(
				intItemId
				,intItemLocationId
				,dblAverageCost
		)
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = 1
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = 2
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,intItemLocationId = 3
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,intItemLocationId = 4
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,intItemLocationId = 5
				,dblAverageCost = 2.15

		----------------------------------------------------------------
		-- Fake data for tblICInventoryFIFO
		----------------------------------------------------------------
		BEGIN 
			INSERT INTO dbo.tblICInventoryFIFO (
					dtmDate
					,intItemId
					,intItemLocationId
					,intItemUOMId
					,dblStockIn
					,dblStockOut
					,dblCost
					,intTransactionId
					,strTransactionId
			)
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @WetGrains 
					,intItemLocationId = 1
					,intItemUOMId = @WetGrains_BushelUOMId
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @StickyGrains 
					,intItemLocationId = 2
					,intItemUOMId = @StickyGrains_BushelUOMId
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @PremiumGrains 
					,intItemLocationId = 3
					,intItemUOMId = @PremiumGrains_BushelUOMId
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @ColdGrains 
					,intItemLocationId = 4
					,intItemUOMId = @ColdGrains_BushelUOMId
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @HotGrains 
					,intItemLocationId = 5
					,intItemUOMId = @HotGrains_BushelUOMId
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
		END 

		----------------------------------------------------------------
		-- Fake data for tblICInventoryFIFOOut
		----------------------------------------------------------------
		-- No data required	

		----------------------------------------------------------------
		-- Fake data for tblICInventoryTransaction
		----------------------------------------------------------------
		BEGIN 
			INSERT INTO dbo.tblICInventoryTransaction (
				dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,intTransactionId
				,strTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,intTransactionTypeId
				,ysnIsUnposted
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,strBatchId
				,dblExchangeRate
				,intCurrencyId
			)
			SELECT	dtmDate = '01/01/2014'
					,dblQty = 100
					,dblUOMQty = 1
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @WetGrains
					,intItemLocationId = 1
					,intItemUOMId = @WetGrains_BushelUOMId
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,dblQty = 100
					,dblUOMQty = 1
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @StickyGrains
					,intItemLocationId = 2
					,intItemUOMId = @WetGrains_BushelUOMId
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,dblQty = 100
					,dblUOMQty = 1
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @PremiumGrains
					,intItemLocationId = 3
					,intItemUOMId = @PremiumGrains_BushelUOMId
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,dblQty = 100
					,dblUOMQty = 1
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @ColdGrains
					,intItemLocationId = 4
					,intItemUOMId = @ColdGrains_BushelUOMId
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,dblQty = 100
					,dblUOMQty = 1
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @HotGrains
					,intItemLocationId = 5
					,intItemUOMId = @HotGrains_BushelUOMId
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
		END 

		----------------------------------------------------------------
		-- Fake data for tblGLDetail & GL Summary 
		----------------------------------------------------------------
		BEGIN 

			INSERT INTO dbo.tblGLDetail(
					dtmDate
					,intAccountId
					,dblDebit
					,dblCredit
					,intTransactionId
					,strTransactionId
					,ysnIsUnposted
					,intJournalLineNo
					,strBatchId
					,dblExchangeRate
					,intCurrencyId
			)
			-- @WetGrains
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 1 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @APClearing_NewHaven
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 1 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- @StickyGrains
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 2 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @APClearing_NewHaven
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 2 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- @PremiumGrains
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 3 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @APClearing_NewHaven
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 3 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- @ColdGrains
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 4 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @APClearing_NewHaven
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 4 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- @HotGrains
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 5 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intAccountId = @APClearing_NewHaven
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 5 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD

			INSERT INTO dbo.tblGLSummary(
					dtmDate
					,dblDebit
					,dblCredit
					,intAccountId
			)
			SELECT	dtmDate = '01/01/2014'
					,dblDebit = (215.00 * 5)
					,dblCredit = 0
					,intAccountId = @Inventory_NewHaven
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,dblDebit = 0
					,dblCredit = (215.00 * 5)
					,intAccountId = @APClearing_NewHaven

		END
	END 

	---------------------------------------------------------------------------------------------------------------
	-- Sell Stock (75 qty) 
	---------------------------------------------------------------------------------------------------------------
	BEGIN 
		----------------------------------------------------------------
		-- Fake data for inventory shipment
		----------------------------------------------------------------
		INSERT INTO dbo.tblICInventoryShipment (
				dtmShipDate
				,strBOLNumber
				,intShipFromLocationId 
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT	dtmShipDate = '01/16/2014'
				,strBOLNumber = 'InvShip-00001'
				,intShipFromLocationId = @Default_Location			
				,intEntityId = 1
				,intCreatedUserId = 1
				,ysnPosted = 1

		INSERT INTO dbo.tblICInventoryShipmentItem (
				intInventoryShipmentId 
				,intItemId 
				,dblQuantity
				,dblUnitPrice
				,intUnitMeasureId
		)
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @WetGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
				,intUnitMeasureId = @WetGrains_BushelUOMId
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @StickyGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
				,intUnitMeasureId = @StickyGrains_BushelUOMId
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @PremiumGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
				,intUnitMeasureId = @PremiumGrains_BushelUOMId
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @ColdGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
				,intUnitMeasureId = @ColdGrains_BushelUOMId
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @HotGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
				,intUnitMeasureId = @HotGrains_BushelUOMId

		-- Reduce stock qty from the Item Stock table 
		UPDATE	ItemStock
		SET		dblUnitOnHand -= 75
		FROM	dbo.tblICItemStock ItemStock INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemStock.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @Default_Location

		-- Add out qty in the fifo table
		UPDATE	FIFO
		SET		dblStockOut += 75
		FROM	dbo.tblICInventoryFIFO FIFO INNER JOIN dbo.tblICItemLocation ItemLocation
					ON FIFO.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @Default_Location

		-- Add the fifo out records
		INSERT INTO dbo.tblICInventoryFIFOOut (
				intInventoryFIFOId
				,intInventoryTransactionId
				,dblQty
		)
		SELECT	intInventoryFIFOId = 1
				,intInventoryTransactionId = 6
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryFIFOId = 2
				,intInventoryTransactionId = 7
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryFIFOId = 3
				,intInventoryTransactionId = 8
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryFIFOId = 4
				,intInventoryTransactionId = 9
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryFIFOId = 5
				,intInventoryTransactionId = 10
				,dblQty = 75

		----------------------------------------------------------------
		-- Fake data for tblICInventoryTransaction
		----------------------------------------------------------------
		SET	@strBatchId = 'BATCH-0000002'
		INSERT INTO dbo.tblICInventoryTransaction (
				dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intTransactionId
				,strTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,intTransactionTypeId
				,ysnIsUnposted
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,strBatchId
		)
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
				,dblUOMQty = 1
				,dblCost = 2.15
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 1
				,intItemUOMId = @WetGrains_BushelUOMId
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
				,dblUOMQty = 1
				,dblCost = 2.15
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @StickyGrains
				,intItemLocationId = 2
				,intItemUOMId = @StickyGrains_BushelUOMId
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
				,dblUOMQty = 1
				,dblCost = 2.15
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @PremiumGrains
				,intItemLocationId = 3
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
				,dblUOMQty = 1
				,dblCost = 2.15
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @ColdGrains
				,intItemLocationId = 4
				,intItemUOMId = @ColdGrains_BushelUOMId
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
				,dblUOMQty = 1
				,dblCost = 2.15
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @HotGrains
				,intItemLocationId = 5
				,intItemUOMId = @HotGrains_BushelUOMId
				,strBatchId = @strBatchId

		----------------------------------------------------------------
		-- Fake data for tblGLDetail & GL Summary 
		----------------------------------------------------------------
		BEGIN
			INSERT INTO dbo.tblGLDetail(
					dtmDate
					,intAccountId
					,dblDebit
					,dblCredit
					,intTransactionId
					,strTransactionId
					,ysnIsUnposted
					,intJournalLineNo
					,dblExchangeRate
					,strBatchId
			)
			-- @WetGrains
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 0
					,dblCredit = 161.250
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 6
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @InventoryInTransit_NewHaven
					,dblDebit = 161.250
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 6
					,dblExchangeRate = 1
					,@strBatchId
			-- @StickyGrains
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 0
					,dblCredit = 161.250
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 7 
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @InventoryInTransit_NewHaven
					,dblDebit = 161.250
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 7
					,dblExchangeRate = 1
					,@strBatchId
			-- @PremiumGrains
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 0
					,dblCredit = 161.250
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 8
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @InventoryInTransit_NewHaven
					,dblDebit = 161.250
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 8 
					,dblExchangeRate = 1
					,@strBatchId
			-- @ColdGrains
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 0
					,dblCredit = 161.250
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 9
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @InventoryInTransit_NewHaven
					,dblDebit = 161.250
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 9
					,dblExchangeRate = 1
					,@strBatchId
			-- @HotGrains
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @Inventory_NewHaven
					,dblDebit = 0
					,dblCredit = 161.250
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 10 
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,intAccountId = @InventoryInTransit_NewHaven
					,dblDebit = 161.250
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = 'InvShip-0001'
					,ysnIsUnposted = 0 
					,intJournalLineNo = 10
					,dblExchangeRate = 1
					,@strBatchId

			INSERT INTO dbo.tblGLSummary(
					dtmDate
					,dblDebit
					,dblCredit
					,intAccountId
			)
			SELECT	dtmDate = '01/16/2014'
					,dblDebit = 0
					,dblCredit = (161.25 * 5)
					,intAccountId = @Inventory_NewHaven
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,dblDebit = (161.25 * 5)
					,dblCredit = 0
					,intAccountId = @InventoryInTransit_NewHaven
		END 
	END 
END