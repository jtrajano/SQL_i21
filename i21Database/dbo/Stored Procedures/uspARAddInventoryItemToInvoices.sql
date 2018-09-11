﻿CREATE PROCEDURE [dbo].[uspARAddInventoryItemToInvoices]
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
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @ZeroDecimal	NUMERIC(18, 6) = 0.000000
		,@DateOnly		DATETIME = CAST(GETDATE() AS DATE)
		,@InitTranCount	INT
		,@Savepoint		NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInventoryItemToInvoices' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

DECLARE @ItemEntries InvoiceStagingTable
DELETE FROM @ItemEntries
INSERT INTO @ItemEntries SELECT * FROM @InvoiceEntries


DECLARE @InvalidRecords AS TABLE (
	 [intId]				INT
	,[strMessage]			NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]			INT												NULL
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intInvoiceId]			INT												NULL
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
)
SELECT
	 [intId]				= IT.[intId]
	,[strMessage]			= 'Invoice does not exists!'
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
	,[strMessage]			= 'Invoice is already posted!'
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
	,[strMessage]			= 'Item does not exists!'
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
	,[strMessage]			= 'The company location from the target Invoice does not exists!'
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
	,[strMessage]			= 'The item(' + CAST(IT.[intItemId] AS NVARCHAR(20)) + ') was not set up to be available on the specified location(' + CAST(IT.[intCompanyLocationId] AS NVARCHAR(20)) + ')!'
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
	
DECLARE  @IntegrationLog InvoiceIntegrationLogStagingTable
DELETE FROM @IntegrationLog
INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strMessage]
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
	,[strMessage]							= [strMessage]
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
	 [intId]							INT
	,[intInvoiceId]						INT
	,[intInvoiceDetailId]				INT
	,[dblPrice]							NUMERIC(18,6)
	,[dblUnitPrice]						NUMERIC(18,6)
	,[dblTermDiscount]					NUMERIC(18,6)
	,[strTermDiscountBy]				NVARCHAR(50)
	,[dblTermDiscountRate]				NUMERIC(18,6)
	,[ysnTermDiscountExempt]			BIT
	,[strPricing]						NVARCHAR(250)
	,[intCurrencyExchangeRateTypeId]	INT
	,[intCurrencyExchangeRateId]		INT
    ,[strCurrencyExchangeRateType]		NVARCHAR(20)
    ,[dblCurrencyExchangeRate]			NUMERIC(18,6)
	,[intSubCurrencyId]					INT
	,[dblSubCurrencyRate]				NUMERIC(18,6)
	,[strSubCurrency]					NVARCHAR(40)
	,[intContractUOMId]					INT
	,[strContractUOM]					NVARCHAR(50)
	,[intPriceUOMId]					INT
	,[strPriceUOM]						NVARCHAR(50)
	,[dblDeviation]						NUMERIC(18,6)
	,[intContractHeaderId]				INT
	,[intContractDetailId]				INT
	,[strContractNumber]				NVARCHAR(50)
	,[intContractSeq]					INT
	,[dblPriceUOMQuantity]				NUMERIC(18,6)
	,[dblQuantity]						NUMERIC(18,6)
	,[dblAvailableQty]					NUMERIC(18,6)
	,[ysnUnlimitedQty]					BIT
	,[strPricingType]					NVARCHAR(50)
	,[intTermId]						INT NULL
	,[intSort]							INT
)
BEGIN TRY
	DELETE FROM #Pricing
	INSERT INTO #Pricing(
		 [intId]
		,[intInvoiceId]
		,[intInvoiceDetailId]
		,[dblPrice]
		,[dblUnitPrice]
		,[dblTermDiscount]
		,[strTermDiscountBy]
		,[dblTermDiscountRate]
		,[ysnTermDiscountExempt]
		,[strPricing]
		,[intCurrencyExchangeRateTypeId]
		,[strCurrencyExchangeRateType]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[strSubCurrency]
		,[intContractUOMId]
		,[strContractUOM]
		,[intPriceUOMId]
		,[strPriceUOM]
		,[dblDeviation]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[strContractNumber]
		,[intContractSeq]
		,[dblPriceUOMQuantity]
		,[dblQuantity]
		,[dblAvailableQty]
		,[ysnUnlimitedQty]
		,[strPricingType]
		,[intTermId]
		,[intSort]
	)
	SELECT
		 [intId]							= IE.[intId]
		,[intInvoiceId]						= IE.[intInvoiceId] 
		,[intInvoiceDetailId]				= IE.[intInvoiceDetailId]
		,[dblPrice]							= IP.[dblPrice]
		,[dblUnitPrice]						= IP.[dblUnitPrice]
		,[dblTermDiscount]					= IP.[dblTermDiscount]
		,[strTermDiscountBy]				= IP.[strTermDiscountBy]
		,[dblTermDiscountRate]				= IP.[dblTermDiscountRate] 
		,[ysnTermDiscountExempt]			= IP.[ysnTermDiscountExempt]
		,[strPricing]						= IP.[strPricing]
		,[intCurrencyExchangeRateTypeId]	= IP.[intCurrencyExchangeRateTypeId]
		,[strCurrencyExchangeRateType]		= IP.[strCurrencyExchangeRateType]
		,[dblCurrencyExchangeRate]			= IP.[dblCurrencyExchangeRate]
		,[intSubCurrencyId]					= IP.[intSubCurrencyId]
		,[dblSubCurrencyRate]				= IP.[dblSubCurrencyRate]
		,[strSubCurrency]					= IP.[strSubCurrency]
		,[intContractUOMId]					= IP.[intContractUOMId]
		,[strContractUOM]					= IP.[strContractUOM]
		,[intPriceUOMId]					= IP.[intPriceUOMId]
		,[strPriceUOM]						= IP.[strPriceUOM]
		,[dblDeviation]						= IP.[dblDeviation]
		,[intContractHeaderId]				= IP.[intContractHeaderId]
		,[intContractDetailId]				= IP.[intContractDetailId]
		,[strContractNumber]				= IP.[strContractNumber]
		,[intContractSeq]					= IP.[intContractSeq]
		,[dblPriceUOMQuantity]				= IP.[dblPriceUOMQuantity]
		,[dblQuantity]						= IP.[dblQuantity]
		,[dblAvailableQty]					= IP.[dblAvailableQty]
		,[ysnUnlimitedQty]					= IP.[ysnUnlimitedQty]
		,[strPricingType]					= IP.[strPricingType]
		,[intTermId]						= IP.[intTermId]
		,[intSort]							= IP.[intSort]
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
		,ISNULL(IE.[dblCurrencyExchangeRate], 1)	--@CurrencyExchangeRate
		,IE.[intCurrencyExchangeRateId] --@CurrencyExchangeRateTypeId
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

IF(OBJECT_ID('tempdb..#InvoiceInventoryItem') IS NOT NULL)
BEGIN
    DROP TABLE #InvoiceInventoryItem
END

CREATE TABLE #InvoiceInventoryItem
	([intInvoiceId]						INT												NOT NULL
	,[intInvoiceDetailId]				INT												NULL
	,[strDocumentNumber]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[intItemId]						INt												NULL
	,[intPrepayTypeId]					INT												NULL
	,[dblPrepayRate]					NUMERIC(18, 6)									NULL
	,[strItemDescription]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
	,[dblQtyOrdered]					NUMERIC(18, 6)									NULL
	,[intOrderUOMId]					INT												NULL
	,[dblQtyShipped]					NUMERIC(18, 6)									NULL
	,[intItemUOMId]						INT												NULL
	,[intPriceUOMId]					INT												NULL
	,[dblUnitQuantity]					NUMERIC(18, 6)									NULL
	,[dblItemWeight]					NUMERIC(18, 6)									NULL
	,[intItemWeightUOMId]				INT												NULL
	,[dblDiscount]						NUMERIC(18, 6)									NULL
	,[dblItemTermDiscount]				NUMERIC(18, 6)									NULL
	,[strItemTermDiscountBy]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
	,[dblItemTermDiscountAmount]		NUMERIC(18, 6)									NULL
	,[dblBaseItemTermDiscountAmount]	NUMERIC(18, 6)									NULL
	,[dblItemTermDiscountExemption]		NUMERIC(18, 6)									NULL
	,[dblBaseItemTermDiscountExemption]	NUMERIC(18, 6)									NULL
	,[dblTermDiscountRate]				NUMERIC(18, 6)									NULL
	,[ysnTermDiscountExempt]			BIT												NULL
	,[dblPrice]							NUMERIC(18, 6)									NULL
	,[dblBasePrice]						NUMERIC(18, 6)									NULL
	,[dblUnitPrice]						NUMERIC(18, 6)									NULL
	,[dblBaseUnitPrice]					NUMERIC(18, 6)									NULL
	,[strPricing]						NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
	,[dblTotalTax]						NUMERIC(18, 6)									NULL
	,[dblBaseTotalTax]					NUMERIC(18, 6)									NULL
	,[dblTotal]							NUMERIC(18, 6)									NULL
	,[dblBaseTotal]						NUMERIC(18, 6)									NULL
	,[intCurrencyExchangeRateTypeId]	INT												NULL
	,[intCurrencyExchangeRateId]		INT												NULL
	,[dblCurrencyExchangeRate]			NUMERIC(18, 6)									NULL
	,[intSubCurrencyId]					INT												NULL
	,[dblSubCurrencyRate]				NUMERIC(18, 6)									NULL
	,[ysnRestricted]					BIT												NULL
	,[ysnBlended]						BIT												NULL
	,[intAccountId]						INT												NULL
	,[intCOGSAccountId]					INT												NULL
	,[intSalesAccountId]				INT												NULL
	,[intInventoryAccountId]			INT												NULL
	,[intServiceChargeAccountId]		INT												NULL
	,[intLicenseAccountId]				INT												NULL
	,[intMaintenanceAccountId]			INT												NULL
	,[strMaintenanceType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL			
	,[strFrequency]						NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[dtmMaintenanceDate]				DATETIME										NULL
	,[dblMaintenanceAmount]				NUMERIC(18, 6)									NULL
	,[dblBaseMaintenanceAmount]			NUMERIC(18, 6)									NULL
	,[dblLicenseAmount]					NUMERIC(18, 6)									NULL
	,[dblBaseLicenseAmount]				NUMERIC(18, 6)									NULL
	,[intTaxGroupId]					INT												NULL
	,[intStorageLocationId]				INT												NULL
	,[intCompanyLocationSubLocationId]	INT												NULL
	,[intSCInvoiceId]					INT												NULL
	,[intSCBudgetId]					INT												NULL
	,[strSCInvoiceNumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strSCBudgetDescription]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[intInventoryShipmentItemId]		INT												NULL
	,[intInventoryShipmentChargeId]		INT												NULL
	,[intRecipeItemId]					INT												NULL
	,[strShipmentNumber]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	,[intSalesOrderDetailId]			INT												NULL
	,[strSalesOrderNumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strVFDDocumentNumber]				NVARCHAR(100) 	COLLATE Latin1_General_CI_AS	NULL
	,[intContractHeaderId]				INT												NULL
	,[intContractDetailId]				INT												NULL
	,[dblContractBalance]				NUMERIC(18, 6)									NULL
	,[dblContractAvailable]				NUMERIC(18, 6)									NULL
	,[intShipmentId]					INT												NULL
	,[intShipmentPurchaseSalesContractId]	INT											NULL
	,[dblShipmentGrossWt]				NUMERIC(18, 6)									NULL
	,[dblShipmentTareWt]				NUMERIC(18, 6)									NULL
	,[dblShipmentNetWt]					NUMERIC(18, 6)									NULL
	,[intTicketId]						INT												NULL
	,[intTicketHoursWorkedId]			INT												NULL
	,[intCustomerStorageId]				INT												NULL
	,[intSiteDetailId]					INT												NULL
	,[intLoadDetailId]					INT												NULL
	,[intLotId]							INT												NULL
	,[intOriginalInvoiceDetailId]		INT												NULL
	,[intConversionAccountId]			INT												NULL
	,[intEntitySalespersonId]			INT												NULL
	,[intSiteId]						INT												NULL
	,[strBillingBy]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[dblPercentFull]					NUMERIC(18, 6)									NULL
	,[dblNewMeterReading]				NUMERIC(18, 6)									NULL
	,[dblPreviousMeterReading]			NUMERIC(18, 6)									NULL
	,[dblConversionFactor]				NUMERIC(18, 6)									NULL
	,[intPerformerId]					INT												NULL
	,[ysnLeaseBilling]					INT												NULL
	,[ysnVirtualMeterReading]			BIT												NULL
	,[dblOriginalItemWeight]			NUMERIC(18, 6)									NULL
	,[intRecipeId]						INT												NULL
	,[intSubLocationId]					INT												NULL
	,[intCostTypeId]					INT												NULL
	,[intMarginById]					INT												NULL
	,[intCommentTypeId]					INT												NULL
	,[dblMargin]						NUMERIC(18, 6)									NULL
	,[dblRecipeQuantity]				NUMERIC(18, 6)									NULL
	,[intStorageScheduleTypeId]			INT												NULL
	,[intDestinationGradeId]			INT												NULL
	,[intDestinationWeightId]			INT												NULL
	,[intConcurrencyId]					INT												NULL
	,[ysnRecomputeTax]					BIT												NULL
	,[intEntityId]						INT												NULL
	,[intId]							INT												NULL
	,[strTransactionType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]						INT												NULL
	,[strSourceId]						NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[ysnPost]							BIT												NULL
	,[intTempDetailIdForTaxes]			INT												NULL)

INSERT INTO #InvoiceInventoryItem
	([intInvoiceId]
	,[intInvoiceDetailId]
	,[strDocumentNumber]
	,[intItemId]
	,[intPrepayTypeId]
	,[dblPrepayRate]
	,[strItemDescription]
	,[dblQtyOrdered]
	,[intOrderUOMId]
	,[dblQtyShipped]
	,[intItemUOMId]
	,[intPriceUOMId]
	,[dblUnitQuantity]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblItemTermDiscountAmount]
	,[dblBaseItemTermDiscountAmount]
	,[dblItemTermDiscountExemption]
	,[dblBaseItemTermDiscountExemption]
	,[dblTermDiscountRate]
	,[ysnTermDiscountExempt]
	,[dblPrice]
	,[dblBasePrice]
	,[dblUnitPrice]
	,[dblBaseUnitPrice]
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
	,[ysnRecomputeTax]
	,[intEntityId]
	,[intId]
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[ysnPost]
	,[intTempDetailIdForTaxes])
SELECT
	 [intInvoiceId]							= IE.[intInvoiceId]
	,[intInvoiceDetailId]					= NULL
	,[strDocumentNumber]					= ISNULL(IE.[strDocumentNumber], IE.[strSourceId])
	,[intItemId]							= IC.[intItemId]
	,[intPrepayTypeId]						= IE.[intPrepayTypeId]
	,[dblPrepayRate]						= IE.[dblPrepayRate]
	,[strItemDescription]					= ISNULL(ISNULL(IE.[strItemDescription], IC.[strDescription]), '')
	,[dblQtyOrdered]						= ISNULL(IE.[dblQtyOrdered], @ZeroDecimal)
	,[intOrderUOMId]						= IE.[intOrderUOMId]
	,[dblQtyShipped]						= ISNULL(IE.[dblQtyShipped], @ZeroDecimal)
	,[intItemUOMId]							= ISNULL(IP.[intContractUOMId], ISNULL(ISNULL(IE.[intItemUOMId], IL.[intIssueUOMId]), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM ICUOM WITH (NOLOCK) WHERE ICUOM.[intItemId] = IC.[intItemId] ORDER BY ICUOM.[ysnStockUnit] DESC, [intItemUOMId])))
	,[intPriceUOMId]						= ISNULL(IP.[intPriceUOMId], ISNULL(IP.[intContractUOMId], ISNULL(ISNULL(IE.[intItemUOMId], IL.[intIssueUOMId]), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM ICUOM WITH (NOLOCK) WHERE ICUOM.[intItemId] = IC.[intItemId] ORDER BY ICUOM.[ysnStockUnit] DESC, [intItemUOMId]))))
	,[dblUnitQuantity]						= ISNULL(IP.[dblPriceUOMQuantity], ISNULL(IE.[dblContractPriceUOMQty], 1.000000))
	,[dblItemWeight]						= IE.[dblItemWeight]
	,[intItemWeightUOMId]					= IE.[intItemWeightUOMId]
	,[dblDiscount]							= ISNULL(IE.[dblDiscount], @ZeroDecimal)
	,[dblItemTermDiscount]					= ISNULL(ISNULL(IP.[dblTermDiscount], IE.[dblItemTermDiscount]), @ZeroDecimal)
	,[strItemTermDiscountBy]				= ISNULL(IP.[strTermDiscountBy], IE.[strItemTermDiscountBy])
	,[dblItemTermDiscountAmount]			= [dbo].[fnARGetItemTermDiscount](	ISNULL(IP.[strTermDiscountBy], IE.[strItemTermDiscountBy])
																				,ISNULL(IP.[dblTermDiscount], IE.[dblItemTermDiscount])
																				,IE.[dblQtyShipped]
																				,(CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
																				,1.000000)
	,[dblBaseItemTermDiscountAmount]		 = [dbo].[fnARGetItemTermDiscount](	ISNULL(IP.[strTermDiscountBy], IE.[strItemTermDiscountBy])
																				,ISNULL(IP.[dblTermDiscount], IE.[dblItemTermDiscount])
																				,IE.[dblQtyShipped]
																				,(CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
																				,(CASE WHEN ISNULL(IP.[dblCurrencyExchangeRate], 0.000000) <> @ZeroDecimal THEN IP.[dblCurrencyExchangeRate] ELSE (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END) END))
	,[dblItemTermDiscountExemption]			= [dbo].[fnARGetItemTermDiscountExemption](	IP.[ysnTermDiscountExempt]
																						,IP.[dblTermDiscountRate]
																						,IE.[dblQtyShipped]
																						,(CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
																						,1.000000)
	,[dblBaseItemTermDiscountExemption]		= [dbo].[fnARGetItemTermDiscountExemption](	IP.[ysnTermDiscountExempt]
																						,IP.[dblTermDiscountRate]
																						,IE.[dblQtyShipped]
																						,(CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
																						,(CASE WHEN ISNULL(IP.[dblCurrencyExchangeRate], 0.000000) <> @ZeroDecimal THEN IP.[dblCurrencyExchangeRate] ELSE (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END) END))
	,[dblTermDiscountRate]					= ISNULL(IP.[dblTermDiscountRate], @ZeroDecimal)
	,[ysnTermDiscountExempt]				= ISNULL(IP.[ysnTermDiscountExempt], 0)
	,[dblPrice]								= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END)
	,[dblBasePrice]							= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblPrice], IE.[dblPrice]), @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
	,[dblUnitPrice]							= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblUnitPrice], IE.[dblUnitPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblUnitPrice], IE.[dblUnitPrice]), @ZeroDecimal) END)
	,[dblBaseUnitPrice]						= (CASE WHEN (ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]),0) <> 0) THEN ISNULL(ISNULL(IP.[dblUnitPrice], IE.[dblUnitPrice]), @ZeroDecimal) * ISNULL(ISNULL(IP.[dblSubCurrencyRate], IE.[dblSubCurrencyRate]), 1) ELSE ISNULL(ISNULL(IP.[dblUnitPrice], IE.[dblUnitPrice]), @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
	,[strPricing]							= ISNULL(IP.[strPricing], CASE WHEN ISNULL(IE.[strPricing],'') = '' THEN 'Subsystem - ' COLLATE Latin1_General_CI_AS + IE.[strSourceTransaction] COLLATE Latin1_General_CI_AS ELSE IE.[strPricing] COLLATE Latin1_General_CI_AS END)
	,[dblTotalTax]							= @ZeroDecimal
	,[dblBaseTotalTax]						= @ZeroDecimal
	,[dblTotal]								= @ZeroDecimal
	,[dblBaseTotal]							= @ZeroDecimal
	,[intCurrencyExchangeRateTypeId]		= ISNULL(IP.[intCurrencyExchangeRateTypeId], IE.[intCurrencyExchangeRateTypeId])
	,[intCurrencyExchangeRateId]			= IE.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]				= CASE WHEN ISNULL(IP.[dblCurrencyExchangeRate], 0.000000) <> @ZeroDecimal THEN IP.[dblCurrencyExchangeRate] ELSE (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END) END
	,[intSubCurrencyId]						= ISNULL(ISNULL(IP.[intSubCurrencyId], IE.[intSubCurrencyId]), IE.[intCurrencyId])
	,[dblSubCurrencyRate]					= CASE WHEN ISNULL(IP.[dblSubCurrencyRate], 0.000000) <> @ZeroDecimal THEN IP.[dblSubCurrencyRate] ELSE (CASE WHEN ISNULL(IE.[dblSubCurrencyRate], 0) = 0 THEN 1.000000 ELSE ISNULL(IE.[dblSubCurrencyRate], 1.000000) END) END
	,[ysnRestricted]						= ISNULL(IE.[ysnRestricted], 0)
	,[ysnBlended]							= ISNULL(IE.[ysnBlended], 0)
	,[intAccountId]							= NULL --Acct.[intAccountId]
	,[intCOGSAccountId]						= NULL --Acct.[intCOGSAccountId]
	,[intSalesAccountId]					= IE.[intSalesAccountId] --ISNULL(IE.[intSalesAccountId], Acct.[intSalesAccountId])
	,[intInventoryAccountId]				= NULL --Acct.[intInventoryAccountId]
	,[intServiceChargeAccountId]			= NULL --Acct.[intAccountId]
	,[intLicenseAccountId]					= NULL --Acct.[intGeneralAccountId]
	,[intMaintenanceAccountId]				= NULL --Acct.[intMaintenanceSalesAccountId]
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
	,[ysnLeaseBilling]						= ISNULL(IE.[ysnLeaseBilling], 0)
	,[ysnVirtualMeterReading]				= ISNULL(IE.[ysnVirtualMeterReading], 0)
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
		,[dblUnitPrice]
		,[dblTermDiscount]
		,[strTermDiscountBy]
		,[ysnTermDiscountExempt]
		,[dblTermDiscountRate]
		,[strPricing]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[dblDeviation]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intContractSeq]
		,[dblAvailableQty]
		,[intCurrencyExchangeRateTypeId]
		,[dblCurrencyExchangeRate]
		,[intContractUOMId]
		,[intPriceUOMId]
		,[dblPriceUOMQuantity]
	FROM
		#Pricing WITH (NOLOCK)
	) IP
		ON IE.[intInvoiceId] = IP.[intInvoiceId]
		AND (IE.[intId] = IP.[intId]
			OR
			IE.[intInvoiceDetailId] = IP.[intInvoiceDetailId])
--No need for this; accounts are being updated during posting (uspARUpdateTransactionAccounts)
--And this has been causing performance issue
--LEFT OUTER JOIN
--	(
--	SELECT
--		 [intAccountId] 
--		,[intCOGSAccountId] 
--		,[intSalesAccountId]
--		,[intInventoryAccountId]	
--		,[intGeneralAccountId]
--		,[intMaintenanceSalesAccountId]		
--		,[intItemId]
--		,[intLocationId]			
--	FROM vyuARGetItemAccount WITH (NOLOCK)
--	) Acct
--		ON IC.[intItemId] = Acct.[intItemId]
--		AND IL.[intLocationId] = Acct.[intLocationId]		

BEGIN TRY
MERGE INTO tblARInvoiceDetail AS Target
USING 
	(
	SELECT
		 [intInvoiceId]
		,[intInvoiceDetailId]
		,[strDocumentNumber]
		,[intItemId]
		,[intPrepayTypeId]
		,[dblPrepayRate]
		,[strItemDescription]
		,[dblQtyOrdered]
		,[intOrderUOMId]
		,[dblQtyShipped]
		,[intItemUOMId]
		,[intPriceUOMId]
		,[dblUnitQuantity]
		,[dblItemWeight]
		,[intItemWeightUOMId]
		,[dblDiscount]
		,[dblItemTermDiscount]
		,[strItemTermDiscountBy]
		,[dblItemTermDiscountAmount]
		,[dblBaseItemTermDiscountAmount]
		,[dblItemTermDiscountExemption]
		,[dblBaseItemTermDiscountExemption]
		,[dblTermDiscountRate]
		,[ysnTermDiscountExempt]
		,[dblPrice]
		,[dblBasePrice]
		,[dblUnitPrice]
		,[dblBaseUnitPrice]
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
		,[ysnRecomputeTax]
		,[intEntityId]
		,[intId]
		,[strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[ysnPost]
		,[intTempDetailIdForTaxes]
	FROM
		#InvoiceInventoryItem
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
	,[intPriceUOMId]
	,[dblUnitQuantity]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblItemTermDiscountAmount]
	,[dblBaseItemTermDiscountAmount]
	,[dblItemTermDiscountExemption]
	,[dblBaseItemTermDiscountExemption]
	,[dblTermDiscountRate]
	,[ysnTermDiscountExempt]
	,[dblPrice]
	,[dblBasePrice]
	,[dblUnitPrice]
	,[dblBaseUnitPrice]
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
	,[intPriceUOMId]
	,[dblUnitQuantity]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblItemTermDiscountAmount]
	,[dblBaseItemTermDiscountAmount]
	,[dblItemTermDiscountExemption]
	,[dblBaseItemTermDiscountExemption]
	,[dblTermDiscountRate]
	,[ysnTermDiscountExempt]
	,[dblPrice]
	,[dblBasePrice]
	,[dblUnitPrice]
	,[dblBaseUnitPrice]
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
	OUTPUT  
		@IntegrationLogId						--[intIntegrationLogId]
		,INSERTED.[intInvoiceId]				--[intInvoiceId]
		,INSERTED.[intInvoiceDetailId]			--[intInvoiceDetailId]
		,Source.[intTempDetailIdForTaxes]		--[intTempDetailIdForTaxes]	
		,Source.[intId]							--[intId]
		,'Line Item was successfully added.'	--[strErrorMessage]
		,Source.[strTransactionType]			--[strTransactionType]
		,Source.[strType]						--[strType]
		,Source.[strSourceTransaction]			--[strSourceTransaction]
		,Source.[intSourceId]					--[intSourceId]
		,Source.[strSourceId]					--[strSourceId]
		,Source.[ysnPost]						--[ysnPost]
		,NULL									--[ysnRecap]
		,1										--[ysnInsert]
		,0										--[ysnHeader]
		,1										--[ysnSuccess]
		,NULL									--[ysnPosted]
		,NULL									--[ysnUnPosted]
		,NULL									--[strBatchId]
		,Source.[ysnRecomputeTax]				--[ysnRecomputeTax]
	INTO @IntegrationLog(
		[intIntegrationLogId]
        ,[intInvoiceId]
        ,[intInvoiceDetailId]
        ,[intTemporaryDetailIdForTax]
        ,[intId]
        ,[strMessage]
        ,[strTransactionType]
        ,[strType]
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
        ,[strBatchId]
		,[ysnRecomputeTax]          
	);					

	IF ISNULL(@IntegrationLogId, 0) <> 0
		EXEC [uspARInsertInvoiceIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog
			
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