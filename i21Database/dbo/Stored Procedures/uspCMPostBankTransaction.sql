CREATE PROCEDURE [dbo].[uspCMPostBankTransaction]
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionId		NVARCHAR(40) = NULL 
	,@strBatchId			NVARCHAR(40) = NULL 
	,@intUserId				INT		= NULL 
	,@intEntityId			INT		= NULL
	,@ysnCMScreen			BIT		= 0
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
	,@outBatchId 			NVARCHAR(40) = NULL OUTPUT
	,@ysnBatch				BIT		= 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Start the transaction 
BEGIN TRANSACTION

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

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@STARTING_NUM_TRANSACTION_TYPE_Id AS INT = 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@MODULE_NAME AS NVARCHAR(100) = 'Cash Management' -- Module where this posting code belongs. 
	,@TRANSACTION_FORM AS NVARCHAR(100) = 'Bank Transactions'

	-- Transaction type related variables
	,@BANK_TRANSACTION_TYPE_Id AS INT = 5 			-- (Default) Bank Transaction type id is 5 (See tblCMBankTransactionType). 
	,@GL_DETAIL_CODE AS NVARCHAR(10) = 'BTRN'		-- (Default) String code used in GL Detail table. 
	,@STARTING_NUMBER_TRANS_TYPE AS NVARCHAR(100) = ''
	
	,@BANK_DEPOSIT INT = 1
	,@BANK_WITHDRAWAL INT = 2
	,@MISC_CHECKS INT = 3
	,@BANK_TRANSFER INT = 4
	,@BANK_TRANSACTION INT = 5
	,@CREDIT_CARD_CHARGE INT = 6
	,@CREDIT_CARD_RETURNS INT = 7
	,@CREDIT_CARD_PAYMENTS INT = 8
	,@BANK_TRANSFER_WD INT = 9
	,@BANK_TRANSFER_DEP INT = 10
	,@ORIGIN_DEPOSIT AS INT = 11
	,@ORIGIN_CHECKS AS INT = 12
	,@ORIGIN_EFT AS INT = 13
	,@ORIGIN_WITHDRAWAL AS INT = 14
	,@ORIGIN_WIRE AS INT = 15
	,@AP_PAYMENT AS INT = 16
    ,@BANK_STMT_IMPORT AS INT = 17
	,@AR_PAYMENT AS INT = 18
	,@VOID_CHECK AS INT = 19
	,@AP_ECHECK AS INT = 20
	,@PAYCHECK AS INT = 21
	
	-- Local Variables
	,@intTransactionId AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@dblAmountDetailTotal AS NUMERIC(18,6)
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT	
	,@intBankAccountId AS INT
	,@ysnBankAccountActive AS BIT
	,@intCreatedEntityId AS INT
	,@ysnAllowUserSelfPost AS BIT = 0
	,@ysnPOS AS BIT
	
	-- Table Variables
	,@RecapTable AS RecapTableType
	,@GLEntries AS RecapTableType	
	,@intDefaultCurrencyId INT 
	,@intCurrencyId INT
	,@dblExchangeRate DECIMAL(18,6)
	,@ysnForeignTransaction AS BIT = 0 
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------
SELECT TOP 1  @intDefaultCurrencyId= intDefaultCurrencyId FROM tblSMCompanyPreference 
-- Read the header table and populate the variables. 
SELECT	TOP 1 
		@intTransactionId = intTransactionId
		,@dtmDate = dtmDate
		,@dblAmount = dblAmount
		,@ysnTransactionPostedFlag = ysnPosted
		,@BANK_TRANSACTION_TYPE_Id = intBankTransactionTypeId -- Retrieve the ACTUAL transaction type id used in the transaction. 
		,@ysnTransactionClearedFlag = ysnClr
		,@intBankAccountId = intBankAccountId
		,@intCreatedEntityId = intEntityId
		,@intCurrencyId = intCurrencyId
		,@ysnPOS = ysnPOS
		,@dblExchangeRate = ISNULL(dblExchangeRate,1)
		,@ysnForeignTransaction = CASE WHEN @intDefaultCurrencyId <> intCurrencyId THEN CAST(1 as bit) ELSE CAST(0 AS BIT) END
FROM	[dbo].tblCMBankTransaction 
WHERE	strTransactionId = @strTransactionId 


IF @@ERROR <> 0	GOTO Post_Rollback		

-- Read the user preference
SELECT	@ysnAllowUserSelfPost = 1
FROM	dbo.tblSMUserPreference 
WHERE	ysnAllowUserSelfPost = 1 
		AND [intEntityUserSecurityId] = @intUserId
IF @@ERROR <> 0	GOTO Post_Rollback		
		
-- Read the detail table and populate the variables. 
SELECT	@dblAmountDetailTotal = ISNULL(SUM(ISNULL(dblCredit, 0) - ISNULL(dblDebit, 0)), 0)
FROM	[dbo].tblCMBankTransactionDetail
WHERE	intTransactionId = @intTransactionId 
IF @@ERROR <> 0	GOTO Post_Rollback		

-- Determine the CODE to use based from the bank transaction type. 
SELECT	@STARTING_NUMBER_TRANS_TYPE = strBankTransactionTypeName
FROM	dbo.tblCMBankTransactionType
WHERE	intBankTransactionTypeId = @BANK_TRANSACTION_TYPE_Id

SELECT	@GL_DETAIL_CODE = REPLACE(strPrefix, '-', '')
FROM	dbo.tblSMStartingNumber
WHERE	strTransactionType = @STARTING_NUMBER_TRANS_TYPE

SELECT	@MODULE_NAME = strModule
FROM	dbo.tblSMStartingNumber
WHERE	strTransactionType = @STARTING_NUMBER_TRANS_TYPE

IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the bank transaction id exists. 
IF @intTransactionId IS NULL
BEGIN 
	-- Cannot find the transaction.
	RAISERROR('Cannot find the transaction.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already posted
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1
BEGIN 
	-- The transaction is already posted.
	RAISERROR('The transaction is already posted.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already posted
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0
BEGIN 
	-- The transaction is already unposted.
	RAISERROR('The transaction is already unposted.', 11, 1)
	GOTO Post_Rollback
END 

-- Unposting a POS posted transaction is not allowed
IF @ysnPost = 0 AND @ysnPOS = 1
BEGIN 
	-- The transaction is already unposted.
	RAISERROR('POS transaction is not allowed to be unposted.', 11, 1)
	GOTO Post_Rollback
END 

IF @ysnCMScreen = 1
BEGIN
	DECLARE @ccrTransId NVARCHAR(20) = '', @ysnPostedCC BIT
	SELECT TOP 1  @ccrTransId = strCcdReference, @ysnPostedCC = ISNULL(CC.ysnPosted,0) FROM tblCCSiteHeader CC JOIN tblCMBankTransaction CM ON CM.intTransactionId = CC.intCMBankTransactionId AND @strTransactionId = CM.strTransactionId
	IF (ISNULL(@ccrTransId, '') <> '')
	BEGIN
		IF @ysnPost = 0 
			BEGIN
			IF @ysnPostedCC = 1
				RAISERROR('Unposting Not Allowed. Please unpost Dealer Credit Card %s', 11, 1, @ccrTransId)
				GOTO Post_Rollback	
			END
		ELSE
		BEGIN
			IF @ysnPostedCC = 0
			BEGIN
				RAISERROR('Posting Not Allowed. Please post Dealer Credit Card %s', 11, 1, @ccrTransId)
				GOTO Post_Rollback	
			END
		END
	END
END


IF @ysnRecap = 0
BEGIN
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

	-- Check the bank transaction balance. 
	IF ISNULL(@dblAmountDetailTotal, 0) <> ISNULL(@dblAmount, 0)
	BEGIN
		-- The debit and credit amounts are not balanced.
		RAISERROR('The debit and credit amounts are not balanced.', 11, 1)
		GOTO Post_Rollback
	END 
	
	-- Check if the transaction is already reconciled
	IF @ysnPost = 0 AND @ysnTransactionClearedFlag = 1
	BEGIN
		-- 'The transaction is already cleared.'
		RAISERROR('The transaction is already cleared.', 11, 1)
		GOTO Post_Rollback
	END

	DECLARE @GLAccountSetupIsValid INT = 0

	SELECT	@GLAccountSetupIsValid = COUNT(1),	@ysnBankAccountActive=ISNULL(CM.ysnActive,0) & ISNULL(GL.ysnActive,0)
	FROM	tblCMBankAccount CM JOIN vyuGLAccountDetail GL 
	ON GL.intAccountId = CM.intGLAccountId
	WHERE	intBankAccountId = @intBankAccountId
	GROUP BY intBankAccountId, CM.ysnActive, GL.ysnActive

	IF @ysnBankAccountActive = 0
	BEGIN
			-- 'The bank account is inactive.'
			RAISERROR('The bank account or its associated GL account is inactive.', 11, 1)
			GOTO Post_Rollback
		END
	IF (@GLAccountSetupIsValid = 0)
	BEGIN
	RAISERROR('The GL Account associated with the bank has invalid setup or non existent.', 11, 1)
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


	-- Check if amount is zero. 
	IF @dblAmount = 0 AND @ysnPost = 1
		BEGIN 
		-- Cannot post a zero-value transaction.
		RAISERROR('Cannot post a zero-value transaction.', 11, 1)
		GOTO Post_Rollback
	END 

END

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
IF (@strBatchId IS NULL)
BEGIN
	IF (@ysnRecap = 0)
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchId OUTPUT 
	ELSE
		SELECT @strBatchId = NEWID()

	SELECT @outBatchId = @strBatchId
	IF @@ERROR <> 0	GOTO Post_Rollback
End

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Bank Transaction. 
	-- 1. DEBIT SIDE
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
			,[intJournalLineNo]
	)
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= BankAccnt.intGLAccountId
			,[dblDebit]				= CASE WHEN @ysnForeignTransaction = 0 THEN @dblAmountDetailTotal ELSE ROUND(@dblAmountDetailTotal * @dblExchangeRate,2) END  
			,[dblCredit]			= 0
			,[dblDebitForeign]		= CASE WHEN @ysnForeignTransaction = 0 THEN 0 ELSE @dblAmountDetailTotal END
			,[dblCreditForeign]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= NULL
			,[intCurrencyId]		= A.intCurrencyId
			,[intCurrencyExchangeRateTypeId] =  A.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= @dblExchangeRate
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
			,[intJournalLineNo]		= NULL
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankAccount BankAccnt
				ON A.intBankAccountId = BankAccnt.intBankAccountId
			INNER JOIN vyuGLAccountDetail GLAccnt
				ON BankAccnt.intGLAccountId = GLAccnt.intAccountId
	WHERE	A.strTransactionId = @strTransactionId
	
	-- 2. CREDIT SIDE
	UNION ALL 
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= B.intGLAccountId
			,[dblDebit]				= 0
			,[dblCredit]			= ROUND((ISNULL(B.dblCredit, 0) - ISNULL(B.dblDebit, 0)) * CASE WHEN @ysnForeignTransaction = 0 THEN 1 ELSE @dblExchangeRate END ,2) 
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= CASE WHEN @ysnForeignTransaction = 0 THEN 0 ELSE ISNULL(B.dblCredit, 0) - ISNULL(B.dblDebit, 0)  END
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= NULL
			,[intCurrencyId]		= A.intCurrencyId
			,[intCurrencyExchangeRateTypeId] = A.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= @dblExchangeRate
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
			,[intJournalLineNo]		= B.intTransactionDetailId
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankTransactionDetail B
				ON A.intTransactionId = B.intTransactionId
			INNER JOIN vyuGLAccountDetail GLAccnt
				ON B.intGLAccountId = GLAccnt.intAccountId
	WHERE	A.strTransactionId = @strTransactionId
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	DECLARE @gainLoss DECIMAL (18,6)
	SELECT @gainLoss = SUM(dblDebit - dblCredit) from #tmpGLDetail WHERE dblExchangeRate <> 1

	if(@gainLoss <> 0  AND @intDefaultCurrencyId <> @intCurrencyId)
		EXEC [uspCMInsertGainLossBankTransfer] @strDescription = 
		'Gain / Loss on Multicurrency Bank Transaction'
	
END --@ysnPost = 1
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC dbo.uspCMReverseGLEntries @strTransactionId, @GL_DETAIL_CODE, NULL, @intUserId,@strBatchId
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	
END --@ysnPost = 0

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
			,intFiscalPeriodId = F.intGLFiscalYearPeriodId
			,intConcurrencyId += 1 
	FROM tblCMBankTransaction A
	CROSS APPLY dbo.fnGLGetFiscalPeriod(A.dtmDate) F
	WHERE	strTransactionId = @strTransactionId
	

	IF @@ERROR <> 0	GOTO Post_Rollback
END --@ysnRecap = 0

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
			,CASE WHEN [dblDebit] < 0 THEN 0 ELSE [dblDebit] END 
			,CASE WHEN [dblDebit] < 0 THEN ABS([dblDebit]) ELSE [dblCredit] END 
			,CASE WHEN [dblDebitForeign] < 0 THEN 0 ELSE [dblDebitForeign] END 
			,CASE WHEN [dblDebitForeign] < 0 THEN ABS([dblDebitForeign]) ELSE [dblCreditForeign] END 
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
	EXEC dbo.uspGLPostRecap  @RecapTable,@intEntityId,@ysnBatch
	GOTO Post_Exit

Audit_Log:
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
   
	EXEC uspSMAuditLog 
	   @keyValue = @intTransactionId       -- Primary Key Value of the Bank Deposit. 
	   ,@screenName = 'CashManagement.view.BankTransactions'        -- Screen Namespace
	   ,@entityId = @intUserId     -- Entity Id.
	   ,@actionType = @actionType                             -- Action Type
	   ,@changeDescription = @strDescription     -- Description
	   ,@fromValue = ''          -- Previous Value
	   ,@toValue = ''           -- New Value
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail