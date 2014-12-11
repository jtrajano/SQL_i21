
CREATE PROCEDURE uspCMPostBankTransfer
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionId		NVARCHAR(40) = NULL 
	,@intUserId				INT		= NULL 
	,@intEntityId			INT		= NULL
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
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
	,[strBatchId] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL
	,[intAccountId] [int] NULL
	,[dblDebit] [numeric](18, 6) NULL
	,[dblCredit] [numeric](18, 6) NULL
	,[dblDebitUnit] [numeric](18, 6) NULL
	,[dblCreditUnit] [numeric](18, 6) NULL
	,[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[strTransactionId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intTransactionId] [int] NULL
	,[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyId] [int] NULL
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
	@BANK_TRANSACTION_TYPE_Id AS INT			= 4 -- Bank Transfer Type Id is 4 (See tblCMBankTransactionType). 
	,@STARTING_NUM_TRANSACTION_TYPE_Id AS INT	= 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10)			= 'BTFR' -- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100)				= 'Cash Management' -- Module where this posting code belongs.
	,@TRANSACTION_FORM AS NVARCHAR(100)			= 'Bank Transfer'
	,@BANK_TRANSFER_WD AS INT					= 9 -- Transaction code for Bank Transfer Withdrawal. It also refers to as Bank Transfer FROM.
	,@BANK_TRANSFER_DEP AS INT					= 10 -- Transaction code for Bank Transfer Deposit. It also refers to as Bank Transfer TO. 
	,@BANK_TRANSFER_WD_PREFIX AS NVARCHAR(3)	= '-WD'
	,@BANK_TRANSFER_DEP_PREFIX AS NVARCHAR(4)	= '-DEP'
	
	-- Local Variables
	,@intTransactionId AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@strBatchId AS NVARCHAR(40)
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT
	,@intBankAccountIdFrom AS INT
	,@intBankAccountIdTo AS INT
	,@ysnBankAccountIdInactive AS BIT
	,@intCreatedEntityId AS INT
	,@ysnAllowUserSelfPost AS BIT = 0
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read bank transfer table 
SELECT	TOP 1 
		@intTransactionId = intTransactionId
		,@dtmDate = dtmDate
		,@dblAmount = dblAmount
		,@ysnTransactionPostedFlag = ysnPosted
		,@intBankAccountIdFrom = intBankAccountIdFrom
		,@intBankAccountIdTo = intBankAccountIdTo
		,@intCreatedEntityId = intEntityId
FROM	[dbo].tblCMBankTransfer 
WHERE	strTransactionId = @strTransactionId 
IF @@ERROR <> 0	GOTO Post_Rollback	

-- Read the company preference
SELECT	@ysnAllowUserSelfPost = 1
FROM	dbo.tblSMPreferences 
WHERE	strPreference = 'AllowUserSelfPost' 
		AND LOWER(RTRIM(LTRIM(strValue))) = 'true'		
IF @@ERROR <> 0	GOTO Post_Rollback			
		
--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the bank transfer id exists. 
IF @intTransactionId IS NULL
BEGIN 
	-- Cannot find the transaction.
	RAISERROR(50004, 11, 1)
	GOTO Post_Rollback
END 

-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0) AND @ysnRecap = 0
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR(50005, 11, 1)
	GOTO Post_Rollback
END

