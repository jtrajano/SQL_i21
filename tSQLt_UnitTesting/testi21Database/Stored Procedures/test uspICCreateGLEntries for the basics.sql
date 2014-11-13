CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntries for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for COA used for Items]; 

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;		

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

		DECLARE @intItemId AS INT
				,@intItemLocationId AS INT
				,@intTransactionId AS INT
				,@strTransactionId AS NVARCHAR(40)
				,@strBatchId AS NVARCHAR(20)
				,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
				,@intUserId AS INT
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