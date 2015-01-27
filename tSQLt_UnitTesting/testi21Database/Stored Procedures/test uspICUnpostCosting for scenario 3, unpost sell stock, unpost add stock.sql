﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting for scenario 3, unpost sell stock, unpost add stock]
AS
-- Arrange 
BEGIN 
	EXEC [testi21Database].[Fake posted transactions using AVG, scenario 3];
	
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

	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @intTransactionId AS INT = 1
	DECLARE @strTransactionId AS NVARCHAR(40)
	DECLARE @intUserId AS INT = 1
	DECLARE @GLDetail AS dbo.RecapTableType 

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
		,intLocationId INT
		,dtmDate DATETIME
		,dblUnitQty NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
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
		,intLocationId INT
		,dtmDate DATETIME
		,dblUnitQty NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
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
		,intLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)

	CREATE TABLE actualItemStock (
		intItemId INT
		,intLocationId INT
		,dblAverageCost NUMERIC(18,6)
		,dblUnitOnHand NUMERIC(18,6)
	)
	
	CREATE TABLE expectedFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intLocationId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT		
		,ysnIsUnposted BIT 		
	)
	
	CREATE TABLE actualFIFO (
		intInventoryFIFOId INT
		,intItemId INT
		,intLocationId INT
		,dtmDate DATETIME
		,dblStockIn NUMERIC(18,6)
		,dblStockOut NUMERIC(18,6)
		,dblCost NUMERIC(18,6)
		,strTransactionId NVARCHAR(40)
		,intTransactionId INT
		,ysnIsUnposted BIT 		
	)	
END 

-- Act
BEGIN
	-- Begin: Unpost Sell Stock 
	BEGIN 
		SET @strBatchId = 'BATCH-0000003'
		SET @strTransactionId = 'InvShip-0001'
		SET @intTransactionId = 1

		-- Setup the expected data. 
		-- Reverse the posted GL entries
		INSERT INTO dbo.expectedGLDetail (
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
				,intJournalLineNo = intJournalLineNo + 5
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
				,intLocationId 
				,dtmDate 
				,dblUnitQty 
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
				,intLocationId 
				,dtmDate 
				,dblUnitQty 
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
				,intLocationId 
				,dtmDate 
				-- Reverse the unit qty
				--{
					,dblUnitQty = dblUnitQty * -1
				--}
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
		-- Expect the stock to go back to 100. The average cost should remain the same. 
		INSERT INTO expectedItemStock (
				intItemId
				,intLocationId
				,dblAverageCost
				,dblUnitOnHand
		)
		SELECT	intItemId = @WetGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.15
				,dblUnitOnHand = 100
		UNION ALL
		SELECT	intItemId = @StickyGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.15
				,dblUnitOnHand = 100
		UNION ALL
		SELECT	intItemId = @PremiumGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.15
				,dblUnitOnHand = 100
		UNION ALL
		SELECT	intItemId = @ColdGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.15
				,dblUnitOnHand = 100
		UNION ALL
		SELECT	intItemId = @HotGrains
				,intLocationId = @Default_Location
				,dblAverageCost = 2.15
				,dblUnitOnHand = 100
			
		-- Setup the expected FIFO data
		INSERT INTO dbo.expectedFIFO (
				intInventoryFIFOId
				,intItemId
				,intLocationId
				,dtmDate
				,dblStockIn
				,dblStockOut
				,dblCost
				,strTransactionId
				,intTransactionId
				,ysnIsUnposted
		)
		-- The In qty will remain at 100. 
		SELECT	intInventoryFIFOId = 1
				,intItemId = @WetGrains
				,intLocationId = @Default_Location
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
				,ysnIsUnposted = 0
		UNION ALL 
		SELECT	intInventoryFIFOId = 2
				,intItemId = @StickyGrains
				,intLocationId = @Default_Location
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
				,ysnIsUnposted = 0
		UNION ALL 
		SELECT	intInventoryFIFOId = 3
				,intItemId = @PremiumGrains
				,intLocationId = @Default_Location
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1
				,ysnIsUnposted = 0
		UNION ALL 
		SELECT	intInventoryFIFOId = 4
				,intItemId = @ColdGrains
				,intLocationId = @Default_Location
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1							
				,ysnIsUnposted = 0
		UNION ALL 
		SELECT	intInventoryFIFOId = 5
				,intItemId = @HotGrains
				,intLocationId = @Default_Location
				,dtmDate = '01/01/2014'
				,dblStockIn = 100
				,dblStockOut = 0
				,dblCost = 2.15
				,strTransactionId = 'InvRcpt-0001'
				,intTransactionId = 1					
				,ysnIsUnposted = 0
		
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
		)
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intUserId
	END 
	-- End: Unpost Sell Stock 
	
	-- Begin: Unpost Add Stock
	BEGIN 
		SET @strBatchId = 'BATCH-0000004'
		SET @strTransactionId = 'InvRcpt-0001'
		SET @intTransactionId = 1

		-- Setup the expected data. 
		-- Reverse the posted GL entries
		INSERT INTO dbo.expectedGLDetail (
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
				,intJournalLineNo = intJournalLineNo + 15
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
				,intLocationId 
				,dtmDate 
				,dblUnitQty 
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
				,intLocationId 
				,dtmDate 
				,dblUnitQty 
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
				,intLocationId 
				,dtmDate 
				-- Reverse the unit qty
				--{
					,dblUnitQty = dblUnitQty * -1
				--}
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
		SET		dblUnitOnHand -= 100
		FROM	expectedItemStock
		WHERE	intLocationId = @Default_Location
				AND intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)
			
		-- Expect FIFO in records are plugged out to prevent further use in the future. 
		UPDATE	expectedFIFO
		SET		dblStockOut = 100
				,ysnIsUnposted = 1
		FROM	expectedFIFO
		WHERE	intLocationId = @Default_Location
				AND intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @ColdGrains, @HotGrains)	

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
		)
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intUserId				
	END 
	-- End: Unpost Add Stock
