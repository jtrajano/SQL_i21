CREATE PROCEDURE [testi21Database].[test the uspCMAddDeposit stored procedure]
AS
BEGIN
	-- ARRANGE 
	BEGIN 
		-- Constant GL account variables
		DECLARE @BankOfAmerica_Default AS INT = 1000
		DECLARE @MiscExpenses_Default AS INT = 4000
		DECLARE @BankOfAmerica_NewHaven AS INT = 1001
		DECLARE @MiscExpenses_NewHaven AS INT = 4001
		DECLARE @BankOfAmerica_BetterHaven AS INT = 1002
		DECLARE @MiscExpenses_BetterHaven AS INT = 4002	
	
		-- Add fake data
		EXEC [testi21Database].[Fake open fiscal year and accounting periods]
		EXEC [testi21Database].[Fake COA used in Cash Management]		

		-- Arrange the fake table 
		EXEC tSQLt.FakeTable 'dbo.tblCMBankTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblCMBankTransactionDetail';	
		EXEC tSQLt.FakeTable 'dbo.tblCMBankAccount', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;
	
		-- Add fake bank account 	
		INSERT INTO tblCMBankAccount (
				ysnActive
				,intGLAccountId
		)
		SELECT	1
				,@BankOfAmerica_Default

		-- Variables used in calling the stored procedure 
		DECLARE @intBankAccountId AS INT = 1
				,@dtmDate AS DATETIME = GETDATE()
				,@intGLAccountId AS INT = @MiscExpenses_Default
				,@dblAmount AS NUMERIC(18,6) = 496.88
				,@strDescription AS NVARCHAR(255) = 'this is the description'
				,@intUserId AS INT = 4546
				,@isAddSuccessful AS BIT = 0;

		-- Create the actual table
		CREATE TABLE actual (
			intBankAccountId INT
			,dtmDate DATETIME
			,dblAmount NUMERIC(18,6)
			,strMemo NVARCHAR(255) COLLATE Latin1_General_CI_AS
			,intCreatedUserId INT
		)

		-- Create the exepcted table
		CREATE TABLE expected (
			[intBankAccountId]         INT              NOT NULL,
			[dtmDate]                  DATETIME         NOT NULL,
			[dblAmount]                DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
			[strMemo]                  NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
			[intCreatedUserId]         INT              NULL
		)

		-- Setup the expected data. 
		INSERT INTO expected (intBankAccountId, dtmDate, dblAmount, strMemo, intCreatedUserId) 
		SELECT @intBankAccountId, @dtmDate, 496.88, 'this is the description', 4546

		-- Create the actual detail table 
		CREATE TABLE actualDetail (
			[intGLAccountId]	INT              NOT NULL,
			[dblDebit]			DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
			[dblCredit]			DECIMAL (18, 6)  DEFAULT 0 NOT NULL
		)

		-- Create the expected detail table 
		CREATE TABLE dbo.expectedDetail (
			[intGLAccountId]	INT              NOT NULL,
			[dblDebit]			DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
			[dblCredit]			DECIMAL (18, 6)  DEFAULT 0 NOT NULL
		)

		-- Setup the expected detail data
		INSERT INTO expectedDetail (intGLAccountId, dblDebit, dblCredit) SELECT @intGLAccountId, 0, 496.88
	END 

	-- ACT
	BEGIN 
		EXEC dbo.uspCMAddDeposit 
			@intBankAccountId, 
			@dtmDate, 
			@intGLAccountId, 
			@dblAmount, 
			@strDescription, 
			@intUserId, 
			@isAddSuccessful OUTPUT
	END 
			
	-- ASSERT
	BEGIN 
		INSERT	actual
		SELECT	intBankAccountId, dtmDate, dblAmount, strMemo, intCreatedUserId
		FROM	dbo.tblCMBankTransaction	
	 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

		INSERT	actualDetail
		SELECT	intGLAccountId, dblDebit, dblCredit
		FROM	dbo.tblCMBankTransactionDetail

		EXEC tSQLt.AssertEqualsTable 'expectedDetail', 'actualDetail';
	END 
	
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('actualDetail') IS NOT NULL 
		DROP TABLE actualDetail

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
	
	IF OBJECT_ID('expectedDetail') IS NOT NULL 
		DROP TABLE dbo.expectedDetail
END 
