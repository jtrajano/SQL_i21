CREATE PROCEDURE PostPayment
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
	,[intConcurrencyID]			[int] NULL
	,[intUserID]				[int] NULL
	,[strTransactionForm]		[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strModuleName]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strUOMCode]				[char](6)  COLLATE Latin1_General_CI_AS NULL
)

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@BANK_TRANSACTION_TYPE_ID AS INT = 1 			-- Bank Deposit type ID is 1. 
	,@STARTING_NUM_TRANSACTION_TYPE_ID AS INT = 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10) = 'AP'		-- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100) = 'Accounts Payable' -- Module where this posting code belongs. 
	
	-- Local Variables
	,@cntID AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@dblAmountDetailTotal AS NUMERIC(18,6)
	,@strBatchID AS NVARCHAR(40)
	,@intUserID AS INT
	,@ysnTransactionPostedFlag AS BIT
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback	

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read the header table and populate the variables. 
SELECT	TOP 1 
		@cntID = intPaymentId,
		@dtmDate = dtmDatePaid,
		@dblAmount = dblAmountPaid,
		@intUserID = 1,
		@ysnTransactionPostedFlag = ysnPosted
FROM	[dbo].tblAPPayments 
WHERE	intPaymentId = @strTransactionID 
		--AND intBankTransactionTypeID = @BANK_TRANSACTION_TYPE_ID
IF @@ERROR <> 0	GOTO Post_Rollback		
		
		
-- Read the detail table and populate the variables. 
SELECT	@dblAmountDetailTotal = SUM(ISNULL(dblPayment, 0))
FROM	[dbo].tblAPPaymentDetails A
WHERE	intPaymentId = @strTransactionID 
IF @@ERROR <> 0	GOTO Post_Rollback		


--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the bank deposit id exists. 
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

-- Check the bank deposit balance. 
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

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
EXEC [dbo].GetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_ID, @strBatchID OUTPUT 
IF @@ERROR <> 0	GOTO Post_Rollback

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Bank Deposit. 
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
			,[intConcurrencyID]
			,[intUserID]
			,[strTransactionForm]
			,[strModuleName]
			,[strUOMCode]
	)
	SELECT	[intPaymentId]		= @strTransactionID
			,[intTransactionID]		= NULL
			,[dtmDatePaid]				= @dtmDate
			,[strBatchID]			= @strBatchID
			,[intAccountID]			= A.intBankAccountId
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmountPaid
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= 'Posted Payable'
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= NULL
			,[strJobID]				= NULL
			,[intCurrencyID]		= 1
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDatePaid
			,[strProductID]			= NULL
			,[strWarehouseID]		= NULL
			,[strNum]				= ''--CAST(A.intReferenceNo AS NVARCHAR(100))
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyID]		= 1
			,[intUserID]			= ''--A.intLastModifiedUserID
			,[strTransactionForm]	= A.intPaymentId
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblAPPayments A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intBankAccountId = GLAccnt.intAccountID
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.intPaymentId = @strTransactionID
	
	---- 2. CREDIT SIDE
	UNION ALL 
	SELECT	[strBillId]		= @strTransactionID
			,[intTransactionID]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchID]			= @strBatchID
			,[intAccountID]			= B.intAccountId
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= SUM(B.dblPayment)
			,[dblCredit]			= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= 'Posted Payable'
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= NULL
			,[strJobID]				= NULL
			,[intCurrencyID]		= 1
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDatePaid
			,[strProductID]			= NULL
			,[strWarehouseID]		= NULL
			,[strNum]				= ''--CAST(A.intReferenceNo AS NVARCHAR(100))
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyID]		= 1
			,[intUserID]			= ''--A.intLastModifiedUserID
			,[strTransactionForm]	= A.intPaymentId
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblAPPayments A 
			LEFT JOIN tblAPPaymentDetails B ON A.intPaymentId = B.intPaymentId
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON B.intAccountId = GLAccnt.intAccountID
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.intPaymentId = @strTransactionID
	GROUP BY A.intPaymentId, B.intAccountId, GLAccntGrp.strAccountGroup, A.dtmDatePaid
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC [dbo].ReverseGLEntries @strTransactionID, @GL_DETAIL_CODE, NULL, @intUserID	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblAPBills
	SET		ysnPosted = 0
			--,intConcurrencyID += 1 
	WHERE	strBillId = @strTransactionID
	IF @@ERROR <> 0	GOTO Post_Rollback
END


--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The G/L Ledger detail table)
---------------------------------------------------------------------------------------------------------------------------------------
EXEC [dbo].[BookGLEntries] @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
IF @isSuccessful = 0 GOTO Post_Rollback

	
-- Update the posted flag in the transaction table
UPDATE tblAPPayments
SET		ysnPosted = 1
		--,intConcurrencyID += 1 
WHERE	intPaymentId = @strTransactionID

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
			,[intConcurrencyID]		
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
			,[intConcurrencyID]		
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
