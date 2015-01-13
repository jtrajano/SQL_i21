---------------------------------------------------------------------------------------------------
-- Scenario 1: Add stock 
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [testi21Database].[Fake posted transactions using AVG, scenario 2]
AS

BEGIN
	-- Use the 'fake data for simple COA' for the simple items
	EXEC testi21Database.[Fake items for posted transactions]

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
				
	-- Declare the variable for unit of measure
	DECLARE @Each AS INT = 1

	-- Declare the account ids
	DECLARE @Inventory_Default AS INT = 1000
	DECLARE @CostOfGoods_Default AS INT = 2000
	DECLARE @APClearing_Default AS INT = 3000
	DECLARE @WriteOffSold_Default AS INT = 4000
	DECLARE @RevalueSold_Default AS INT = 5000 
	DECLARE @AutoNegative_Default AS INT = 6000

	DECLARE @Inventory_NewHaven AS INT = 1001
	DECLARE @CostOfGoods_NewHaven AS INT = 2001
	DECLARE @APClearing_NewHaven AS INT = 3001
	DECLARE @WriteOffSold_NewHaven AS INT = 4001
	DECLARE @RevalueSold_NewHaven AS INT = 5001
	DECLARE @AutoNegative_NewHaven AS INT = 6001

	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002

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
	)
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @WetGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @StickyGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @PremiumGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @ColdGrains
			,dblQuantity = 100
			,dblUnitPrice = 55.23
	UNION ALL
	SELECT 	intInventoryShipmentId = 1
			,intItemId = @HotGrains
			,dblQuantity = 100
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
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @WetGrains 
				,intLocationId = @Default_Location
				,dblStockIn = 0
				,dblStockOut = 100 
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @StickyGrains 
				,intLocationId = @Default_Location
				,dblStockIn = 0
				,dblStockOut = 100 
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @PremiumGrains 
				,intLocationId = @Default_Location
				,dblStockIn = 0
				,dblStockOut = 100 
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @ColdGrains 
				,intLocationId = @Default_Location
				,dblStockIn = 0
				,dblStockOut = 100
				,dblCost = 2.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intItemId = @HotGrains 
				,intLocationId = @Default_Location
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
		)
		SELECT	dtmDate = '01/01/2014'
				,dblUnitQty = -100
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
				,intLocationId = @Default_Location
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblUnitQty = -100
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
				,intLocationId = @Default_Location
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblUnitQty = -100
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
				,intLocationId = @Default_Location
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblUnitQty = -100
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
				,intLocationId = @Default_Location
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblUnitQty = -100
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
				,intLocationId = @Default_Location
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
		)
		-- @WetGrains
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		-- @StickyGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @APClearing_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		-- @PremiumGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @APClearing_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		-- @ColdGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @APClearing_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		-- @HotGrains
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @Inventory_Default
				,dblDebit = 200.00
				,dblCredit = 0
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,intAccountId = @APClearing_Default
				,dblDebit = 0
				,dblCredit = 200.00
				,intTransactionId = 1
				,strTransactionId = 'InvShip-0001'
				,ysnIsUnposted = 0 
				,intJournalLineNo = NULL 

		INSERT INTO dbo.tblGLSummary(
				dtmDate
				,dblDebit
				,dblCredit
				,intAccountId
		)
		SELECT	dtmDate = '01/01/2014'
				,dblDebit = (200.00 * 5)
				,dblCredit = 0
				,intAccountId = @Inventory_Default
		UNION ALL 
		SELECT	dtmDate = '01/01/2014'
				,dblDebit = 0
				,dblCredit = (200.00 * 5)
				,intAccountId = @APClearing_Default

	END 
END