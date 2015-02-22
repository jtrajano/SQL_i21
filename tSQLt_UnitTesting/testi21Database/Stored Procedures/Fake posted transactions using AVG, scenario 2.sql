---------------------------------------------------------------------------------------------------
/*
	Scenario 2: Sell stock 	

	tblICInventoryFIFO
	-----------------------------------------------------------------
	Fifo Id	Date		In		Out		Cost	Inbound Transaction
	-------	---------	------	-----	------	---------------------
	1		1/1/2014	0		50		$2.00	InvShip-00001

	tblICInventoryFIFOOut
	-----------------------------------------------------------------
	Id		Fifo Id		Inventory Transaction Id	Revalue Id	Qty
	-----	---------	-------------------------	----------	-----
	None

	tblICInventoryTransaction
	-------------------------------------------------------------------------------------------------------------------
	Id	Date		Qty		Cost	Value Adj	Transaction Id	Related Transaction Id	Type				Is Unposted
	---	---------	------	------	----------	--------------	----------------------	-------------------	-----------
	1	1/1/2014	-50		$2.000	NULL		InvShip-00001	NULL					Inventory Shipment	
	
	G/L Entries
	----------------------------------------------------------------------------------------
	Date		Account					Debit		Credit		Journal Id		Is Unposted
	----------	----------------------	-----------	----------	-------------	------------
	1/1/2014	Inventory In-Transit	$100.00
				Inventory							$100.00
*/
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [testi21Database].[Fake posted transactions using AVG, scenario 2]
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
				
	-- Declare the variable for unit of measure
	DECLARE @Each AS INT = 1

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
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;
	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	
		
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
	SELECT	dtmShipDate = '01/01/2014'
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
			,dblQuantity = 100
			,dblUnitPrice = 55.23
			,intUnitMeasureId = @WetGrains_BushelUOMId
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @StickyGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
			,intUnitMeasureId = @StickyGrains_BushelUOMId
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @PremiumGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
			,intUnitMeasureId = @PremiumGrains_BushelUOMId
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @ColdGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
			,intUnitMeasureId = @ColdGrains_BushelUOMId
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @HotGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
			,intUnitMeasureId = @HotGrains_BushelUOMId

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
			,dblUnitOnHand	= -100
	UNION ALL 
	SELECT 	intItemId = @StickyGrains
			,intItemLocationId = 2
			,dblUnitOnHand	= -100	
	UNION ALL 
	SELECT 	intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dblUnitOnHand	= -100		
	UNION ALL 
	SELECT 	intItemId = @ColdGrains
			,intItemLocationId = 4
			,dblUnitOnHand	= -100
	UNION ALL 
	SELECT 	intItemId = @HotGrains
			,intItemLocationId = 5
			,dblUnitOnHand	= -100

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
			,dblAverageCost = 2.00
	UNION ALL 
	SELECT 	intItemId = @StickyGrains
			,intItemLocationId = 2
			,dblAverageCost = 2.00
	UNION ALL 
	SELECT 	intItemId = @PremiumGrains
			,intItemLocationId = 3
			,dblAverageCost = 2.00
	UNION ALL 
	SELECT 	intItemId = @ColdGrains
			,intItemLocationId = 4
			,dblAverageCost = 2.00
	UNION ALL 
	SELECT 	intItemId = @HotGrains
			,intItemLocationId = 5
			,dblAverageCost = 2.00

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
				,dblStockIn = 0
				,dblStockOut = 100 
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @StickyGrains 
				,intItemLocationId = 2
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dblStockIn = 0
				,dblStockOut = 100 
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @PremiumGrains 
				,intItemLocationId = 3
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,dblStockIn = 0
				,dblStockOut = 100 
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @ColdGrains 
				,intItemLocationId = 4
				,intItemUOMId = @ColdGrains_BushelUOMId
				,dblStockIn = 0
				,dblStockOut = 100
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @HotGrains 
				,intItemLocationId = 5
				,intItemUOMId = @HotGrains_BushelUOMId
				,dblStockIn = 0
				,dblStockOut = 100
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
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
		SELECT	dtmDate = '01/01/2014'
				,dblQty = -100
				,dblUOMQty = 1
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intItemLocationId = 1
				,intItemUOMId = @WetGrains_BushelUOMId
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblQty = -100
				,dblUOMQty = 1
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
				,ysnIsUnposted = 0
				,intItemId = @StickyGrains
				,intItemLocationId = 2
				,intItemUOMId = @StickyGrains_BushelUOMId
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblQty = -100
				,dblUOMQty = 1
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
				,ysnIsUnposted = 0
				,intItemId = @PremiumGrains
				,intItemLocationId = 3
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblQty = -100
				,dblUOMQty = 1
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
				,ysnIsUnposted = 0
				,intItemId = @ColdGrains
				,intItemLocationId = 4
				,intItemUOMId = @ColdGrains_BushelUOMId
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblQty = -100
				,dblUOMQty = 1
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
				,ysnIsUnposted = 0
				,intItemId = @HotGrains
				,intItemLocationId = 5
				,intItemUOMId = @HotGrains_BushelUOMId
				,strBatchId = @strBatchId				
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
				,dblExchangeRate
		)
		-- @WetGrains
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 1 
				,dblExchangeRate = 1
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @InventoryInTransit_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 1 
				,dblExchangeRate = 1
		-- @StickyGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 2 
				,dblExchangeRate = 1
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @InventoryInTransit_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 2
				,dblExchangeRate = 1
		-- @PremiumGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 3
				,dblExchangeRate = 1
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @InventoryInTransit_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 3 
				,dblExchangeRate = 1
		-- @ColdGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 4 
				,dblExchangeRate = 1
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @InventoryInTransit_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 4
				,dblExchangeRate = 1
		-- @HotGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 5 
				,dblExchangeRate = 1
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @InventoryInTransit_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = 5 
				,dblExchangeRate = 1

		INSERT INTO dbo.tblGLSummary(
				dtmDate
				,dblDebit
				,dblCredit
				,intAccountId
		)
		SELECT	dtmDate = '01/01/2014'
				,dblDebit = 0
				,dblCredit = (200.00 * 5)
				,intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblDebit = (200.00 * 5)
				,dblCredit = 0
				,intAccountId = @InventoryInTransit_Default

	END 
END