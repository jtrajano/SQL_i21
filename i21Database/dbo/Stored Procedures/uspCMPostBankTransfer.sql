CREATE PROCEDURE [dbo].[uspCMPostBankTransfer]
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionId		NVARCHAR(40) = NULL 
	,@strBatchId			NVARCHAR(40) = NULL 
	,@intUserId				INT		= NULL 
	,@intEntityId			INT		= NULL
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
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT
	,@intBankAccountIdFrom AS INT
	,@intBankAccountIdTo AS INT
	,@ysnBankAccountActive AS BIT
	,@intCreatedEntityId AS INT
	,@ysnAllowUserSelfPost AS BIT = 0
	,@dblRate DECIMAL (18,6)
	,@dblHistoricRate DECIMAL (18,6)
	,@intCurrencyIdFrom INT
	,@intCurrencyIdTo INT
	,@intDefaultCurrencyId INT
	,@ysnFunctionalToForeign BIT
	,@ysnForeignToFunctional BIT
	,@ysnForeignToForeign BIT
	,@ysnDefaultTransfer BIT
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	,@GLEntries AS RecapTableType
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
		,@dblRate = dblRate
		,@intCurrencyIdFrom = B.intCurrencyId
		,@intCurrencyIdTo = C.intCurrencyId
FROM	[dbo].tblCMBankTransfer A JOIN
[dbo].tblCMBankAccount B ON B.intBankAccountId = A.intBankAccountIdFrom JOIN
[dbo].tblCMBankAccount C ON C.intBankAccountId = A.intBankAccountIdTo
WHERE	strTransactionId = @strTransactionId 


SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

SELECT @ysnForeignToFunctional = CASE WHEN @intDefaultCurrencyId <> @intCurrencyIdFrom AND @intCurrencyIdTo = @intDefaultCurrencyId THEN CAST(1 AS BIT) ELSE CAST (0 AS BIT) END
SELECT @ysnFunctionalToForeign = CASE WHEN @intDefaultCurrencyId <> @intCurrencyIdTo AND @intCurrencyIdFrom = @intDefaultCurrencyId THEN CAST(1 AS BIT) ELSE CAST (0 AS BIT) END
SELECT @ysnForeignToForeign = CASE WHEN @intDefaultCurrencyId <> @intCurrencyIdTo AND @intCurrencyIdFrom <> @intDefaultCurrencyId AND  @intCurrencyIdFrom = @intCurrencyIdTo THEN CAST(1 AS BIT) ELSE CAST (0 AS BIT) END
SELECT @ysnDefaultTransfer = CASE WHEN @intDefaultCurrencyId = @intCurrencyIdTo AND @intCurrencyIdFrom = @intCurrencyIdTo THEN 1 ELSE 0 END

SELECT @dblHistoricRate = 
	CASE 
	WHEN @ysnDefaultTransfer = 1 THEN 1
	WHEN @ysnForeignToFunctional = 1 THEN dbo.fnCMGetBankAccountHistoricRate(@intBankAccountIdFrom, @dtmDate ) 
	WHEN @ysnFunctionalToForeign = 1 THEN @dblRate
	ELSE
	1 END


IF @@ERROR <> 0	GOTO Post_Rollback	

-- Read the user preference
SELECT	@ysnAllowUserSelfPost = 1
FROM	dbo.tblSMUserPreference 
WHERE	ysnAllowUserSelfPost = 1 
		AND [intEntityUserSecurityId] = @intUserId
IF @@ERROR <> 0	GOTO Post_Rollback			
		
--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the bank transfer id exists. 
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

