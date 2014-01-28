
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE PostCMMiscChecks
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionID		NVARCHAR(40) = NULL 
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
	[strTransactionID]			[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intTransactionID]			[int] NULL
	,[dtmDate]					[datetime] NOT NULL
	,[strBatchID]				[nvarchar](20)  COLLATE Latin1_General_CI_AS NULL
	,[intAccountID]				[int] NULL
	,[strAccountGroup]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[dblDebit]					[numeric](18, 6) NULL
	,[dblCredit]				[numeric](18, 6) NULL
	,[dblDebitUnit]				[numeric](18, 6) NULL
	,[dblCreditUnit]			[numeric](18, 6) NULL
	,[strDescription]			[nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[strCode]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[strReference]				[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strJobID]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyID]			[int] NULL
	,[dblExchangeRate]			[numeric](38, 20) NOT NULL
	,[dtmDateEntered]			[datetime] NOT NULL
	,[dtmTransactionDate]		[datetime] NULL
	,[strProductID]				[nvarchar](50)  COLLATE Latin1_General_CI_AS NULL
	,[strWarehouseID]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[strNum]					[nvarchar](100)  COLLATE Latin1_General_CI_AS NULL
	,[strCompanyName]			[nvarchar](150)  COLLATE Latin1_General_CI_AS NULL
	,[strBillInvoiceNumber]		[nvarchar](35)  COLLATE Latin1_General_CI_AS NULL
	,[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[ysnIsUnposted]			[bit] NOT NULL
	,[intConcurrencyId]			[int] NULL
	,[intUserID]				[int] NULL
	,[strTransactionForm]		[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strModuleName]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strUOMCode]				[char](6)  COLLATE Latin1_General_CI_AS NULL
)

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@BANK_TRANSACTION_TYPE_ID AS INT = 3 			-- Misc Checks type ID is 3 (See tblCMBankTransactionType). 
	,@STARTING_NUM_TRANSACTION_TYPE_ID AS INT = 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10) = 'MCHK'		-- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100) = 'Cash Management' -- Module where this posting code belongs. 
	
	-- Local Variables
	,@cntID AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@dblAmountDetailTotal AS NUMERIC(18,6)
	,@strBatchID AS NVARCHAR(40)
	,@intUserID AS INT
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT	
	,@intBankAccountID AS INT
	,@ysnBankAccountIDInactive AS BIT	
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read the header table and populate the variables. 
SELECT	TOP 1 
		@cntID = cntID
		,@dtmDate = dtmDate
		,@dblAmount = dblAmount
		,@intUserID = intLastModifiedUserID
		,@ysnTransactionPostedFlag = ysnPosted
		,@ysnTransactionClearedFlag = ysnClr		
		,@intBankAccountID = intBankAccountID
FROM	[dbo].tblCMBankTransaction 
WHERE	strTransactionID = @strTransactionID 
		AND intBankTransactionTypeID = @BANK_TRANSACTION_TYPE_ID
IF @@ERROR <> 0	GOTO Post_Rollback		
		
		
-- Read the detail table and populate the variables. 
SELECT	@dblAmountDetailTotal = SUM(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0))
FROM	[dbo].tblCMBankTransactionDetail
WHERE	strTransactionID = @strTransactionID 
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the Misc Checks exists. 
IF @cntID IS NULL
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

-- Check if the bank account is inactive
IF @ysnRecap = 0 
BEGIN
	SELECT	@ysnBankAccountIDInactive = 1
	FROM	tblCMBankAccount
	WHERE	intBankAccountID = @intBankAccountID
			AND ysnActive = 0
	
	IF @ysnBankAccountIDInactive = 1
	BEGIN
		-- 'The bank account is inactive.'
		RAISERROR(50010, 11, 1)
		GOTO Post_Rollback
	END
