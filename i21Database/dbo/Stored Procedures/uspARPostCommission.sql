CREATE PROCEDURE [dbo].[uspARPostCommission]
	@batchId			AS NVARCHAR(40)		= NULL
	,@post				AS BIT				= 0
	,@recap				AS BIT				= 0
	,@param				AS NVARCHAR(MAX)	= NULL
	,@userId			AS INT				= 1
	,@beginDate			AS DATE				= NULL
	,@endDate			AS DATE				= NULL
	,@beginTransaction	AS NVARCHAR(50)		= NULL
	,@endTransaction	AS NVARCHAR(50)		= NULL
	,@exclude			AS NVARCHAR(MAX)	= NULL
	,@successfulCount	AS INT				= 0 OUTPUT
	,@invalidCount		AS INT				= 0 OUTPUT
	,@success			AS BIT				= 0 OUTPUT
	,@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	,@transType			AS NVARCHAR(25)		= 'all'
	,@raiseError		AS BIT				= 0
	,@companyLocationId	AS INT				= NULL
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS ON  

IF @raiseError = 1
	SET XACT_ABORT ON

DECLARE @GLEntries						RecapTableType
DECLARE @PostCommissionData				CommissionPostingTable
DECLARE @InvalidCommissionData			TABLE (intCommissionId INT, strCommissionNumber NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, strBatchId NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, strPostingError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL)
DECLARE @PostDate						DATETIME = GETDATE()
DECLARE @PostSuccessfulMsg				NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg			NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME					NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME					NVARCHAR(25) = 'Commissions'
DECLARE @CODE							NVARCHAR(25) = 'AR'
DECLARE @POSTDESC						NVARCHAR(10) = 'Posted '
DECLARE @intEntityUserId				INT = ISNULL((SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WITH (NOLOCK) WHERE intEntityId = @userId), @userId)
DECLARE @intDefaultCurrencyId			INT = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
DECLARE @strCurrencyExchangeRateType	NVARCHAR(100) = (SELECT TOP 1 SMC.strCurrencyExchangeRateType FROM tblSMMultiCurrency SM INNER JOIN tblSMCurrencyExchangeRateType SMC ON SM.intAccountsReceivableRateTypeId = SMC.intCurrencyExchangeRateTypeId)
DECLARE @ZeroDecimal					DECIMAL(18,6) = 0
DECLARE @intCommissionExpenseAccountId  INT = NULL
DECLARE @intAPAccountId					INT = NULL
DECLARE @totalRecords					INT = 0
DECLARE @totalInvalid					INT = 0
DECLARE @ErrorMerssage					NVARCHAR(MAX)

SELECT TOP 1 @intCommissionExpenseAccountId = intCommissionExpenseAccountId
FROM dbo.tblARCompanyPreference

SELECT TOP 1 @intAPAccountId = intAPAccount 
FROM dbo.tblSMCompanyLocation 
WHERE intCompanyLocationId = @companyLocationId

SET @post		= ISNULL(@post, 0)
SET @recap		= ISNULL(@recap, 0)
SET @recapId	= '1'
SET @success	= 1
SET @param		= NULLIF(@param, '')
SET @exclude	= NULLIF(@exclude, '')

IF(LEN(RTRIM(LTRIM(ISNULL(@batchId,'')))) = 0)
	EXEC dbo.uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--GET COMMISSIONS TO POST
IF @param IS NOT NULL
	BEGIN
		INSERT INTO @PostCommissionData (
			 [intCommissionId]
			,[intCommissionExpenseAccountId]
			,[intAPAccountId]
			,[intCompanyLocationId]
			,[strCommissionNumber]
			,[strBatchId]
			,[dblTotalAmount]
			,[ysnPosted]
			,[ysnPaid]
		)
		SELECT [intCommissionId]				= [intCommissionId]	
			,[intCommissionExpenseAccountId]	= @intCommissionExpenseAccountId
			,[intAPAccountId]					= @intAPAccountId
			,[intCompanyLocationId]				= @companyLocationId
			,[strCommissionNumber]				= [strCommissionNumber]
			,[strBatchId]						= @batchIdUsed
			,[dblTotalAmount]					= [dblTotalAmount]
			,[ysnPosted]						= [ysnPosted]
			,[ysnPaid]							= [ysnPaid]
		FROM tblARCommission C
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@param)
		) D ON C.intCommissionId = D.intID
	END
ELSE
	BEGIN
		INSERT INTO @PostCommissionData (
			 [intCommissionId]
			,[intCommissionExpenseAccountId]
			,[intAPAccountId]
			,[intCompanyLocationId]
			,[strCommissionNumber]
			,[strBatchId]
			,[dblTotalAmount]
			,[ysnPosted]
			,[ysnPaid]
		)
		SELECT [intCommissionId]				= [intCommissionId]	
			,[intCommissionExpenseAccountId]	= @intCommissionExpenseAccountId
			,[intAPAccountId]					= @intAPAccountId
			,[intCompanyLocationId]				= @companyLocationId
			,[strCommissionNumber]				= [strCommissionNumber]
			,[strBatchId]						= @batchIdUsed
			,[dblTotalAmount]					= [dblTotalAmount]
			,[ysnPosted]						= [ysnPosted]
			,[ysnPaid]							= [ysnPaid]
		FROM tblARCommission
	END

IF(@exclude IS NOT NULL)
	BEGIN		
		DELETE FROM A
		FROM @PostCommissionData A
		WHERE intCommissionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@exclude))
	END
	
--VALIDATE RECORDS TO POST
INSERT INTO @InvalidCommissionData (
	 [intCommissionId]
	,[strCommissionNumber]
	,[strBatchId]
	,[strPostingError])
SELECT
	 [intCommissionId]		= [intCommissionId]
	,[strCommissionNumber]	= [strCommissionNumber]
	,[strBatchId]			= [strBatchId]
	,[strPostingError]		= [strPostingError]
FROM [dbo].[fnARGetInvalidCommissionForPosting](@PostCommissionData, @post, @recap)

SELECT @totalInvalid = COUNT(*) FROM @InvalidCommissionData

IF(@totalInvalid > 0)
	BEGIN
		--Insert Invalid Post transaction result
		INSERT INTO tblARPostResult(
			  [strMessage]
			, [strTransactionType]
			, [strTransactionId]
			, [strBatchNumber]
			, [intTransactionId]
		)
		SELECT [strMessage]			= [strPostingError]
			, [strTransactionType]	= 'Commissions'
			, [strTransactionId]	= [strCommissionNumber]
			, [strBatchNumber]		= [strBatchId]
			, [intTransactionId]	= [intCommissionId]
		FROM @InvalidCommissionData
		ORDER BY strPostingError DESC

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE @PostCommissionData
		FROM @PostCommissionData A
		INNER JOIN @InvalidCommissionData B ON A.intCommissionId = B.intCommissionId
				
		IF @raiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingError] FROM @InvalidCommissionData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END					
	END

SELECT @totalRecords = COUNT(*) FROM @PostCommissionData
			
IF(@totalInvalid >= 1 AND @totalRecords <= 0)
	BEGIN
		IF @raiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingError] FROM @InvalidCommissionData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END				
		GOTO Post_Exit	
	END

--INSERT GL ENTRIES
IF @post = 1
	BEGIN
		INSERT INTO @GLEntries (
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
			,[dblForeignRate]
			,[strRateType]
		)
		SELECT
			 [dtmDate]					= @PostDate
			,[strBatchID]				= @batchIdUsed
			,[intAccountId]				= @intAPAccountId
			,[dblDebit]					= COMM.dblTotalAmount
			,[dblCredit]				= @ZeroDecimal
			,[dblDebitUnit]				= @ZeroDecimal
			,[dblCreditUnit]			= @ZeroDecimal
			,[strDescription]			= ''
			,[strCode]					= @CODE
			,[strReference]				= E.strEntityNo
			,[intCurrencyId]			= @intDefaultCurrencyId
			,[dblExchangeRate]			= 1
			,[dtmDateEntered]			= @PostDate
			,[dtmTransactionDate]		= @PostDate
			,[strJournalLineDescription]= @POSTDESC + 'Commission'
			,[intJournalLineNo]			= COMM.intCommissionId
			,[ysnIsUnposted]			= 0
			,[intUserId]				= @userId
			,[intEntityId]				= @intEntityUserId				
			,[strTransactionId]			= COMM.strCommissionNumber
			,[intTransactionId]			= COMM.intCommissionId
			,[strTransactionType]		= 'Calculate Commission'
			,[strTransactionForm]		= @SCREEN_NAME
			,[strModuleName]			= @MODULE_NAME
			,[intConcurrencyId]			= 1
			,[dblDebitForeign]			= COMM.dblTotalAmount
			,[dblDebitReport]			= COMM.dblTotalAmount
			,[dblCreditForeign]			= @ZeroDecimal
			,[dblCreditReport]			= @ZeroDecimal
			,[dblReportingRate]			= @ZeroDecimal
			,[dblForeignRate]			= @ZeroDecimal
			,[strRateType]				= @strCurrencyExchangeRateType
		FROM dbo.tblARCommission COMM
		INNER JOIN @PostCommissionData PCD ON COMM.intCommissionId = PCD.intCommissionId
		LEFT JOIN (
			SELECT intEntityId
				 , strEntityNo
			FROM tblEMEntity WITH (NOLOCK)
		) E ON COMM.intEntityId = E.intEntityId

		UNION ALL

		SELECT
			 [dtmDate]					= @PostDate
			,[strBatchID]				= @batchIdUsed
			,[intAccountId]				= @intCommissionExpenseAccountId
			,[dblDebit]					= @ZeroDecimal
			,[dblCredit]				= COMM.dblTotalAmount
			,[dblDebitUnit]				= @ZeroDecimal
			,[dblCreditUnit]			= @ZeroDecimal
			,[strDescription]			= ''
			,[strCode]					= @CODE
			,[strReference]				= E.strEntityNo
			,[intCurrencyId]			= @intDefaultCurrencyId
			,[dblExchangeRate]			= 1
			,[dtmDateEntered]			= @PostDate
			,[dtmTransactionDate]		= @PostDate
			,[strJournalLineDescription]= @POSTDESC + 'Commission'
			,[intJournalLineNo]			= COMM.intCommissionId
			,[ysnIsUnposted]			= 0
			,[intUserId]				= @userId
			,[intEntityId]				= @intEntityUserId				
			,[strTransactionId]			= COMM.strCommissionNumber
			,[intTransactionId]			= COMM.intCommissionId
			,[strTransactionType]		= 'Calculate Commission'
			,[strTransactionForm]		= @SCREEN_NAME
			,[strModuleName]			= @MODULE_NAME
			,[intConcurrencyId]			= 1
			,[dblDebitForeign]			= @ZeroDecimal
			,[dblDebitReport]			= @ZeroDecimal
			,[dblCreditForeign]			= COMM.dblTotalAmount
			,[dblCreditReport]			= COMM.dblTotalAmount
			,[dblReportingRate]			= @ZeroDecimal
			,[dblForeignRate]			= @ZeroDecimal
			,[strRateType]				= @strCurrencyExchangeRateType
		FROM dbo.tblARCommission COMM
		INNER JOIN @PostCommissionData PCD ON COMM.intCommissionId = PCD.intCommissionId
		LEFT JOIN (
			SELECT intEntityId
				 , strEntityNo
			FROM tblEMEntity WITH (NOLOCK)
		) E ON COMM.intEntityId = E.intEntityId
	END
ELSE
	BEGIN
		INSERT INTO @GLEntries (
			 [dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dblDebitForeign]
			,[dblCreditForeign]
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
			,[strRateType]
		)
		SELECT	
			 [dtmDate]						= GLD.dtmDate 
			,[strBatchId]					= @batchIdUsed
			,[intAccountId]					= GLD.intAccountId
			,[dblDebit]						= GLD.dblCredit
			,[dblCredit]					= GLD.dblDebit
			,[dblDebitUnit]					= GLD.dblCreditUnit
			,[dblCreditUnit]				= GLD.dblDebitUnit
			,[dblDebitForeign]				= GLD.dblCreditForeign
			,[dblCreditForeign]				= GLD.dblDebitForeign				
			,[strDescription]				= GLD.strDescription
			,[strCode]						= GLD.strCode
			,[strReference]					= GLD.strReference
			,[intCurrencyId]				= GLD.intCurrencyId
			,[dblExchangeRate]				= GLD.dblExchangeRate
			,[dtmDateEntered]				= @PostDate
			,[dtmTransactionDate]			= GLD.dtmTransactionDate
			,[strJournalLineDescription]	= REPLACE(GLD.strJournalLineDescription, @POSTDESC, 'Unposted ')
			,[intJournalLineNo]				= GLD.intJournalLineNo 
			,[ysnIsUnposted]				= 1
			,[intUserId]					= @userId
			,[intEntityId]					= @intEntityUserId
			,[strTransactionId]				= GLD.strTransactionId
			,[intTransactionId]				= GLD.intTransactionId
			,[strTransactionType]			= GLD.strTransactionType
			,[strTransactionForm]			= GLD.strTransactionForm
			,[strModuleName]				= GLD.strModuleName
			,[intConcurrencyId]				= GLD.intConcurrencyId
			,[strRateType]					= @strCurrencyExchangeRateType
		FROM @PostCommissionData PCD
		INNER JOIN (
			SELECT dtmDate, intAccountId, intGLDetailId, intTransactionId, strTransactionId, strDescription, strCode, strReference, intCurrencyId, dblExchangeRate, dtmTransactionDate, 
				strJournalLineDescription, intJournalLineNo, strTransactionType, strTransactionForm, strModuleName, intConcurrencyId, dblCredit, dblDebit, dblCreditUnit, dblDebitUnit, ysnIsUnposted,
				dblCreditForeign, dblDebitForeign
			FROM dbo.tblGLDetail WITH (NOLOCK)
			WHERE ysnIsUnposted = 0
		) GLD ON PCD.intCommissionId = GLD.intTransactionId
			 AND PCD.strCommissionNumber = GLD.strTransactionId		
		ORDER BY GLD.intGLDetailId		
	END

