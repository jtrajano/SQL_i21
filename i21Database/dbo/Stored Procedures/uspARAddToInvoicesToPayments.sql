CREATE PROCEDURE [dbo].[uspARAddToInvoicesToPayments]
	 @PaymentEntries	PaymentIntegrationStagingTable	READONLY
	,@IntegrationLogId	INT
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6) = 0.000000
		,@DateOnly DATETIME = CAST(GETDATE() AS DATE)

DECLARE @ItemEntries PaymentIntegrationStagingTable
DELETE FROM @ItemEntries
INSERT INTO @ItemEntries
	([intId]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intPaymentId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[dtmDatePaid]
	,[intPaymentMethodId]
	,[strPaymentMethod]
	,[strPaymentInfo]
	,[strNotes]
	,[intAccountId]
	,[intBankAccountId]
	,[intWriteOffAccountId]		
	,[dblAmountPaid]
	,[strPaymentOriginalId]
	,[ysnUseOriginalIdAsPaymentNumber]
	,[ysnApplytoBudget]
	,[ysnApplyOnAccount]
	,[ysnInvoicePrepayment]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[ysnAllowPrepayment]
	,[ysnPost]
	,[ysnRecap]
	,[ysnUnPostAndUpdate]
	,[intEntityId]
	--Detail																																															
	,[intPaymentDetailId]
	,[intInvoiceId]
	,[strTransactionType]
	,[intBillId]
	,[strTransactionNumber]
	,[intTermId]
	,[intInvoiceAccountId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[ysnApplyTermDiscount]
	,[dblDiscount]
	,[dblDiscountAvailable]
	,[dblInterest]
	,[dblPayment]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[ysnAllowOverpayment]
	,[ysnFromAP])
SELECT
	 [intId]							= PE.[intId]
	,[strSourceTransaction]				= PE.[strSourceTransaction]
	,[intSourceId]						= PE.[intSourceId]
	,[strSourceId]						= PE.[strSourceId]
	,[intPaymentId]						= PE.[intPaymentId]
	,[intEntityCustomerId]				= PE.[intEntityCustomerId]
	,[intCompanyLocationId]				= PE.[intCompanyLocationId]
	,[intCurrencyId]					= PE.[intCurrencyId]
	,[dtmDatePaid]						= PE.[dtmDatePaid]
	,[intPaymentMethodId]				= PE.[intPaymentMethodId]
	,[strPaymentMethod]					= PE.[strPaymentMethod]
	,[strPaymentInfo]					= PE.[strPaymentInfo]
	,[strNotes]							= PE.[strNotes]
	,[intAccountId]						= PE.[intAccountId]
	,[intBankAccountId]					= PE.[intBankAccountId]
	,[intWriteOffAccountId]				= PE.[intWriteOffAccountId]
	,[dblAmountPaid]					= PE.[dblAmountPaid]
	,[strPaymentOriginalId]				= PE.[strPaymentOriginalId]
	,[ysnUseOriginalIdAsPaymentNumber]	= PE.[ysnUseOriginalIdAsPaymentNumber]
	,[ysnApplytoBudget]					= PE.[ysnApplytoBudget]
	,[ysnApplyOnAccount]				= PE.[ysnApplyOnAccount]
	,[ysnInvoicePrepayment]				= PE.[ysnInvoicePrepayment]
	,[ysnImportedFromOrigin]			= PE.[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]				= PE.[ysnImportedAsPosted]
	,[ysnAllowPrepayment]				= PE.[ysnAllowPrepayment]
	,[ysnPost]							= PE.[ysnPost]
	,[ysnRecap]							= PE.[ysnRecap]
	,[ysnUnPostAndUpdate]				= PE.[ysnUnPostAndUpdate]
	,[intEntityId]						= PE.[intEntityId]
	--Detail																																															
	,[intPaymentDetailId]				= PE.[intPaymentDetailId]
	,[intInvoiceId]						= PE.[intInvoiceId]
	,[strTransactionType]				= ARI.[strTransactionType]
	,[intBillId]						= PE.[intBillId]
	,[strTransactionNumber]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[strTransactionNumber] ELSE APB.[strTransactionNumber] END
	,[intTermId]						= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[intTermId] ELSE APB.[intTermId] END
	,[intInvoiceAccountId]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[intAccountId] ELSE APB.[intAccountId] END
	,[dblInvoiceTotal]					= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ISNULL(ARI.[dblInvoiceTotal], @ZeroDecimal) * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE ISNULL(APB.[dblInvoiceTotal], @ZeroDecimal) END
	,[dblBaseInvoiceTotal]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ISNULL(ARI.[dblBaseInvoiceTotal], @ZeroDecimal) * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE ISNULL(APB.[dblBaseInvoiceTotal], @ZeroDecimal) END
	,[ysnApplyTermDiscount]				= PE.[ysnApplyTermDiscount]
	,[dblDiscount]						= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 AND dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) = -1 THEN @ZeroDecimal ELSE ISNULL(PE.[dblDiscount], @ZeroDecimal) END
	,[dblDiscountAvailable]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](PE.[dtmDatePaid], ARI.[dtmDate], ARI.[intTermId], ARI.[dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) ELSE @ZeroDecimal END
	,[dblInterest]						= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 AND dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) = -1 THEN @ZeroDecimal ELSE ISNULL(PE.[dblInterest], @ZeroDecimal) END
	,[dblPayment]						= ISNULL(PE.[dblPayment], @ZeroDecimal)
	,[dblAmountDue]						= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ISNULL(ARI.[dblAmountDue], @ZeroDecimal) * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE ISNULL(APB.[dblAmountDue], @ZeroDecimal) END
	,[dblBaseAmountDue]					= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ISNULL(ARI.[dblBaseAmountDue], @ZeroDecimal) * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE ISNULL(APB.[dblBaseAmountDue], @ZeroDecimal) END
	,[strInvoiceReportNumber]			= PE.[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]	= PE.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]		= PE.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ISNULL(PE.[dblCurrencyExchangeRate], 1.000000)
	,[ysnAllowOverpayment]				= ISNULL(PE.[ysnAllowOverpayment], 0)
	,[ysnFromAP]						= ISNULL(PE.[ysnFromAP], 0)
FROM @PaymentEntries PE
LEFT OUTER JOIN
	(
		SELECT
			 [intInvoiceId]
			,[strInvoiceNumber] AS [strTransactionNumber]
			,[strTransactionType]
			,[intTermId]
			,[intAccountId]
			,[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]
			,[dblAmountDue]
			,[dblBaseAmountDue]
			,[dtmDate]
		FROM
			tblARInvoice			
	)ARI
		ON ISNULL(PE.[ysnFromAP], 0) = 0
		AND PE.[intInvoiceId] = ARI.[intInvoiceId]
LEFT OUTER JOIN
	(
		SELECT
			 [intBillId]
			,[strBillId] AS [strTransactionNumber]
			,CASE	WHEN [intTransactionType] = 1 THEN 'Bill'
					WHEN [intTransactionType] = 2 THEN 'Vendor Prepayment'
					WHEN [intTransactionType] = 3 THEN 'Debit Memo'
					ELSE 'Unknown Type' 
			 END AS [strTransactionType]
			,[intTermsId] AS [intTermId]
			,[intAccountId]
			,[dblTotal] AS [dblInvoiceTotal]
			,[dblTotal] AS [dblBaseInvoiceTotal]
			,[dblAmountDue]
			,[dblAmountDue] AS [dblBaseAmountDue]
		FROM
			tblAPBill			
	)APB
		ON ISNULL(PE.[ysnFromAP], 0) = 1
		AND PE.[intBillId] = APB.[intBillId]


DECLARE @InvalidRecords AS TABLE (
	 [intId]				INT
	,[strMessage]			NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]			INT												NULL
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intPaymentId]			INT												NULL
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strMessage]		
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intPaymentId]
)
SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'The payment Id provided does not exists!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblARPayment ARP WITH (NOLOCK) WHERE ARP.[intPaymentId] = IT.[intPaymentId])

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'The payment is already posted!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	EXISTS(SELECT NULL FROM tblARPayment ARP WITH (NOLOCK) WHERE ARP.[intPaymentId] = IT.[intPaymentId] AND ARP.[ysnPosted] = 1)

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'The Invoice Id provided does not exists!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId])
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Invoice ' + IT.[strTransactionNumber] + ' is not yet posted!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId] AND ARI.[ysnPosted] = 0)
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'The Voucher Id provided does not exists!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblAPBill APB WITH (NOLOCK) WHERE APB.[intBillId] = IT.[intBillId])
	AND IT.[ysnFromAP] = 1

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Invoice ' + IT.[strTransactionNumber] + ' is not yet posted!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	EXISTS(SELECT NULL FROM tblAPBill APB WITH (NOLOCK) WHERE APB.[intBillId] = IT.[intBillId] AND APB.[ysnPosted] = 0)
	AND IT.[ysnFromAP] = 1

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Adding Invoice(' + IT.[strTransactionNumber] + ') of type ''Cash'' is not allowed!'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId] AND ARI.[ysnPosted] = 1 AND [strTransactionType] = 'Cash')
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Adding Invoice(' + IT.[strTransactionNumber] + ') of type ''Cash Refund'' is not allowed!'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId] AND ARI.[ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund')
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Invoice ' + IT.[strTransactionNumber] + ' is not yet posted!'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId] AND ((ARI.[ysnPosted] = 1 AND ARI.[strTransactionType] <> 'Customer Prepayment') OR (ARI.[ysnPosted] = 0 AND ARI.[strTransactionType] = 'Customer Prepayment')))
	AND IT.[ysnFromAP] = 1
	

IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


DELETE FROM V
FROM @ItemEntries V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])


INSERT INTO @InvalidRecords(
	 [intId]
	,[strMessage]		
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intPaymentId]
)
SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Payment on ' + IT.[strTransactionNumber] + ' is over the transaction''s amount due.'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	(IT.[dblAmountDue] + IT.[dblInterest]) < (IT.[dblPayment] + (CASE WHEN IT.[ysnApplyTermDiscount] = 1 THEN IT.[dblDiscountAvailable] ELSE IT.[dblDiscount] END))
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Payment of ' + CONVERT(NVARCHAR(100),CAST(ISNULL(IT.[dblPayment], @ZeroDecimal) AS MONEY),2)  + ' for invoice ' + IT.[strTransactionNumber] + ' will cause an under payment.'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	([dbo].fnRoundBanker(ISNULL((SELECT SUM(ISNULL(ARPD.dblPayment, @ZeroDecimal)) FROM tblARPaymentDetail ARPD WHERE ARPD.[intPaymentId] = IT.[intPaymentId]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) + IT.[dblPayment]) > (IT.[dblAmountPaid] + IT.[dblPayment]) AND IT.[strTransactionType] <> 'Customer Prepayment'
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Payment of ' + CONVERT(NVARCHAR(100),CAST(ISNULL(IT.[dblPayment], @ZeroDecimal) AS MONEY),2)  + ' for invoice ' + IT.[strTransactionNumber] + ' will cause an over payment.'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	IT.[ysnAllowOverpayment] = 0 
	AND ([dbo].fnRoundBanker(ISNULL((SELECT SUM(ISNULL(ARPD.[dblPayment], @ZeroDecimal)) FROM tblARPaymentDetail ARPD WHERE ARPD.[intPaymentId] = IT.[intPaymentId]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) + IT.[dblPayment]) > (IT.[dblAmountPaid] + IT.[dblPayment])
	AND IT.[ysnFromAP] = 0

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Positive payment amount is not allowed for invoice(' + IT.[strTransactionNumber] + ') of type ''' + IT.[strTransactionType] + '''.'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	IT.[strTransactionType] IN ('Credit Memo','Overpayment') AND IT.[dblPayment] > 0
	AND IT.[ysnFromAP] = 0


IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


DELETE FROM V
FROM @ItemEntries V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])
	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION
	
DECLARE  @IntegrationLog PaymentIntegrationLogStagingTable
DELETE FROM @IntegrationLog
INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strMessage]
	,[strPostingMessage]
	,[strBatchIdForNewPost]
	,[intPostedNewCount]
	,[strBatchIdForNewPostRecap]
	,[intRecapNewCount]
	,[strBatchIdForExistingPost]
	,[intPostedExistingCount]
	,[strBatchIdForExistingRecap]
	,[intRecapPostExistingCount]
	,[strBatchIdForExistingUnPost]
	,[intUnPostedExistingCount]
	,[strBatchIdForExistingUnPostRecap]
	,[intRecapUnPostedExistingCount]
	,[intPaymentId]
	,[intPaymentDetailId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[intId]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[ysnPost]
	,[ysnRecap]
	,[ysnInsert]
	,[ysnHeader]
	,[ysnSuccess]
	,[ysnPosted]
	,[ysnUnPosted]
	,[strBatchId])
SELECT
	 [intIntegrationLogId]				= @IntegrationLogId
	,[dtmDate]							= @DateOnly
	,[intEntityId]						= @UserId
	,[intGroupingOption]				= 0
	,[strMessage]						= [strMessage]
	,[strPostingMessage]				= ''
	,[strBatchIdForNewPost]				= ''
	,[intPostedNewCount]				= 0
	,[strBatchIdForNewPostRecap]		= ''
	,[intRecapNewCount]					= 0
	,[strBatchIdForExistingPost]		= ''
	,[intPostedExistingCount]			= 0
	,[strBatchIdForExistingRecap]		= ''
	,[intRecapPostExistingCount]		= 0
	,[strBatchIdForExistingUnPost]		= ''
	,[intUnPostedExistingCount]			= 0
	,[strBatchIdForExistingUnPostRecap]	= ''
	,[intRecapUnPostedExistingCount]	= 0
	,[intPaymentId]						= [intPaymentId]
	,[intPaymentDetailId]				= NULL
	,[intEntityCustomerId]				= NULL
	,[intCompanyLocationId]				= NULL
	,[intCurrencyId]					= NULL
	,[intId]							= [intId]
	,[strSourceTransaction]				= [strSourceTransaction]
	,[intSourceId]						= [intSourceId]
	,[strSourceId]						= [strSourceId]
	,[ysnPost]							= NULL
	,[ysnRecap]							= NULL
	,[ysnInsert]						= 1
	,[ysnHeader]						= 0
	,[ysnSuccess]						= 0
	,[ysnPosted]						= NULL
	,[ysnUnPosted]						= NULL
	,[strBatchId]						= ''
FROM
	@InvalidRecords
	

