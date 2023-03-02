﻿CREATE PROCEDURE [dbo].[uspARPostInvoiceRecap]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@BatchId           NVARCHAR(40)
    ,@PostDate          DATETIME                
    ,@UserId            INT
	,@BatchIdUsed		NVARCHAR(40)	= NULL OUTPUT
	,@strSessionId		NVARCHAR(50)	= NULL
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

DECLARE @GLEntries 							RecapTableType
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
	
	EXEC dbo.uspARGenerateGLEntries @Post			= @Post
								  , @Recap			= 1
								  , @PostDate		= @PostDate
								  , @BatchId		= @BatchIdUsed
								  , @UserId			= @UserId
								  , @strSessionId 	= @strSessionId 

	INSERT INTO @GLEntries
		([dtmDate]
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
		,[strDocument]
		,[strComments]
		,[strSourceDocumentId]
		,[intSourceLocationId]
		,[intSourceUOMId]
		,[dblSourceUnitDebit]
		,[dblSourceUnitCredit]
		,[intCommodityId]
		,[intSourceEntityId]
		,[ysnRebuild])
	SELECT
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
		,[strDocument]
		,[strComments]
		,[strSourceDocumentId]
		,[intSourceLocationId]
		,[intSourceUOMId]
		,[dblSourceUnitDebit]
		,[dblSourceUnitCredit]
		,[intCommodityId]
		,[intSourceEntityId]
		,[ysnRebuild]
	FROM tblARPostInvoiceGLEntries
	WHERE strSessionId = @strSessionId

	IF @InitTranCount = 0
		ROLLBACK TRANSACTION
	ELSE
		ROLLBACK TRANSACTION @Savepoint
    
    DELETE  Q
    FROM tblARPostingQueue Q
    INNER JOIN tblARPostInvoiceHeader I ON Q.strTransactionNumber = I.strInvoiceNumber
	WHERE I.strSessionId = @strSessionId
    
    DELETE FROM tblGLPostRecap WHERE [strBatchId] = @BatchIdUsed
		 
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
		,[intCurrencyExchangeRateTypeId]
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
		,[dblDebitForeign]					= A.dblDebitForeign
		,[dblCreditForeign]					= A.dblCreditForeign	
		,[intCurrencyId]					= A.[intCurrencyId]
		,[dtmDate]							= A.[dtmDate]
		,[ysnIsUnposted]					= A.[ysnIsUnposted]
		,[intConcurrencyId]					= A.[intConcurrencyId]	
		,[dblExchangeRate]					= ISNULL(A.dblExchangeRate, @OneDecimal)
		,[intUserId]						= A.[intUserId]
		,[dtmDateEntered]					= A.[dtmDateEntered]
		,[strBatchId]						= A.[strBatchId]
		,[strCode]							= A.[strCode]
		,[strModuleName]					= A.[strModuleName]
		,[strTransactionForm]				= A.[strTransactionForm]
		,[strTransactionType]				= A.[strTransactionType]
		,[strAccountId]						= B.[strAccountId]
		,[strAccountGroup]					= C.[strAccountGroup]
		,[strRateType]						= A.strRateType
		,[intCurrencyExchangeRateTypeId]	= A.[intCurrencyExchangeRateTypeId]
	FROM @GLEntries A
	INNER JOIN dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
	INNER JOIN dbo.tblGLAccountGroup C ON B.intAccountGroupId = C.intAccountGroupId			
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Credit
	CROSS APPLY dbo.fnGetDebitUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) DebitUnit
	CROSS APPLY dbo.fnGetCreditUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) CreditUnit
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

RETURN 1;

Post_Exit:
	RETURN 0;