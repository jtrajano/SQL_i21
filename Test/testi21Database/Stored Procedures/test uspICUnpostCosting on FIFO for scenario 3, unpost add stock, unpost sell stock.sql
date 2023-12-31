﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting on FIFO for scenario 3, unpost add stock, unpost sell stock]
AS
-- Arrange 
BEGIN 
	EXEC [testi21Database].[Fake posted transactions using FIFO, scenario 3];
	
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

	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @intTransactionId AS INT = 1
	DECLARE @strTransactionId AS NVARCHAR(40)
	DECLARE @intEntityUserSecurityId AS INT = 1
	DECLARE @GLDetail AS dbo.RecapTableType 

	DECLARE @AUTO_NEGATIVE AS INT = 1

	-- Create the tables used for assertion
	CREATE TABLE expectedGLDetail (
		dtmDate DATETIME
		,strBatchId NVARCHAR(20)
		,intAccountId INT
		,dblDebit NUMERIC(18,6)
		,dblCredit NUMERIC(18,6)
		,dblDebitUnit NUMERIC(18,6)
		,dblCreditUnit NUMERIC(18,6)
		,strDescription NVARCHAR(255)
		,strCode NVARCHAR(40)
		,intJournalLineNo INT
		,ysnIsUnposted BIT
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT
		,strModuleName NVARCHAR(255)
	)

	CREATE TABLE actualGLDetail (
		dtmDate DATETIME
		,strBatchId NVARCHAR(20)
		,intAccountId INT
		,dblDebit NUMERIC(18,6)
		,dblCredit NUMERIC(18,6)
		,dblDebitUnit NUMERIC(18,6)
		,dblCreditUnit NUMERIC(18,6)
		,strDescription NVARCHAR(255)
		,strCode NVARCHAR(40)
		,intJournalLineNo INT
		,ysnIsUnposted BIT
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT
		,strModuleName NVARCHAR(255)
	)

	CREATE TABLE expectedInventoryTransaction (
		intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblQty NUMERIC(18,6)
		,dblUOMQty NUMERIC(18,6)
		,dblCost NUMERIC(38, 20)
		,dblValue NUMERIC(18,6)
		,dblSalesPrice NUMERIC(18,6)
		,intTransactionId INT
		,strTransactionId NVARCHAR(40)
		,strBatchId NVARCHAR(20)
		,intTransactionTypeId INT
		,ysnIsUnposted BIT
		,intRelatedInventoryTransactionId INT
		,intRelatedTransactionId INT
		,strRelatedTransactionId NVARCHAR(40)
		,strTransactionForm NVARCHAR(255)	
	)

	CREATE TABLE actualInventoryTransaction (
		intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblQty NUMERIC(18,6)
		,dblUOMQty NUMERIC(18,6)
		,dblCost NUMERIC(38, 20)
		,dblValue NUMERIC(18,6)
		,dblSalesPrice NUMERIC(18,6)
		,intTransactionId INT
		,strTransactionId NVARCHAR(40)
		,strBatchId NVARCHAR(20)
		,intTransactionTypeId INT
		,ysnIsUnposted BIT
		,intRelatedInventoryTransactionId INT
		,intRelatedTransactionId INT
		,strRelatedTransactionId NVARCHAR(40)
		,strTransactionForm NVARCHAR(255)	
	)
	
	CREATE TABLE expectedItemStock (
		intItemId INT
		,intItemLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)

	CREATE TABLE actualItemStock (
		intItemId INT
		,intItemLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)
	
	CREATE TABLE expectedFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(38, 20)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)
	
	CREATE TABLE actualFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intItemLocationId INT
		,intItemUOMId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(38, 20)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
	)	
END 