IF  @ysnRecap = 0
BEGIN
-- Validate the date against the FY Periods
	IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0) AND @ysnRecap = 0
	BEGIN 
		-- Unable to find an open fiscal year period to match the transaction date.
		RAISERROR('Unable to find an open fiscal year period to match the transaction date.', 11, 1)
		GOTO Post_Rollback
	END

	-- Validate the date against the FY Periods per module
	IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDateByModule(@dtmDate,@MODULE_NAME) = 0) AND @ysnRecap = 0
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
	-- Check if the transaction is already cleared or reconciled
	IF @ysnPost = 0 AND @ysnRecap = 0
	BEGIN
		DECLARE @intBankTransactionTypeId AS INT
		DECLARE @clearedTransactionCount AS INT

		SELECT TOP 1 @ysnTransactionClearedFlag = 1, @intBankTransactionTypeId = intBankTransactionTypeId
		FROM	tblCMBankTransaction 
		WHERE	strLink = @strTransactionId
				AND ysnClr = 1
				AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)

		SELECT  @clearedTransactionCount = COUNT(intTransactionId)
		FROM	tblCMBankTransaction 
		WHERE	strLink = @strTransactionId
				AND ysnClr = 1
				AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)
			
		IF @ysnTransactionClearedFlag = 1
		BEGIN
			-- 'The transaction is already cleared.'
			IF @clearedTransactionCount = 2
			BEGIN
				RAISERROR('The transaction is already cleared.', 11, 1)
				GOTO Post_Rollback
			END

			IF @intBankTransactionTypeId = @BANK_TRANSFER_WD
			BEGIN
				RAISERROR('Transfer %s transaction is already cleared.', 11, 1, 'From')
				GOTO Post_Rollback
			END
			ELSE
				RAISERROR('Transfer %s transaction is already cleared.', 11, 1, 'To')
				GOTO Post_Rollback
		
		END
	END

	-- Check if the bank account is inactive
	IF @ysnRecap = 0 
	BEGIN
		SELECT TOP 1 @ysnBankAccountActive = ISNULL(A.ysnActive,0) & ISNULL(B.ysnActive,0)
		FROM	tblCMBankAccount A JOIN vyuGLAccountDetail B
		ON A.intGLAccountId = B.intAccountId
		WHERE	intBankAccountId IN (@intBankAccountIdFrom, @intBankAccountIdTo) 

	
		IF @ysnBankAccountActive = 0
		BEGIN
			-- 'The bank account is inactive.'
			RAISERROR('The bank account or its associated GL account is inactive.', 11, 1)
			GOTO Post_Rollback
		END
	END 

	-- Check Company preference: Allow User Self Post
	IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId AND @ysnRecap = 0 
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
	IF @dblAmount = 0 AND @ysnPost = 1 AND @ysnRecap = 0
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
END

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
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= GLAccnt.intAccountId
			,[dblDebit]				= 0
			,[dblCredit]			= CASE WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountUSD.Val ELSE A.dblAmount END
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= CASE WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN A.dblAmount  ELSE AmountForeign.Val  END
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strReferenceFrom
			,[intCurrencyId]		= @intCurrencyIdFrom
			,[intCurrencyExchangeRateTypeId] =  A.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= CASE WHEN @intCurrencyIdTo <> @intDefaultCurrencyId or @intCurrencyIdFrom <> @intDefaultCurrencyId  THEN ISNULL(@dblHistoricRate,1) ELSE 1 END
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
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIdFrom = GLAccnt.intAccountId
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
			OUTER APPLY
			(
				SELECT ROUND(A.dblAmount * ISNULL(@dblHistoricRate,1),2)Val
			)AmountUSD
			OUTER APPLY
			(
				SELECT ROUND(A.dblAmount / ISNULL(@dblHistoricRate,1),2)Val
			)AmountForeign
	WHERE	A.strTransactionId = @strTransactionId

	
	
	-- 2. DEBIT SIdE (TARGET OF THE FUND)
	UNION ALL 
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchId
			,[intAccountId]			= GLAccnt.intAccountId
			,[dblDebit]				= CASE WHEN  @intCurrencyIdFrom <> @intDefaultCurrencyId  THEN  AmountUSD.Val ELSE  A.dblAmount END
			,[dblCredit]			= 0 
			,[dblDebitForeign]		= CASE WHEN @intCurrencyIdTo <> @intDefaultCurrencyId THEN AmountForeign.Val ELSE A.dblAmount END
			,[dblCreditForeign]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strReferenceTo
			,[intCurrencyId]		= @intCurrencyIdTo
			,[intCurrencyExchangeRateTypeId] = A.[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]		= CASE WHEN @intCurrencyIdTo <> @intDefaultCurrencyId OR @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  ISNULL(@dblRate, 1) ELSE 1 END
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
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIdTo = GLAccnt.intAccountId		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
			OUTER APPLY
			(
				SELECT ROUND(A.dblAmount * ISNULL(@dblRate,1),2)Val
			)AmountUSD
			OUTER APPLY
			(
				SELECT ROUND(A.dblAmount / ISNULL(@dblRate,1),2)Val
			)AmountForeign
	WHERE	A.strTransactionId = @strTransactionId
	IF @@ERROR <> 0	GOTO Post_Rollback

	if(@dblRate <> @dblHistoricRate AND @intDefaultCurrencyId = @intCurrencyIdTo AND @intDefaultCurrencyId <> @intCurrencyIdFrom )
		EXEC [uspCMInsertGainLossBankTransfer] @strDescription = 'Gain / Loss from Bank Transfer'
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC dbo.uspCMReverseGLEntries @strTransactionId, @GL_DETAIL_CODE, NULL, @intUserId, @strBatchId
	IF @@ERROR <> 0	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The General Ledger Detail table)
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

	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransfer
	SET		ysnPosted = @ysnPost
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	IF @@ERROR <> 0	GOTO Post_Rollback

	IF @ysnPost = 1
	BEGIN
		INSERT INTO tblCMBankTransaction (
			strTransactionId
			,intBankTransactionTypeId
			,intBankAccountId
			,intCurrencyId
			,intCurrencyExchangeRateTypeId
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
				,intCurrencyId				= @intCurrencyIdFrom
				,intCurrencyExchangeRateTypeId =CASE WHEN @ysnForeignToFunctional = 1  OR @ysnForeignToForeign =1 THEN A.intCurrencyExchangeRateTypeId ELSE NULL END  
				,dblExchangeRate			= CASE WHEN @ysnForeignToFunctional = 1  OR @ysnForeignToForeign =1 THEN ISNULL(@dblHistoricRate,1)  ELSE 1 END 
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
				,strMemo					= CASE WHEN ISNULL(A.strReferenceFrom,'') = '' THEN 
												A.strDescription 
												WHEN ISNULL(A.strDescription,'') = '' THEN
												A.strReferenceFrom
												ELSE A.strDescription + ' / ' + A.strReferenceFrom 
											  END
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
				,intCurrencyId				= @intCurrencyIdTo
				--,intCurrencyExchangeRateTypeId = A.[intCurrencyExchangeRateTypeId]
				,intCurrencyExchangeRateTypeId =CASE WHEN @ysnFunctionalToForeign =1 or @ysnForeignToForeign = 1 THEN A.intCurrencyExchangeRateTypeId ELSE NULL END  
				,dblExchangeRate			=  CASE WHEN @ysnFunctionalToForeign = 1 or @ysnForeignToForeign = 1 THEN  ISNULL(@dblRate,1) ELSE 1 END
				,dtmDate					= A.dtmDate
				,strPayee					= ''
				,intPayeeId					= NULL
				,strAddress					= ''
				,strZipCode					= ''
				,strCity					= ''
				,strState					= ''
				,strCountry					= ''
				,dblAmount					= AmountUSD.Val
				,strAmountInWords			= dbo.fnConvertNumberToWord(AmountUSD.Val)
				,strMemo					= CASE WHEN ISNULL(A.strReferenceTo,'') = '' THEN 
												A.strDescription 
												WHEN ISNULL(A.strDescription,'') = '' THEN
												A.strReferenceTo
												ELSE A.strDescription + ' / ' + A.strReferenceTo 
											  END
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
				OUTER APPLY(
					SELECT CASE WHEN @intCurrencyIdFrom <> @intCurrencyIdTo
												AND @intCurrencyIdTo <> @intDefaultCurrencyId
												AND @intCurrencyIdFrom = @intDefaultCurrencyId
												THEN ROUND(dblAmount/A.dblRate,2)
											  WHEN
												@intCurrencyIdFrom <> @intCurrencyIdTo
												AND @intCurrencyIdTo = @intDefaultCurrencyId
												AND @intCurrencyIdFrom <> @intDefaultCurrencyId


											 THEN ROUND(dblAmount*A.dblRate,2)
											 ELSE A.dblAmount END
											 Val
				)AmountUSD
				OUTER APPLY(
					SELECT ROUND(A.dblAmount / ISNULL(A.dblRate,1),2)Val
				)AmountForeign
		WHERE	A.strTransactionId = @strTransactionId
	END
	ELSE
	BEGIN
		DELETE FROM tblCMBankTransaction
		WHERE	strLink = @strTransactionId
				AND ysnClr = 0
				AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)
	END
	IF @@ERROR <> 0	GOTO Post_Rollback
END
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
			,@ysnBatch
	GOTO Post_Exit

Audit_Log:
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
   
	EXEC uspSMAuditLog 
	   @keyValue = @intTransactionId       -- Primary Key Value of the Bank Deposit. 
	   ,@screenName = 'CashManagement.view.BankTransfer'        -- Screen Namespace
	   ,@entityId = @intUserId     -- Entity Id.
	   ,@actionType = @actionType                             -- Action Type
	   ,@changeDescription = @strDescription     -- Description
	   ,@fromValue = ''          -- Previous Value
	   ,@toValue = ''           -- New Value
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail