﻿CREATE PROCEDURE testi21Database.[test fnGetGLEntriesErrors for error 50005]
AS 
BEGIN
	-- Arrange
	BEGIN 	
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

		DECLARE @InvalidAccountId AS INT = -999999

		-- Create the expected table
		CREATE TABLE expected (
			strTransactionId NVARCHAR(40)
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
			,strModuleName NVARCHAR(50)
		)

		-- Create the actual table
		CREATE TABLE actual (
			strTransactionId NVARCHAR(40)
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
			,strModuleName NVARCHAR(50)
		)

		DECLARE @GLEntries AS RecapTableType

		-- Insert data in GL Entries
		INSERT INTO @GLEntries (
			dtmDate
			,dblExchangeRate
			,dtmDateEntered
			,ysnIsUnposted
			,intConcurrencyId
			,intAccountId
			,strTransactionId
			,dblDebit
			,dblCredit
			,strModuleName 
			,strCode 
			,strTransactionType 
			,strTransactionForm
		)
		SELECT 
			dtmDate = GETDATE()
			,dblExchangeRate = 1
			,dtmDateEntered = GETDATE()
			,ysnIsUnposted = 0
			,intConcurrencyId = 1
			,intAccountId = @Inventory_Default
			,strTransactionId = 'DUMMY-00001'
			,dblDebit = 3
			,dblCredit = 0
			,strModuleName = 'Inventory'
			,strCode = 'IC'
			,strTransactionType = 'Inventory Receipt'
			,strTransactionForm = 'Inventory Receipt'

		UNION ALL 
		SELECT 
			dtmDate = GETDATE()
			,dblExchangeRate = 1
			,dtmDateEntered = GETDATE()
			,ysnIsUnposted = 0
			,intConcurrencyId = 1
			,intAccountId = @Inventory_Default
			,strTransactionId = 'DUMMY-00001'
			,dblDebit = NULL 
			,dblCredit = 3
			,strModuleName = 'Inventory'
			,strCode = 'IC'
			,strTransactionType = 'Inventory Receipt'
			,strTransactionForm = 'Inventory Receipt'

		UNION ALL 
		SELECT 
			dtmDate = GETDATE()
			,dblExchangeRate = 1
			,dtmDateEntered = GETDATE()
			,ysnIsUnposted = 0
			,intConcurrencyId = 1
			,intAccountId = @Inventory_Default
			,strTransactionId = 'DUMMY-00003'
			,dblDebit = 9
			,dblCredit = 0
			,strModuleName = 'Inventory'
			,strCode = 'IC'
			,strTransactionType = 'Inventory Receipt'
			,strTransactionForm = 'Inventory Receipt'

		UNION ALL 
		SELECT 
			dtmDate = GETDATE()
			,dblExchangeRate = 1
			,dtmDateEntered = GETDATE()
			,ysnIsUnposted = 0
			,intConcurrencyId = 1
			,intAccountId = @Inventory_Default
			,strTransactionId = 'DUMMY-00003'
			,dblDebit = NULL 
			,dblCredit = 9
			,strModuleName = 'Inventory'
			,strCode = 'IC'
			,strTransactionType = 'Inventory Receipt'
			,strTransactionForm = 'Inventory Receipt'

		-- Insert the expected data 
		INSERT INTO expected (strTransactionId, strText, intErrorCode, strModuleName) VALUES ('DUMMY-00001', 'Unable to find an open fiscal year period to match the transaction date.', 60004, 'Inventory')
		INSERT INTO expected (strTransactionId, strText, intErrorCode, strModuleName) VALUES ('DUMMY-00003', 'Unable to find an open fiscal year period to match the transaction date.', 60004, 'Inventory')
		INSERT INTO expected (strTransactionId, strText, intErrorCode, strModuleName) VALUES ('DUMMY-00001', 'Unable to find an open fiscal year period for Inventory module to match the transaction date.', 60009, 'Inventory')
		INSERT INTO expected (strTransactionId, strText, intErrorCode, strModuleName) VALUES ('DUMMY-00003', 'Unable to find an open fiscal year period for Inventory module to match the transaction date.', 60009, 'Inventory')


		-- Call the fake data for GL Account 
		EXEC testi21Database.[Fake COA used for fake inventory items];

		-- Create fake data for the fiscal year periods
		EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;
	END 

	-- Act
	BEGIN
		-- Debit and credit amounts are not balanced.
		INSERT INTO actual
		SELECT * FROM dbo.fnGetGLEntriesErrors(@GLEntries)
	END 

	-- Assert
	BEGIN 		
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END