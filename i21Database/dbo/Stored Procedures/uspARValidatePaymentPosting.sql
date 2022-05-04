CREATE PROCEDURE [dbo].[uspARValidatePaymentPosting]
     @PaymentId     AS INT
    ,@Post          AS BIT
    ,@UserId        AS INT
    ,@BankAccountId AS INT = NULL
    ,@BatchId       AS NVARCHAR(40) = NULL
    ,@PostDate      AS DATETIME = NULL
    ,@Error         AS NVARCHAR(500) = NULL OUTPUT		
AS	

DECLARE @RetryDataFix BIT = 1
RetryDataFix:

DECLARE @ErrorMessage	NVARCHAR(500)
DECLARE @OneBit			BIT = 1
DECLARE @ZeroBit		BIT = 0
DECLARE @ZeroDecimal	NUMERIC(18, 6) = 0
DECLARE @UserEntityID	INT = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId)
DECLARE @PaymentIds		PaymentId
DECLARE @GLEntries		RecapTableType

SET @Error		= ''
SET @PostDate	= ISNULL(@PostDate, GETDATE())
SET @BatchId	= ISNULL(@BatchId, 'TestBatchId')
SET @Post		= (SELECT TOP 1 CASE WHEN ysnPosted = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END FROM tblARPayment WHERE intPaymentId = @PaymentId)
SET @Post		= ISNULL(@Post, 1)

--INVALID BASE AMOUNTS HEADER
UPDATE tblARPayment
SET dblAmountPaid			= [dbo].[fnRoundBanker](dblAmountPaid, 2)
  , dblBaseAmountPaid		= [dbo].[fnRoundBanker](dblAmountPaid, 2)
  , dblUnappliedAmount		= [dbo].[fnRoundBanker](dblUnappliedAmount, 2)
  , dblBaseUnappliedAmount	= [dbo].[fnRoundBanker](dblUnappliedAmount, 2)
  , dblOverpayment			= [dbo].[fnRoundBanker](dblOverpayment, 2)
  , dblBaseOverpayment		= [dbo].[fnRoundBanker](dblOverpayment, 2)
WHERE ysnPosted = 0
  AND dblExchangeRate = 1.000000
  AND (dblAmountPaid <> dblBaseAmountPaid OR dblUnappliedAmount <> dblBaseUnappliedAmount)
  AND intPaymentId = @PaymentId

--INVALID BASE AMOUNTS DETAIL
UPDATE PD 
SET dblPayment		= [dbo].[fnRoundBanker](PD.dblPayment, 2)
  , dblBasePayment	= [dbo].[fnRoundBanker](PD.dblPayment, 2)
  , dblDiscount		= [dbo].[fnRoundBanker](PD.dblDiscount, 2)
  , dblBaseDiscount	= [dbo].[fnRoundBanker](PD.dblDiscount, 2)
  , dblInterest		= [dbo].[fnRoundBanker](PD.dblInterest, 2)
 , dblBaseInterest	= [dbo].[fnRoundBanker](PD.dblInterest, 2)
FROM tblARPaymentDetail PD
INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
WHERE P.ysnPosted = 0
  AND PD.dblCurrencyExchangeRate = 1.000000
  AND (PD.dblPayment <> PD.dblBasePayment OR PD.dblDiscount <> PD.dblBaseDiscount OR PD.dblInterest <> PD.dblBaseInterest)
  AND P.intPaymentId = @PaymentId

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
    ,[intCreditCardFeeAccountId]        INT             NULL
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
    ,[dblCreditCardFee]					NUMERIC(18,6)   NULL
	,[dblBaseCreditCardFee]				NUMERIC(18,6)   NULL

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
    ,[intCreditCardFeeAccountId]        INT             NULL
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
    ,[dblAdjustedBasePayment]           NUMERIC(18,6)   NULL
    ,[dblDiscount]                      NUMERIC(18,6)   NULL
    ,[dblBaseDiscount]                  NUMERIC(18,6)   NULL
    ,[dblAdjustedBaseDiscount]          NUMERIC(18,6)   NULL
	,[dblWriteOffAmount]				NUMERIC(18,6)   NULL
	,[dblBaseWriteOffAmount]			NUMERIC(18,6)   NULL
    ,[dblAdjustedBaseWriteOffAmount]	NUMERIC(18,6)   NULL
    ,[dblInterest]                      NUMERIC(18,6)   NULL
    ,[dblBaseInterest]                  NUMERIC(18,6)   NULL
    ,[dblAdjustedBaseInterest]          NUMERIC(18,6)   NULL
    ,[dblInvoiceTotal]                  NUMERIC(18,6)   NULL
    ,[dblBaseInvoiceTotal]              NUMERIC(18,6)   NULL
    ,[dblAmountDue]                     NUMERIC(18,6)   NULL
    ,[dblBaseAmountDue]                 NUMERIC(18,6)   NULL
    ,[dblCreditCardFee]					NUMERIC(18,6)   NULL
	,[dblBaseCreditCardFee]				NUMERIC(18,6)   NULL

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
	,[dblTransactionPayment]			NUMERIC(18,6)   NULL
    ,[dblBaseTransactionPayment]		NUMERIC(18,6)   NULL
	,[intCurrencyExchangeRateTypeId]    INT             NULL
    ,[dblCurrencyExchangeRate]          NUMERIC(18,6)   NULL
    ,[strRateType]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL)