BEGIN TRY
MERGE INTO tblARPaymentDetail AS Target
USING 
	(
	SELECT
		 [intPaymentId]						= [intPaymentId]
		,[intPaymentDetailId]				= [intPaymentDetailId]
		,[intInvoiceId]						= [intInvoiceId]
		,[intBillId]						= [intBillId]
		,[strTransactionNumber]				= [strTransactionNumber]
		,[intTermId]						= [intTermId]
		,[intAccountId]						= [intAccountId]
		,[dblInvoiceTotal]					= [dblInvoiceTotal]
		,[dblBaseInvoiceTotal]				= [dblBaseInvoiceTotal]
		,[dblDiscount]						= [dblDiscount]
		,[dblBaseDiscount]					= [dbo].fnRoundBanker([dblDiscount] * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
		,[dblDiscountAvailable]				= [dblDiscountAvailable]
		,[dblBaseDiscountAvailable]			= [dbo].fnRoundBanker([dblDiscountAvailable] * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
		,[dblInterest]						= [dblInterest]
		,[dblBaseInterest]					= [dbo].fnRoundBanker([dblInterest] * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
		,[dblAmountDue]						= [dblAmountDue]
		,[dblBaseAmountDue]					= [dbo].fnRoundBanker([dblAmountDue] * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
		,[dblPayment]						= [dblPayment]
		,[dblBasePayment]					= [dbo].fnRoundBanker([dblPayment] * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
		,[strInvoiceReportNumber]			= [strInvoiceReportNumber]
		,[intCurrencyExchangeRateTypeId]	= [intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]		= [intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]			= [dblCurrencyExchangeRate]
		,[intConcurrencyId]					= 1
		,[intId]							= [intId]
		,[strSourceTransaction]				= [strSourceTransaction]
		,[intSourceId]						= [intSourceId]
		,[strSourceId]						= [strSourceId]
		,[ysnPost]							= [ysnPost]
		,[ysnRecap]							= [ysnRecap]
	FROM
		@ItemEntries IE
	)
AS Source
ON Target.[intPaymentDetailId] = Source.[intPaymentDetailId]
WHEN NOT MATCHED BY TARGET THEN
INSERT(
	 [intPaymentId]
	,[intInvoiceId]
	,[intBillId]
	,[strTransactionNumber]
	,[intTermId]
	,[intAccountId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblDiscount]
	,[dblBaseDiscount]
	,[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]
	,[dblInterest]
	,[dblBaseInterest]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intConcurrencyId]
	)
VALUES(
	 [intPaymentId]
	,[intInvoiceId]
	,[intBillId]
	,[strTransactionNumber]
	,[intTermId]
	,[intAccountId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblDiscount]
	,[dblBaseDiscount]
	,[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]
	,[dblInterest]
	,[dblBaseInterest]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intConcurrencyId]
)
	OUTPUT  
			@IntegrationLogId						--[intIntegrationLogId]
           ,INSERTED.[intPaymentId]					--[intPaymentId]
           ,INSERTED.[intPaymentDetailId]			--[intPaymentDetailId]
           ,Source.[intId]							--[intId]
           ,'Invoice - ' + Source.[strSourceTransaction] + ' successfully added!' --[strMessage]
           ,''										--[strPostingMessage]
           ,Source.[strSourceTransaction]			--[strSourceTransaction]
           ,Source.[intSourceId]					--[intSourceId]
           ,Source.[strSourceId]					--[strSourceId]
           ,Source.[ysnPost]						--[ysnPost]
           ,Source.[ysnRecap]						--[ysnRecap]
           ,1										--[ysnInsert]
           ,0										--[ysnHeader]
           ,1										--[ysnSuccess]
           ,NULL									--[ysnPosted]
           ,NULL									--[ysnUnPosted]
           ,''										--[strPostedTransactionId]
           ,NULL									--[strBatchId]
           ,1										--[intConcurrencyId]
		INTO tblARPaymentIntegrationLogDetail(
			[intIntegrationLogId]
           ,[intPaymentId]
           ,[intPaymentDetailId]
           ,[intId]
           ,[strMessage]
           ,[strPostingMessage]
           ,[strSourceTransaction]
           ,[intSourceId]
           ,[strSourceId]
           ,[ysnPost]
           ,[ysnRecap]
           ,[ysnInsert]
           ,[ysnHeader]
           ,[ysnSuccess]
           ,[ysnPosted]
           ,[ysnUnPosted]
           ,[strPostedTransactionId]
           ,[strBatchId]
           ,[intConcurrencyId]
		);					

	IF ISNULL(@IntegrationLogId, 0) <> 0
		EXEC [uspARInsertPaymentIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog
			
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
		
BEGIN TRY

	DECLARE @InsertedPaymentIds Id	
	DELETE FROM @InsertedPaymentIds

	INSERT INTO @InsertedPaymentIds([intId])
	SELECT
		 [intId]	= ARPD.[intPaymentId]
	FROM
		(SELECT [intPaymentId], [intId] FROM tblARPaymentIntegrationLogDetail WITH (NOLOCK) WHERE ISNULL([ysnHeader], 0) = 1 AND ISNULL([ysnSuccess], 0) = 1) ARPD
	INNER JOIN
		(SELECT [intId] FROM @ItemEntries) IFI
			ON IFI. [intId] = ARPD.[intId] 



	EXEC [dbo].[uspARReComputePaymentAmounts] @InvoiceIds = @InsertedPaymentIds
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


IF ISNULL(@RaiseError,0) = 0	
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END
GO