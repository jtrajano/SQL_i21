
CREATE PROCEDURE [dbo].[uspCMPostBankDeposit]
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionId		NVARCHAR(40) = NULL 
	,@strBatchId			NVARCHAR(40) = NULL 
	,@intUserId				INT		= NULL 
	,@intEntityId			INT		= NULL
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
	,@outBatchId 			NVARCHAR(40) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Start the transaction 
BEGIN TRANSACTION

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@BANK_TRANSACTION_TYPE_Id AS INT = 1 			-- Bank Deposit type Id is 1. 
	,@STARTING_NUM_TRANSACTION_TYPE_Id AS INT = 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10) = 'BDEP'		-- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100) = 'Cash Management' -- Module where this posting code belongs. 
	,@TRANSACTION_FORM AS NVARCHAR(100) = 'Bank Deposit'
	,@RETURNVALUE AS INT = 0
	
	-- Local Variables
	,@intTransactionId AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@dblShortAmount AS NUMERIC(18,6)
	,@dblTotalAmount AS NUMERIC(18,6)
	,@intShortGLAccountId AS INT
	,@dblAmountDetailTotal AS NUMERIC(18,6)
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT
	,@intBankAccountId AS INT
	,@ysnBankAccountIdInactive AS BIT
	,@intCreatedEntityId AS INT
	,@ysnAllowUserSelfPost AS BIT = 0
	,@intCurrencyId INT
	,@intDefaultCurrencyId INT
	-- Table Variables
	,@RecapTable AS RecapTableType
	,@GLEntries AS  RecapTableType
	,@ysnForeignTransaction AS BIT
	
	-- CREATE THE TEMPORARY TABLE 
	CREATE TABLE #tmpGLDetail (
		[dtmDate] [datetime] NOT NULL
		,[strBatchId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
		,[intAccountId] [int] NULL
		,[dblDebit] [numeric](18, 6) NULL
		,[dblCredit] [numeric](18, 6) NULL
		,[dblDebitForeign] [numeric](18, 6) NULL
		,[dblCreditForeign] [numeric](18, 6) NULL
		,[dblDebitUnit] [numeric](18, 6) NULL
		,[dblCreditUnit] [numeric](18, 6) NULL
		,[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
		,[strCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
		,[strTransactionId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
		,[intTransactionId] [int] NULL
		,[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
		,[intCurrencyId] [int] NULL
		,[intCurrencyExchangeRateTypeId] [int] NULL
		,[dblExchangeRate] [numeric](38, 20) NOT NULL
		,[dtmDateEntered] [datetime] NOT NULL
		,[dtmTransactionDate] [datetime] NULL
		,[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
		,[intJournalLineNo] [int]
		,[ysnIsUnposted] [bit] NOT NULL
		,[intUserId] [int] NULL
		,[intEntityId] [int] NULL
		,[strTransactionType] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
		,[strTransactionForm] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
		,[strModuleName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL		
		,[intConcurrencyId] [int] NULL
	)
	
-- Note: 
-- 1. Table variables (such as @RecapTable) are unaffected by COMMIT or ROLLBACK TRANSACTION.
-- 2. Temp tables (such as #tmpGLDetail) are affected by COMMIT and ROLLBACK TRANSACTION. 
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read the header table and populate the variables. 
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

SELECT	TOP 1 
		@intTransactionId = intTransactionId
		,@dtmDate = dtmDate
		,@dblAmount = dblAmount
		,@dblShortAmount = dblShortAmount
		,@dblTotalAmount = ISNULL(dblAmount, 0) + ISNULL(dblShortAmount,0)
		,@intShortGLAccountId = intShortGLAccountId
		,@ysnTransactionPostedFlag = ysnPosted
		,@ysnTransactionClearedFlag = ysnClr
		,@intBankAccountId = intBankAccountId
		,@intCreatedEntityId = intEntityId
		,@intCurrencyId = intCurrencyId
		,@ysnForeignTransaction = CASE WHEN @intDefaultCurrencyId <> @intCurrencyId THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM	[dbo].tblCMBankTransaction 
WHERE	strTransactionId = @strTransactionId 
		AND intBankTransactionTypeId = @BANK_TRANSACTION_TYPE_Id


IF @@ERROR <> 0	GOTO Post_Rollback				

-- Read the user preference
SELECT	@ysnAllowUserSelfPost = 1
FROM	dbo.tblSMUserPreference 
WHERE	ysnAllowUserSelfPost = 1 
		AND [intEntityUserSecurityId] = @intEntityId
IF @@ERROR <> 0	GOTO Post_Rollback		
		
-- Read the detail table and populate the variables. 
SELECT	@dblAmountDetailTotal = SUM(ISNULL(dblCredit, 0) - ISNULL(dblDebit, 0))
FROM	[dbo].tblCMBankTransactionDetail
WHERE	intTransactionId = @intTransactionId 
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the bank deposit id exists. 
IF @intTransactionId IS NULL
BEGIN 
	-- Cannot find the transaction.
	RAISERROR('Cannot find the transaction.', 11, 1)
	GOTO Post_Rollback
END 

IF @ysnRecap = 0
BEGIN
	IF @ysnPost = 1 AND NOT EXISTS(SELECT TOP 1 1 FROM tblCMBankTransactionDetail where  intTransactionId = @intTransactionId )
	BEGIN
		RAISERROR('Cannot post an empty detail transaction.', 11, 1)
		GOTO Post_Rollback
	END
	
-- Validate the date against the FY Periods
	IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0)
	BEGIN 
		-- Unable to find an open fiscal year period to match the transaction date.
		RAISERROR('Unable to find an open fiscal year period to match the transaction date.', 11, 1)
		GOTO Post_Rollback
	END

	-- Validate the date against the FY Periods per module
	IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDateByModule(@dtmDate,@MODULE_NAME) = 0)
	BEGIN 
		-- Unable to find an open fiscal year period to match the transaction date and the given module.
		IF @ysnPost = 1
		BEGIN
			--You cannot %s transaction under a closed module.
			RAISERROR('You cannot %s transaction under a closed module.', 11, 1, 'Post')
			GOTO Post_Rollback
		END
		ELSE
		BEGIN
			--You cannot %s transaction under a closed module.
			RAISERROR('You cannot %s transaction under a closed module.', 11, 1, 'Unpost')
			GOTO Post_Rollback
		END
	END

	-- Check the bank deposit balance. 
	IF ISNULL(@dblAmountDetailTotal, 0) <> ISNULL(@dblTotalAmount, 0)
	BEGIN
		-- The debit and credit amounts are not balanced.
		RAISERROR('The debit and credit amounts are not balanced.', 11, 1)
		GOTO Post_Rollback
	END 

	-- Check if the transaction is already posted
	IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1
	BEGIN 
		-- The transaction is already posted.
		RAISERROR('The transaction is already posted.', 11, 1)
		GOTO Post_Rollback
	END 

	-- Check if the transaction is already unposted
	IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0
	BEGIN 
		-- The transaction is already unposted.
		RAISERROR('The transaction is already unposted.', 11, 1)
		GOTO Post_Rollback
	END 

	-- Check if the transaction is already reconciled
	IF @ysnPost = 0 AND @ysnTransactionClearedFlag = 1
	BEGIN
		-- 'The transaction is already cleared.'
		RAISERROR('The transaction is already cleared.', 11, 1)
		GOTO Post_Rollback
	END

	-- Check if the bank account is inactive
	SELECT	@ysnBankAccountIdInactive = 1
	FROM	tblCMBankAccount
	WHERE	intBankAccountId = @intBankAccountId
			AND (ysnActive = 0 OR intGLAccountId IN (SELECT intAccountId FROM tblGLAccount WHERE ysnActive = 0))
	
	IF @ysnBankAccountIdInactive = 1
	BEGIN
		-- 'The bank account is inactive.'
		RAISERROR('The bank account or its associated GL account is inactive.', 11, 1)
		GOTO Post_Rollback
	END
	-- Check Company preference: Allow User Self Post
	IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId
	BEGIN 
		-- 'You cannot %s transactions you did not create. Please contact your local administrator.'
		IF @ysnPost = 1	
		BEGIN 
			RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Post')
			GOTO Post_Rollback
		END 
		IF @ysnPost = 0
		BEGIN
			RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Unpost')
			GOTO Post_Rollback		
		END
	END 

	-- Check if amount in detail has zero value. 
	IF EXISTS (SELECT TOP 1 1 
		FROM tblCMBankTransaction A	JOIN  tblCMBankTransactionDetail B 
		ON A.intTransactionId = B.intTransactionId
		WHERE A.intTransactionId = @intTransactionId AND B.dblDebit = 0 AND B.dblCredit = 0	AND @ysnPost = 1)
	BEGIN
		RAISERROR('Cannot post zero-value transaction detail.', 11, 1)
		GOTO Post_Rollback
	END
	
END --@ysnRecap = 0

--Check if the header date is less than detail date
IF EXISTS (
	SELECT TOP 1 * FROM tblCMBankTransaction A
	INNER JOIN  tblCMBankTransactionDetail B ON A.intTransactionId = B.intTransactionId
	WHERE strTransactionId = @strTransactionId
	AND DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0) < DATEADD(dd, DATEDIFF(dd, 0, B.dtmDate), 0)
)
BEGIN
	RAISERROR('Date must be equal or greater than detail date.', 11, 1)
	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	PROCESSING OF THE UNDEPOSITED FUNDS
---------------------------------------------------------------------------------------------------------------------------------------

IF (@ysnRecap = 0)
BEGIN 
	EXEC uspCMProcessUndepositedFunds @ysnPost, @intBankAccountId, @strTransactionId, @intUserId, @isSuccessful OUTPUT 
	IF @isSuccessful = 0 GOTO Post_Rollback
END 

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
IF (@strBatchId IS NULL)
BEGIN
	--EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchId OUTPUT 
	--IF @@ERROR <> 0	GOTO Post_Rollback

	IF (@ysnRecap = 0)
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchId OUTPUT 
	ELSE
		SELECT @strBatchId = NEWID()

	SELECT @outBatchId = @strBatchId
	IF @@ERROR <> 0	GOTO Post_Rollback
End

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Bank Deposit. 
	INSERT INTO #tmpGLDetail (
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[ysnIsUnposted]
			,[intConcurrencyId]
			,[intUserId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intEntityId]
	)
	-- 1. DEBIT SIDE
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= BankAccnt.intGLAccountId
			,[dblDebit]				= CASE WHEN @ysnForeignTransaction = 0 THEN A.dblAmount ELSE ROUND(A.dblAmount * A.dblExchangeRate,2) END 
			,[dblCredit]			= 0
			,[dblDebitForeign]		= CASE WHEN @ysnForeignTransaction = 0 THEN 0 ELSE A.dblAmount END
			,[dblCreditForeign]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo 
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= ISNULL(Entity.strName, A.strPayee)
			,[intCurrencyId]		= A.intCurrencyId
			,[intCurrencyExchangeRateTypeId] =  A.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= ISNULL(A.dblExchangeRate,1)
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionType]	= @TRANSACTION_FORM
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankAccount BankAccnt
				ON A.intBankAccountId = BankAccnt.intBankAccountId
			INNER JOIN tblGLAccount GLAccnt
				ON BankAccnt.intGLAccountId = GLAccnt.intAccountId
			LEFT JOIN [dbo].tblEMEntity Entity
				ON A.intPayeeId = Entity.intEntityId
	WHERE	A.strTransactionId = @strTransactionId

	--1.5 DEBIT SIDE SHORT
	UNION ALL
	SELECT	[strTransactionId]		= @strTransactionId 
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= A.intShortGLAccountId
			,[dblDebit]				= CASE WHEN @ysnForeignTransaction = 0 THEN A.dblShortAmount ELSE ROUND(A.dblShortAmount * A.dblExchangeRate,2) END --A.dblShortAmount * ISNULL(A.dblExchangeRate,1)
			,[dblCredit]			= 0
			,[dblDebitForeign]		= CASE WHEN @ysnForeignTransaction = 0 THEN 0 ELSE A.dblShortAmount  END
			,[dblCreditForeign]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= ISNULL(Entity.strName, A.strPayee)
			,[intCurrencyId]		= A.intCurrencyId
			,[intCurrencyExchangeRateTypeId] =  A.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= ISNULL(A.dblExchangeRate,1)
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionType]	= @TRANSACTION_FORM
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankAccount BankAccnt
				ON A.intBankAccountId = BankAccnt.intBankAccountId
			INNER JOIN tblGLAccount GLAccnt
				ON A.intShortGLAccountId = GLAccnt.intAccountId
			LEFT JOIN [dbo].tblEMEntity Entity
				ON A.intPayeeId = Entity.intEntityId
	WHERE	A.strTransactionId = @strTransactionId AND A.intShortGLAccountId IS NOT NULL AND A.intShortGLAccountId <> 0 AND A.dblShortAmount <> 0
	
	-- 2. CREDIT SIdE
	UNION ALL 
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= B.intGLAccountId
			,[dblDebit]				= CASE WHEN @ysnForeignTransaction = 0 THEN B.dblDebit ELSE ROUND(B.dblDebit * B.dblExchangeRate,2) END
			,[dblCredit]			= CASE WHEN @ysnForeignTransaction = 0 THEN B.dblCredit ELSE ROUND(B.dblCredit * B.dblExchangeRate,2) END
			,[dblDebitForeign]		= CASE WHEN @ysnForeignTransaction = 0 THEN 0 ELSE B.dblDebit END
			,[dblCreditForeign]		= CASE WHEN @ysnForeignTransaction = 0 THEN 0 ELSE B.dblCredit END
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= Entity.strEntityNo
			,[intCurrencyId]		= A.intCurrencyId
			,[intCurrencyExchangeRateTypeId] =  B.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= CASE WHEN @ysnForeignTransaction = 0 THEN 1 ELSE B.dblExchangeRate END
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionType]	= @TRANSACTION_FORM
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransaction A 
	INNER JOIN [dbo].tblCMBankTransactionDetail B
				ON A.intTransactionId = B.intTransactionId
			INNER JOIN tblGLAccount GLAccnt
				ON B.intGLAccountId = GLAccnt.intAccountId
			LEFT JOIN [dbo].tblEMEntity Entity
				ON B.intEntityId = Entity.intEntityId
	WHERE	A.strTransactionId = @strTransactionId

	DECLARE @gainLoss DECIMAL (18,6)
	SELECT @gainLoss = SUM(dblDebit - dblCredit) from #tmpGLDetail WHERE dblExchangeRate <> 1

	if(@gainLoss <> 0  AND @ysnForeignTransaction = 1)
		EXEC [uspCMInsertGainLossBankTransfer] @strDescription = 'Gain / Loss on Multicurrency Bank Deposit'
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table

	
END -- @ysnPost = 1
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC dbo.uspCMReverseGLEntries @strTransactionId, @GL_DETAIL_CODE, NULL, @intUserId, @strBatchId
	IF @@ERROR <> 0	GOTO Post_Rollback
	

	--RESET GENERATION FLAGS IN UNDEPOSITED TABLE
	UPDATE Undeposited SET ysnGenerated =0 , intBankFileAuditId = null
	FROM tblCMUndepositedFund Undeposited
	JOIN tblCMBankTransactionDetail B on B.intUndepositedFundId = Undeposited.intUndepositedFundId
	JOIN tblCMBankTransaction A on A.intTransactionId = B.intTransactionId
	WHERE A.strTransactionId = @strTransactionId
	AND @ysnRecap = 0
	-- Update the posted flag in the transaction table
	
END-- @ysnPost = 0

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The G/L Ledger detail table)
---------------------------------------------------------------------------------------------------------------------------------------
--EXEC dbo.uspCMBookGLEntries @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
--IF @isSuccessful = 0 GOTO Post_Rollback
IF @ysnRecap = 0
BEGIN
	INSERT INTO @GLEntries(
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]	
			) 
SELECT
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]	 
FROM #tmpGLDetail


	DECLARE @PostResult INT
	EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = @ysnPost, @SkipICValidation = 1
		
	IF @@ERROR <> 0	OR @PostResult <> 0 GOTO Post_Rollback

	UPDATE 	A 
	SET		ysnPosted = @ysnPost
			,intFiscalPeriodId = F.intFiscalPeriodId
			,intConcurrencyId += 1 
	FROM tblCMBankTransaction A
	CROSS APPLY dbo.fnGLGetFiscalPeriod(A.dtmDate) F
	WHERE	strTransactionId = @strTransactionId

	IF @@ERROR <> 0	GOTO Post_Rollback
END -- @ysnRecap = 0

--=====================================================================================================================================
-- 	Check if process is only a RECAP
---------------------------------------------------------------------------------------------------------------------------------------
IF @ysnRecap = 1 
BEGIN	
	-- INSERT THE DATA FROM #tmpGLDetail TO @RecapTable
	INSERT INTO @RecapTable (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
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
	SELECT	[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
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
	FROM	#tmpGLDetail
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	GOTO Recap_Rollback
END

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	SET @message_id = 10000
	SET @isSuccessful = 1
	COMMIT TRANSACTION
	GOTO Audit_Log
	GOTO Post_Exit

-- If error occured, undo changes to all tables affected
Post_Rollback:
	SET @isSuccessful = 0
	ROLLBACK TRANSACTION
	GOTO Post_Exit
	
Recap_Rollback: 
	SET @isSuccessful = 1
	ROLLBACK TRANSACTION 		
	--EXEC dbo.uspCMPostRecap @RecapTable
		EXEC dbo.uspGLPostRecap 
			@RecapTable
			,@intEntityId
	GOTO Post_Exit

Audit_Log:
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
   
	EXEC uspSMAuditLog 
	   @keyValue = @intTransactionId       -- Primary Key Value of the Bank Deposit. 
	   ,@screenName = 'CashManagement.view.BankDeposit'        -- Screen Namespace
	   ,@entityId = @intUserId     -- Entity Id.
	   ,@actionType = @actionType                             -- Action Type
	   ,@changeDescription = @strDescription     -- Description
	   ,@fromValue = ''          -- Previous Value
	   ,@toValue = ''           -- New Value
		
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail
  