-- Act
BEGIN
	-- Begin: Unpost Add Stock 
	BEGIN 
		SET @strBatchId = 'BATCH-0000003'
		SET @strTransactionId = 'InvRcpt-0001'
		SET @intTransactionId = 1

		-- Setup the expected data. 
		-------------------------------------------------------------
		-- Begin: Reverse the posted GL entries
		-------------------------------------------------------------
		INSERT INTO expectedGLDetail (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,intJournalLineNo
			,ysnIsUnposted
			,strTransactionId
			,intTransactionId 
			,strModuleName 
		)
		SELECT	dtmDate
				,strBatchId = @strBatchId
				,intAccountId
				-----------------------------------------------
				-- Reverse the debit and credit amounts
				-- { 
					,dblDebit = dblCredit 
					,dblCredit = dblDebit 
				-- }
				,ISNULL(dblDebitUnit, 0)
				,ISNULL(dblCreditUnit, 0)
				,strDescription
				,strCode
				,intJournalLineNo = intJournalLineNo + 10
				,ysnIsUnposted = 1
				,strTransactionId
				,intTransactionId 
				,strModuleName 
		FROM	dbo.tblGLDetail
		WHERE	tblGLDetail.intTransactionId = @intTransactionId
				AND tblGLDetail.strTransactionId = @strTransactionId
		-------------------------------------------------------------
		-- End: Reverse the posted GL entries
		-------------------------------------------------------------

		---------------------------------------------------------------
		---- Begin: Expect Auto Variance G/L entries
		---------------------------------------------------------------			
		--UNION ALL 
		--SELECT	dtmDate = '01/01/2014'
		--		,strBatchId = @strBatchId
		--		,intAccountId = GLAccount.intAccountId
		--		,dblDebit = 0
		--		,dblCredit = ABS(-75 * 2.15)
		--		,dblDebitUnit = 0
		--		,dblCreditUnit = 0
		--		,strDescription = GLAccount.strDescription
		--		,strCode = 'IAN'
		--		,intJournalLineNo = 
		--			CASE	WHEN  InventoryAccountSetup.intItemId = @WetGrains THEN 16
		--					WHEN  InventoryAccountSetup.intItemId = @StickyGrains THEN 17
		--					WHEN  InventoryAccountSetup.intItemId = @PremiumGrains THEN 18
		--					WHEN  InventoryAccountSetup.intItemId = @ColdGrains THEN 19
		--					WHEN  InventoryAccountSetup.intItemId = @HotGrains THEN 20
		--			END 
		--		,ysnIsUnposted = 0
		--		,strTransactionId = 'InvRcpt-0001'
		--		,intTransactionId = 1
		--		,strModuleName = 'Inventory'
		--FROM	(
		--			SELECT	Stock.intItemId, Stock.intItemLocationId, AutoNegative.intAccountId 
		--			FROM	dbo.tblICItemStock Stock INNER JOIN dbo.tblICItemLocation ItemLocation
		--						ON Stock.intItemId = ItemLocation.intItemId
		--						AND Stock.intItemLocationId = ItemLocation.intItemLocationId							
		--					OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intItemLocationId, 'Auto-Variance') AutoNegative
		--			WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
		--					AND ItemLocation.intLocationId = @Default_Location						
		--		) InventoryAccountSetup
		--		INNER JOIN dbo.tblGLAccount GLAccount
		--			ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId

		--UNION ALL 
		--SELECT	dtmDate = '01/01/2014'
		--		,strBatchId = @strBatchId
		--		,intAccountId = GLAccount.intAccountId
		--		,dblDebit = ABS(-75 * 2.15)
		--		,dblCredit = 0
		--		,dblDebitUnit = 0
		--		,dblCreditUnit = 0
		--		,strDescription = GLAccount.strDescription
		--		,strCode = 'IAN'
		--		,intJournalLineNo = 
		--			CASE	WHEN  InventoryAccountSetup.intItemId = @WetGrains THEN 16
		--					WHEN  InventoryAccountSetup.intItemId = @StickyGrains THEN 17
		--					WHEN  InventoryAccountSetup.intItemId = @PremiumGrains THEN 18
		--					WHEN  InventoryAccountSetup.intItemId = @ColdGrains THEN 19
		--					WHEN  InventoryAccountSetup.intItemId = @HotGrains THEN 20
		--			END 
		--		,ysnIsUnposted = 0
		--		,strTransactionId = 'InvRcpt-0001'
		--		,intTransactionId = 1
		--		,strModuleName = 'Inventory'
		--FROM	(
		--			SELECT	Stock.intItemId, Stock.intItemLocationId, Inventory.intAccountId 
		--			FROM	dbo.tblICItemStock Stock INNER JOIN dbo.tblICItemLocation ItemLocation
		--						ON Stock.intItemId = ItemLocation.intItemId
		--						AND Stock.intItemLocationId = ItemLocation.intItemLocationId							
		--					OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intItemLocationId, 'Inventory') Inventory
		--			WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
		--					AND ItemLocation.intLocationId = @Default_Location
		--		) InventoryAccountSetup
		--		INNER JOIN dbo.tblGLAccount GLAccount
		--			ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId			
		---------------------------------------------------------------
		---- Begin: Expect Auto Variance G/L entries
		---------------------------------------------------------------
		

		-- Reverse of the inventory transactions
		INSERT INTO expectedInventoryTransaction (
				intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted 
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		)
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
		UNION ALL 
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,dtmDate 
				-- Reverse the unit qty
				--{
					,dblQty = dblQty * -1
				--}
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId = @strBatchId
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId = intInventoryTransactionId
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId

		-------------------------------------------------------------------------------------
		---- Expect the Auto Variance transactions
		--UNION ALL 
		--SELECT	intItemId 
		--		,intItemLocationId 
		--		,dtmDate = '01/01/2014'
		--		,dblQty = 0
		--		,dblCost = 0
		--		,dblValue = (75 * 2.15) -- Re-add the sold transaction when unposting an add-transaction
		--		,dblSalesPrice = 0
		--		,intTransactionId = @intTransactionId
		--		,strTransactionId = @strTransactionId
		--		,strBatchId = @strBatchId
		--		,intTransactionTypeId = @AUTO_NEGATIVE
		--		,ysnIsUnposted = 0
		--		,intRelatedInventoryTransactionId = NULL
		--		,intRelatedTransactionId = NULL
		--		,strRelatedTransactionId = NULL
		--		,strTransactionForm = NULL
		--FROM	(
		--			SELECT	Stock.intItemId, Stock.intItemLocationId, Inventory.intAccountId 
		--			FROM	dbo.tblICItemStock Stock INNER JOIN dbo.tblICItemLocation ItemLocation
		--						ON Stock.intItemId = ItemLocation.intItemId
		--						AND Stock.intItemLocationId = ItemLocation.intItemLocationId							
		--					OUTER APPLY dbo.fnGetItemGLAccountAsTable (Stock.intItemId, Stock.intItemLocationId, 'Auto-Variance') Inventory
		--			WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
		--					AND ItemLocation.intLocationId = @Default_Location								
		--		) InventoryAccountSetup
		--		INNER JOIN dbo.tblGLAccount GLAccount
		--			ON InventoryAccountSetup.intAccountId = GLAccount.intAccountId
			
		-- Setup the expected Item Stock
		-- Expect the stock to go negative. The average cost should remain the same. 
		INSERT INTO expectedItemStock (
				intItemId
				,intItemLocationId
				,dblAverageCost
				,dblUnitOnHand
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = 1
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @StickyGrains
				,intItemLocationId = 2
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @PremiumGrains
				,intItemLocationId = 3
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @ColdGrains
				,intItemLocationId = 4
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
		UNION ALL
		SELECT	intItemId = @HotGrains
				,intItemLocationId = 5
				,dblAverageCost = 2.15
				,dblUnitOnHand = -75
			
		-- Setup the expected FIFO data
		INSERT INTO expectedFIFO (
				intInventoryFIFOId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
				,strTransactionId
				,intTransactionId
		)
		-- Plug the out-qty 
		SELECT	intInventoryFIFOId = 1
				,intItemId = @WetGrains
				,intItemLocationId = 1
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		UNION ALL 
		SELECT	intInventoryFIFOId = 2
				,intItemId = @StickyGrains
				,intItemLocationId = 2
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		UNION ALL 
		SELECT	intInventoryFIFOId = 3
				,intItemId = @PremiumGrains
				,intItemLocationId = 3
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		UNION ALL 
		SELECT	intInventoryFIFOId = 4
				,intItemId = @ColdGrains
				,intItemLocationId = 4
				,intItemUOMId = @ColdGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1							
		UNION ALL 
		SELECT	intInventoryFIFOId = 5
				,intItemId = @HotGrains
				,intItemLocationId = 5
				,intItemUOMId = @HotGrains_BushelUOMId
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 100
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
		-- When add stock is removed, all the sold stocks from it need to have negative fifo entries 
		UNION ALL 
		SELECT	intInventoryFIFOId = 6
				,intItemId = @WetGrains
				,intItemLocationId = 1
				,intItemUOMId = @WetGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1			
		UNION ALL 
		SELECT	intInventoryFIFOId = 7
				,intItemId = @StickyGrains
				,intItemLocationId = 2
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1	
		UNION ALL 
		SELECT	intInventoryFIFOId = 8
				,intItemId = @PremiumGrains
				,intItemLocationId = 3
				,intItemUOMId = @PremiumGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1	
		UNION ALL 
		SELECT	intInventoryFIFOId = 9
				,intItemId = @ColdGrains
				,intItemLocationId = 4
				,intItemUOMId = @ColdGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1	
		UNION ALL 
		SELECT	intInventoryFIFOId = 10
				,intItemId = @HotGrains
				,intItemLocationId = 5
				,intItemUOMId = @HotGrains_BushelUOMId
				,dtmDate = '01/16/2014'
				,dblStockIn = 0
				,dblStockOut = 75
				,dblCost = 2.15
				,strTransactionId = 'InvShip-0001'
				,intTransactionId = 1					

		-- Do the act
		INSERT INTO @GLDetail (
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
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]					
		)
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
	END 
	-- End: Unpost Add Stock 
	
	-- Begin: Unpost Sell Stock
	BEGIN 
		SET @strBatchId = 'BATCH-0000004'
		SET @strTransactionId = 'InvShip-0001'
		SET @intTransactionId = 1

		-- Setup the expected data. 
		-- Reverse the posted GL entries
		INSERT INTO expectedGLDetail (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,intJournalLineNo
			,ysnIsUnposted
			,strTransactionId
			,intTransactionId 
			,strModuleName 
		)
		SELECT	dtmDate
				,strBatchId = @strBatchId
				,intAccountId
				-----------------------------------------------
				-- Reverse the debit and credit amounts
				-- { 
					,dblDebit = dblCredit 
					,dblCredit = dblDebit 
				-- }
				,ISNULL(dblDebitUnit, 0)
				,ISNULL(dblCreditUnit, 0)
				,strDescription
				,strCode
				,intJournalLineNo = intJournalLineNo + 10
				,ysnIsUnposted = 1
				,strTransactionId
				,intTransactionId 
				,strModuleName 
		FROM	dbo.tblGLDetail
		WHERE	tblGLDetail.intTransactionId = @intTransactionId
				AND tblGLDetail.strTransactionId = @strTransactionId

		-- Reverse of the inventory transactions
		INSERT INTO expectedInventoryTransaction (
				intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted 
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		)
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				,dblQty 
				,dblUOMQty 
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId 
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId 
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
		UNION ALL 
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId
				,dtmDate 
				-- Reverse the unit qty
				--{
					,dblQty = dblQty * -1
				--}
				,dblUOMQty
				,dblCost 
				,dblValue
				,dblSalesPrice 
				,intTransactionId 
				,strTransactionId 
				,strBatchId = @strBatchId
				,intTransactionTypeId 
				,ysnIsUnposted = 1
				,intRelatedInventoryTransactionId = intInventoryTransactionId
				,intRelatedTransactionId 
				,strRelatedTransactionId 
				,strTransactionForm 
		FROM	dbo.tblICInventoryTransaction
		WHERE	intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
			
		-- Setup the expected Item Stock
		-- Expect the stock goes back to zero. The average cost should remain the same. 
		UPDATE	expectedItemStock
		SET		dblUnitOnHand += 75
		FROM	expectedItemStock INNER JOIN dbo.tblICItemLocation ItemLocation
					ON expectedItemStock.intItemId = ItemLocation.intItemId
					AND expectedItemStock.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @Default_Location
			
		-- Expect FIFO in records are plugged out to prevent further use in the future. 		
		UPDATE	expectedFIFO
		SET		dblStockIn += 75
		FROM	expectedFIFO INNER JOIN dbo.tblICItemLocation ItemLocation
					ON expectedFIFO.intItemId = ItemLocation.intItemId
					AND expectedFIFO.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
				AND ItemLocation.intLocationId = @Default_Location
				AND expectedFIFO.dblStockOut = 75
	
		-- Do the act
		INSERT INTO @GLDetail (
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
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
		)
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
	END 
	-- End: Unpost Sell Stock
