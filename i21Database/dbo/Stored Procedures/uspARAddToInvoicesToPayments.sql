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
	,[intBillId]						= PE.[intBillId]
	,[strTransactionNumber]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[strTransactionNumber] ELSE APB.[strTransactionNumber] END
	,[intTermId]						= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[intTermId] ELSE APB.[intTermId] END
	,[intInvoiceAccountId]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[intAccountId] ELSE APB.[intAccountId] END
	,[dblInvoiceTotal]					= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[dblInvoiceTotal] * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE APB.[dblInvoiceTotal] END
	,[dblBaseInvoiceTotal]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[dblBaseInvoiceTotal] * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE APB.[dblBaseInvoiceTotal] END
	,[ysnApplyTermDiscount]				= PE.[ysnApplyTermDiscount]
	,[dblDiscount]						= PE.[dblDiscount]
	,[dblDiscountAvailable]				= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](PE.[dtmDatePaid], ARI.[dtmDate], ARI.[intTermId], ARI.[dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) ELSE @ZeroDecimal END
	,[dblInterest]						= PE.[dblInterest]
	,[dblPayment]						= PE.[dblPayment]
	,[dblAmountDue]						= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[dblAmountDue] * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE APB.[dblAmountDue] END
	,[dblBaseAmountDue]					= CASE WHEN ISNULL(PE.[ysnFromAP], 0) = 0 THEN ARI.[dblBaseAmountDue] * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType]) ELSE APB.[dblBaseAmountDue] END
	,[strInvoiceReportNumber]			= PE.[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]	= PE.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]		= PE.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= PE.[dblCurrencyExchangeRate]
	,[ysnAllowOverpayment]				= PE.[ysnAllowOverpayment]
	,[ysnFromAP]						= PE.[ysnFromAP]
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
	,[strMessage]			= 'The invoice Id provided does not exists!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId])

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Invoice ' + ARI.[strInvoiceNumber] + ' is not yet posted!'	
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
INNER JOIN
	(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[ysnPosted] = 0) ARI
	ON 
		IT.[intInvoiceId] = ARI.[intInvoiceId]

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Adding Invoice(' + ARI.[strInvoiceNumber] + ') of type ''Cash'' is not allowed!'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
INNER JOIN
	(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice ARI WITH (NOLOCK) WHERE [ysnPosted] = 1 AND [strTransactionType] = 'Cash') ARI
	ON 
		IT.[intInvoiceId] = ARI.[intInvoiceId]

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Adding Invoice(' + ARI.[strInvoiceNumber] + ') of type ''Cash Refund'' is not allowed!'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
INNER JOIN
	(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice ARI WITH (NOLOCK) WHERE [ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund') ARI
	ON 
		IT.[intInvoiceId] = ARI.[intInvoiceId]

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Invoice ' + ARI.[strInvoiceNumber] + ' is not yet posted!'
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intPaymentId]			= IT.[intPaymentId]
FROM
	@ItemEntries IT
LEFT OUTER JOIN
	(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice ARI WITH (NOLOCK) WHERE (([ysnPosted] = 1 AND [strTransactionType] <> 'Customer Prepayment') OR ([ysnPosted] = 0 AND [strTransactionType] = 'Customer Prepayment'))) ARI
	ON 
		IT.[intInvoiceId] = ARI.[intInvoiceId]
WHERE
	ARI.[intInvoiceId] IS NULL
	

IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


DELETE FROM V
FROM @ItemEntries V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])


--INSERT INTO @InvalidRecords(
--	 [intId]
--	,[strMessage]		
--	,[strSourceTransaction]
--	,[intSourceId]
--	,[strSourceId]
--	,[intPaymentId]
--)
--SELECT
--	 [intId]				= IT.[intId]
--	,[strMessage]			= 'The payment Id provided does not exists!'	
--	,[strSourceTransaction]	= IT.[strSourceTransaction]
--	,[intSourceId]			= IT.[intSourceId]
--	,[strSourceId]			= IT.[strSourceId]
--	,[intPaymentId]			= IT.[intPaymentId]
--FROM
--	@ItemEntries IT
--INNER JOIN
--	(
--		SELECT 
--	)


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
--INSERT INTO @IntegrationLog
--	([intIntegrationLogId]
--	,[dtmDate]
--	,[intEntityId]
--	,[intGroupingOption]
--	,[strMessage]
--	,[strBatchIdForNewPost]
--	,[intPostedNewCount]
--	,[strBatchIdForNewPostRecap]
--	,[intRecapNewCount]
--	,[strBatchIdForExistingPost]
--	,[intPostedExistingCount]
--	,[strBatchIdForExistingRecap]
--	,[intRecapPostExistingCount]
--	,[strBatchIdForExistingUnPost]
--	,[intUnPostedExistingCount]
--	,[strBatchIdForExistingUnPostRecap]
--	,[intRecapUnPostedExistingCount]
--	,[intIntegrationLogDetailId]
--	,[intInvoiceId]
--	,[intInvoiceDetailId]
--	,[intTemporaryDetailIdForTax]
--	,[intId]
--	,[strTransactionType]
--	,[strType]
--	,[strSourceTransaction]
--	,[intSourceId]
--	,[strSourceId]
--	,[ysnPost]
--	,[ysnInsert]
--	,[ysnHeader]
--	,[ysnSuccess])
--SELECT
--	 [intIntegrationLogId]					= @IntegrationLogId
--	,[dtmDate]								= @DateOnly
--	,[intEntityId]							= @UserId
--	,[intGroupingOption]					= 0
--	,[strMessage]							= [strMessage]
--	,[strBatchIdForNewPost]					= ''
--	,[intPostedNewCount]					= 0
--	,[strBatchIdForNewPostRecap]			= ''
--	,[intRecapNewCount]						= 0
--	,[strBatchIdForExistingPost]			= ''
--	,[intPostedExistingCount]				= 0
--	,[strBatchIdForExistingRecap]			= ''
--	,[intRecapPostExistingCount]			= 0
--	,[strBatchIdForExistingUnPost]			= ''
--	,[intUnPostedExistingCount]				= 0
--	,[strBatchIdForExistingUnPostRecap]		= ''
--	,[intRecapUnPostedExistingCount]		= 0
--	,[intIntegrationLogDetailId]			= 0
--	,[intInvoiceId]							= [intInvoiceId]
--	,[intInvoiceDetailId]					= NULL
--	,[intTemporaryDetailIdForTax]			= NULL
--	,[intId]								= [intId]
--	,[strTransactionType]					= [strTransactionType]
--	,[strType]								= [strType]
--	,[strSourceTransaction]					= [strSourceTransaction]
--	,[intSourceId]							= [intSourceId]
--	,[strSourceId]							= [strSourceId]
--	,[ysnPost]								= NULL
--	,[ysnInsert]							= 1
--	,[ysnHeader]							= 0
--	,[ysnSuccess]							= 0
--FROM
--	@InvalidRecords
	
--CREATE TABLE #Pricing(
--	 [intId]				INT
--	,[intInvoiceId]			INT
--	,[intInvoiceDetailId]	INT
--	,[dblPrice]				NUMERIC(18,6)
--	,[dblTermDiscount]		NUMERIC(18,6)
--	,[strTermDiscountBy]	NVARCHAR(50)
--	,[strPricing]			NVARCHAR(250)
--	,[intSubCurrencyId]		INT
--	,[dblSubCurrencyRate]	NUMERIC(18,6)
--	,[strSubCurrency]		NVARCHAR(40)
--	,[intPriceUOMId]		INT
--	,[strPriceUOM]			NVARCHAR(50)
--	,[dblDeviation]			NUMERIC(18,6)
--	,[intContractHeaderId]	INT
--	,[intContractDetailId]	INT
--	,[strContractNumber]	NVARCHAR(50)
--	,[intContractSeq]		INT
--	,[dblAvailableQty]      NUMERIC(18,6)
--	,[ysnUnlimitedQty]      BIT
--	,[strPricingType]		NVARCHAR(50)
--	,[intTermId]			INT NULL
--	,[intSort]				INT
--)
--BEGIN TRY
--	DELETE FROM #Pricing
--	INSERT INTO #Pricing(
--		 [intId]
--		,[intInvoiceId]
--		,[intInvoiceDetailId]
--		,[dblPrice]
--		,[dblTermDiscount]
--		,[strTermDiscountBy]
--		,[strPricing]
--		,[intSubCurrencyId]
--		,[dblSubCurrencyRate]
--		,[strSubCurrency]
--		,[intPriceUOMId]
--		,[strPriceUOM]
--		,[dblDeviation]
--		,[intContractHeaderId]
--		,[intContractDetailId]
--		,[strContractNumber]
--		,[intContractSeq]
--		,[dblAvailableQty]
--		,[ysnUnlimitedQty]
--		,[strPricingType]
--		,[intTermId]
--		,[intSort]
--	)
--	SELECT
--		 [intId]				= IE.[intId]
--		,[intInvoiceId]			= IE.[intInvoiceId] 
--		,[intInvoiceDetailId]	= IE.[intInvoiceDetailId]
--		,[dblPrice]				= IP.[dblPrice]
--		,[dblTermDiscount]		= IP.[dblTermDiscount]
--		,[strTermDiscountBy]	= IP.[strTermDiscountBy]
--		,[strPricing]			= IP.[strPricing]
--		,[intSubCurrencyId]		= IP.[intSubCurrencyId]
--		,[dblSubCurrencyRate]	= IP.[dblSubCurrencyRate]
--		,[strSubCurrency]		= IP.[strSubCurrency]
--		,[intPriceUOMId]		= IP.[intPriceUOMId]
--		,[strPriceUOM]			= IP.[strPriceUOM]
--		,[dblDeviation]			= IP.[dblDeviation]
--		,[intContractHeaderId]	= IP.[intContractHeaderId]
--		,[intContractDetailId]	= IP.[intContractDetailId]
--		,[strContractNumber]	= IP.[strContractNumber]
--		,[intContractSeq]		= IP.[intContractSeq]	
--		,[dblAvailableQty]		= IP.[dblAvailableQty]
--		,[ysnUnlimitedQty]		= IP.[ysnUnlimitedQty]
--		,[strPricingType]		= IP.[strPricingType]
--		,[intTermId]			= IP.[intTermId]
--		,[intSort]				= IP.[intSort]
--	FROM
--		@ItemEntries IE
--	CROSS APPLY
--		[dbo].[fnARGetItemPricingDetails]
--	(
--		 IE.[intItemId]				--@ItemId
--		,IE.[intEntityCustomerId]	--@CustomerId
--		,IE.[intCompanyLocationId]	--@LocationId
--		,IE.[intItemUOMId]			--@ItemUOMId
--		,IE.[intCurrencyId]			--@CurrencyId
--		,IE.[dtmDate]				--@TransactionDate
--		,IE.[dblQtyShipped]			--@Quantity
--		,IE.[intContractHeaderId]	--@ContractHeaderId
--		,IE.[intContractDetailId]	--@ContractDetailId
--		,''							--@ContractNumber
--		,''							--@ContractSeq
--		,0							--@AvailableQuantity
--		,0							--@UnlimitedQuantity
--		,0							--@OriginalQuantity
--		,0							--@CustomerPricingOnly
--		,0							--@ItemPricingOnly
--		,0							--@ExcludeContractPricing
--		,NULL						--@VendorId
--		,NULL						--@SupplyPointId
--		,0							--@LastCost
--		,IE.[intShipToLocationId]	--@ShipToLocationId
--		,NULL						--@VendorLocationId
--		,NULL						--@PricingLevelId
--		,0							--@AllowQtyToExceed
--		,IE.[strType]				--@InvoiceType
--		,IE.[intTermId]				--@TermId
--		,0							--@GetAllAvailablePricing
--	) IP
--	WHERE
--		ISNULL(IE.[ysnRefreshPrice],0) = 1

--END TRY
--BEGIN CATCH
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

--BEGIN TRY
--MERGE INTO tblARInvoiceDetail AS Target
--USING 
--	(
--	SELECT
--		 [intInvoiceId]							= IE.[intInvoiceId]
--		,[intInvoiceDetailId]					= NULL
--		,[strDocumentNumber]					= IE.[strDocumentNumber]
--		,[intItemId]							= IC.[intItemId]
--		,[intPrepayTypeId]						= IE.[intPrepayTypeId]
--		,[dblPrepayRate]						= IE.[dblPrepayRate]
--		,[strItemDescription]					= ISNULL(ISNULL(IE.[strItemDescription], IC.[strDescription]), '')
--		,[dblQtyOrdered]						= ISNULL(IE.[dblQtyOrdered], @ZeroDecimal)
--		,[intOrderUOMId]						= IE.[intOrderUOMId]
--		,[dblQtyShipped]						= ISNULL(IE.[dblQtyShipped], @ZeroDecimal)
--		,[intItemUOMId]							= ISNULL(ISNULL(IE.[intItemUOMId], IL.[intIssueUOMId]), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM ICUOM WITH (NOLOCK) WHERE ICUOM.[intItemId] = IC.[intItemId] ORDER BY ICUOM.[ysnStockUnit] DESC, [intItemUOMId]))
--		,[dblItemWeight]						= IE.[dblItemWeight]
--		,[intItemWeightUOMId]					= IE.[intItemWeightUOMId]
--		,[dblDiscount]							= ISNULL(IE.[dblDiscount], @ZeroDecimal)
--		,[dblItemTermDiscount]					= ISNULL(ISNULL(IP.[dblTermDiscount], IE.[dblItemTermDiscount]), @ZeroDecimal)
--		,[strItemTermDiscountBy]				= ISNULL(IP.[strTermDiscountBy], IE.[strItemTermDiscountBy])
--		,[dblPrice]								= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
--		,[dblBasePrice]							= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
--		,[strPricing]							= ISNULL(IP.[strPricing], IE.[strPricing])
--		,[dblTotalTax]							= @ZeroDecimal
--		,[dblBaseTotalTax]						= @ZeroDecimal
--		,[dblTotal]								= @ZeroDecimal
--		,[dblBaseTotal]							= @ZeroDecimal
--		,[intCurrencyExchangeRateTypeId]		= IE.[intCurrencyExchangeRateTypeId]
--		,[intCurrencyExchangeRateId]			= IE.[intCurrencyExchangeRateId]
--		,[dblCurrencyExchangeRate]				= CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END
--		,[intSubCurrencyId]						= ISNULL(ISNULL(IP.[intSubCurrencyId], IE.[intSubCurrencyId]), IE.[intCurrencyId])
--		,[dblSubCurrencyRate]					= CASE WHEN ISNULL(ISNULL(IP.[intSubCurrencyId], IE.[intSubCurrencyId]), 0) = 0 THEN 1 ELSE ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) END
--		,[ysnRestricted]						= IE.[ysnRestricted]
--		,[ysnBlended]							= IE.[ysnBlended]
--		,[intAccountId]							= Acct.[intAccountId]
--		,[intCOGSAccountId]						= Acct.[intCOGSAccountId]
--		,[intSalesAccountId]					= ISNULL(IE.[intSalesAccountId], Acct.[intSalesAccountId])
--		,[intInventoryAccountId]				= Acct.[intInventoryAccountId]
--		,[intServiceChargeAccountId]			= Acct.[intAccountId]
--		,[intLicenseAccountId]					= Acct.[intGeneralAccountId]
--		,[intMaintenanceAccountId]				= Acct.[intMaintenanceSalesAccountId]
--		,[strMaintenanceType]					= IE.[strMaintenanceType]
--		,[strFrequency]							= IE.[strFrequency]
--		,[dtmMaintenanceDate]					= IE.[dtmMaintenanceDate]
--		,[dblMaintenanceAmount]					= IE.[dblMaintenanceAmount]
--		,[dblBaseMaintenanceAmount]				= IE.[dblMaintenanceAmount] * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
--		,[dblLicenseAmount]						= IE.[dblLicenseAmount]
--		,[dblBaseLicenseAmount]					= IE.[dblLicenseAmount] * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
--		,[intTaxGroupId]						= IE.[intTaxGroupId]
--		,[intStorageLocationId]					= IE.[intStorageLocationId]
--		,[intCompanyLocationSubLocationId]		= IE.[intCompanyLocationSubLocationId]
--		,[intSCInvoiceId]						= IE.[intSCInvoiceId]
--		,[intSCBudgetId]						= IE.[intSCBudgetId]
--		,[strSCInvoiceNumber]					= IE.[strSCInvoiceNumber]
--		,[strSCBudgetDescription]				= IE.[strSCBudgetDescription]
--		,[intInventoryShipmentItemId]			= IE.[intInventoryShipmentItemId]
--		,[intInventoryShipmentChargeId]			= IE.[intInventoryShipmentChargeId]
--		,[intRecipeItemId]						= IE.[intRecipeItemId]
--		,[strShipmentNumber]					= IE.[strShipmentNumber]
--		,[intSalesOrderDetailId]				= IE.[intSalesOrderDetailId]
--		,[strSalesOrderNumber]					= IE.[strSalesOrderNumber]
--		,[strVFDDocumentNumber]					= IE.[strVFDDocumentNumber]
--		,[intContractHeaderId]					= ISNULL(IP.[intContractHeaderId], IE.[intContractHeaderId])
--		,[intContractDetailId]					= ISNULL(IP.[intContractDetailId], IE.[intContractDetailId])
--		,[dblContractBalance]					= @ZeroDecimal
--		,[dblContractAvailable]					= ISNULL(IP.[dblAvailableQty], @ZeroDecimal)
--		,[intShipmentId]						= IE.[intShipmentId]
--		,[intShipmentPurchaseSalesContractId]	= IE.[intShipmentPurchaseSalesContractId]
--		,[dblShipmentGrossWt]					= IE.[dblShipmentGrossWt]	
--		,[dblShipmentTareWt]					= IE.[dblShipmentTareWt]
--		,[dblShipmentNetWt]						= IE.[dblShipmentNetWt]
--		,[intTicketId]							= IE.[intTicketId]
--		,[intTicketHoursWorkedId]				= IE.[intTicketHoursWorkedId]
--		,[intCustomerStorageId]					= IE.[intCustomerStorageId]
--		,[intSiteDetailId]						= IE.[intSiteDetailId]
--		,[intLoadDetailId]						= IE.[intLoadDetailId]
--		,[intLotId]								= IE.[intLotId]
--		,[intOriginalInvoiceDetailId]			= IE.[intOriginalInvoiceDetailId]
--		,[intConversionAccountId]				= IE.[intConversionAccountId]
--		,[intEntitySalespersonId]				= IE.[intEntitySalespersonId]
--		,[intSiteId]							= IE.[intSiteId]
--		,[strBillingBy]							= IE.[strBillingBy]
--		,[dblPercentFull]						= IE.[dblPercentFull]
--		,[dblNewMeterReading]					= IE.[dblNewMeterReading]
--		,[dblPreviousMeterReading]				= IE.[dblPreviousMeterReading]
--		,[dblConversionFactor]					= IE.[dblConversionFactor]
--		,[intPerformerId]						= IE.[intPerformerId]
--		,[ysnLeaseBilling]						= IE.[ysnLeaseBilling]
--		,[ysnVirtualMeterReading]				= IE.[ysnVirtualMeterReading]
--		,[dblOriginalItemWeight]				= @ZeroDecimal
--		,[intRecipeId]							= IE.[intRecipeId]
--		,[intSubLocationId]						= IE.[intSubLocationId]
--		,[intCostTypeId]						= IE.[intCostTypeId]
--		,[intMarginById]						= IE.[intMarginById]
--		,[intCommentTypeId]						= IE.[intCommentTypeId]
--		,[dblMargin]							= IE.[dblMargin]
--		,[dblRecipeQuantity]					= IE.[dblRecipeQuantity]
--		,[intStorageScheduleTypeId]				= IE.[intStorageScheduleTypeId]
--		,[intDestinationGradeId]				= IE.[intDestinationGradeId]
--		,[intDestinationWeightId]				= IE.[intDestinationWeightId]
--		,[intConcurrencyId]						= 1
--		,[ysnRecomputeTax]						= IE.[ysnRecomputeTax]
--		,[intEntityId]							= IE.[intEntityId]
--		,[intId]								= IE.[intId]
--		,[strTransactionType]					= IE.[strTransactionType]
--		,[strType]								= IE.[strType]
--		,[strSourceTransaction]					= IE.[strSourceTransaction]
--		,[intSourceId]							= IE.[intSourceId]
--		,[strSourceId]							= IE.[strSourceId]
--		,[ysnPost]								= IE.[ysnPost]
--		,[intTempDetailIdForTaxes]				= IE.[intTempDetailIdForTaxes]
--	FROM
--		@ItemEntries IE
--	INNER JOIN
--		(
--		SELECT
--			 [intItemId]
--			,[strDescription]
--		FROM tblICItem WITH (NOLOCK)
--		) IC
--			ON IE.[intItemId] = IC.[intItemId]
--	INNER JOIN
--		(
--		SELECT
--			intItemId
--			,[intLocationId] 
--			,[intIssueUOMId]
--		FROM tblICItemLocation WITH (NOLOCK)
--		) IL
--			ON IC.intItemId = IL.intItemId
--			AND IE.[intCompanyLocationId] = IL.[intLocationId]
--	LEFT OUTER JOIN
--		(
--		SELECT
--			 [intId]
--			,[intInvoiceId]
--			,[intInvoiceDetailId]
--			,[dblPrice]
--			,[dblTermDiscount]
--			,[strTermDiscountBy]
--			,[strPricing]
--			,[intSubCurrencyId]
--			,[dblSubCurrencyRate]
--			,[dblDeviation]
--			,[intContractHeaderId]
--			,[intContractDetailId]
--			,[intContractSeq]
--			,[dblAvailableQty]
--		FROM
--			#Pricing WITH (NOLOCK)
--		) IP
--			ON IE.[intInvoiceId] = IP.[intInvoiceId]
--			AND (IE.[intId] = IP.[intId]
--				OR
--				IE.[intInvoiceDetailId] = IP.[intInvoiceDetailId])
--	LEFT OUTER JOIN
--		(
--		SELECT
--			 [intAccountId] 
--			,[intCOGSAccountId] 
--			,[intSalesAccountId]
--			,[intInventoryAccountId]	
--			,[intGeneralAccountId]
--			,[intMaintenanceSalesAccountId]		
--			,[intItemId]
--			,[intLocationId]			
--		FROM vyuARGetItemAccount WITH (NOLOCK)
--		) Acct
--			ON IC.[intItemId] = Acct.[intItemId]
--			AND IL.[intLocationId] = Acct.[intLocationId]		
--	)
--AS Source
--ON Target.[intInvoiceDetailId] = Source.[intInvoiceDetailId]
--WHEN NOT MATCHED BY TARGET THEN
--INSERT(
--	 [intInvoiceId]
--	,[strDocumentNumber]
--	,[intItemId]
--	,[intPrepayTypeId]
--	,[dblPrepayRate]
--	,[strItemDescription]
--	,[dblQtyOrdered]
--	,[intOrderUOMId]
--	,[dblQtyShipped]
--	,[intItemUOMId]
--	,[dblItemWeight]
--	,[intItemWeightUOMId]
--	,[dblDiscount]
--	,[dblItemTermDiscount]
--	,[strItemTermDiscountBy]
--	,[dblPrice]
--	,[dblBasePrice]
--	,[strPricing]
--	,[dblTotalTax]
--	,[dblBaseTotalTax]
--	,[dblTotal]
--	,[dblBaseTotal]
--	,[intCurrencyExchangeRateTypeId]
--	,[intCurrencyExchangeRateId]
--	,[dblCurrencyExchangeRate]
--	,[intSubCurrencyId]
--	,[dblSubCurrencyRate]
--	,[ysnRestricted]
--	,[ysnBlended]
--	,[intAccountId]
--	,[intCOGSAccountId]
--	,[intSalesAccountId]
--	,[intInventoryAccountId]
--	,[intServiceChargeAccountId]
--	,[intLicenseAccountId]
--	,[intMaintenanceAccountId]
--	,[strMaintenanceType]
--	,[strFrequency]
--	,[dtmMaintenanceDate]
--	,[dblMaintenanceAmount]
--	,[dblBaseMaintenanceAmount]
--	,[dblLicenseAmount]
--	,[dblBaseLicenseAmount]
--	,[intTaxGroupId]
--	,[intStorageLocationId]
--	,[intCompanyLocationSubLocationId]
--	,[intSCInvoiceId]
--	,[intSCBudgetId]
--	,[strSCInvoiceNumber]
--	,[strSCBudgetDescription]
--	,[intInventoryShipmentItemId]
--	,[intInventoryShipmentChargeId]
--	,[intRecipeItemId]
--	,[strShipmentNumber]
--	,[intSalesOrderDetailId]
--	,[strSalesOrderNumber]
--	,[strVFDDocumentNumber]
--	,[intContractHeaderId]
--	,[intContractDetailId]
--	,[dblContractBalance]
--	,[dblContractAvailable]
--	,[intShipmentId]
--	,[intShipmentPurchaseSalesContractId]
--	,[dblShipmentGrossWt]
--	,[dblShipmentTareWt]
--	,[dblShipmentNetWt]
--	,[intTicketId]
--	,[intTicketHoursWorkedId]
--	,[intCustomerStorageId]
--	,[intSiteDetailId]
--	,[intLoadDetailId]
--	,[intLotId]
--	,[intOriginalInvoiceDetailId]
--	,[intConversionAccountId]
--	,[intEntitySalespersonId]
--	,[intSiteId]
--	,[strBillingBy]
--	,[dblPercentFull]
--	,[dblNewMeterReading]
--	,[dblPreviousMeterReading]
--	,[dblConversionFactor]
--	,[intPerformerId]
--	,[ysnLeaseBilling]
--	,[ysnVirtualMeterReading]
--	,[dblOriginalItemWeight]		
--	,[intRecipeId]
--	,[intSubLocationId]
--	,[intCostTypeId]
--	,[intMarginById]
--	,[intCommentTypeId]
--	,[dblMargin]
--	,[dblRecipeQuantity]
--	,[intStorageScheduleTypeId]
--	,[intDestinationGradeId]
--	,[intDestinationWeightId]
--	,[intConcurrencyId]
--	)
--VALUES(
--	 [intInvoiceId]
--	,[strDocumentNumber]
--	,[intItemId]
--	,[intPrepayTypeId]
--	,[dblPrepayRate]
--	,[strItemDescription]
--	,[dblQtyOrdered]
--	,[intOrderUOMId]
--	,[dblQtyShipped]
--	,[intItemUOMId]
--	,[dblItemWeight]
--	,[intItemWeightUOMId]
--	,[dblDiscount]
--	,[dblItemTermDiscount]
--	,[strItemTermDiscountBy]
--	,[dblPrice]
--	,[dblBasePrice]
--	,[strPricing]
--	,[dblTotalTax]
--	,[dblBaseTotalTax]
--	,[dblTotal]
--	,[dblBaseTotal]
--	,[intCurrencyExchangeRateTypeId]
--	,[intCurrencyExchangeRateId]
--	,[dblCurrencyExchangeRate]
--	,[intSubCurrencyId]
--	,[dblSubCurrencyRate]
--	,[ysnRestricted]
--	,[ysnBlended]
--	,[intAccountId]
--	,[intCOGSAccountId]
--	,[intSalesAccountId]
--	,[intInventoryAccountId]
--	,[intServiceChargeAccountId]
--	,[intLicenseAccountId]
--	,[intMaintenanceAccountId]
--	,[strMaintenanceType]
--	,[strFrequency]
--	,[dtmMaintenanceDate]
--	,[dblMaintenanceAmount]
--	,[dblBaseMaintenanceAmount]
--	,[dblLicenseAmount]
--	,[dblBaseLicenseAmount]
--	,[intTaxGroupId]
--	,[intStorageLocationId]
--	,[intCompanyLocationSubLocationId]
--	,[intSCInvoiceId]
--	,[intSCBudgetId]
--	,[strSCInvoiceNumber]
--	,[strSCBudgetDescription]
--	,[intInventoryShipmentItemId]
--	,[intInventoryShipmentChargeId]
--	,[intRecipeItemId]
--	,[strShipmentNumber]
--	,[intSalesOrderDetailId]
--	,[strSalesOrderNumber]
--	,[strVFDDocumentNumber]
--	,[intContractHeaderId]
--	,[intContractDetailId]
--	,[dblContractBalance]
--	,[dblContractAvailable]
--	,[intShipmentId]
--	,[intShipmentPurchaseSalesContractId]
--	,[dblShipmentGrossWt]
--	,[dblShipmentTareWt]
--	,[dblShipmentNetWt]
--	,[intTicketId]
--	,[intTicketHoursWorkedId]
--	,[intCustomerStorageId]
--	,[intSiteDetailId]
--	,[intLoadDetailId]
--	,[intLotId]
--	,[intOriginalInvoiceDetailId]
--	,[intConversionAccountId]
--	,[intEntitySalespersonId]
--	,[intSiteId]
--	,[strBillingBy]
--	,[dblPercentFull]
--	,[dblNewMeterReading]
--	,[dblPreviousMeterReading]
--	,[dblConversionFactor]
--	,[intPerformerId]
--	,[ysnLeaseBilling]
--	,[ysnVirtualMeterReading]
--	,[dblOriginalItemWeight]		
--	,[intRecipeId]
--	,[intSubLocationId]
--	,[intCostTypeId]
--	,[intMarginById]
--	,[intCommentTypeId]
--	,[dblMargin]
--	,[dblRecipeQuantity]
--	,[intStorageScheduleTypeId]
--	,[intDestinationGradeId]
--	,[intDestinationWeightId]
--	,[intConcurrencyId]
--)
--	OUTPUT  
--			@IntegrationLogId						--[intIntegrationLogId]
--			,INSERTED.[intInvoiceId]				--[intInvoiceId]
--			,INSERTED.[intInvoiceDetailId]			--[intInvoiceDetailId]
--			,Source.[intTempDetailIdForTaxes]		--[intTempDetailIdForTaxes]	
--			,Source.[intId]							--[intId]
--			,'Line Item was successfully added.'	--[strErrorMessage]
--			,Source.[strTransactionType]			--[strTransactionType]
--			,Source.[strType]						--[strType]
--			,Source.[strSourceTransaction]			--[strSourceTransaction]
--			,Source.[intSourceId]					--[intSourceId]
--			,Source.[strSourceId]					--[strSourceId]
--			,Source.[ysnPost]						--[ysnPost]
--			,0										--[ysnRecap]
--			,1										--[ysnInsert]
--			,0										--[ysnHeader]
--			,1										--[ysnSuccess]
--			,NULL									--[ysnPosted]
--			,NULL									--[ysnUnPosted]
--			,NULL									--[strBatchId]
--			,1										--[intConcurrencyId]
--		INTO tblARInvoiceIntegrationLogDetail(
--			[intIntegrationLogId]
--           ,[intInvoiceId]
--           ,[intInvoiceDetailId]
--           ,[intTemporaryDetailIdForTax]
--           ,[intId]
--           ,[strMessage]
--           ,[strTransactionType]
--           ,[strType]
--           ,[strSourceTransaction]
--           ,[intSourceId]
--           ,[strSourceId]
--           ,[ysnPost]
--           ,[ysnRecap]
--           ,[ysnInsert]
--           ,[ysnHeader]
--           ,[ysnSuccess]
--           ,[ysnPosted]
--           ,[ysnUnPosted]
--           ,[strBatchId]
--           ,[intConcurrencyId]
--		);					

