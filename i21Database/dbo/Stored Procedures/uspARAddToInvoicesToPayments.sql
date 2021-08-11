CREATE PROCEDURE [dbo].[uspARAddToInvoicesToPayments]
	 @PaymentEntries	PaymentIntegrationStagingTable	READONLY
	,@IntegrationLogId	INT
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
	,@SkipRecompute     BIT                 = 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @ZeroDecimal NUMERIC(18, 6) = 0.000000
		,@DateOnly DATETIME = CAST(GETDATE() AS DATE)
		,@InitTranCount INT
		,@Savepoint NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddToInvoicesToPayments' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)


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
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
	,[strReceivePaymentType]
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
	,[intWriteOffAccountDetailId]
	,[strTransactionNumber]
	,[intTermId]
	,[intInvoiceAccountId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[ysnApplyTermDiscount]
	,[dblDiscount]
	,[dblDiscountAvailable]
	,[dblWriteOffAmount]
	,[dblInterest]
	,[dblPayment]
	,[dblCreditCardFee]
	,[dblAmountDue]
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
	,[intExchangeRateTypeId]			= PE.[intExchangeRateTypeId]
	,[dblExchangeRate]					= PE.[dblExchangeRate]
	,[strReceivePaymentType]			= PE.[strReceivePaymentType]
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
	,[intInvoiceId]						= RFP.[intInvoiceId]
	,[strTransactionType]				= RFP.[strTransactionType]
	,[intBillId]						= RFP.[intBillId]
	,[intWriteOffAccountDetailId]		= PE.[intWriteOffAccountDetailId]
	,[strTransactionNumber]				= RFP.[strTransactionNumber]
	,[intTermId]						= RFP.[intTermId]
	,[intInvoiceAccountId]				= RFP.[intAccountId]
	,[dblInvoiceTotal]					= [dbo].fnRoundBanker(ISNULL(RFP.[dblInvoiceTotal], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]())
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL 
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) 
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblBaseInvoiceTotal]				= [dbo].fnRoundBanker(ISNULL(RFP.[dblBaseInvoiceTotal], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]())
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL 
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) 
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[ysnApplyTermDiscount]				= ISNULL(PE.[ysnApplyTermDiscount],0)
	,[dblDiscount]						= (CASE WHEN RFP.[intInvoiceId] IS NOT NULL 
												THEN (CASE WHEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) = -1.000000
																			   THEN @ZeroDecimal 
																			   ELSE (CASE WHEN ISNULL(PE.[ysnApplyTermDiscount],0) = 1 
																			         THEN [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](PE.[dtmDatePaid], RFP.[dtmDate], RFP.[intTermId], RFP.[dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) 
																					 ELSE [dbo].fnRoundBanker(ISNULL(PE.[dblDiscount], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]())
																					 END) 
																		  END)
												ELSE [dbo].fnRoundBanker(ISNULL(PE.[dblDiscount], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()) * (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)	
	,[dblDiscountAvailable]				= [dbo].fnRoundBanker(ISNULL(RFP.[dblDiscountAvailable],@ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) * (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
	,[dblWriteOffAmount]				= ABS([dbo].fnRoundBanker(ISNULL(PE.[dblWriteOffAmount], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType])
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblInterest]						= ABS([dbo].fnRoundBanker(ISNULL(PE.[dblInterest], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL AND dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) = -1.000000
												THEN @ZeroDecimal
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblPayment]						= ABS([dbo].fnRoundBanker(ISNULL(PE.[dblPayment], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType])
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblCreditCardFee]					= ABS([dbo].fnRoundBanker(ISNULL(PE.[dblCreditCardFee], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL AND dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) = -1.000000
												THEN @ZeroDecimal
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblAmountDue]						= ISNULL(PE.dblAmountDue, ABS([dbo].fnRoundBanker(ISNULL(RFP.[dblAmountDue], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType])
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END))
	,[strInvoiceReportNumber]			= PE.[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]	= RFP.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]		= RFP.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ISNULL(RFP.[dblCurrencyExchangeRate], 1.000000)
	,[ysnAllowOverpayment]				= ISNULL(PE.[ysnAllowOverpayment], 0)
	,[ysnFromAP]						= ISNULL(PE.[ysnFromAP], 0)
FROM @PaymentEntries PE
INNER JOIN
	(
		SELECT
			 [intInvoiceId]
			,[intBillId]
			,[strTransactionNumber]
			,[strTransactionType]
			,[intTermId]
			,[intAccountId]
			,[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]
			,[dblAmountDue]
			,[dblBaseAmountDue]
			,[dblDiscountAvailable]
			,[dblBaseDiscountAvailable]
			,[dtmDate]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
		FROM
			[vyuARInvoicesForPaymentIntegration]
		WHERE
			[intInvoiceId] IS NOT NULL
			AND [intBillId] IS NULL
	) RFP
		ON	PE.[intInvoiceId] = RFP.[intInvoiceId] 

UNION

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
	,[intExchangeRateTypeId]			= PE.[intExchangeRateTypeId]
	,[dblExchangeRate]					= PE.[dblExchangeRate]
	,[strReceivePaymentType]			= PE.[strReceivePaymentType]
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
	,[intInvoiceId]						= RFP.[intInvoiceId]
	,[strTransactionType]				= RFP.[strTransactionType]
	,[intBillId]						= RFP.[intBillId]
	,[intWriteOffAccountDetailId]		= NULL
	,[strTransactionNumber]				= RFP.[strTransactionNumber]
	,[intTermId]						= RFP.[intTermId]
	,[intInvoiceAccountId]				= RFP.[intAccountId]
	,[dblInvoiceTotal]					= [dbo].fnRoundBanker(ISNULL(RFP.[dblInvoiceTotal], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]())
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL 
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) 
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblBaseInvoiceTotal]				= [dbo].fnRoundBanker(ISNULL(RFP.[dblBaseInvoiceTotal], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]())
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL 
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) 
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[ysnApplyTermDiscount]				= ISNULL(PE.[ysnApplyTermDiscount],0)
	,[dblDiscount]						= (CASE WHEN RFP.[intInvoiceId] IS NOT NULL 
												THEN (CASE WHEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) = -1.000000
																			   THEN @ZeroDecimal 
																			   ELSE (CASE WHEN ISNULL(PE.[ysnApplyTermDiscount],0) = 1 
																			         THEN [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](PE.[dtmDatePaid], RFP.[dtmDate], RFP.[intTermId], RFP.[dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) 
																					 ELSE [dbo].fnRoundBanker(ISNULL(PE.[dblDiscount], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]())
																					 END) 
																		  END)
												ELSE [dbo].fnRoundBanker(ISNULL(PE.[dblDiscount], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()) * (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)		
	,[dblDiscountAvailable]				= [dbo].fnRoundBanker(ISNULL(RFP.[dblDiscountAvailable],@ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) * (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
	,[dblWriteOffAmount]				= @ZeroDecimal
	,[dblInterest]						= ABS([dbo].fnRoundBanker(ISNULL(PE.[dblInterest], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL AND dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType]) = -1.000000
												THEN @ZeroDecimal
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblPayment]						= ABS([dbo].fnRoundBanker(ISNULL(PE.[dblPayment], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType])
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END)
	,[dblCreditCardFee]					= @ZeroDecimal
	,[dblAmountDue]						= ISNULL(PE.dblAmountDue, ABS([dbo].fnRoundBanker(ISNULL(RFP.[dblAmountDue], @ZeroDecimal),[dbo].[fnARGetDefaultDecimal]()))
										* (CASE WHEN RFP.[intInvoiceId] IS NOT NULL
												THEN dbo.fnARGetInvoiceAmountMultiplier(RFP.[strTransactionType])
												ELSE (CASE WHEN RFP.[strTransactionType] IN ('Voucher','Deferred Interest') THEN -1.000000 ELSE 1.000000 END)
										   END))	
	,[strInvoiceReportNumber]			= PE.[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]	= RFP.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]		= RFP.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ISNULL(RFP.[dblCurrencyExchangeRate], 1.000000)
	,[ysnAllowOverpayment]				= ISNULL(PE.[ysnAllowOverpayment], 0)
	,[ysnFromAP]						= ISNULL(PE.[ysnFromAP], 0)
FROM @PaymentEntries PE
INNER JOIN
	(
		SELECT
			 [intInvoiceId]
			,[intBillId]
			,[strTransactionNumber]
			,[strTransactionType]
			,[intTermId]
			,[intAccountId]
			,[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]
			,[dblAmountDue]
			,[dblBaseAmountDue]
			,[dblDiscountAvailable]
			,[dblBaseDiscountAvailable]
			,[dtmDate]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
		FROM
			[vyuARInvoicesForPaymentIntegration]
		WHERE
			[intBillId] IS NOT NULL
			AND [intInvoiceId] IS NULL
	) RFP
		ON	PE.[intBillId] = RFP.[intBillId] 

--Clear Discounts for Partial Payment AR-5721
UPDATE @ItemEntries
SET dblAmountDue = dblAmountDue + dblDiscount
  , dblDiscount = 0
WHERE ISNULL(dblAmountDue, 0) <> 0
  AND ISNULL(dblDiscount, 0) <> 0

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
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
	
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

UPDATE IE
SET 
	 IE.[dblBaseDiscount]		= [dbo].fnRoundBanker([dblDiscount] * ISNULL(P.[dblExchangeRate], 1.000000), [dbo].[fnARGetDefaultDecimal]())
	,IE.[dblBaseInterest]		= [dbo].fnRoundBanker([dblInterest] * ISNULL(P.[dblExchangeRate], 1.000000), [dbo].[fnARGetDefaultDecimal]())
	,IE.[dblBaseAmountDue]		= [dbo].fnRoundBanker([dblAmountDue] * ISNULL(P.[dblExchangeRate], 1.000000), [dbo].[fnARGetDefaultDecimal]())
	,IE.[dblBasePayment]		= [dbo].fnRoundBanker([dblPayment] * ISNULL(P.[dblExchangeRate], 1.000000), [dbo].[fnARGetDefaultDecimal]())
	,IE.[dblBaseWriteOffAmount] = [dbo].fnRoundBanker([dblWriteOffAmount] * ISNULL(P.[dblExchangeRate], 1.000000), [dbo].[fnARGetDefaultDecimal]())
	,IE.[dblBaseCreditCardFee]	= [dbo].fnRoundBanker([dblCreditCardFee] * ISNULL(P.[dblExchangeRate], 1.000000), [dbo].[fnARGetDefaultDecimal]())
FROM
	@ItemEntries IE
INNER JOIN
	tblARPayment P
		ON IE.[intPaymentId] = P.[intPaymentId]
	

BEGIN TRY
MERGE INTO tblARPaymentDetail AS Target
USING 
	(
	SELECT
		 [intPaymentId]						= [intPaymentId]
		,[intPaymentDetailId]				= [intPaymentDetailId]
		,[intInvoiceId]						= [intInvoiceId]
		,[intBillId]						= [intBillId]
		,[intWriteOffAccountId]				= [intWriteOffAccountDetailId]
		,[strTransactionNumber]				= [strTransactionNumber]
		,[intTermId]						= [intTermId]
		,[intAccountId]						= [intInvoiceAccountId]
		,[dblInvoiceTotal]					= [dblInvoiceTotal]
		,[dblBaseInvoiceTotal]				= [dblBaseInvoiceTotal]
		,[dblDiscount]						= [dblDiscount]
		,[dblBaseDiscount]					= [dblBaseDiscount]
		,[dblDiscountAvailable]				= [dblDiscountAvailable]
		,[dblBaseDiscountAvailable]			= [dblBaseDiscountAvailable]
		,[dblWriteOffAmount]				= [dblWriteOffAmount]
		,[dblBaseWriteOffAmount]			= [dblBaseWriteOffAmount]
		,[dblInterest]						= [dblInterest]
		,[dblBaseInterest]					= [dblBaseInterest]
		,[dblAmountDue]						= [dblAmountDue]
		,[dblBaseAmountDue]					= [dblBaseAmountDue]
		,[dblPayment]						= [dblPayment]
		,[dblBasePayment]					= [dblBasePayment]
		,[dblCreditCardFee]					= [dblCreditCardFee]
		,[dblBaseCreditCardFee]				= [dblBaseCreditCardFee]
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
	,[intWriteOffAccountId]
	,[strTransactionNumber]
	,[intTermId]
	,[intAccountId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblDiscount]
	,[dblBaseDiscount]
	,[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]
	,[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]
	,[dblInterest]
	,[dblBaseInterest]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[dblCreditCardFee]
	,[dblBaseCreditCardFee]
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
	,[intWriteOffAccountId]
	,[strTransactionNumber]
	,[intTermId]
	,[intAccountId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblDiscount]
	,[dblBaseDiscount]
	,[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]
	,[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]
	,[dblInterest]
	,[dblBaseInterest]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[dblCreditCardFee]
	,[dblBaseCreditCardFee]
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
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
		
BEGIN TRY

	DECLARE @CreatedPaymentIds PaymentId	
	
	IF ISNULL(@SkipRecompute, 0) = 0
	BEGIN
		DELETE FROM @CreatedPaymentIds

		INSERT INTO @CreatedPaymentIds(
			 [intHeaderId]
			,[intDetailId])
		SELECT 
			 [intHeaderId]						= ARPD.[intPaymentId]
			,[intDetailId]						= NULL
		 FROM
			(SELECT [intPaymentId], [intId] FROM tblARPaymentIntegrationLogDetail WITH (NOLOCK) WHERE ISNULL([ysnHeader], 0) = 0 AND ISNULL([ysnSuccess], 0) = 1) ARPD
		INNER JOIN
			(SELECT [intId], [intPaymentId] FROM @ItemEntries) IFI
				ON IFI. [intPaymentId] = ARPD.[intPaymentId]

		EXEC [dbo].[uspARReComputePaymentAmounts] @PaymentIds = @CreatedPaymentIds
	END
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


IF ISNULL(@RaiseError,0) = 0
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

SET @ErrorMessage = NULL;
RETURN 1;
	
	
END
GO