-- Check if the transaction is already posted
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1
BEGIN 
	-- The transaction is already posted.
	RAISERROR(50007, 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already posted
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0
BEGIN 
	-- The transaction is already unposted.
	RAISERROR(50008, 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already cleared or reconciled
IF @ysnPost = 0 AND @ysnRecap = 0
BEGIN
	SELECT TOP 1 @ysnTransactionClearedFlag = 1
	FROM	tblCMBankTransaction 
	WHERE	strLink = @strTransactionId
			AND ysnClr = 1
			AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)
			
	IF @ysnTransactionClearedFlag = 1
	BEGIN
		-- 'The transaction is already cleared.'
		RAISERROR(50009, 11, 1)
		GOTO Post_Rollback
	END
END

-- Check if the bank account is inactive
IF @ysnRecap = 0 
BEGIN
	SELECT TOP 1 @ysnBankAccountIdInactive = 1
	FROM	tblCMBankAccount
	WHERE	intBankAccountId IN (@intBankAccountIdFrom, @intBankAccountIdTo) 
			AND ysnActive = 0
	
	IF @ysnBankAccountIdInactive = 1
	BEGIN
		-- 'The bank account is inactive.'
		RAISERROR(50010, 11, 1)
		GOTO Post_Rollback
	END
END 

-- Check Company preference: Allow User Self Post
IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId AND @ysnRecap = 0 
BEGIN 
	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'
	IF @ysnPost = 1	
	BEGIN 
		RAISERROR(50013, 11, 1, 'Post')
		GOTO Post_Rollback
	END 
	IF @ysnPost = 0
	BEGIN
		RAISERROR(50013, 11, 1, 'Unpost')
		GOTO Post_Rollback		
	END
END 

-- Check if amount is zero. 
IF @dblAmount = 0 AND @ysnPost = 1 AND @ysnRecap = 0
BEGIN 
	-- Cannot post a zero-value transaction.
	RAISERROR(50020, 11, 1)
	GOTO Post_Rollback
END 

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchId OUTPUT 
IF @@ERROR <> 0	GOTO Post_Rollback

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Bank Transfer. 
	-- 1. CREDIT SIdE (SOURCE FUND)
	INSERT INTO #tmpGLDetail (
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
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
			,[ysnIsUnposted]
			,[intConcurrencyId]
			,[intUserId]
			,[strTransactionForm]
			,[strModuleName]
			,[intEntityId]
	)
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= GLAccnt.intAccountId
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmount
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= GLAccnt.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strReferenceFrom
			,[intCurrencyId]		= NULL
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIdFrom = GLAccnt.intAccountId
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId
	
	
	-- 2. DEBIT SIdE (TARGET OF THE FUND)
	UNION ALL 
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= GLAccnt.intAccountId
			,[dblDebit]				= A.dblAmount
			,[dblCredit]			= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= GLAccnt.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strReferenceTo
			,[intCurrencyId]		= NULL
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIdTo = GLAccnt.intAccountId		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransfer
	SET		ysnPosted = 1
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Create new records in tblCMBankTransaction	
	INSERT INTO tblCMBankTransaction (
		strTransactionId
		,intBankTransactionTypeId
		,intBankAccountId
		,intCurrencyId
		,dblExchangeRate
		,dtmDate
		,strPayee
		,intPayeeId
		,strAddress
		,strZipCode
		,strCity
		,strState
		,strCountry
		,dblAmount
		,strAmountInWords
		,strMemo
		,strReferenceNo
		,dtmCheckPrinted
		,ysnCheckToBePrinted
		,ysnCheckVoid
		,ysnPosted
		,strLink
		,ysnClr
		,intEntityId
		,dtmDateReconciled
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId	
	)
	-- Bank Transaction Credit
	SELECT	strTransactionId			= A.strTransactionId + @BANK_TRANSFER_WD_PREFIX
			,intBankTransactionTypeId	= @BANK_TRANSFER_WD
			,intBankAccountId			= A.intBankAccountIdFrom
			,intCurrencyId				= NULL
			,dblExchangeRate			= 1
			,dtmDate					= A.dtmDate
			,strPayee					= ''
			,intPayeeId					= NULL
			,strAddress					= ''
			,strZipCode					= ''
			,strCity					= ''
			,strState					= ''
			,strCountry					= ''
			,dblAmount					= A.dblAmount
			,strAmountInWords			= dbo.fnConvertNumberToWord(A.dblAmount)
			,strMemo					= A.strReferenceFrom
			,strReferenceNo				= ''
			,dtmCheckPrinted			= NULL
			,ysnCheckToBePrinted		= 0
			,ysnCheckVoid				= 0
			,ysnPosted					= 1
			,strLink					= A.strTransactionId
			,ysnClr						= 0
			,intEntityId				= A.intEntityId
			,dtmDateReconciled			= NULL
			,intCreatedUserId			= A.intCreatedUserId
			,dtmCreated					= GETDATE()
			,intLastModifiedUserId		= A.intLastModifiedUserId
			,dtmLastModified			= GETDATE()
			,intConcurrencyId			= 1	
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIdFrom = GLAccnt.intAccountId		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId
	
	-- Bank Transaction Debit
	UNION ALL
	SELECT	strTransactionId			= A.strTransactionId + @BANK_TRANSFER_DEP_PREFIX
			,intBankTransactionTypeId	= @BANK_TRANSFER_DEP
			,intBankAccountId			= A.intBankAccountIdTo
			,intCurrencyId				= NULL
			,dblExchangeRate			= 1
			,dtmDate					= A.dtmDate
			,strPayee					= ''
			,intPayeeId					= NULL
			,strAddress					= ''
			,strZipCode					= ''
			,strCity					= ''
			,strState					= ''
			,strCountry					= ''
			,dblAmount					= A.dblAmount
			,strAmountInWords			= dbo.fnConvertNumberToWord(A.dblAmount)
			,strMemo					= A.strReferenceTo
			,strReferenceNo				= ''
			,dtmCheckPrinted			= NULL
			,ysnCheckToBePrinted		= 0
			,ysnCheckVoid				= 0
			,ysnPosted					= 1
			,strLink					= A.strTransactionId
			,ysnClr						= 0
			,intEntityId				= A.intEntityId
			,dtmDateReconciled			= NULL
			,intCreatedUserId			= A.intCreatedUserId
			,dtmCreated					= GETDATE()
			,intLastModifiedUserId		= A.intLastModifiedUserId
			,dtmLastModified			= GETDATE()
			,intConcurrencyId			= 1	
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIdFrom = GLAccnt.intAccountId		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC dbo.uspCMReverseGLEntries @strTransactionId, @GL_DETAIL_CODE, NULL, @intUserId	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransfer
	SET		ysnPosted = 0
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Delete the records in tblCMBankTransaction
	DELETE FROM tblCMBankTransaction
	WHERE	strLink = @strTransactionId
			AND ysnClr = 0
			AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)
	IF @@ERROR <> 0	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The General Ledger Detail table)
---------------------------------------------------------------------------------------------------------------------------------------
EXEC dbo.uspCMBookGLEntries @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
IF @isSuccessful = 0 GOTO Post_Rollback

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
	SELECT	[dtmDate] 
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
	GOTO Post_Exit

-- If error occured, undo changes to all tables affected
Post_Rollback:
	SET @isSuccessful = 0
	ROLLBACK TRANSACTION		            
	GOTO Post_Exit
	
Recap_Rollback: 
	SET @isSuccessful = 1
	ROLLBACK TRANSACTION 
	EXEC dbo.uspCMPostRecap @RecapTable
	GOTO Post_Exit
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail