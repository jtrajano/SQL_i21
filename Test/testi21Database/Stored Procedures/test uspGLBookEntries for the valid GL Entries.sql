﻿CREATE PROCEDURE [testi21Database].[test uspGLBookEntries for the valid GL Entries]
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

		DECLARE @date AS DATETIME = GETDATE()
		DECLARE @USD AS INT = 1
		DECLARE @UserId AS INT = 1000
		DECLARE @EntityId AS INT = 2000

		DECLARE @strTransactionId AS NVARCHAR(40) = 'DUMMY-00001'
		DECLARE @intTransactionId AS INT = 111

		-- Fake these tables
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail';
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary';

		-- Add fake data
		EXEC testi21Database.[Fake COA used for fake inventory items];
		EXEC testi21Database.[Fake open fiscal year and accounting periods];

		-- Add the expected tables 
		SELECT *
		INTO expected_tblGLDetail 
		FROM dbo.tblGLDetail

		SELECT *
		INTO expected_tblGLSummary
		FROM dbo.tblGLSummary

		DECLARE @GLEntries AS RecapTableType
		DECLARE @ysnPost AS BIT = 1

		-- Add the valid GL entries
		INSERT INTO @GLEntries(
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
		SELECT	[dtmDate] = @date
				,[strBatchId] = 'BATCH-0001'
				,[intAccountId] = @Inventory_Default
				,[dblDebit] = 1000
				,[dblCredit] = 0
				,[dblDebitUnit] = 0 
				,[dblCreditUnit] = 0
				,[strDescription] = 'This is the description'
				,[strCode] = 'Code'
				,[strReference] = 'Reference'
				,[intCurrencyId] = @USD
				,[dblExchangeRate] = 1
				,[dtmDateEntered] = @date
				,[dtmTransactionDate] = @date
				,[strJournalLineDescription] = 'Journal Description'
				,[intJournalLineNo] = 1
				,[ysnIsUnposted] = 0
				,[intUserId] = @UserId
				,[intEntityId] = @EntityId
				,[strTransactionId] = @strTransactionId
				,[intTransactionId] = @intTransactionId
				,[strTransactionType] = 'TRANSACTION TYPE'
				,[strTransactionForm] = 'TRANSACTION FORM'
				,[strModuleName] = 'Inventory'
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[dtmDate] = @date
				,[strBatchId] = 'BATCH-0001'
				,[intAccountId] = @Inventory_Default
				,[dblDebit] = 0
				,[dblCredit] = 1000
				,[dblDebitUnit] = 0 
				,[dblCreditUnit] = 0
				,[strDescription] = 'This is the description'
				,[strCode] = 'Code'
				,[strReference] = 'Reference'
				,[intCurrencyId] = @USD
				,[dblExchangeRate] = 1
				,[dtmDateEntered] = @date
				,[dtmTransactionDate] = @date
				,[strJournalLineDescription] = 'Journal Description'
				,[intJournalLineNo] = 1
				,[ysnIsUnposted] = 0
				,[intUserId] = @UserId
				,[intEntityId] = @EntityId
				,[strTransactionId] = @strTransactionId
				,[intTransactionId] = @intTransactionId
				,[strTransactionType] = 'TRANSACTION TYPE'
				,[strTransactionForm] = 'TRANSACTION FORM'
				,[strModuleName] = 'Inventory'
				,[intConcurrencyId] = 1

		-- Insert the expected tblGLDetail data. 
		INSERT INTO expected_tblGLDetail (
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
		)
		SELECT	[dtmDate] = dbo.fnRemoveTimeOnDate(@date)
				,[strBatchId] = 'BATCH-0001'
				,[intAccountId] = @Inventory_Default
				,[dblDebit] = 1000
				,[dblCredit] = 0
				,[dblDebitUnit] = 0 
				,[dblCreditUnit] = 0
				,[strDescription] = 'This is the description'
				,[strCode] = 'Code'
				,[strReference] = 'Reference'
				,[intCurrencyId] = @USD
				,[dblExchangeRate] = 1
				,[dtmDateEntered] = @date
				,[dtmTransactionDate] = dbo.fnRemoveTimeOnDate(@date)
				,[strJournalLineDescription] = 'Journal Description'
				,[intJournalLineNo] = 1
				,[ysnIsUnposted] = 0
				,[intUserId] = @UserId
				,[intEntityId] = @EntityId
				,[strTransactionId] = @strTransactionId
				,[intTransactionId] = @intTransactionId
				,[strTransactionType] = 'TRANSACTION TYPE'
				,[strTransactionForm] = 'TRANSACTION FORM'
				,[strModuleName] = 'Inventory'
				,[intConcurrencyId] = 1
				,[dblDebitForeign] = 0
				,[dblDebitReport] = 0
				,[dblCreditForeign] = 0
				,[dblCreditReport] = 0
				,[dblReportingRate] = 0
		UNION ALL 
		SELECT	[dtmDate] = dbo.fnRemoveTimeOnDate(@date)
				,[strBatchId] = 'BATCH-0001'
				,[intAccountId] = @Inventory_Default
				,[dblDebit] = 0
				,[dblCredit] = 1000
				,[dblDebitUnit] = 0 
				,[dblCreditUnit] = 0
				,[strDescription] = 'This is the description'
				,[strCode] = 'Code'
				,[strReference] = 'Reference'
				,[intCurrencyId] = @USD
				,[dblExchangeRate] = 1
				,[dtmDateEntered] = @date
				,[dtmTransactionDate] = dbo.fnRemoveTimeOnDate(@date)
				,[strJournalLineDescription] = 'Journal Description'
				,[intJournalLineNo] = 1
				,[ysnIsUnposted] = 0
				,[intUserId] = @UserId
				,[intEntityId] = @EntityId
				,[strTransactionId] = @strTransactionId
				,[intTransactionId] = @intTransactionId
				,[strTransactionType] = 'TRANSACTION TYPE'
				,[strTransactionForm] = 'TRANSACTION FORM'
				,[strModuleName] = 'Inventory'
				,[intConcurrencyId] = 1
				,[dblDebitForeign] = 0
				,[dblDebitReport] = 0
				,[dblCreditForeign] = 0
				,[dblCreditReport] = 0
				,[dblReportingRate] = 0

			INSERT INTO expected_tblGLSummary (
				intAccountId
				,dtmDate
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strCode
				,intConcurrencyId			
			)
			VALUES (
				@Inventory_Default
				,dbo.fnRemoveTimeOnDate(@date)
				,1000
				,1000
				,0
				,0
				,'Code'
				,1
			)
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspGLBookEntries 
			@GLEntries
			,@ysnPost
	END 	

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected_tblGLDetail', 'tblGLDetail';
		EXEC tSQLt.AssertEqualsTable 'expected_tblGLSummary', 'tblGLSummary';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('expected_tblGLDetail') IS NOT NULL 
		DROP TABLE expected_tblGLDetail

	IF OBJECT_ID('expected_tblGLSummary') IS NOT NULL 
		DROP TABLE expected_tblGLSummary
END