END 

-- Assert
BEGIN
	-- Get the data for assertion 
	-- Actual data from @GLDetail
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
		,intJournalLineNo
		,ysnIsUnposted
		,strTransactionId
		,intTransactionId 
		,strModuleName 
	)
	SELECT	dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,intJournalLineNo
			,ysnIsUnposted 
			,strTransactionId
			,intTransactionId 
			,strModuleName 
	FROM	@GLDetail
		
	-- Actual data from tblICInventoryTransaction
	-- Reverse of the inventory transactions
	INSERT INTO actualInventoryTransaction (
			intItemId 
			,intItemLocationId 
			,intItemUOMId 
			,dtmDate 
			,dblQty 
			,dblUOMQty 
			,dblCost 
			,dblValue
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId 
			,intTransactionTypeId 
			,ysnIsUnposted 
			,intRelatedInventoryTransactionId 
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,strTransactionForm 
	)
	SELECT	intItemId 
			,intItemLocationId 
			,intItemUOMId
			,dtmDate 
			,dblQty 
			,dblUOMQty
			,dblCost 
			,dblValue
			,dblSalesPrice 
			,intTransactionId 
			,strTransactionId 
			,strBatchId 
			,intTransactionTypeId 
			,ysnIsUnposted
			,intRelatedInventoryTransactionId 
			,intRelatedTransactionId 
			,strRelatedTransactionId 
			,strTransactionForm 
	FROM	dbo.tblICInventoryTransaction
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId IN ('InvRcpt-0001', 'InvShip-0001')
	
	-- Actual item stock data
	INSERT INTO actualItemStock (
			intItemId
			,intItemLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	ItemStock.intItemId 
			,ItemStock.intItemLocationId 
			,ItemPricing.dblAverageCost 
			,ItemStock.dblUnitOnHand 
	FROM	dbo.tblICItemStock ItemStock INNER JOIN dbo.tblICItemPricing ItemPricing
				ON ItemStock.intItemId = ItemPricing.intItemId
				AND ItemStock.intItemLocationId = ItemPricing.intItemLocationId
	
	-- Actual fifo data 
	INSERT INTO actualFIFO (
			intInventoryFIFOId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
	)	
	SELECT	intInventoryFIFOId
			,tblICInventoryFIFO.intItemId
			,tblICInventoryFIFO.intItemLocationId
			,tblICInventoryFIFO.intItemUOMId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId		
	FROM	dbo.tblICInventoryFIFO INNER JOIN dbo.tblICItemLocation ItemLocation
				ON tblICInventoryFIFO.intItemId = ItemLocation.intItemId
				AND tblICInventoryFIFO.intItemLocationId = ItemLocation.intItemLocationId
	WHERE	ItemLocation.intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @HotGrains, @ColdGrains)
			AND ItemLocation.intLocationId = @Default_Location

	EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail';
	EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction';
	EXEC tSQLt.AssertEqualsTable 'expectedItemStock', 'actualItemStock';
	EXEC tSQLt.AssertEqualsTable 'expectedFIFO', 'actualFIFO';
END 

-- Clean-up: remove the tables used in the unit test
IF OBJECT_ID('expectedGLDetail') IS NOT NULL 
	DROP TABLE expectedGLDetail

IF OBJECT_ID('actualGLDetail') IS NOT NULL 
	DROP TABLE actualGLDetail

IF OBJECT_ID('expectedInventoryTransaction') IS NOT NULL 
	DROP TABLE expectedInventoryTransaction

IF OBJECT_ID('actualInventoryTransaction') IS NOT NULL 
	DROP TABLE actualInventoryTransaction
	
IF OBJECT_ID('expectedItemStock') IS NOT NULL 
	DROP TABLE expectedItemStock

IF OBJECT_ID('actualItemStock') IS NOT NULL 
	DROP TABLE actualItemStock	
	
IF OBJECT_ID('expectedFIFO') IS NOT NULL 
	DROP TABLE expectedFIFO

IF OBJECT_ID('actualFIFO') IS NOT NULL 
	DROP TABLE actualFIFO
GO 
