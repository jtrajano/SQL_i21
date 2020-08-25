CREATE PROCEDURE [dbo].[uspARPostPayment]
	@batchId			AS NVARCHAR(40)		= NULL
	,@post				AS BIT				= 0
	,@recap				AS BIT				= 0
	,@param				AS NVARCHAR(MAX)	= NULL
	,@userId				AS INT				= 1
	,@beginDate			AS DATE				= NULL
	,@endDate			AS DATE				= NULL
	,@beginTransaction	AS NVARCHAR(50)		= NULL
	,@endTransaction		AS NVARCHAR(50)		= NULL
	,@exclude			AS NVARCHAR(MAX)	= NULL
	,@successfulCount	AS INT				= 0 OUTPUT
	,@invalidCount		AS INT				= 0 OUTPUT
	,@success			AS BIT				= 0 OUTPUT
	,@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	,@transType			AS NVARCHAR(25)		= 'all'
	,@raiseError		AS BIT				= 0
	,@bankAccountId	AS INT				= NULL
	,@ysnForFinalInvoice	AS BIT = 0

WITH RECOMPILE
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()
DECLARE @DateNow AS DATETIME
SET @PostDate = CAST(@PostDate AS DATE)

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000
DECLARE @OneHundredDecimal DECIMAL(18,6)
SET @OneHundredDecimal = 100.000000
DECLARE @ZeroBit BIT
SET @ZeroBit = CAST(0 AS BIT)
DECLARE @OneBit BIT
SET @OneBit = CAST(1 AS BIT)

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)


SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostPayment' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

DECLARE @ErrorMerssage NVARCHAR(MAX)

SET @recapId = '1'
SET @success = @OneBit
SET @post = ISNULL(@post, @ZeroBit)
SET @recap = ISNULL(@recap, @ZeroBit)

IF(LEN(RTRIM(LTRIM(ISNULL(@batchId,'')))) = 0) AND @recap = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 3, @batchId OUT
END
SET @batchIdUsed = @batchId

IF(OBJECT_ID('tempdb..#ARPostPaymentHeader') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostPaymentHeader
END
CREATE TABLE #ARPostPaymentHeader
    ([intTransactionId]                 INT             NOT NULL PRIMARY KEY
    ,[intTransactionDetailId]           INT             NULL
    ,[strTransactionId]                 NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NOT NULL UNIQUE NONCLUSTERED
    ,[strReceivePaymentType]            NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[intEntityCustomerId]              INT             NOT NULL
    ,[strCustomerNumber]                NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[strCustomerName]                  NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[intCompanyLocationId]             INT             NULL
    ,[strLocationName]                  NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[intUndepositedFundsId]            INT             NULL
    ,[intSalesAdvAcct]                  INT             NULL	
    ,[intCurrencyId]                    INT             NOT NULL
    ,[intPaymentMethodId]               INT             NOT NULL
    ,[strPaymentMethod]                 NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[strNotes]                         NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
	,[intExchangeRateTypeId]			INT												NULL
	,[dblExchangeRate]					NUMERIC(18, 6)									NULL
    ,[dtmDatePaid]                      DATETIME        NOT NULL
    ,[dtmPostDate]                      DATETIME        NOT NULL
    ,[intWriteOffAccountId]             INT             NULL
    ,[intAccountId]                     INT             NULL
    ,[intBankAccountId]                 INT             NULL
    ,[intARAccountId]                   INT             NULL
    ,[intDiscountAccount]               INT             NULL
    ,[intInterestAccount]               INT             NULL
    ,[intCFAccountId]                   INT             NULL
    ,[intGainLossAccount]               INT             NULL
    ,[intEntityCardInfoId]              INT             NULL
	,[ysnPosted]                        BIT             NULL
	,[ysnInvoicePrepayment]             BIT             NULL
    ,[strBatchId]                       NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                          BIT             NULL
    ,[ysnRecap]                         BIT             NULL
    ,[intEntityId]                      INT             NOT NULL
    ,[intUserId]                        INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]   BIT             NULL
    ,[ysnWithinAccountingDate]          BIT             NULL
    ,[ysnForApproval]                   BIT             NULL
    ,[ysnProcessCreditCard]             BIT             NULL
    ,[ysnApplytoBudget]                 BIT             NULL

    ,[dblAmountPaid]                    NUMERIC(18,6)   NULL
    ,[dblBaseAmountPaid]                NUMERIC(18,6)   NULL
    ,[dblUnappliedAmount]               NUMERIC(18,6)   NULL
    ,[dblBaseUnappliedAmount]           NUMERIC(18,6)   NULL
    ,[dblPayment]                       NUMERIC(18,6)   NULL
    ,[dblBasePayment]                   NUMERIC(18,6)   NULL
    ,[dblDiscount]                      NUMERIC(18,6)   NULL
    ,[dblBaseDiscount]                  NUMERIC(18,6)   NULL
    ,[dblInterest]                      NUMERIC(18,6)   NULL
    ,[dblBaseInterest]                  NUMERIC(18,6)   NULL
    ,[dblInvoiceTotal]                  NUMERIC(18,6)   NULL
    ,[dblBaseInvoiceTotal]              NUMERIC(18,6)   NULL
    ,[dblAmountDue]                     NUMERIC(18,6)   NULL
    ,[dblBaseAmountDue]                 NUMERIC(18,6)   NULL

    ,[intInvoiceId]                     INT             NULL
    ,[ysnExcludedFromPayment]           BIT             NULL
    ,[ysnForgiven]                      BIT             NULL
	,[intBillId]                        INT             NULL
    ,[strTransactionNumber]             NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]               NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strType]                          NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	,[intTransactionAccountId]          INT             NULL
    ,[ysnTransactionPosted]             BIT             NULL
	,[ysnTransactionPaid]               BIT             NULL
	,[ysnTransactionProcessed]          BIT             NULL    
    ,[dtmTransactionPostDate]           DATETIME        NULL
	,[dblTransactionDiscount]           NUMERIC(18,6)   NULL
    ,[dblBaseTransactionDiscount]       NUMERIC(18,6)   NULL
    ,[dblTransactionInterest]           NUMERIC(18,6)   NULL
    ,[dblBaseTransactionInterest]       NUMERIC(18,6)   NULL
    ,[dblTransactionAmountDue]          NUMERIC(18,6)   NULL
    ,[dblBaseTransactionAmountDue]      NUMERIC(18,6)   NULL
	,[intCurrencyExchangeRateTypeId]    INT             NULL
    ,[dblCurrencyExchangeRate]          NUMERIC(18,6)   NULL
    ,[strRateType]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL)

