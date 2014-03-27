﻿
CREATE PROCEDURE uspCMPostMiscChecks
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionId		NVARCHAR(40) = NULL 
	,@intUserId				INT		= NULL 
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
AS

SET QUOTED_IdENTIFIER OFF
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
	[strTransactionId]			[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intTransactionId]			[int] NULL
	,[dtmDate]					[datetime] NOT NULL
	,[strBatchId]				[nvarchar](20)  COLLATE Latin1_General_CI_AS NULL
	,[intAccountId]				[int] NULL
	,[strAccountGroup]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[dblDebit]					[numeric](18, 6) NULL
	,[dblCredit]				[numeric](18, 6) NULL
	,[dblDebitUnit]				[numeric](18, 6) NULL
	,[dblCreditUnit]			[numeric](18, 6) NULL
	,[strDescription]			[nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[strCode]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[strReference]				[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strJobId]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyId]			[int] NULL
	,[dblExchangeRate]			[numeric](38, 20) NOT NULL
	,[dtmDateEntered]			[datetime] NOT NULL
	,[dtmTransactionDate]		[datetime] NULL
	,[strProductId]				[nvarchar](50)  COLLATE Latin1_General_CI_AS NULL
	,[strWarehouseId]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[strNum]					[nvarchar](100)  COLLATE Latin1_General_CI_AS NULL
	,[strCompanyName]			[nvarchar](150)  COLLATE Latin1_General_CI_AS NULL
	,[strBillInvoiceNumber]		[nvarchar](35)  COLLATE Latin1_General_CI_AS NULL
	,[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[ysnIsUnposted]			[bit] NOT NULL
	,[intConcurrencyId]			[int] NULL
	,[intUserId]				[int] NULL
	,[strTransactionForm]		[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strModuleName]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strUOMCode]				[char](6)  COLLATE Latin1_General_CI_AS NULL
)

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@BANK_TRANSACTION_TYPE_Id AS INT = 3 			-- Misc Checks type Id is 3 (See tblCMBankTransactionType). 
	,@STARTING_NUM_TRANSACTION_TYPE_Id AS INT = 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10) = 'MCHK'		-- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100) = 'Cash Management' -- Module where this posting code belongs. 
	
	-- Local Variables
	,@intTransactionId AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@dblAmountDetailTotal AS NUMERIC(18,6)
	,@strBatchId AS NVARCHAR(40)
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT	
	,@intBankAccountId AS INT
	,@ysnBankAccountIdInactive AS BIT
	,@ysnCheckVoid AS BIT	
	,@intCreatedUserId AS INT
	,@ysnAllowUserSelfPost AS BIT = 0
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read the header table and populate the variables. 
SELECT	TOP 1 
		@intTransactionId = intTransactionId
		,@dtmDate = dtmDate
		,@dblAmount = dblAmount
		,@ysnTransactionPostedFlag = ysnPosted
		,@ysnTransactionClearedFlag = ysnClr
		,@ysnCheckVoid = ysnCheckVoid		
		,@intBankAccountId = intBankAccountId
		,@intCreatedUserId = intCreatedUserId
FROM	[dbo].tblCMBankTransaction 
WHERE	strTransactionId = @strTransactionId 
		AND intBankTransactionTypeId = @BANK_TRANSACTION_TYPE_Id
IF @@ERROR <> 0	GOTO Post_Rollback		
		
-- Read the detail table and populate the variables. 
SELECT	@dblAmountDetailTotal = SUM(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0))
FROM	[dbo].tblCMBankTransactionDetail
WHERE	intTransactionId = @intTransactionId 
IF @@ERROR <> 0	GOTO Post_Rollback		

-- Read the company preference
SELECT	@ysnAllowUserSelfPost = 1
FROM	dbo.tblSMPreferences 
WHERE	strPreference = 'AllowUserSelfPost' 
		AND LOWER(RTRIM(LTRIM(strValue))) = 'true'		
IF @@ERROR <> 0	GOTO Post_Rollback	

--=====================================================================================================================================
-- 	VALIdATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the Misc Checks exists. 
IF @intTransactionId IS NULL
BEGIN 
	-- Cannot find the transaction.
	RAISERROR(50004, 11, 1)
	GOTO Post_Rollback
END 

-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0)
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR(50005, 11, 1)
	GOTO Post_Rollback
END

-- Check the amount in Misc Check. See if it is balanced. 
IF ISNULL(@dblAmountDetailTotal, 0) <> ISNULL(@dblAmount, 0) AND @ysnRecap = 0
BEGIN
	-- The debit and credit amounts are not balanced.
	RAISERROR(50006, 11, 1)
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