END 

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
EXEC [dbo].GetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_ID, @strBatchID OUTPUT 
IF @@ERROR <> 0	GOTO Post_Rollback

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Misc Checks. 
	-- 1. DEBIT SIDE
	INSERT INTO #tmpGLDetail (
			[strTransactionID]
			,[intTransactionID]
			,[dtmDate]
			,[strBatchID]
			,[intAccountID]
			,[strAccountGroup]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[strJobID]
			,[intCurrencyID]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strProductID]
			,[strWarehouseID]
			,[strNum]
			,[strCompanyName]
			,[strBillInvoiceNumber]
			,[strJournalLineDescription]
			,[ysnIsUnposted]
			,[intConcurrencyId]
			,[intUserID]
			,[strTransactionForm]
			,[strModuleName]
			,[strUOMCode]
	)
	
	SELECT	[strTransactionID]			= @strTransactionID
			,[intTransactionID]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchID]			= @strBatchID
			,[intAccountID]			= B.intGLAccountID
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= B.dblDebit
			,[dblCredit]			= B.dblCredit
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strPayee
			,[strJobID]				= NULL
			,[intCurrencyID]		= A.intCurrencyID
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strProductID]			= NULL
			,[strWarehouseID]		= NULL
			,[strNum]				= A.strReferenceNo
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserID]			= A.intLastModifiedUserID
			,[strTransactionForm]	= A.strTransactionID
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankTransactionDetail B
				ON A.strTransactionID = B.strTransactionID
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON B.intGLAccountID = GLAccnt.intAccountID
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID			
	WHERE	A.strTransactionID = @strTransactionID		
	
	-- 2. CREDIT SIDE
	UNION ALL 
	SELECT	[strTransactionID]		= @strTransactionID
			,[intTransactionID]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchID]			= @strBatchID
			,[intAccountID]			= BankAccnt.intGLAccountID
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmount
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strMemo
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strPayee
			,[strJobID]				= NULL
			,[intCurrencyID]		= A.intCurrencyID
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strProductID]			= NULL
			,[strWarehouseID]		= NULL
			,[strNum]				= A.strReferenceNo
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserID]			= A.intLastModifiedUserID
			,[strTransactionForm]	= A.strTransactionID
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankAccount BankAccnt
				ON A.intBankAccountID = BankAccnt.intBankAccountID
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON BankAccnt.intGLAccountID = GLAccnt.intAccountID
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.strTransactionID = @strTransactionID
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransaction
	SET		ysnPosted = 1
			,intConcurrencyId += 1 
	WHERE	strTransactionID = @strTransactionID
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC [dbo].ReverseGLEntries @strTransactionID, @GL_DETAIL_CODE, NULL, @intUserID	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransaction
	SET		ysnPosted = 0
			,intConcurrencyId += 1 
	WHERE	strTransactionID = @strTransactionID
	IF @@ERROR <> 0	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The G/L Ledger detail table)
---------------------------------------------------------------------------------------------------------------------------------------
EXEC [dbo].[BookGLEntries] @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
IF @isSuccessful = 0 GOTO Post_Rollback

--=====================================================================================================================================
-- 	Check if process is only a RECAP
---------------------------------------------------------------------------------------------------------------------------------------
IF @ysnRecap = 1 
BEGIN	
	-- INSERT THE DATA FROM #tmpGLDetail TO @RecapTable
	INSERT INTO @RecapTable (
			[strTransactionID]		
			,[intTransactionID]		
			,[dtmDate]				
			,[strBatchID]			
			,[intAccountID]			
			,[strAccountGroup]		
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitUnit]			
			,[dblCreditUnit]		
			,[strDescription]		
			,[strCode]				
			,[strReference]			
			,[strJobID]				
			,[intCurrencyID]		
			,[dblExchangeRate]		
			,[dtmDateEntered]		
			,[dtmTransactionDate]	
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[intUserID]			
			,[strTransactionForm]	
			,[strModuleName]		
			,[strUOMCode]			
	)	
	SELECT	@strTransactionID
			,NULL
			,[dtmDate]				
			,[strBatchID]			
			,[intAccountID]			
			,[strAccountGroup]		
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitUnit]			
			,[dblCreditUnit]		
			,[strDescription]		
			,[strCode]				
			,[strReference]			
			,[strJobID]				
			,[intCurrencyID]		
			,[dblExchangeRate]		
			,[dtmDateEntered]		
			,[dtmTransactionDate]	
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[intUserID]			
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
	EXEC PostRecap @RecapTable
	GOTO Post_Exit
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpGLDetail')) DROP TABLE #tmpGLDetail
  