IF(OBJECT_ID('tempdb..#ARPostPaymentDetail') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostPaymentDetail
END
CREATE TABLE #ARPostPaymentDetail
    ([intTransactionId]                 INT             NOT NULL
    ,[intTransactionDetailId]           INT             NOT NULL  PRIMARY KEY
    ,[strTransactionId]                 NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strReceivePaymentType]            NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[intEntityCustomerId]              INT             NOT NULL
    ,[strCustomerNumber]                NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[strCustomerName]                  NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[intCompanyLocationId]             INT             NULL
    ,[strLocationName]                  NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[intUndepositedFundsId]            INT             NULL
    ,[intSalesAdvAcct]                  INT             NULL
    ,[intCurrencyId]                    INT             NOT NULL
    ,[intPaymentMethodId]               INT             NOT NULL
    ,[strPaymentMethod]                 NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[strNotes]                         NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
	,[intExchangeRateTypeId]			INT												NULL
	,[dblExchangeRate]					NUMERIC(18, 6)									NULL
    ,[dtmDatePaid]                      DATETIME        NOT NULL
    ,[dtmPostDate]                      DATETIME        NOT NULL
    ,[intWriteOffAccountId]             INT             NULL	
    ,[intAccountId]                     INT             NULL
    ,[intBankAccountId]                 INT             NULL
    ,[intARAccountId]                   INT             NULL
    ,[intDiscountAccount]               INT             NULL
    ,[intInterestAccount]               INT             NULL
    ,[intCFAccountId]                   INT             NULL
    ,[intGainLossAccount]               INT             NULL
    ,[intEntityCardInfoId]              INT             NULL
	,[ysnPosted]                        BIT             NULL
	,[ysnInvoicePrepayment]             BIT             NULL
    ,[strBatchId]                       NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                          BIT             NULL
    ,[ysnRecap]                         BIT             NULL
    ,[intEntityId]                      INT             NOT NULL
    ,[intUserId]                        INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]   BIT             NULL
    ,[ysnWithinAccountingDate]          BIT             NULL
    ,[ysnForApproval]                   BIT             NULL
    ,[ysnProcessCreditCard]             BIT             NULL
    ,[ysnApplytoBudget]                 BIT             NULL

    ,[dblAmountPaid]                    NUMERIC(18,6)   NULL
    ,[dblBaseAmountPaid]                NUMERIC(18,6)   NULL
    ,[dblUnappliedAmount]               NUMERIC(18,6)   NULL
    ,[dblBaseUnappliedAmount]           NUMERIC(18,6)   NULL
    ,[dblPayment]                       NUMERIC(18,6)   NULL
    ,[dblBasePayment]                   NUMERIC(18,6)   NULL
    ,[dblDiscount]                      NUMERIC(18,6)   NULL
    ,[dblBaseDiscount]                  NUMERIC(18,6)   NULL
	,[dblWriteOffAmount]				NUMERIC(18,6)   NULL
	,[dblBaseWriteOffAmount]			NUMERIC(18,6)   NULL
    ,[dblInterest]                      NUMERIC(18,6)   NULL
    ,[dblBaseInterest]                  NUMERIC(18,6)   NULL
    ,[dblInvoiceTotal]                  NUMERIC(18,6)   NULL
    ,[dblBaseInvoiceTotal]              NUMERIC(18,6)   NULL
    ,[dblAmountDue]                     NUMERIC(18,6)   NULL
    ,[dblBaseAmountDue]                 NUMERIC(18,6)   NULL

    ,[intInvoiceId]                     INT             NULL
    ,[ysnExcludedFromPayment]           BIT             NULL
    ,[ysnForgiven]                      BIT             NULL
	,[intBillId]                        INT             NULL
	,[intWriteOffAccountDetailId]		INT				NULL
    ,[strTransactionNumber]             NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]               NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strType]                          NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	,[intTransactionAccountId]          INT             NULL
    ,[ysnTransactionPosted]             BIT             NULL
	,[ysnTransactionPaid]               BIT             NULL
	,[ysnTransactionProcessed]          BIT             NULL    
    ,[dtmTransactionPostDate]           DATETIME        NULL
	,[dblTransactionDiscount]           NUMERIC(18,6)   NULL
    ,[dblBaseTransactionDiscount]       NUMERIC(18,6)   NULL
    ,[dblTransactionInterest]           NUMERIC(18,6)   NULL
    ,[dblBaseTransactionInterest]       NUMERIC(18,6)   NULL
    ,[dblTransactionAmountDue]          NUMERIC(18,6)   NULL
    ,[dblBaseTransactionAmountDue]      NUMERIC(18,6)   NULL
	,[intCurrencyExchangeRateTypeId]    INT             NULL
    ,[dblCurrencyExchangeRate]          NUMERIC(18,6)   NULL
    ,[strRateType]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL)