--INSERT TO RECAP TABLE
IF @recap = 1
	BEGIN
		DELETE GLDR  
		FROM @PostCommissionData PCD  
		INNER JOIN (
			SELECT intTransactionId
				 , strTransactionId
			FROM dbo.tblGLDetailRecap WITH (NOLOCK)
			WHERE strCode = @CODE
		) GLDR ON PCD.strCommissionNumber = GLDR.strTransactionId 
			  AND PCD.intCommissionId = GLDR.intTransactionId
		   
		INSERT INTO tblGLPostRecap(
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dblDebitForeign]
			,[dblCreditForeign]			
			,[intCurrencyId]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
			,[strAccountId]
			,[strAccountGroup]
			,[strRateType]
		)
		SELECT
			 [strTransactionId]					= A.[strTransactionId]
			,[intTransactionId]					= A.[intTransactionId]
			,[intAccountId]						= A.[intAccountId]
			,[strDescription]					= B.[strDescription]
			,[strJournalLineDescription]		= A.[strJournalLineDescription]
			,[strReference]						= A.[strReference]	
			,[dtmTransactionDate]				= A.[dtmTransactionDate]
			,[dblDebit]							= Debit.[Value]
			,[dblCredit]						= Credit.[Value]
			,[dblDebitUnit]						= DebitUnit.[Value]
			,[dblCreditUnit]					= CreditUnit.[Value]
			,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @intDefaultCurrencyId THEN 0.00 ELSE A.[dblDebitForeign] END
			,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @intDefaultCurrencyId THEN 0.00 ELSE A.[dblCreditForeign] END
			,[intCurrencyId]					= A.[intCurrencyId]
			,[dtmDate]							= A.[dtmDate]
			,[ysnIsUnposted]					= A.[ysnIsUnposted]
			,[intConcurrencyId]					= A.[intConcurrencyId]	
			,[dblExchangeRate]					= CASE WHEN A.[intCurrencyId] = @intDefaultCurrencyId THEN 0.00 ELSE A.[dblExchangeRate] END
			,[intUserId]						= A.[intUserId]
			,[dtmDateEntered]					= A.[dtmDateEntered]
			,[strBatchId]						= A.[strBatchId]
			,[strCode]							= A.[strCode]
			,[strModuleName]					= A.[strModuleName]
			,[strTransactionForm]				= A.[strTransactionForm]
			,[strTransactionType]				= A.[strTransactionType]
			,[strAccountId]						= B.[strAccountId]
			,strAccountGroup					= C.[strAccountGroup]
			,[strRateType]						= @strCurrencyExchangeRateType
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId			
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit		
	END
ELSE 
	BEGIN
		IF @post = 0
			BEGIN
				UPDATE GLD
				SET GLD.ysnIsUnposted = 1
				FROM tblGLDetail GLD
				INNER JOIN @PostCommissionData PCD ON PCD.intCommissionId = GLD.intTransactionId AND PCD.strCommissionNumber = GLD.strTransactionId
			END

		IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries		= @GLEntries
										, @ysnPost			= @post
										, @XACT_ABORT_ON	= @raiseError
			END

		DECLARE @tmpBatchId NVARCHAR(100)

		SELECT @tmpBatchId = [strBatchId] 
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit

		UPDATE tblGLPostRecap 
		SET dblCreditForeign = CASE WHEN intCurrencyId = @intDefaultCurrencyId THEN 0.00 ELSE dblDebitForeign END
		  , dblDebitForeign = CASE WHEN intCurrencyId = @intDefaultCurrencyId THEN 0.00 ELSE dblDebitForeign END
		  , dblExchangeRate = CASE WHEN intCurrencyId = @intDefaultCurrencyId THEN 0.00 ELSE dblExchangeRate END
		  , strRateType = CASE WHEN intCurrencyId = @intDefaultCurrencyId THEN NULL ELSE strRateType END
		WHERE tblGLPostRecap.strBatchId = @tmpBatchId

		UPDATE COMM
		SET ysnPosted = CASE WHEN @post = 1 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
		FROM tblARCommission COMM
		INNER JOIN @PostCommissionData PDC ON COMM.intCommissionId = PDC.intCommissionId AND COMM.strCommissionNumber = PDC.strCommissionNumber

		RETURN 1;
	END

Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;