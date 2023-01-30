CREATE PROCEDURE [dbo].[uspARPostPaymentRecap]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@BatchId           NVARCHAR(40)
    ,@PostDate          DATETIME                
    ,@UserId            INT
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@raiseError		AS BIT				= 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '


DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000

DECLARE @ErrorMerssage NVARCHAR(MAX)
DECLARE @DelimitedIds VARCHAR(MAX)
DECLARE @TransactionName AS VARCHAR(500) = 'Payment Transaction' + CAST(NEWID() AS NVARCHAR(100));
IF @@TRANCOUNT = 0
	BEGIN TRANSACTION @TransactionName
ELSE	 
	SAVE TRAN @TransactionName

BEGIN TRY

    DECLARE @StartingNumberId INT
    SET @StartingNumberId = 3
    IF(LEN(RTRIM(LTRIM(ISNULL(@BatchId,'')))) = 0)
    BEGIN
        EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @BatchId OUT
    END

	SET @BatchIdUsed = @BatchId

    IF @Post = 1
        EXEC [dbo].[uspARPrePostPaymentIntegration]

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('ARPostPaymentNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
            
			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intTransactionId] AS NVARCHAR(250))
			FROM
				#ARPostPaymentHeader
			WHERE
				[ysnRecap] = 1
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Receive Payment', @ErrorMerssage, @DelimitedIds

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

BEGIN TRY
IF(OBJECT_ID('tempdb..#ARPaymentGLEntries') IS NOT NULL)
    BEGIN
        DROP TABLE #ARPaymentGLEntries
    END
	CREATE TABLE #ARPaymentGLEntries
	([dtmDate]                  DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign]			NUMERIC (18, 9) NULL,
	[dblDebitReport]			NUMERIC (18, 9) NULL,
	[dblCreditForeign]			NUMERIC (18, 9) NULL,
	[dblCreditReport]			NUMERIC (18, 9) NULL,
	[dblReportingRate]			NUMERIC (18, 9) NULL,
	[dblForeignRate]			NUMERIC (18, 9) NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[strRateType]			    NVARCHAR(50)	COLLATE Latin1_General_CI_AS,
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intSourceLocationId]		INT NULL,
	[intSourceUOMId]			INT NULL,
	[dblSourceUnitDebit]		NUMERIC (18, 6)  NULL,
	[dblSourceUnitCredit]		NUMERIC (18, 6)  NULL,
	[intCommodityId]			INT NULL,
	intSourceEntityId INT NULL,
	ysnRebuild BIT NULL)
	
    EXEC [dbo].[uspARGeneratePaymentGLEntries]
         @Post     = @Post
	    ,@Recap    = @Recap
        ,@PostDate = @PostDate
        ,@BatchId  = @BatchIdUsed
        ,@UserId   = @UserId

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('ARPostPaymentNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
            
			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intTransactionId] AS NVARCHAR(250))
			FROM
				#ARPostPaymentHeader
			WHERE
				[ysnRecap] = 1
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Receive Payment', @ErrorMerssage, @DelimitedIds

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

DECLARE @Payment [ReceivePaymentPostingTable]
INSERT @Payment
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
    ,[dtmDatePaid]
    ,[dtmPostDate]
    ,[intWriteOffAccountId]
    ,[intAccountId]
    ,[intBankAccountId]
    ,[intARAccountId]
    ,[intDiscountAccount]
    ,[intInterestAccount]
    ,[intCFAccountId]
    ,[intGainLossAccount]
    ,[intEntityCardInfoId]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]

    ,[dblAmountPaid]
    ,[dblBaseAmountPaid]
    ,[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]
    ,[dblPayment]
    ,[dblBasePayment]
    ,[dblDiscount]
    ,[dblBaseDiscount]
    ,[dblInterest]
    ,[dblBaseInterest]
    ,[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]
    ,[dblAmountDue]
    ,[dblBaseAmountDue]

    ,[intInvoiceId]
    ,[ysnExcludedFromPayment]
    ,[ysnForgiven]
	,[intBillId]
    ,[strTransactionNumber]
    ,[strTransactionType]
    ,[strType]
    ,[intTransactionAccountId]
    ,[ysnTransactionPosted]
	,[ysnTransactionPaid]
    ,[ysnTransactionProcessed]
    ,[dtmTransactionPostDate]
	,[dblTransactionDiscount]
    ,[dblBaseTransactionDiscount]
    ,[dblTransactionInterest]
    ,[dblBaseTransactionInterest]
    ,[dblTransactionAmountDue]
    ,[dblBaseTransactionAmountDue]
    ,[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]
    ,[strRateType])
SELECT 
     [intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
    ,[dtmDatePaid]
    ,[dtmPostDate]
    ,[intWriteOffAccountId]
    ,[intAccountId]
    ,[intBankAccountId]
    ,[intARAccountId]
    ,[intDiscountAccount]
    ,[intInterestAccount]
    ,[intCFAccountId]
    ,[intGainLossAccount]
    ,[intEntityCardInfoId]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]

    ,[dblAmountPaid]
    ,[dblBaseAmountPaid]
    ,[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]
    ,[dblPayment]
    ,[dblBasePayment]
    ,[dblDiscount]
    ,[dblBaseDiscount]
    ,[dblInterest]
    ,[dblBaseInterest]
    ,[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]
    ,[dblAmountDue]
    ,[dblBaseAmountDue]

    ,[intInvoiceId]
    ,[ysnExcludedFromPayment]
    ,[ysnForgiven]
	,[intBillId]
    ,[strTransactionNumber]
    ,[strTransactionType]
    ,[strType]
    ,[intTransactionAccountId]
    ,[ysnTransactionPosted]
	,[ysnTransactionPaid]
    ,[ysnTransactionProcessed]
    ,[dtmTransactionPostDate]
	,[dblTransactionDiscount]
    ,[dblBaseTransactionDiscount]
    ,[dblTransactionInterest]
    ,[dblBaseTransactionInterest]
    ,[dblTransactionAmountDue]
    ,[dblBaseTransactionAmountDue]
    ,[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]
    ,[strRateType]
FROM
    #ARPostPaymentHeader

DECLARE @GLEntries RecapTableType
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
FROM
    #ARPaymentGLEntries

DECLARE @DefaultCurrencyId                  INT
        ,@DefaultCurrencyExchangeRateTypeId INT

SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)

ROLLBACK TRAN @TransactionName		

BEGIN TRY	

    DELETE FROM tblGLPostRecap WHERE [strBatchId] = @BatchId
		 
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
			,[intCurrencyId]
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			,[strDescription]					= B.strDescription
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value
			,Credit.Value
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,[dblDebitForeign]					= A.[dblDebitForeign]
			,[dblCreditForeign]					= A.[dblCreditForeign]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,[dblExchangeRate]					= A.dblForeignRate
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,[strRateType]						= A.[strRateType]
			,A.[intCurrencyId]
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit
				

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('ARPostPaymentNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
            
			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intTransactionId] AS NVARCHAR(250))
			FROM
				#ARPostPaymentHeader
			WHERE
				[ysnRecap] = 1
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Receive Payment', @ErrorMerssage, @DelimitedIds

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

	RETURN 1;

Post_Exit:
	RETURN 0;