IF(OBJECT_ID('tempdb..#ARPostZeroPayment') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostZeroPayment
END
CREATE TABLE #ARPostZeroPayment
    ([intTransactionId]                 INT             NOT NULL PRIMARY KEY)

DECLARE @PaymentIds AS [PaymentId]
EXEC [dbo].[uspARPopulatePaymentDetailForPosting]
     @Param             = @param
    ,@BeginDate         = @beginDate
    ,@EndDate           = @endDate
    ,@BeginTransaction  = @beginTransaction
    ,@EndTransaction    = @endTransaction
    ,@IntegrationLogId  = NULL
    ,@PaymemntIds       = @PaymentIds
    ,@Post              = @post
    ,@Recap             = @recap
    ,@PostDate          = @PostDate
    ,@BatchId           = @batchIdUsed
    ,@UserId            = @userId

 --Removed excluded payments to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	DECLARE @PaymentsExclude TABLE(intPaymentId INT);
	INSERT INTO @PaymentsExclude
	SELECT intID FROM fnGetRowsFromDelimitedValues(@exclude)

	DELETE FROM A
	FROM #ARPostPaymentHeader A
	WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.[intTransactionId] = B.[intPaymentId])

    DELETE FROM A
	FROM #ARPostPaymentDetail A
	WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.[intTransactionId] = B.[intPaymentId])
END

IF(OBJECT_ID('tempdb..#ARPaymentAccount') IS NOT NULL)
BEGIN
    DROP TABLE #ARPaymentAccount
END
CREATE TABLE #ARPaymentAccount
    ([intAccountId]         INT NOT NULL    PRIMARY KEY CLUSTERED
    ,[strAccountId]         NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[strAccountCategory]	NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[ysnActive]            BIT                                             NOT NULL)


IF(OBJECT_ID('tempdb..#ARInvalidPaymentData') IS NOT NULL)
BEGIN
    DROP TABLE #ARInvalidPaymentData
END
CREATE TABLE #ARInvalidPaymentData
    ([intTransactionId]         INT             NOT NULL
    ,[strTransactionId]         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]       NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[intTransactionDetailId]   INT             NULL
    ,[strBatchId]               NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[strError]                 NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL)
		
DECLARE @totalInvalid INT
DECLARE @totalRecords INT

EXEC [dbo].[uspARPopulateInvalidPostPaymentData]
     @Post     = @post
    ,@Recap    = @recap
    ,@PostDate = @PostDate
    ,@BatchId  = @batchIdUsed

