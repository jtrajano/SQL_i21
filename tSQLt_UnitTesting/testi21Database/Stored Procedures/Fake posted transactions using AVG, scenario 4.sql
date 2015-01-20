---------------------------------------------------------------------------------------------------
/*
	Scenario 4: Sell Stock, Add Stock

	tblICInventoryFIFO
	-----------------------------------------------------------------
	Fifo Id	Date		In		Out		Cost	Inbound Transaction
	-------	---------	------	-----	------	---------------------
	1		1/1/2014	75		75		$2.00	InvShip-00001
	2		1/16/2014	100		75		$2.15	InvRcpt-00001

	tblICInventoryFIFOOut
	-----------------------------------------------------------------
	Id		Fifo Id		Inventory Transaction Id	Revalue Id	Qty
	-----	---------	-------------------------	----------	-----
	1		2			InvShip-00001				1			75

	tblICInventoryTransaction
	-------------------------------------------------------------------------------------------------------------------
	Id	Date		Qty		Cost	Value Adj	Transaction Id	Related Transaction Id	Type				Is Unposted
	---	---------	------	------	----------	--------------	----------------------	-------------------	-----------
	1	1/1/2014	-75		$2.000	NULL		InvShip-00001	NULL					Inventory Shipment	
	2	1/16/2014	100		$2.150	NULL		InvRcpt-00001	NULL					Inventory Receipt	
	3	1/16/2014	75		$2.000	NULL		InvRcpt-00001	InvShip-00001			Write-Off Sold
	4	1/16/2014	-75		$2.150	NULL		InvRcpt-00001	InvShip-00001			Revalue Sold
	
	
	G/L Entries
	----------------------------------------------------------------------------------------
	Date		Account					Debit		Credit		Journal Id		Is Unposted
	----------	---------------------	-----------	----------	-------------	------------
	1/1/2014	Inventory In-Transit	150.00					1					
				Inventory							150.00		1
	1/16/2014	Inventory				215.00					2
				AP Clearing							215.00		2
				Inventory				150.00					3
				Write-Off Sold						150.00		3
				Revalue Sold			161.250					4
				Inventory							161.250		4

*/
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [testi21Database].[Fake posted transactions using AVG, scenario 4]
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
	DECLARE @strBatchId AS NVARCHAR(20) 
	DECLARE @strTransactionId AS NVARCHAR(40)
	DECLARE @strRelatedTransactionId AS NVARCHAR(40)
	DECLARE @dtmDate AS DATETIME 

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

	---------------------------------------------------------------------------------------------------------------
	-- Sell Stock (75 qty) 
	---------------------------------------------------------------------------------------------------------------
	BEGIN 
		SET @strBatchId = 'BATCH-0000001'
		SET @strTransactionId = 'InvShip-00001'
		SET @dtmDate = '01/01/2014'

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
		SELECT	dtmShipDate = @dtmDate
				,strBOLNumber = @strTransactionId
				,intShipFromLocationId = @Default_Location			
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

		----------------------------------------------------------------
		-- Fake data for tblICInventoryFIFO
		----------------------------------------------------------------
		BEGIN 
			INSERT INTO dbo.tblICInventoryFIFO (
					dtmDate
					,intItemId
					,intLocationId
					,dblStockIn
					,dblStockOut
					,dblCost
					,intTransactionId
					,strTransactionId
			)
			SELECT	dtmDate = @dtmDate
					,intItemId = @WetGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 0
					,dblStockOut = 75 
					,dblCost = 2.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @StickyGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 0
					,dblStockOut = 75
					,dblCost = 2.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @PremiumGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 0
					,dblStockOut = 75
					,dblCost = 2.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @ColdGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 0
					,dblStockOut = 75
					,dblCost = 2.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @HotGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 0
					,dblStockOut = 75 
					,dblCost = 2.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
		END 

		----------------------------------------------------------------
		-- Fake data for tblICItemStock
		----------------------------------------------------------------
		INSERT INTO dbo.tblICItemStock(
				intItemId
				,intLocationId
				,dblAverageCost
				,dblUnitOnHand	
		)
		SELECT 	intItemId = @WetGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.00
				,dblUnitOnHand	= -75
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.00
				,dblUnitOnHand	= -75
		UNION ALL 
		SELECT 	intItemId = @PremiumGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.00
				,dblUnitOnHand	= -75
		UNION ALL 
		SELECT 	intItemId = @ColdGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.00
				,dblUnitOnHand	= -75	
		UNION ALL 
		SELECT 	intItemId = @HotGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.00
				,dblUnitOnHand	= -75

		------------------------------
		-- Add the fifo out records
		------------------------------
		-- Can't add fifo out records when stock is negative. 

		----------------------------------------------------------------
		-- Fake data for tblICInventoryTransaction
		----------------------------------------------------------------
		INSERT INTO dbo.tblICInventoryTransaction (
				dtmDate
				,dblUnitQty
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
				,intLocationId
				,strBatchId
		)
		SELECT	dtmDate = @dtmDate
				,dblUnitQty = -75
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = @strTransactionId
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @WetGrains
				,intLocationId = @Default_Location
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = @dtmDate
				,dblUnitQty = -75
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = @strTransactionId
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @StickyGrains
				,intLocationId = @Default_Location
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = @dtmDate
				,dblUnitQty = -75
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = @strTransactionId
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @PremiumGrains
				,intLocationId = @Default_Location
				,strBatchId = @strBatchId
		UNION ALL 
		SELECT	dtmDate = @dtmDate
				,dblUnitQty = -75
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = @strTransactionId
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @ColdGrains
				,intLocationId = @Default_Location
				,strBatchId = @strBatchId			
		UNION ALL 
		SELECT	dtmDate = @dtmDate
				,dblUnitQty = -75
				,dblCost = 2.00
				,dblValue = 0
				,dblSalesPrice = 55.23
				,intTransactionId = 1
				,strTransactionId = @strTransactionId
				,intRelatedTransactionId = NULL 
				,strRelatedTransactionId = NULL 
				,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Shipment')
				,ysnIsUnposted = 0
				,intItemId = @HotGrains
				,intLocationId = @Default_Location
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
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 1
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @InventoryInTransit_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 1
					,dblExchangeRate = 1
					,@strBatchId
			-- @StickyGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 2 
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @InventoryInTransit_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 2
					,dblExchangeRate = 1
					,@strBatchId
			-- @PremiumGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 3
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @InventoryInTransit_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 3 
					,dblExchangeRate = 1
					,@strBatchId
			-- @ColdGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 4
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @InventoryInTransit_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 4
					,dblExchangeRate = 1
					,@strBatchId
			-- @HotGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 5 
					,dblExchangeRate = 1
					,@strBatchId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @InventoryInTransit_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 5
					,dblExchangeRate = 1
					,@strBatchId

			INSERT INTO dbo.tblGLSummary(
					dtmDate
					,dblDebit
					,dblCredit
					,intAccountId
			)
			SELECT	dtmDate = @dtmDate
					,dblDebit = 0
					,dblCredit = (75 * 2.00 * 5)
					,intAccountId = @Inventory_Default
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblDebit = (75 * 2.00 * 5)
					,dblCredit = 0
					,intAccountId = @InventoryInTransit_Default
		END 
	END 
	-- End: Sell Stock (75 qty) 

	---------------------------------------------------------------------------------------------------------------
	-- Add stock (100 qty with $2.15) 
	---------------------------------------------------------------------------------------------------------------
	BEGIN 
		SET @strBatchId = 'BATCH-0000002'
		SET @strTransactionId = 'InvRcpt-00001'
		SET @strRelatedTransactionId = 'InvShip-00001'
		SET @dtmDate = '01/16/2014'

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
		SELECT	dtmReceiptDate = @dtmDate
				,intEntityId = 1
				,intCreatedUserId = 1
				,strReceiptNumber = @strTransactionId
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
		UPDATE	ItemStock
		SET		dblUnitOnHand += 100
				,dblAverageCost = 2.15
		FROM	dbo.tblICItemStock ItemStock
		WHERE	intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND intLocationId = @Default_Location

		----------------------------------------------------------------
		-- Fake data for tblICInventoryFIFO
		----------------------------------------------------------------
		BEGIN 
			-- Update the negative stocks 
			UPDATE	FIFO
			SET		dblStockIn = 75
			FROM	dbo.tblICInventoryFIFO FIFO
			WHERE	dblStockIn = 0
					AND dblStockOut = 75

			-- Add new cost buckets for the incoming stocks
			INSERT INTO dbo.tblICInventoryFIFO (
					dtmDate
					,intItemId
					,intLocationId
					,dblStockIn
					,dblStockOut
					,dblCost
					,intTransactionId
					,strTransactionId
			)
			SELECT	dtmDate = @dtmDate
					,intItemId = @WetGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 100
					,dblStockOut = 75 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @StickyGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 100
					,dblStockOut = 75
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @PremiumGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 100
					,dblStockOut = 75
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @ColdGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 100
					,dblStockOut = 75
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intItemId = @HotGrains 
					,intLocationId = @Default_Location
					,dblStockIn = 100
					,dblStockOut = 75 
					,dblCost = 2.15
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
		END 

		----------------------------------------------------------------
		-- Fake data for tblICInventoryFIFOOut
		----------------------------------------------------------------
		INSERT INTO dbo.tblICInventoryFIFOOut (
				intInventoryFIFOId
				,intInventoryTransactionId
				,dblQty
				,intRevalueFifoId
		)
		SELECT	intInventoryFIFOId = 6
				,intInventoryTransactionId = 8
				,dblQty = 75
				,intRevalueFifoId = 1
		UNION ALL 
		SELECT	intInventoryFIFOId = 7
				,intInventoryTransactionId = 11
				,dblQty = 75
				,intRevalueFifoId = 2
		UNION ALL 
		SELECT	intInventoryFIFOId = 8
				,intInventoryTransactionId = 14
				,dblQty = 75
				,intRevalueFifoId = 3
		UNION ALL 
		SELECT	intInventoryFIFOId = 9
				,intInventoryTransactionId = 17
				,dblQty = 75
				,intRevalueFifoId = 4
		UNION ALL 
		SELECT	intInventoryFIFOId = 10
				,intInventoryTransactionId = 20
				,dblQty = 75
				,intRevalueFifoId = 5

		----------------------------------------------------------------
		-- Fake data for tblICInventoryTransaction
		----------------------------------------------------------------
		BEGIN 
			INSERT INTO dbo.tblICInventoryTransaction (
				dtmDate
				,dblUnitQty
				,dblCost
				,dblValue
				,intTransactionId
				,strTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,intTransactionTypeId
				,ysnIsUnposted
				,intItemId
				,intLocationId
				,strBatchId
				,dblExchangeRate
				,intCurrencyId
			)
			----------------------------------------------------
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 100
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @WetGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Write-Off Sold')
					,ysnIsUnposted = 0
					,intItemId = @WetGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (-75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Revalue Sold')
					,ysnIsUnposted = 0
					,intItemId = @WetGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			----------------------------------------------------
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 100
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @StickyGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Write-Off Sold')
					,ysnIsUnposted = 0
					,intItemId = @StickyGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (-75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Revalue Sold')
					,ysnIsUnposted = 0
					,intItemId = @StickyGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			----------------------------------------------------
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 100
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @PremiumGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Write-Off Sold')
					,ysnIsUnposted = 0
					,intItemId = @PremiumGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (-75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Revalue Sold')
					,ysnIsUnposted = 0
					,intItemId = @PremiumGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			----------------------------------------------------
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 100
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @ColdGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Write-Off Sold')
					,ysnIsUnposted = 0
					,intItemId = @ColdGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (-75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Revalue Sold')
					,ysnIsUnposted = 0
					,intItemId = @ColdGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			----------------------------------------------------
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 100
					,dblCost = 2.15
					,dblValue = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = NULL 
					,strRelatedTransactionId = NULL 
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Receipt')
					,ysnIsUnposted = 0
					,intItemId = @HotGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Write-Off Sold')
					,ysnIsUnposted = 0
					,intItemId = @HotGrains
					,intLocationId = @Default_Location
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblUnitQty = 0
					,dblCost = 0
					,dblValue = (-75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,intRelatedTransactionId = 1
					,strRelatedTransactionId = @strRelatedTransactionId
					,intTransactionTypeId = (SELECT TOP 1 ICType.intTransactionTypeId FROM tblICInventoryTransactionType ICType WHERE ICType.strName = 'Inventory Revalue Sold')
					,ysnIsUnposted = 0
					,intItemId = @HotGrains
					,intLocationId = @Default_Location
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
			-----------------------------------------------
			-- @WetGrains
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 6
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @APClearing_Default
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 6 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 7
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @WriteOffSold_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 7
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @RevalueSold_Default
					,dblDebit = (75 * 2.15)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 8
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 8
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD

			-----------------------------------------------
			-- @StickyGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 9
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @APClearing_Default
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 9
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 10
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @WriteOffSold_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 10
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @RevalueSold_Default
					,dblDebit = (75 * 2.15)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 11
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 11
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD

			-----------------------------------------------
			-- @PremiumGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 12
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @APClearing_Default
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 12 
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 13
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @WriteOffSold_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 13
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @RevalueSold_Default
					,dblDebit = (75 * 2.15)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 14
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 14
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD

			-----------------------------------------------
			-- @ColdGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 15
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @APClearing_Default
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 15
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 16
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @WriteOffSold_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 16
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @RevalueSold_Default
					,dblDebit = (75 * 2.15)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 17
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 17
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD

			-----------------------------------------------
			-- @HotGrains
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 215.00
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 18
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @APClearing_Default
					,dblDebit = 0
					,dblCredit = 215.00
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 18
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = (75 * 2.00)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 19
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @WriteOffSold_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.00)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 19
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @RevalueSold_Default
					,dblDebit = (75 * 2.15)
					,dblCredit = 0
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 20
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,intAccountId = @Inventory_Default
					,dblDebit = 0
					,dblCredit = (75 * 2.15)
					,intTransactionId = 1
					,strTransactionId = @strTransactionId
					,ysnIsUnposted = 0 
					,intJournalLineNo = 20
					,strBatchId = @strBatchId
					,dblExchangeRate = @USD_ExchangeRate
					,intCurrencyId = @USD

			INSERT INTO dbo.tblGLSummary(
					dtmDate
					,dblDebit
					,dblCredit
					,intAccountId
			)
			-- Summary from Inventory Receipt
			SELECT	dtmDate = @dtmDate
					,dblDebit = (100 * 2.15 * 5)
					,dblCredit = 0
					,intAccountId = @Inventory_Default
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblDebit = 0
					,dblCredit = (100 * 2.15 * 5)
					,intAccountId = @APClearing_Default
			-- Write-Off Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblDebit = 0
					,dblCredit = (75 * 2.00 * 5)
					,intAccountId = @WriteOffSold_Default
			-- Revalue Sold
			UNION ALL 
			SELECT	dtmDate = @dtmDate
					,dblDebit = (75 * 2.15 * 5)
					,dblCredit = 0
					,intAccountId = @RevalueSold_Default

			-- Update Inventory account for Write-Off Sold and Revalue Sold
			UPDATE	GLSummary
			SET		dblDebit += (75 * 2.00 * 5)
					,dblCredit += (75 * 2.15 * 5)
			FROM	dbo.tblGLSummary GLSummary
			WHERE	GLSummary.dtmDate = @dtmDate
					AND intAccountId = @Inventory_Default

		END
	END 
	-- End: Add stock (100 qty with $2.15) 
END