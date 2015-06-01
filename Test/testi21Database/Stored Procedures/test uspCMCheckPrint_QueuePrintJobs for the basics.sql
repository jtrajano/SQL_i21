CREATE PROCEDURE [testi21Database].[test uspCMCheckPrint_QueuePrintJobs for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Constant GL account variables
		DECLARE @BankOfAmerica_Default AS INT = 1000
		DECLARE @MiscExpenses_Default AS INT = 4000
		DECLARE @BankOfAmerica_NewHaven AS INT = 1001
		DECLARE @MiscExpenses_NewHaven AS INT = 4001
		DECLARE @BankOfAmerica_BetterHaven AS INT = 1002
		DECLARE @MiscExpenses_BetterHaven AS INT = 4002	

		DECLARE -- Constant variables for bank account types:
			@BANK_DEPOSIT INT = 1
			,@BANK_WITHDRAWAL INT = 2
			,@MISC_CHECKS INT = 3
			,@AP_PAYMENT AS INT = 16
			,@CASH_PAYMENT AS NVARCHAR(20) = 'Cash'

		-- Add fake data
		EXEC [testi21Database].[Fake COA used in Cash Management]
		
		-- Arrange the fake table 
		EXEC tSQLt.FakeTable 'dbo.tblCMBankTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblCMBankTransactionDetail';	
		EXEC tSQLt.FakeTable 'dbo.tblCMBankAccount', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblCMCheckNumberAudit', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblCMCheckPrintJobSpool', @Identity = 1;

		-- Add fake bank account 	
		INSERT INTO tblCMBankAccount (
				ysnActive
				,intGLAccountId
				,intCheckNextNo
		)
		SELECT	1
				,@BankOfAmerica_Default
				,1000

		DECLARE	@intBankAccountId INT = 1,
				@strTransactionId NVARCHAR(40) = 'MISC-100001',
				@strBatchId NVARCHAR(20),
				@intTransactionType INT = @MISC_CHECKS,
				@intUserId INT = 1

		-- Add fake bank transaction 
		INSERT INTO tblCMBankTransaction (
			strTransactionId
			,intBankTransactionTypeId
			,intBankAccountId
			,dtmDate
			,dblAmount
			,ysnPosted
			,ysnClr
			,ysnCheckToBePrinted
			,strReferenceNo
		)
		VALUES (
			@strTransactionId
			,@MISC_CHECKS
			,@intBankAccountId
			,'01/01/2014'
			,100.00
			,1
			,0
			,1
			,'000001'
		)

		SELECT * INTO expected FROM tblCMCheckPrintJobSpool WHERE 1 = 0
		SELECT * INTO actual FROM tblCMCheckPrintJobSpool WHERE 1 = 0
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspCMCheckPrint_QueuePrintJobs
			@intBankAccountId
			, @strTransactionId
			, @strBatchId
			, @intTransactionType
			, @intUserId
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