SET @totalInvalid = ISNULL((SELECT COUNT(DISTINCT [intTransactionId]) FROM #ARInvalidPaymentData),0)



IF(@totalInvalid = 0)
BEGIN
	IF @post = @OneBit
		 EXEC [dbo].[uspARPopulatePaymentAccountForPosting]
END

IF(@totalInvalid > 0)
BEGIN
    INSERT INTO 
		tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	SELECT
		 [strError]
		,[strTransactionType]
		,[strTransactionId]
		,[strBatchId]
		,[intTransactionId]
	FROM
		#ARInvalidPaymentData

	SET @invalidCount = @totalInvalid

    DELETE A
    FROM
        #ARPostPaymentHeader A
    INNER JOIN 
        #ARInvalidPaymentData I
			ON A.intTransactionId = I.intTransactionId

    DELETE A
    FROM
        #ARPostPaymentDetail A
    INNER JOIN 
        #ARInvalidPaymentData I
			ON A.intTransactionId = I.intTransactionId
																						
    IF @raiseError = @OneBit
    BEGIN
        SELECT TOP 1 @ErrorMerssage = strError FROM #ARInvalidPaymentData
        RAISERROR(@ErrorMerssage, 11, 1)							
        GOTO Post_Exit
    END													

END

--Get all to be post record
SELECT @totalRecords = (SELECT COUNT(DISTINCT [intTransactionId]) FROM #ARPostPaymentHeader)

IF(@totalInvalid >= 1 AND @totalRecords <= 0)
	BEGIN
		IF @raiseError = @ZeroBit
		BEGIN
			IF @InitTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @Savepoint
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	
		END
		IF @raiseError = @OneBit
			BEGIN
				SELECT TOP 1 @ErrorMerssage = strError FROM #ARInvalidPaymentData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END	
		GOTO Post_Exit
	END	

IF(OBJECT_ID('tempdb..#ARPostOverPayment') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostOverPayment
END
CREATE TABLE #ARPostOverPayment
    ([intTransactionId]                 INT             NOT NULL PRIMARY KEY)

IF(OBJECT_ID('tempdb..#ARPostPrePayment') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostPrePayment
END
CREATE TABLE #ARPostPrePayment
    ([intTransactionId]                 INT             NOT NULL PRIMARY KEY)

IF @post = @OneBit
BEGIN
	--+overpayment
	INSERT INTO
		#ARPostOverPayment
	SELECT
		DISTINCT
		A.[intPaymentId]
	FROM
		tblARPayment A 
	INNER JOIN
		(
		SELECT DISTINCT [intTransactionId] FROM #ARPostPaymentHeader WHERE [ysnPost] = @OneBit
		) P
			ON A.[intPaymentId] = P.[intTransactionId]
	WHERE
		(A.[dblAmountPaid]) > (SELECT SUM([dblPayment]) FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND [intTransactionId] = A.[intPaymentId])
		AND EXISTS(SELECT NULL FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND [intTransactionId] = A.[intPaymentId] AND [dblPayment] <> @ZeroDecimal)
		OR @ysnForFinalInvoice = 1
					
	--+prepayment
	INSERT INTO
		#ARPostPrePayment
	SELECT
		A.[intPaymentId]
	FROM
		tblARPayment A 
	INNER JOIN
		(
		SELECT DISTINCT [intTransactionId] FROM #ARPostPaymentHeader WHERE [ysnPost] = @OneBit
		) P
			ON A.[intPaymentId] = P.[intTransactionId]				
	WHERE
		(A.[dblAmountPaid]) <> @ZeroDecimal
		AND ISNULL((SELECT SUM([dblPayment]) FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND ([intInvoiceId] IS NOT NULL OR [intBillId] IS NOT NULL) AND [intTransactionId] = A.[intPaymentId]), @ZeroDecimal) = @ZeroDecimal	
		AND NOT EXISTS(SELECT NULL FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND ([intInvoiceId] IS NOT NULL OR [intBillId] IS NOT NULL) AND [intTransactionId] = A.[intPaymentId] AND [dblPayment] <> @ZeroDecimal)											
		AND @ysnForFinalInvoice = 0
						 																
END

IF @post = @ZeroBit And @recap = @ZeroBit
BEGIN
			
	---overpayment
	INSERT INTO
		#ARPostOverPayment
	SELECT
		DISTINCT
		A.[intPaymentId]
	FROM
		tblARPayment A 
	INNER JOIN
		(
		SELECT DISTINCT [intTransactionId] FROM #ARPostPaymentHeader WHERE [ysnPost] = @ZeroBit
		) P
			ON A.[intPaymentId] = P.[intTransactionId]
	INNER JOIN
		tblARInvoice I
			ON A.[strRecordNumber] = I.[strComments] OR A.[intPaymentId] = I.[intPaymentId] 				
	WHERE
		I.[strTransactionType] = 'Overpayment'
					
	---prepayment
	INSERT INTO
		#ARPostPrePayment
	SELECT
		DISTINCT
		A.[intPaymentId]
	FROM
		tblARPayment A 
	INNER JOIN
		(
		SELECT DISTINCT [intTransactionId] FROM #ARPostPaymentHeader WHERE [ysnPost] = @ZeroBit
		) P
			ON A.[intPaymentId] = P.[intTransactionId]
	INNER JOIN
		tblARInvoice I
			ON A.[strRecordNumber] = I.[strComments] OR A.[intPaymentId] = I.[intPaymentId]				
	WHERE
		I.[strTransactionType] = 'Customer Prepayment'		
					
END

BEGIN TRY

    IF @recap = 1
    BEGIN
        EXEC [dbo].[uspARPostPaymentRecap]
		        @BatchId         = @batchIdUsed 
		       ,@PostDate        = @PostDate
		       ,@UserId          = @userId
		       ,@raiseError      = @raiseError			   
		       ,@BatchIdUsed     = @batchIdUsed OUT
			   ,@Post			 = @post
        GOTO Do_Commit
    END

    IF @post = 1
        EXEC [dbo].[uspARPrePostPaymentIntegration]

END TRY
BEGIN CATCH
    SELECT @ErrorMerssage = ERROR_MESSAGE()
    IF @raiseError = @ZeroBit
    BEGIN
        IF @InitTranCount = 0
            IF (XACT_STATE()) <> 0
                ROLLBACK TRANSACTION
        ELSE
            IF (XACT_STATE()) <> 0
                ROLLBACK TRANSACTION @Savepoint
        SET @CurrentTranCount = @@TRANCOUNT
        SET @CurrentSavepoint = SUBSTRING(('uspARPostPaymentNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
        IF @CurrentTranCount = 0
            BEGIN TRANSACTION
        ELSE
            SAVE TRANSACTION @CurrentSavepoint
											
        EXEC uspARInsertPostResult @batchId, 'Receive Payment', @ErrorMerssage, @param	

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
		IF @raiseError = @OneBit
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
	
    DECLARE @GLEntries RecapTableType

    EXEC [dbo].[uspARGeneratePaymentGLEntries]
         @Post     = @post
	    ,@Recap    = @recap
        ,@PostDate = @PostDate
        ,@BatchId  = @batchIdUsed
        ,@UserId   = @userId

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

    DECLARE @InvalidGLEntries AS TABLE
        ([strTransactionId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
        ,[strText]          NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
        ,[intErrorCode]     INT
        ,[strModuleName]    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL)

    DECLARE @DiscountAccount INT
    SET @DiscountAccount = (SELECT TOP 1 [intDiscountAccountId] FROM tblARCompanyPreference WHERE [intDiscountAccountId] IS NOT NULL AND [intDiscountAccountId] <> 0)

	INSERT INTO @InvalidGLEntries
        ([strTransactionId]
        ,[strText]
        ,[intErrorCode]
        ,[strModuleName])
    SELECT DISTINCT
         [strTransactionId] = ARPD.[strTransactionId]
        ,[strText]          = 'Invalid Discount Entry(Record - ' + ARPD.[strTransactionId] + ')!'	
        ,[intErrorCode]     = ARPD.[intTransactionDetailId]
        ,[strModuleName]    = GE.[strModuleName]
	FROM
		@GLEntries GE
	INNER JOIN
		#ARPostPaymentDetail ARPD
			ON GE.[intJournalLineNo] = ARPD.[intTransactionDetailId]
			AND GE.[intTransactionId] = ARPD.[intTransactionId]
	WHERE				
		GE.intAccountId = @DiscountAccount
		AND ARPD.dblDiscount = @ZeroDecimal
		AND ARPD.dblBaseDiscount = @ZeroDecimal

    DELETE FROM @GLEntries
    WHERE
		[strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    INSERT INTO @InvalidGLEntries
        ([strTransactionId]
        ,[strText]
        ,[intErrorCode]
        ,[strModuleName])
    SELECT DISTINCT
         [strTransactionId]
        ,[strText]
        ,[intErrorCode]
        ,[strModuleName]
    FROM
        [dbo].[fnGetGLEntriesErrors](@GLEntries, @post)


	DECLARE @InvalidGLTransactionID NVARCHAR(100)
	DECLARE @InvalidGLModule NVARCHAR(100) 
	SELECT TOP 1 @InvalidGLTransactionID = [strTransactionId], @InvalidGLModule = strModuleName  FROM @InvalidGLEntries
	UPDATE @InvalidGLEntries SET strTransactionId = @InvalidGLTransactionID, strModuleName = @InvalidGLModule WHERE strTransactionId IS NULL


    DECLARE @invalidGLCount INT
	SET @invalidGLCount = ISNULL((SELECT COUNT(DISTINCT[strTransactionId]) FROM @InvalidGLEntries), 0)
	SET @totalRecords = @totalRecords - @invalidGLCount    
				
	IF(@invalidGLCount > 0)
	BEGIN

		INSERT INTO 
		    tblARPostResult([strMessage], [strTransactionType], [strTransactionId], [strBatchNumber], [intTransactionId])
		SELECT
		     [strMessage]         = IGLE.[strText]
		    ,[strTransactionType] = PPH.[strTransactionType]
		    ,[strTransactionId]   = IGLE.[strTransactionId]
		    ,[strBatchNumber]     = @batchIdUsed
		    ,[intTransactionId]   = PPH.[intTransactionId]
		FROM
		    @InvalidGLEntries IGLE
		LEFT OUTER JOIN
			#ARPostPaymentHeader PPH
				ON IGLE.[strTransactionId] = PPH.[strTransactionId]

		DELETE A
		FROM
			#ARPostPaymentHeader A
		INNER JOIN 
			#ARInvalidPaymentData I
				ON A.intTransactionId = I.intTransactionId

		DELETE A
		FROM
			#ARPostPaymentDetail A
		INNER JOIN 
			#ARInvalidPaymentData I
				ON A.intTransactionId = I.intTransactionId
																						
		IF @raiseError = @OneBit
		BEGIN
			SELECT TOP 1 @ErrorMerssage = strError FROM #ARInvalidPaymentData
			RAISERROR(@ErrorMerssage, 11, 1)							
			GOTO Post_Exit
		END	

	END

    DELETE FROM @GLEntries
    WHERE
		[strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM #ARPostPaymentHeader
    WHERE
		[strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM #ARPostPaymentDetail
    WHERE
		[strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    EXEC dbo.uspGLBookEntries
             @GLEntries         = @GLEntries
            ,@ysnPost           = @post
            ,@SkipGLValidation	= 1
			,@SkipICValidation	= 1
			

    EXEC [dbo].[uspARPostPaymentIntegration]
         @Post					= @post
        ,@PostDate				= @PostDate
        ,@BatchId				= @batchId
        ,@UserId				= @userId
        ,@IntegrationLogId		= NULL
	
    SET @totalInvalid = ISNULL(@totalInvalid,0) + ISNULL(@invalidGLCount,0)
	SET @invalidCount = @totalInvalid												
	SET @successfulCount = ISNULL((SELECT COUNT(DISTINCT [strTransactionId]) FROM @GLEntries),0)
	IF @successfulCount = 0
		SET @success = @ZeroBit
	--SELECT @successfulCount = COUNT(*) 
	--FROM tblARPostResult 
	--WHERE strBatchNumber = @batchId 
	--  AND strTransactionType = 'Receive Payment'
	--  AND strMessage IN ('Transaction successfully posted.', 'Transaction successfully unposted.')

END TRY
BEGIN CATCH
    SELECT @ErrorMerssage = ERROR_MESSAGE()
    IF @raiseError = @ZeroBit
    BEGIN
        IF @InitTranCount = 0
            IF (XACT_STATE()) <> 0
                ROLLBACK TRANSACTION
        ELSE
            IF (XACT_STATE()) <> 0
                ROLLBACK TRANSACTION @Savepoint
        SET @CurrentTranCount = @@TRANCOUNT
        SET @CurrentSavepoint = SUBSTRING(('uspARPostPaymentNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
        IF @CurrentTranCount = 0
            BEGIN TRANSACTION
        ELSE
            SAVE TRANSACTION @CurrentSavepoint
											
        EXEC uspARInsertPostResult @batchId, 'Receive Payment', @ErrorMerssage, @param	

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
		IF @raiseError = @OneBit
			RAISERROR(@ErrorMerssage, 11, 1)
		GOTO Post_Exit
END CATCH

Do_Commit:
IF ISNULL(@raiseError,0) = @ZeroBit
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END

	RETURN 1;
Do_Rollback:
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint

			EXEC uspARInsertPostResult @batchId, 'Receive Payment', @ErrorMerssage, @param								

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
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END			
		END
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;