-- Check if the transaction is already reconciled
IF @ysnPost = 0 AND @ysnRecap = 0 AND @ysnTransactionClearedFlag = 1
BEGIN
	-- 'The transaction is already cleared.'
	RAISERROR(50009, 11, 1)
	GOTO Post_Rollback
END

-- Check if the Check is already voided.
IF @ysnRecap = 0 AND @ysnCheckVoid = 1
BEGIN
	-- 'Check is already voided.'
	RAISERROR(50012, 11, 1)
	GOTO Post_Rollback
END

-- Check if the bank account is inactive
IF @ysnRecap = 0 
BEGIN
	SELECT	@ysnBankAccountIdInactive = 1
	FROM	tblCMBankAccount
	WHERE	intBankAccountId = @intBankAccountId
			AND ysnActive = 0
	
	IF @ysnBankAccountIdInactive = 1
	BEGIN
		-- 'The bank account is inactive.'
		RAISERROR(50010, 11, 1)
		GOTO Post_Rollback
	END
END 

-- Check Company preference: Allow User Self Post
IF @ysnAllowUserSelfPost = 1 AND @intUserId <> @intCreatedUserId AND @ysnRecap = 0 
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

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchId OUTPUT 
IF @@ERROR <> 0	GOTO Post_Rollback

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Misc Checks. 	
	INSERT INTO #tmpGLDetail (
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[strAccountGroup]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[strJobId]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strProductId]
			,[strWarehouseId]
			,[strNum]
			,[strCompanyName]
			,[strBillInvoiceNumber]
			,[strJournalLineDescription]
			,[ysnIsUnposted]
			,[intConcurrencyId]
			,[intUserId]
			,[strTransactionForm]
			,[strModuleName]
			,[strUOMCode]
	)
	-- 1. CREDIT SIDE
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= BankAccnt.intGLAccountId
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmount
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strPayee
			,[strJobId]				= NULL
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strProductId]			= NULL
			,[strWarehouseId]		= NULL
			,[strNum]				= A.strReferenceNo
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionForm]	= A.strTransactionId
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankAccount BankAccnt
				ON A.intBankAccountId = BankAccnt.intBankAccountId
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON BankAccnt.intGLAccountId = GLAccnt.intAccountId
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId
		
	-- 2. DEBIT SIDE
	UNION ALL 
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= B.intGLAccountId
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= B.dblDebit
			,[dblCredit]			= B.dblCredit
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= B.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strPayee
			,[strJobId]				= NULL
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strProductId]			= NULL
			,[strWarehouseId]		= NULL
			,[strNum]				= A.strReferenceNo
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionForm]	= A.strTransactionId
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankTransactionDetail B
				ON A.intTransactionId = B.intTransactionId
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON B.intGLAccountId = GLAccnt.intAccountId
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId		

	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransaction
	SET		ysnPosted = 1
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC dbo.uspCMReverseGLEntries @strTransactionId, @GL_DETAIL_CODE, NULL, @intUserId	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransaction
	SET		ysnPosted = 0
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	IF @@ERROR <> 0	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The G/L Ledger detail table)
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
			[strTransactionId]		
			,[intTransactionId]		
			,[dtmDate]				
			,[strBatchId]			
			,[intAccountId]			
			,[strAccountGroup]		
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitUnit]			
			,[dblCreditUnit]		
			,[strDescription]		
			,[strCode]				
			,[strReference]			
			,[strJobId]				
			,[intCurrencyId]		
			,[dblExchangeRate]		
			,[dtmDateEntered]		
			,[dtmTransactionDate]	
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[intUserId]			
			,[strTransactionForm]	
			,[strModuleName]		
			,[strUOMCode]			
	)
	SELECT	@strTransactionId
			,NULL
			,[dtmDate]				
			,[strBatchId]			
			,[intAccountId]			
			,[strAccountGroup]		
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitUnit]			
			,[dblCreditUnit]		
			,[strDescription]		
			,[strCode]				
			,[strReference]			
			,[strJobId]				
			,[intCurrencyId]		
			,[dblExchangeRate]		
			,[dtmDateEntered]		
			,[dtmTransactionDate]	
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[intUserId]			
			,[strTransactionForm]	
			,[strModuleName]		
			,[strUOMCode]	
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
	EXEC uspCMPostRecap @RecapTable
	GOTO Post_Exit
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail