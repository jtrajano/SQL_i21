CREATE PROCEDURE [dbo].[uspARAddInventoryItemToInvoices]
	 @InvoiceEntries	InvoiceStagingTable	READONLY
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

DECLARE @ItemEntries InvoiceStagingTable
DELETE FROM @ItemEntries
INSERT INTO @ItemEntries SELECT * FROM @InvoiceEntries


DECLARE @InvalidRecords AS TABLE (
	 [intId]				INT
	,[strErrorMessage]		NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]			INT												NULL
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intInvoiceId]			INT												NULL
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strErrorMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
)
SELECT
	 [intId]				= IT.[intId]
	,[strErrorMessage]		= 'Invoice does not exists!'
	,[strTransactionType]	= IT.[strTransactionType]
	,[strType]				= IT.[strType]
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intInvoiceId]			= IT.[intInvoiceId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId])

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strErrorMessage]		= 'Invoice is already posted!'
	,[strTransactionType]	= IT.[strTransactionType]
	,[strType]				= IT.[strType]
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intInvoiceId]			= IT.[intInvoiceId]
FROM
	@ItemEntries IT
WHERE
	EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId] AND ISNULL(ARI.[ysnPosted],0) = 1)

UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strErrorMessage]		= 'Item does not exists!'
	,[strTransactionType]	= IT.[strTransactionType]
	,[strType]				= IT.[strType]
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intInvoiceId]			= IT.[intInvoiceId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblICItem IC WITH (NOLOCK) WHERE IC.[intItemId] = IT.[intItemId])
	
UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strErrorMessage]		= 'The company location from the target Invoice does not exists!'
	,[strTransactionType]	= IT.[strTransactionType]
	,[strType]				= IT.[strType]
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intInvoiceId]			= IT.[intInvoiceId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] = IT.[intCompanyLocationId])
		
UNION ALL

SELECT
	 [intId]				= IT.[intId]
	,[strErrorMessage]		= 'The item(' + CAST(IT.[intItemId] AS NVARCHAR(20)) + ') was not set up to be available on the specified location(' + CAST(IT.[intCompanyLocationId] AS NVARCHAR(20)) + ')!'
	,[strTransactionType]	= IT.[strTransactionType]
	,[strType]				= IT.[strType]
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intInvoiceId]			= IT.[intInvoiceId]
FROM
	@ItemEntries IT
WHERE
	NOT EXISTS(	SELECT NULL 
				FROM tblICItem IC WITH (NOLOCK) INNER JOIN tblICItemLocation IL WITH (NOLOCK) ON IC.intItemId = IL.intItemId
				WHERE IC.[intItemId] = IT.[intItemId] AND IL.[intLocationId] = IT.[intCompanyLocationId])
	

IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strErrorMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


DELETE FROM V
FROM @ItemEntries V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])

	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION
	
DECLARE  @IntegrationLog InvoiceIntegrationLogStagingTable
DELETE FROM @IntegrationLog
INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strErrorMessage]
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
	,[intIntegrationLogDetailId]
	,[intInvoiceId]
	,[intInvoiceDetailId]
	,[intTemporaryDetailIdForTax]
	,[intId]
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[ysnPost]
	,[ysnInsert]
	,[ysnHeader]
	,[ysnSuccess])
SELECT
	 [intIntegrationLogId]					= @IntegrationLogId
	,[dtmDate]								= @DateOnly
	,[intEntityId]							= @UserId
	,[intGroupingOption]					= 0
	,[strErrorMessage]						= [strErrorMessage]
	,[strBatchIdForNewPost]					= ''
	,[intPostedNewCount]					= 0
	,[strBatchIdForNewPostRecap]			= ''
	,[intRecapNewCount]						= 0
	,[strBatchIdForExistingPost]			= ''
	,[intPostedExistingCount]				= 0
	,[strBatchIdForExistingRecap]			= ''
	,[intRecapPostExistingCount]			= 0
	,[strBatchIdForExistingUnPost]			= ''
	,[intUnPostedExistingCount]				= 0
	,[strBatchIdForExistingUnPostRecap]		= ''
	,[intRecapUnPostedExistingCount]		= 0
	,[intIntegrationLogDetailId]			= 0
	,[intInvoiceId]							= [intInvoiceId]
	,[intInvoiceDetailId]					= NULL
	,[intTemporaryDetailIdForTax]			= NULL
	,[intId]								= [intId]
	,[strTransactionType]					= [strTransactionType]
	,[strType]								= [strType]
	,[strSourceTransaction]					= [strSourceTransaction]
	,[intSourceId]							= [intSourceId]
	,[strSourceId]							= [strSourceId]
	,[ysnPost]								= NULL
	,[ysnInsert]							= 1
	,[ysnHeader]							= 0
	,[ysnSuccess]							= 0
FROM
	@InvalidRecords
	
CREATE TABLE #Pricing(
	 [intId]				INT
	,[intInvoiceId]			INT
	,[intInvoiceDetailId]	INT
	,[dblPrice]				NUMERIC(18,6)
	,[dblTermDiscount]		NUMERIC(18,6)
	,[strTermDiscountBy]	NVARCHAR(50)
	,[strPricing]			NVARCHAR(250)
	,[intSubCurrencyId]		INT
	,[dblSubCurrencyRate]	NUMERIC(18,6)
	,[strSubCurrency]		NVARCHAR(40)
	,[intPriceUOMId]		INT
	,[strPriceUOM]			NVARCHAR(50)
	,[dblDeviation]			NUMERIC(18,6)
	,[intContractHeaderId]	INT
	,[intContractDetailId]	INT
	,[strContractNumber]	NVARCHAR(50)
	,[intContractSeq]		INT
	,[dblAvailableQty]      NUMERIC(18,6)
	,[ysnUnlimitedQty]      BIT
	,[strPricingType]		NVARCHAR(50)
	,[intTermId]			INT NULL
	,[intSort]				INT
)
BEGIN TRY
	DELETE FROM #Pricing
	INSERT INTO #Pricing(
		 [intId]
		,[intInvoiceId]
		,[intInvoiceDetailId]
		,[dblPrice]
		,[dblTermDiscount]
		,[strTermDiscountBy]
		,[strPricing]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[strSubCurrency]
		,[intPriceUOMId]
		,[strPriceUOM]
		,[dblDeviation]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[strContractNumber]
		,[intContractSeq]
		,[dblAvailableQty]
		,[ysnUnlimitedQty]
		,[strPricingType]
		,[intTermId]
		,[intSort]
	)
	SELECT
		 [intId]				= IE.[intId]
		,[intInvoiceId]			= IE.[intInvoiceId] 
		,[intInvoiceDetailId]	= IE.[intInvoiceDetailId]
		,[dblPrice]				= IP.[dblPrice]
		,[dblTermDiscount]		= IP.[dblTermDiscount]
		,[strTermDiscountBy]	= IP.[strTermDiscountBy]
		,[strPricing]			= IP.[strPricing]
		,[intSubCurrencyId]		= IP.[intSubCurrencyId]
		,[dblSubCurrencyRate]	= IP.[dblSubCurrencyRate]
		,[strSubCurrency]		= IP.[strSubCurrency]
		,[intPriceUOMId]		= IP.[intPriceUOMId]
		,[strPriceUOM]			= IP.[strPriceUOM]
		,[dblDeviation]			= IP.[dblDeviation]
		,[intContractHeaderId]	= IP.[intContractHeaderId]
		,[intContractDetailId]	= IP.[intContractDetailId]
		,[strContractNumber]	= IP.[strContractNumber]
		,[intContractSeq]		= IP.[intContractSeq]	
		,[dblAvailableQty]		= IP.[dblAvailableQty]
		,[ysnUnlimitedQty]		= IP.[ysnUnlimitedQty]
		,[strPricingType]		= IP.[strPricingType]
		,[intTermId]			= IP.[intTermId]
		,[intSort]				= IP.[intSort]
	FROM
		@ItemEntries IE
	CROSS APPLY
		[dbo].[fnARGetItemPricingDetails]
	(
		 IE.[intItemId]				--@ItemId
		,IE.[intEntityCustomerId]	--@CustomerId
		,IE.[intCompanyLocationId]	--@LocationId
		,IE.[intItemUOMId]			--@ItemUOMId
		,IE.[intCurrencyId]			--@CurrencyId
		,IE.[dtmDate]				--@TransactionDate
		,IE.[dblQtyShipped]			--@Quantity
		,IE.[intContractHeaderId]	--@ContractHeaderId
		,IE.[intContractDetailId]	--@ContractDetailId
		,''							--@ContractNumber
		,''							--@ContractSeq
		,0							--@AvailableQuantity
		,0							--@UnlimitedQuantity
		,0							--@OriginalQuantity
		,0							--@CustomerPricingOnly
		,0							--@ItemPricingOnly
		,0							--@ExcludeContractPricing
		,NULL						--@VendorId
		,NULL						--@SupplyPointId
		,0							--@LastCost
		,IE.[intShipToLocationId]	--@ShipToLocationId
		,NULL						--@VendorLocationId
		,NULL						--@PricingLevelId
		,0							--@AllowQtyToExceed
		,IE.[strType]				--@InvoiceType
		,IE.[intTermId]				--@TermId
		,0							--@GetAllAvailablePricing
	) IP
	WHERE
		ISNULL(IE.[ysnRefreshPrice],0) = 1

END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

BEGIN TRY
MERGE INTO tblARInvoiceDetail AS Target
USING 
	(
	SELECT
		 [intInvoiceId]							= IE.[intInvoiceId]
		,[intInvoiceDetailId]					= NULL
		,[strDocumentNumber]					= IE.[strDocumentNumber]
		,[intItemId]							= IC.[intItemId]
		,[intPrepayTypeId]						= IE.[intPrepayTypeId]
		,[dblPrepayRate]						= IE.[dblPrepayRate]
		,[strItemDescription]					= ISNULL(ISNULL(IE.[strItemDescription], IC.[strDescription]), '')
		,[dblQtyOrdered]						= ISNULL(IE.[dblQtyOrdered], @ZeroDecimal)
		,[intOrderUOMId]						= IE.[intOrderUOMId]
		,[dblQtyShipped]						= ISNULL(IE.[dblQtyShipped], @ZeroDecimal)
		,[intItemUOMId]							= ISNULL(ISNULL(IE.[intItemUOMId], IL.[intIssueUOMId]), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM ICUOM WITH (NOLOCK) WHERE ICUOM.[intItemId] = IC.[intItemId] ORDER BY ICUOM.[ysnStockUnit] DESC, [intItemUOMId]))
		,[dblItemWeight]						= IE.[dblItemWeight]
		,[intItemWeightUOMId]					= IE.[intItemWeightUOMId]
		,[dblDiscount]							= ISNULL(IE.[dblDiscount], @ZeroDecimal)
		,[dblItemTermDiscount]					= ISNULL(ISNULL(IP.[dblTermDiscount], IE.[dblItemTermDiscount]), @ZeroDecimal)
		,[strItemTermDiscountBy]				= ISNULL(IP.[strTermDiscountBy], IE.[strItemTermDiscountBy])
		,[dblPrice]								= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
		,[dblBasePrice]							= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
		,[strPricing]							= ISNULL(IP.[strPricing], IE.[strPricing])
		,[dblTotalTax]							= @ZeroDecimal
		,[dblBaseTotalTax]						= @ZeroDecimal
		,[dblTotal]								= @ZeroDecimal
		,[dblBaseTotal]							= @ZeroDecimal
		,[intCurrencyExchangeRateTypeId]		= IE.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]			= IE.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]				= CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END
		,[intSubCurrencyId]						= ISNULL(ISNULL(IP.[intSubCurrencyId], IE.[intSubCurrencyId]), IE.[intCurrencyId])
		,[dblSubCurrencyRate]					= CASE WHEN ISNULL(ISNULL(IP.[intSubCurrencyId], IE.[intSubCurrencyId]), 0) = 0 THEN 1 ELSE ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) END
		,[ysnRestricted]						= IE.[ysnRestricted]
		,[ysnBlended]							= IE.[ysnBlended]
		,[intAccountId]							= Acct.[intAccountId]
		,[intCOGSAccountId]						= Acct.[intCOGSAccountId]
		,[intSalesAccountId]					= ISNULL(IE.[intSalesAccountId], Acct.[intSalesAccountId])
		,[intInventoryAccountId]				= Acct.[intInventoryAccountId]
		,[intServiceChargeAccountId]			= Acct.[intAccountId]
		,[intLicenseAccountId]					= Acct.[intGeneralAccountId]
		,[intMaintenanceAccountId]				= Acct.[intMaintenanceSalesAccountId]
		,[strMaintenanceType]					= IE.[strMaintenanceType]
		,[strFrequency]							= IE.[strFrequency]
		,[dtmMaintenanceDate]					= IE.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]					= IE.[dblMaintenanceAmount]
		,[dblBaseMaintenanceAmount]				= IE.[dblMaintenanceAmount] * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
		,[dblLicenseAmount]						= IE.[dblLicenseAmount]
		,[dblBaseLicenseAmount]					= IE.[dblLicenseAmount] * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
		,[intTaxGroupId]						= IE.[intTaxGroupId]
		,[intStorageLocationId]					= IE.[intStorageLocationId]
		,[intCompanyLocationSubLocationId]		= IE.[intCompanyLocationSubLocationId]
		,[intSCInvoiceId]						= IE.[intSCInvoiceId]
		,[intSCBudgetId]						= IE.[intSCBudgetId]
		,[strSCInvoiceNumber]					= IE.[strSCInvoiceNumber]
		,[strSCBudgetDescription]				= IE.[strSCBudgetDescription]
		,[intInventoryShipmentItemId]			= IE.[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]			= IE.[intInventoryShipmentChargeId]
		,[intRecipeItemId]						= IE.[intRecipeItemId]
		,[strShipmentNumber]					= IE.[strShipmentNumber]
		,[intSalesOrderDetailId]				= IE.[intSalesOrderDetailId]
		,[strSalesOrderNumber]					= IE.[strSalesOrderNumber]
		,[strVFDDocumentNumber]					= IE.[strVFDDocumentNumber]
		,[intContractHeaderId]					= ISNULL(IP.[intContractHeaderId], IE.[intContractHeaderId])
		,[intContractDetailId]					= ISNULL(IP.[intContractDetailId], IE.[intContractDetailId])
		,[dblContractBalance]					= @ZeroDecimal
		,[dblContractAvailable]					= ISNULL(IP.[dblAvailableQty], @ZeroDecimal)
		,[intShipmentId]						= IE.[intShipmentId]
		,[intShipmentPurchaseSalesContractId]	= IE.[intShipmentPurchaseSalesContractId]
		,[dblShipmentGrossWt]					= IE.[dblShipmentGrossWt]	
		,[dblShipmentTareWt]					= IE.[dblShipmentTareWt]
		,[dblShipmentNetWt]						= IE.[dblShipmentNetWt]
		,[intTicketId]							= IE.[intTicketId]
		,[intTicketHoursWorkedId]				= IE.[intTicketHoursWorkedId]
		,[intCustomerStorageId]					= IE.[intCustomerStorageId]
		,[intSiteDetailId]						= IE.[intSiteDetailId]
		,[intLoadDetailId]						= IE.[intLoadDetailId]
		,[intLotId]								= IE.[intLotId]
		,[intOriginalInvoiceDetailId]			= IE.[intOriginalInvoiceDetailId]
		,[intConversionAccountId]				= IE.[intConversionAccountId]
		,[intEntitySalespersonId]				= IE.[intEntitySalespersonId]
		,[intSiteId]							= IE.[intSiteId]
		,[strBillingBy]							= IE.[strBillingBy]
		,[dblPercentFull]						= IE.[dblPercentFull]
		,[dblNewMeterReading]					= IE.[dblNewMeterReading]
		,[dblPreviousMeterReading]				= IE.[dblPreviousMeterReading]
		,[dblConversionFactor]					= IE.[dblConversionFactor]
		,[intPerformerId]						= IE.[intPerformerId]
		,[ysnLeaseBilling]						= IE.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]				= IE.[ysnVirtualMeterReading]
		,[dblOriginalItemWeight]				= @ZeroDecimal
		,[intRecipeId]							= IE.[intRecipeId]
		,[intSubLocationId]						= IE.[intSubLocationId]
		,[intCostTypeId]						= IE.[intCostTypeId]
		,[intMarginById]						= IE.[intMarginById]
		,[intCommentTypeId]						= IE.[intCommentTypeId]
		,[dblMargin]							= IE.[dblMargin]
		,[dblRecipeQuantity]					= IE.[dblRecipeQuantity]
		,[intStorageScheduleTypeId]				= IE.[intStorageScheduleTypeId]
		,[intDestinationGradeId]				= IE.[intDestinationGradeId]
		,[intDestinationWeightId]				= IE.[intDestinationWeightId]
		,[intConcurrencyId]						= 1
		,[ysnRecomputeTax]						= IE.[ysnRecomputeTax]
		,[intEntityId]							= IE.[intEntityId]
		,[intId]								= IE.[intId]
		,[strTransactionType]					= IE.[strTransactionType]
		,[strType]								= IE.[strType]
		,[strSourceTransaction]					= IE.[strSourceTransaction]
		,[intSourceId]							= IE.[intSourceId]
		,[strSourceId]							= IE.[strSourceId]
		,[ysnPost]								= IE.[ysnPost]
		,[intTempDetailIdForTaxes]				= IE.[intTempDetailIdForTaxes]
	FROM
		@ItemEntries IE
	INNER JOIN
		(
		SELECT
			 [intItemId]
			,[strDescription]
		FROM tblICItem WITH (NOLOCK)
		) IC
			ON IE.[intItemId] = IC.[intItemId]
	INNER JOIN
		(
		SELECT
			intItemId
			,[intLocationId] 
			,[intIssueUOMId]
		FROM tblICItemLocation WITH (NOLOCK)
		) IL
			ON IC.intItemId = IL.intItemId
			AND IE.[intCompanyLocationId] = IL.[intLocationId]
	LEFT OUTER JOIN
		(
		SELECT
			 [intId]
			,[intInvoiceId]
			,[intInvoiceDetailId]
			,[dblPrice]
			,[dblTermDiscount]
			,[strTermDiscountBy]
			,[strPricing]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[dblDeviation]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeq]
			,[dblAvailableQty]
		FROM
			#Pricing WITH (NOLOCK)
		) IP
			ON IE.[intInvoiceId] = IP.[intInvoiceId]
			AND (IE.[intId] = IP.[intId]
				OR
				IE.[intInvoiceDetailId] = IP.[intInvoiceDetailId])
	LEFT OUTER JOIN
		(
		SELECT
			 [intAccountId] 
			,[intCOGSAccountId] 
			,[intSalesAccountId]
			,[intInventoryAccountId]	
			,[intGeneralAccountId]
			,[intMaintenanceSalesAccountId]		
			,[intItemId]
			,[intLocationId]			
		FROM vyuARGetItemAccount WITH (NOLOCK)
		) Acct
			ON IC.[intItemId] = Acct.[intItemId]
			AND IL.[intLocationId] = Acct.[intLocationId]		
	)
AS Source
ON Target.[intInvoiceDetailId] = Source.[intInvoiceDetailId]
WHEN NOT MATCHED BY TARGET THEN
INSERT(
	 [intInvoiceId]
	,[strDocumentNumber]
	,[intItemId]
	,[intPrepayTypeId]
	,[dblPrepayRate]
	,[strItemDescription]
	,[dblQtyOrdered]
	,[intOrderUOMId]
	,[dblQtyShipped]
	,[intItemUOMId]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblPrice]
	,[dblBasePrice]
	,[strPricing]
	,[dblTotalTax]
	,[dblBaseTotalTax]
	,[dblTotal]
	,[dblBaseTotal]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId]
	,[dblSubCurrencyRate]
	,[ysnRestricted]
	,[ysnBlended]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intServiceChargeAccountId]
	,[intLicenseAccountId]
	,[intMaintenanceAccountId]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblBaseMaintenanceAmount]
	,[dblLicenseAmount]
	,[dblBaseLicenseAmount]
	,[intTaxGroupId]
	,[intStorageLocationId]
	,[intCompanyLocationSubLocationId]
	,[intSCInvoiceId]
	,[intSCBudgetId]
	,[strSCInvoiceNumber]
	,[strSCBudgetDescription]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[intRecipeItemId]
	,[strShipmentNumber]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[strVFDDocumentNumber]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[dblContractBalance]
	,[dblContractAvailable]
	,[intShipmentId]
	,[intShipmentPurchaseSalesContractId]
	,[dblShipmentGrossWt]
	,[dblShipmentTareWt]
	,[dblShipmentNetWt]
	,[intTicketId]
	,[intTicketHoursWorkedId]
	,[intCustomerStorageId]
	,[intSiteDetailId]
	,[intLoadDetailId]
	,[intLotId]
	,[intOriginalInvoiceDetailId]
	,[intConversionAccountId]
	,[intEntitySalespersonId]
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[ysnLeaseBilling]
	,[ysnVirtualMeterReading]
	,[dblOriginalItemWeight]		
	,[intRecipeId]
	,[intSubLocationId]
	,[intCostTypeId]
	,[intMarginById]
	,[intCommentTypeId]
	,[dblMargin]
	,[dblRecipeQuantity]
	,[intStorageScheduleTypeId]
	,[intDestinationGradeId]
	,[intDestinationWeightId]
	,[intConcurrencyId]
	)
VALUES(
	 [intInvoiceId]
	,[strDocumentNumber]
	,[intItemId]
	,[intPrepayTypeId]
	,[dblPrepayRate]
	,[strItemDescription]
	,[dblQtyOrdered]
	,[intOrderUOMId]
	,[dblQtyShipped]
	,[intItemUOMId]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblPrice]
	,[dblBasePrice]
	,[strPricing]
	,[dblTotalTax]
	,[dblBaseTotalTax]
	,[dblTotal]
	,[dblBaseTotal]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId]
	,[dblSubCurrencyRate]
	,[ysnRestricted]
	,[ysnBlended]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intServiceChargeAccountId]
	,[intLicenseAccountId]
	,[intMaintenanceAccountId]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblBaseMaintenanceAmount]
	,[dblLicenseAmount]
	,[dblBaseLicenseAmount]
	,[intTaxGroupId]
	,[intStorageLocationId]
	,[intCompanyLocationSubLocationId]
	,[intSCInvoiceId]
	,[intSCBudgetId]
	,[strSCInvoiceNumber]
	,[strSCBudgetDescription]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[intRecipeItemId]
	,[strShipmentNumber]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[strVFDDocumentNumber]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[dblContractBalance]
	,[dblContractAvailable]
	,[intShipmentId]
	,[intShipmentPurchaseSalesContractId]
	,[dblShipmentGrossWt]
	,[dblShipmentTareWt]
	,[dblShipmentNetWt]
	,[intTicketId]
	,[intTicketHoursWorkedId]
	,[intCustomerStorageId]
	,[intSiteDetailId]
	,[intLoadDetailId]
	,[intLotId]
	,[intOriginalInvoiceDetailId]
	,[intConversionAccountId]
	,[intEntitySalespersonId]
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[ysnLeaseBilling]
	,[ysnVirtualMeterReading]
	,[dblOriginalItemWeight]		
	,[intRecipeId]
	,[intSubLocationId]
	,[intCostTypeId]
	,[intMarginById]
	,[intCommentTypeId]
	,[dblMargin]
	,[dblRecipeQuantity]
	,[intStorageScheduleTypeId]
	,[intDestinationGradeId]
	,[intDestinationWeightId]
	,[intConcurrencyId]
);
	--OUTPUT  
	--		@IntegrationLogId						--[intIntegrationLogId]
	--		,@DateOnly								--[dtmDate]
	--		,Source.[intEntityId]					--[intEntityId]
	--		,0										--[intGroupingOption]
	--		,'Line Item was successfully added.'	--[strErrorMessage]
	--		,''										--[strBatchIdForNewPost]
	--		,0										--[intPostedNewCount]
	--		,''										--[strBatchIdForNewPostRecap]
	--		,0										--[intRecapNewCount]
	--		,''										--[strBatchIdForExistingPost]
	--		,0										--[intPostedExistingCount]
	--		,''										--[strBatchIdForExistingRecap]
	--		,0										--[intRecapPostExistingCount]
	--		,''										--[strBatchIdForExistingUnPost]
	--		,0										--[intUnPostedExistingCount]
	--		,''										--[strBatchIdForExistingUnPostRecap]
	--		,0										--[intRecapUnPostedExistingCount]
	--		,NULL									--[intIntegrationLogDetailId]
	--		,INSERTED.[intInvoiceId]				--[intInvoiceId]
	--		,INSERTED.[intInvoiceDetailId]			--[intInvoiceDetailId]
	--		,Source.[intTempDetailIdForTaxes]		--[intTempDetailIdForTaxes]	
	--		,Source.[intId]							--[intId]
	--		,Source.[strTransactionType]			--[strTransactionType]
	--		,Source.[strType]						--[strType]
	--		,Source.[strSourceTransaction]			--[strSourceTransaction]
	--		,Source.[intSourceId]					--[intSourceId]
	--		,Source.[strSourceId]					--[strSourceId]
	--		,Source.[ysnPost]						--[ysnPost]
	--		,0										--[ysnUpdateAvailableDiscount]
	--		,Source.[ysnRecomputeTax]				--[ysnRecomputeTax]
	--		,1										--[ysnInsert]
	--		,0										--[ysnHeader]
	--		,1										--[ysnSuccess]
	--	INTO @IntegrationLog(
	--		 [intIntegrationLogId]
	--		,[dtmDate]
	--		,[intEntityId]
	--		,[intGroupingOption]
	--		,[strErrorMessage]
	--		,[strBatchIdForNewPost]
	--		,[intPostedNewCount]
	--		,[strBatchIdForNewPostRecap]
	--		,[intRecapNewCount]
	--		,[strBatchIdForExistingPost]
	--		,[intPostedExistingCount]
	--		,[strBatchIdForExistingRecap]
	--		,[intRecapPostExistingCount]
	--		,[strBatchIdForExistingUnPost]
	--		,[intUnPostedExistingCount]
	--		,[strBatchIdForExistingUnPostRecap]
	--		,[intRecapUnPostedExistingCount]
	--		,[intIntegrationLogDetailId]
	--		,[intInvoiceId]
	--		,[intInvoiceDetailId]
	--		,[intTemporaryDetailIdForTax]
	--		,[intId]
	--		,[strTransactionType]
	--		,[strType]
	--		,[strSourceTransaction]
	--		,[intSourceId]
	--		,[strSourceId]
	--		,[ysnPost]
	--		,[ysnUpdateAvailableDiscount]
	--		,[ysnRecomputeTax]
	--		,[ysnInsert]
	--		,[ysnHeader]
	--		,[ysnSuccess]
	--	);					

	--IF ISNULL(@IntegrationLogId, 0) <> 0
	--	EXEC [uspARInsertInvoiceIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog
			
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

	DECLARE @RecomputeTaxIds InvoiceId	
	DELETE FROM @RecomputeTaxIds

	INSERT INTO @RecomputeTaxIds(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId])
	SELECT 
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount]
		,[intDetailId]						= [intInvoiceDetailId]
	 FROM @IntegrationLog 
	 WHERE
		[ysnSuccess] = 1
		AND ISNULL([ysnRecomputeTax], 0) = 1

	EXEC [dbo].[uspARReComputeInvoicesTaxes] @InvoiceIds = @RecomputeTaxIds


	DECLARE @RecomputeAmountIds InvoiceId	
	DELETE FROM @RecomputeAmountIds

	INSERT INTO @RecomputeAmountIds(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId])
	SELECT 
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount]
		,[intDetailId]						= [intInvoiceDetailId]
	 FROM @IntegrationLog 
	 WHERE
		[ysnSuccess] = 1
		AND ISNULL([ysnRecomputeTax], 0) = 0

	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @RecomputeAmountIds
	
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