---------------------------------------------------------------------------------------------------
/*
	Scenario 3: Add stock, Sell Stock 

	tblICInventoryLIFO
	-----------------------------------------------------------------
	LIFO Id	Date		In		Out		Cost	Inbound Transaction
	-------	---------	------	-----	------	---------------------
	1		1/1/2014	100		75		$2.15	InvRcpt-00001

	tblICInventoryLIFOOut
	-----------------------------------------------------------------
	Id		LIFO Id		Inventory Transaction Id	Revalue Id	Qty
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
CREATE PROCEDURE [testi21Database].[Fake posted transactions using LIFO, scenario 3]
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
	DECLARE	@BetterHaven AS INT = 3
			,@WetGrains_BetterHaven AS INT = 11
			,@StickyGrains_BetterHaven AS INT = 12
			,@PremiumGrains_BetterHaven AS INT = 13
			,@ColdGrains_BetterHaven AS INT = 14
			,@HotGrains_BetterHaven AS INT = 15
			
	-- Declare the variables for the currencies
	DECLARE @USD AS INT = 1;	
	DECLARE @USD_ExchangeRate AS NUMERIC(18,6) = 1;

	-- Declare the variable for unit of measure
	DECLARE @Each AS INT = 1

	-- Declare the account ids
	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002
	DECLARE @InventoryInTransit_BetterHaven AS INT = 7002

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5

	-- Batch Id
	DECLARE @strBatchId AS NVARCHAR(40) = 'BATCH-0000001'

	-- Define the additional tables to fake
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;
	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

	CREATE CLUSTERED INDEX [Fake_IDX_tblICInventoryLIFO]
		ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOId] DESC);		
	
	-- Negative stock options
	DECLARE @AllowNegativeStock AS INT = 1
	DECLARE @AllowNegativeStockWithWriteOff AS INT = 2
	DECLARE @DoNotAllowNegativeStock AS INT = 3

	-- Setup the allow negative stock for LIFO	
	UPDATE dbo.tblICItemLocation
	SET intAllowNegativeInventory = @AllowNegativeStockWithWriteOff

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
				,intLocationId = @BetterHaven
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
				,intUnitMeasureId = @Each
				,intInventoryReceiptId = 1
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @Each
				,intInventoryReceiptId = 1
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @Each
				,intInventoryReceiptId = 1
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @Each
				,intInventoryReceiptId = 1		
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,dblOrderQty = 100
				,dblReceived = 100
				,dblUnitCost = 2.15
				,intUnitMeasureId = @Each
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
				,intItemLocationId = @WetGrains_BetterHaven
				,dblUnitOnHand	= 100
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,dblUnitOnHand	= 100	
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,intItemLocationId = @PremiumGrains_BetterHaven
				,dblUnitOnHand	= 100		
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,intItemLocationId = @ColdGrains_BetterHaven
				,dblUnitOnHand	= 100	
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,intItemLocationId = @HotGrains_BetterHaven
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
				,intItemLocationId = @WetGrains_BetterHaven
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,intItemLocationId = @PremiumGrains_BetterHaven
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,intItemLocationId = @ColdGrains_BetterHaven
				,dblAverageCost = 2.15
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,intItemLocationId = @HotGrains_BetterHaven
				,dblAverageCost = 2.15

		----------------------------------------------------------------
		-- Fake data for tblICInventoryLIFO
		----------------------------------------------------------------
		BEGIN 
			INSERT INTO dbo.tblICInventoryLIFO (
					dtmDate
					,intItemId
					,intItemLocationId
					,dblStockIn
					,dblStockOut
					,dblCost
					,intTransactionId
					,strTransactionId
			)
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @WetGrains 
					,intItemLocationId = @WetGrains_BetterHaven
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @StickyGrains 
					,intItemLocationId = @StickyGrains_BetterHaven
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @PremiumGrains 
					,intItemLocationId = @PremiumGrains_BetterHaven
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @ColdGrains 
					,intItemLocationId = @ColdGrains_BetterHaven
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,intItemId = @HotGrains 
					,intItemLocationId = @HotGrains_BetterHaven
					,dblStockIn = 100
					,dblStockOut = 0 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = 'InvRcpt-0001'
		END 

		----------------------------------------------------------------
		-- Fake data for tblICInventoryLIFOOut
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
					,intItemLocationId = @WetGrains_BetterHaven
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
					,intItemLocationId = @StickyGrains_BetterHaven
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
					,intItemLocationId = @PremiumGrains_BetterHaven
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
					,intItemLocationId = @ColdGrains_BetterHaven
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
					,intItemLocationId = @HotGrains_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @APClearing_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @APClearing_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @APClearing_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @APClearing_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @APClearing_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
			UNION ALL 
			SELECT	dtmDate = '01/01/2014'
					,dblDebit = 0
					,dblCredit = (215.00 * 5)
					,intAccountId = @APClearing_BetterHaven

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
				,intShipFromLocationId = @BetterHaven			
				,intEntityId = 1
				,intCreatedUserId = 1
				,ysnPosted = 1

		INSERT INTO dbo.tblICInventoryShipmentItem (
				intInventoryShipmentId 
				,intItemId 
				,dblQuantity
				,dblUnitPrice
		)
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @WetGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @StickyGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @PremiumGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @ColdGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23
		UNION ALL
		SELECT 	intInventoryShipmentId = 1
				,intItemId = @HotGrains
				,dblQuantity = 75
				,dblUnitPrice = 55.23

		-- Reduce stock qty from the Item Stock table 
		UPDATE	ItemStock
		SET		dblUnitOnHand -= 75
		FROM	dbo.tblICItemStock ItemStock INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemStock.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @BetterHaven

		-- Add out qty in the LIFO table
		UPDATE	LIFO
		SET		dblStockOut += 75
		FROM	dbo.tblICInventoryLIFO LIFO INNER JOIN dbo.tblICItemLocation ItemLocation
					ON LIFO.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @BetterHaven

		-- Add the LIFO out records
		INSERT INTO dbo.tblICInventoryLIFOOut (
				intInventoryLIFOId
				,intInventoryTransactionId
				,dblQty
		)
		SELECT	intInventoryLIFOId = 1
				,intInventoryTransactionId = 6
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryLIFOId = 2
				,intInventoryTransactionId = 7
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryLIFOId = 3
				,intInventoryTransactionId = 8
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryLIFOId = 4
				,intInventoryTransactionId = 9
				,dblQty = 75
		UNION ALL 
		SELECT	intInventoryLIFOId = 5
				,intInventoryTransactionId = 10
				,dblQty = 75

		----------------------------------------------------------------
		-- Fake data for tblICInventoryTransaction
		----------------------------------------------------------------
		SET	@strBatchId = 'BATCH-0000002'
		INSERT INTO dbo.tblICInventoryTransaction (
				dtmDate
				,dblQty
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
				,strBatchId
		)
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
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
				,intItemLocationId = @WetGrains_BetterHaven
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
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
				,intItemLocationId = @StickyGrains_BetterHaven
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
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
				,intItemLocationId = @PremiumGrains_BetterHaven
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
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
				,intItemLocationId = @ColdGrains_BetterHaven
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = '01/16/2014'
				,dblQty = -75
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
				,intItemLocationId = @HotGrains_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @InventoryInTransit_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @InventoryInTransit_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @InventoryInTransit_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @InventoryInTransit_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
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
					,intAccountId = @InventoryInTransit_BetterHaven
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
					,intAccountId = @Inventory_BetterHaven
			UNION ALL 
			SELECT	dtmDate = '01/16/2014'
					,dblDebit = (161.25 * 5)
					,dblCredit = 0
					,intAccountId = @InventoryInTransit_BetterHaven
		END 
	END 
END