END 

-- Assert
BEGIN
	-- Get the data for assertion 
	-- Actual data from @GLDetail
	INSERT INTO dbo.actualGLDetail (
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
			,intLocationId 
			,dtmDate 
			,dblUnitQty 
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
			,intLocationId 
			,dtmDate 
			,dblUnitQty 
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
			,intLocationId
			,dblAverageCost
			,dblUnitOnHand
	)
	SELECT	intItemId 
			,intLocationId 
			,dblAverageCost 
			,dblUnitOnHand 
	FROM dbo.tblICItemStock		
	
	-- Actual fifo data 
	INSERT INTO dbo.actualFIFO (
			intInventoryFIFOId
			,intItemId
			,intLocationId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId
			,ysnIsUnposted
	)	
	SELECT	intInventoryFIFOId
			,intItemId
			,intLocationId
			,dtmDate
			,dblStockIn
			,dblStockOut
			,dblCost
			,strTransactionId
			,intTransactionId		
			,ysnIsUnposted
	FROM	dbo.tblICInventoryFIFO
	WHERE	intItemId IN (@WetGrains, @StickyGrains, @PremiumGrains, @HotGrains, @ColdGrains)
			AND intLocationId IN (@Default_Location)		
				
	EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail';
	EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction';
	EXEC tSQLt.AssertEqualsTable 'expectedItemStock', 'actualItemStock';
	EXEC tSQLt.AssertEqualsTable 'expectedFIFO', 'actualFIFO';	

END 

-- Clean-up: remove the tables used in the unit test
IF OBJECT_ID('expectedGLDetail') IS NOT NULL 
	DROP TABLE expectedGLDetail

IF OBJECT_ID('actualGLDetail') IS NOT NULL 
	DROP TABLE dbo.actualGLDetail

IF OBJECT_ID('expectedInventoryTransaction') IS NOT NULL 
	DROP TABLE expectedInventoryTransaction

IF OBJECT_ID('actualInventoryTransaction') IS NOT NULL 
	DROP TABLE dbo.actualInventoryTransaction
	
IF OBJECT_ID('expectedItemStock') IS NOT NULL 
	DROP TABLE expectedItemStock

IF OBJECT_ID('actualItemStock') IS NOT NULL 
	DROP TABLE dbo.actualItemStock	
	
IF OBJECT_ID('expectedFIFO') IS NOT NULL 
	DROP TABLE expectedFIFO

IF OBJECT_ID('actualFIFO') IS NOT NULL 
	DROP TABLE dbo.actualFIFO