--	IF ISNULL(@IntegrationLogId, 0) <> 0
--		EXEC [uspARInsertInvoiceIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog
			
--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0	
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH
		
--BEGIN TRY

--	DECLARE @RecomputeTaxIds InvoiceId	
--	DELETE FROM @RecomputeTaxIds

--	INSERT INTO @RecomputeTaxIds(
--		 [intHeaderId]
--		,[ysnUpdateAvailableDiscountOnly]
--		,[intDetailId])
--	SELECT 
--		 [intHeaderId]						= [intInvoiceId]
--		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount]
--		,[intDetailId]						= [intInvoiceDetailId]
--	 FROM @IntegrationLog 
--	 WHERE
--		[ysnSuccess] = 1
--		AND ISNULL([ysnRecomputeTax], 0) = 1

--	EXEC [dbo].[uspARReComputeInvoicesTaxes] @InvoiceIds = @RecomputeTaxIds


--	DECLARE @RecomputeAmountIds InvoiceId	
--	DELETE FROM @RecomputeAmountIds

--	INSERT INTO @RecomputeAmountIds(
--		 [intHeaderId]
--		,[ysnUpdateAvailableDiscountOnly]
--		,[intDetailId])
--	SELECT 
--		 [intHeaderId]						= [intInvoiceId]
--		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount]
--		,[intDetailId]						= [intInvoiceDetailId]
--	 FROM @IntegrationLog 
--	 WHERE
--		[ysnSuccess] = 1
--		AND ISNULL([ysnRecomputeTax], 0) = 0

--	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @RecomputeAmountIds
	
--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH


IF ISNULL(@RaiseError,0) = 0	
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END
GO