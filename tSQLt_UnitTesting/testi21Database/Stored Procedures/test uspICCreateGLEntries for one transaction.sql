CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntries for one transaction]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for COA used for Items]; 

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3

		DECLARE @PurchaseType AS INT = 1

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

		INSERT INTO tblICInventoryTransaction (
				intItemId
				,intItemLocationId
				,dtmDate
				,dblUnitQty
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
		)
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = @NewHaven
				,dtmDate = 'January 12, 2014'
				,dblUnitQty = 1
				,dblCost = 12.00
				,dblValue = 0
				,dblSalesPrice = 0
				,intCurrencyId = @USD
				,dblExchangeRate = 1
				,intTransactionId = 1
				,strTransactionId = 'PURCHASE-00001'
				,strBatchId = 'BATCH-000001'
				,intTransactionTypeId = @PurchaseType
				,intLotId = NULL 
				,dtmCreated = GETDATE()
				,intCreatedUserId = 1
				,intConcurrencyId = 1

		CREATE TABLE expected (
			strTransactionId NVARCHAR(40)
			,intTransactionId INT
			,dtmDate DATETIME 
			,strBatchId NVARCHAR(20)
			,intAccountId INT
			,dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
			,dblDebitUnit NUMERIC(18,6)
			,dblCreditUnit NUMERIC(18,6)
			,strDescription NVARCHAR(255)
			,strCode NVARCHAR(20)
			,strReference NVARCHAR(20)
			,intCurrencyId INT
			,dblExchangeRate NUMERIC(18,6)
			,dtmDateEntered DATETIME
			,dtmTransactionDate DATETIME
			,strJournalLineDescription NVARCHAR(255)
			,intJournalLineNo INT
			,ysnIsUnposted BIT
			,intUserId INT 
			,intEntityId INT
			,strTransactionForm NVARCHAR(255)
			,strModuleName NVARCHAR(255)
			,intConcurrencyId INT 
		)

		CREATE TABLE actual (
			strTransactionId NVARCHAR(40)
			,intTransactionId INT
			,dtmDate DATETIME 
			,strBatchId NVARCHAR(20)
			,intAccountId INT
			,dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
			,dblDebitUnit NUMERIC(18,6)
			,dblCreditUnit NUMERIC(18,6)
			,strDescription NVARCHAR(255)
			,strCode NVARCHAR(20)
			,strReference NVARCHAR(20)
			,intCurrencyId INT
			,dblExchangeRate NUMERIC(18,6)
			,dtmDateEntered DATETIME
			,dtmTransactionDate DATETIME
			,strJournalLineDescription NVARCHAR(255)
			,intJournalLineNo INT
			,ysnIsUnposted BIT
			,intUserId INT 
			,intEntityId INT
			,strTransactionForm NVARCHAR(255)
			,strModuleName NVARCHAR(255)
			,intConcurrencyId INT 
		)

		DECLARE @intItemId AS INT = @StickyGrains
				,@intItemLocationId AS INT = @NewHaven 
				,@intTransactionId AS INT = 1
				,@strTransactionId AS NVARCHAR(40) = 'PURCHASE-00001'
				,@strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
				,@intUserId AS INT = 1
	END 
	
	-- Act
	BEGIN 
		INSERT INTO actual 
		EXEC dbo.uspICCreateGLEntries
			@intItemId
			,@intItemLocationId
			,@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@UseGLAccount_ContraInventory
			,@intUserId
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