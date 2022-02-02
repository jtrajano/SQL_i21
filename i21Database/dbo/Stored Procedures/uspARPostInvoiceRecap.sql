CREATE PROCEDURE [dbo].[uspARPostInvoiceRecap]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@BatchId           NVARCHAR(40)
    ,@PostDate          DATETIME                
    ,@UserId            INT
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION @Savepoint

DECLARE @MODULE_NAME						NVARCHAR(25) = 'Accounts Receivable'
	  , @SCREEN_NAME						NVARCHAR(25) = 'Invoice'
	  , @CODE								NVARCHAR(25) = 'AR'
	  , @POSTDESC							NVARCHAR(10) = 'Posted '
	  , @ErrorMerssage						NVARCHAR(MAX)
	  , @DelimitedIds						VARCHAR(MAX)
	  , @ZeroDecimal						DECIMAL(18,6) = 0
	  , @OneDecimal							DECIMAL(18,6) = 1
	  , @StartingNumberId					INT = 3
	  , @DefaultCurrencyId					INT
      , @DefaultCurrencyExchangeRateTypeId	INT

BEGIN TRY    
    IF(LEN(RTRIM(LTRIM(ISNULL(@BatchId,'')))) = 0)
    BEGIN
        EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @BatchId OUT
    END

	SET @BatchIdUsed = @BatchId
	SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
	SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)

	EXEC [dbo].[uspARPostItemResevation]

	IF @Post = 1
		BEGIN
			EXEC [dbo].[uspARProcessSplitOnInvoicePost] @ysnPost	  	= @Post
													  , @ysnRecap	  	= @Recap
													  , @dtmDatePost	= @PostDate
													  , @strBatchId		= @BatchIdUsed
													  , @intUserId		= @UserId
			EXEC [dbo].[uspARPrePostInvoiceIntegration]
			EXEC [dbo].[uspARUpdateTransactionAccountOnPost]  
			EXEC [dbo].uspARGenerateEntriesForAccrual  
			EXEC [dbo].[uspARGenerateGLEntries] @Post     = @Post
											  , @Recap    = @Recap
											  , @PostDate = @PostDate
											  , @BatchId  = @BatchIdUsed
											  , @UserId   = @UserId
		END
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
    IF @InitTranCount = 0
        IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
	ELSE
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @Savepoint
												
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

IF @InitTranCount = 0
	ROLLBACK TRANSACTION
ELSE
	ROLLBACK TRANSACTION @Savepoint

BEGIN TRY	
    DELETE FROM tblGLPostRecap WHERE [strBatchId] = @BatchId
		 
	INSERT INTO tblGLPostRecap WITH (TABLOCK) (
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
	SELECT [strTransactionId]				= A.[strTransactionId]
		,[intTransactionId]					= A.[intTransactionId]
		,[intAccountId]						= A.[intAccountId]
		,[strDescription]					= B.strDescription
		,[strJournalLineDescription]		= A.[strJournalLineDescription]
		,[strReference]						= A.[strReference]	
		,[dtmTransactionDate]				= A.[dtmTransactionDate]
		,[dblDebit]							= Debit.[Value]
		,[dblCredit]						= Credit.[Value]
		,[dblDebitUnit]						= DebitUnit.[Value]
		,[dblCreditUnit]					= CreditUnit.[Value]
		,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN @ZeroDecimal ELSE A.[dblDebitForeign] END
		,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN @ZeroDecimal ELSE A.[dblCreditForeign]	 END 		
		,[intCurrencyId]					= A.[intCurrencyId]
		,[dtmDate]							= A.[dtmDate]
		,[ysnIsUnposted]					= A.[ysnIsUnposted]
		,[intConcurrencyId]					= A.[intConcurrencyId]	
		,[dblExchangeRate]					= ISNULL(RATETYPE.dblCurrencyExchangeRate, @OneDecimal)
		,[intUserId]						= A.[intUserId]
		,[dtmDateEntered]					= A.[dtmDateEntered]
		,[strBatchId]						= A.[strBatchId]
		,[strCode]							= A.[strCode]
		,[strModuleName]					= A.[strModuleName]
		,[strTransactionForm]				= A.[strTransactionForm]
		,[strTransactionType]				= A.[strTransactionType]
		,[strAccountId]						= B.[strAccountId]
		,[strAccountGroup]					= C.[strAccountGroup]
		,[strRateType]						= RATETYPE.strCurrencyExchangeRateType
	FROM ##ARInvoiceGLEntries A
	INNER JOIN dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
	INNER JOIN dbo.tblGLAccountGroup C ON B.intAccountGroupId = C.intAccountGroupId			
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Credit
	CROSS APPLY dbo.fnGetDebitUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) DebitUnit
	CROSS APPLY dbo.fnGetCreditUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) CreditUnit
	OUTER APPLY (
		SELECT SMCERT.strCurrencyExchangeRateType,dblBaseInvoiceTotal,dblInvoiceTotal,dblCurrencyExchangeRate
		FROM dbo.tblARInvoice I
		CROSS APPLY (
			SELECT TOP 1 intCurrencyExchangeRateTypeId = ISNULL(intCurrencyExchangeRateTypeId, @DefaultCurrencyExchangeRateTypeId)
			FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
			WHERE intInvoiceId = I.intInvoiceId
		) ID
		INNER JOIN tblSMCurrencyExchangeRateType SMCERT WITH (NOLOCK) ON SMCERT.intCurrencyExchangeRateTypeId = ID.intCurrencyExchangeRateTypeId
		WHERE I.strInvoiceNumber = A.strTransactionId 
			AND I.intInvoiceId = A.intTransactionId
	) RATETYPE
				

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()
	RAISERROR(@ErrorMerssage, 11, 1)
END CATCH

RETURN 1;

Post_Exit:
	RETURN 0;