IF(OBJECT_ID('tempdb..#ARPostZeroPayment') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostZeroPayment
END

CREATE TABLE #ARPostZeroPayment
    ([intTransactionId]                 INT             NOT NULL PRIMARY KEY)

EXEC [dbo].[uspARPopulatePaymentDetailForPosting]
     @Param             = @PaymentId
    ,@IntegrationLogId  = NULL
    ,@PaymemntIds       = @PaymentIds
    ,@Post              = @Post
    ,@Recap             = 1
    ,@PostDate          = @PostDate
    ,@BatchId           = @BatchId
    ,@UserId            = @UserId
	
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
		
EXEC [dbo].[uspARPopulateInvalidPostPaymentData]
     @Post     = @Post
    ,@Recap    = 1
    ,@PostDate = @PostDate
    ,@BatchId  = @BatchId

SELECT TOP 1 @ErrorMessage = [strError]
FROM #ARInvalidPaymentData
WHERE [strError] NOT IN ('There was no payment to receive.' )

IF LTRIM(RTRIM(ISNULL(@ErrorMessage, ''))) <> ''
BEGIN
	IF(@RetryDataFix = 1)
	BEGIN
		SET @RetryDataFix = 0
		SET @ErrorMessage = ''
		DELETE FROM #ARInvalidPaymentData
		EXEC uspARRebuildPayment @intPaymentId = @PaymentId
		GOTO RetryDataFix
	END

    SET @Error = @ErrorMessage
	RETURN 1
END

IF(OBJECT_ID('tempdb..#ARPostOverPayment') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostOverPayment
END

CREATE TABLE #ARPostOverPayment ([intTransactionId] INT NOT NULL PRIMARY KEY)

IF(OBJECT_ID('tempdb..#ARPostPrePayment') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostPrePayment
END

CREATE TABLE #ARPostPrePayment ([intTransactionId] INT  NOT NULL PRIMARY KEY)

IF @Post = @OneBit
BEGIN
	--OVERPAYMENT
	INSERT INTO #ARPostOverPayment
	SELECT DISTINCT A.[intPaymentId]
	FROM tblARPayment A 
	INNER JOIN (
		SELECT DISTINCT [intTransactionId] 
		FROM #ARPostPaymentHeader 
		WHERE [ysnPost] = @OneBit
	) P ON A.[intPaymentId] = P.[intTransactionId]
	WHERE (A.[dblAmountPaid]) > (SELECT SUM([dblPayment]) FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND [intTransactionId] = A.[intPaymentId])
		AND EXISTS(SELECT NULL FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND [intTransactionId] = A.[intPaymentId] AND [dblPayment] <> @ZeroDecimal)	
					
	--PREPAYMENT
	INSERT INTO #ARPostPrePayment
	SELECT A.[intPaymentId]
	FROM tblARPayment A 
	INNER JOIN (
		SELECT DISTINCT [intTransactionId] 
		FROM #ARPostPaymentHeader 
		WHERE [ysnPost] = @OneBit
	) P ON A.[intPaymentId] = P.[intTransactionId]				
	WHERE (A.[dblAmountPaid]) <> @ZeroDecimal
		AND ISNULL((SELECT SUM([dblPayment]) FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND ([intInvoiceId] IS NOT NULL OR [intBillId] IS NOT NULL) AND [intTransactionId] = A.[intPaymentId]), @ZeroDecimal) = @ZeroDecimal	
		AND NOT EXISTS(SELECT NULL FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND ([intInvoiceId] IS NOT NULL OR [intBillId] IS NOT NULL) AND [intTransactionId] = A.[intPaymentId] AND [dblPayment] <> @ZeroDecimal)											
END

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
	,@Recap    = 1
    ,@PostDate = @PostDate
    ,@BatchId  = @BatchId
    ,@UserId   = @UserId

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
    (strTransactionId   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    ,strText            NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
    ,intErrorCode       INT
    ,strModuleName      NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL)

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
    [dbo].[fnGetGLEntriesErrors](@GLEntries,@Post)

SELECT TOP 1 @ErrorMessage = strText FROM @InvalidGLEntries

IF LTRIM(RTRIM(ISNULL(@ErrorMessage, ''))) <> ''
BEGIN
    SET @Error = @ErrorMessage
	RETURN 1
END

SET @Error = ''

RETURN 0
