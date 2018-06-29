CREATE PROCEDURE [dbo].[uspARAddMiscItemToInvoices]
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
SET @Savepoint = SUBSTRING(('ARAddMiscItemToInvoices' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

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

--UNION ALL

--SELECT
--	 [intId]				= IT.[intId]
--	,[strMessage]			= 'Invoice is already posted!'
--	,[strTransactionType]	= IT.[strTransactionType]
--	,[strType]				= IT.[strType]
--	,[strSourceTransaction]	= IT.[strSourceTransaction]
--	,[intSourceId]			= IT.[intSourceId]
--	,[strSourceId]			= IT.[strSourceId]
--	,[intInvoiceId]			= IT.[intInvoiceId]
--FROM
--	@ItemEntries IT
--WHERE
--	EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = IT.[intInvoiceId] AND ISNULL(ARI.[ysnPosted],0) = 1)

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
	,[strMessage]			= 'Invalid Conversion Account Id! Must be of type ''Asset'' and of category ''General''.'
	,[strTransactionType]	= IT.[strTransactionType]
	,[strType]				= IT.[strType]
	,[strSourceTransaction]	= IT.[strSourceTransaction]
	,[intSourceId]			= IT.[intSourceId]
	,[strSourceId]			= IT.[strSourceId]
	,[intInvoiceId]			= IT.[intInvoiceId]
FROM
	@ItemEntries IT
WHERE
	ISNULL(IT.[intConversionAccountId], 0) <> 0 
	AND NOT EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'General' AND GLAD.[strAccountType] = 'Asset' AND GLAD.[intAccountId] = IT.[intConversionAccountId])
		


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
	
BEGIN TRY
MERGE INTO tblARInvoiceDetail AS Target
USING 
	(
	SELECT
		 [intInvoiceId]							= IE.[intInvoiceId]
		,[intInvoiceDetailId]					= NULL
		,[strDocumentNumber]					= ISNULL(IE.[strDocumentNumber], IE.[strSourceId])
		,[intItemId]							= CASE WHEN (ISNULL(IE.[intCommentTypeId], 0) <> 0) THEN IE.[intItemId] ELSE NULL END 
		,[intPrepayTypeId]						= IE.[intPrepayTypeId]
		,[dblPrepayRate]						= IE.[dblPrepayRate]
		,[strItemDescription]					= ISNULL(IE.[strItemDescription], '')
		,[dblQtyOrdered]						= ISNULL(IE.[dblQtyOrdered], @ZeroDecimal)
		,[intOrderUOMId]						= IE.[intOrderUOMId]
		,[dblQtyShipped]						= ISNULL(IE.[dblQtyShipped], @ZeroDecimal)
		,[intItemUOMId]							= IE.[intItemUOMId]
		,[intPriceUOMId]						= ISNULL(IE.[intPriceUOMId], IE.[intItemUOMId])
		,[dblUnitQuantity]						= ISNULL(IE.[dblContractPriceUOMQty], 1.000000)
		,[dblItemWeight]						= IE.[dblItemWeight]
		,[intItemWeightUOMId]					= IE.[intItemWeightUOMId]
		,[dblDiscount]							= ISNULL(IE.[dblDiscount], @ZeroDecimal)				
		,[dblItemTermDiscount]					= ISNULL(IE.[dblItemTermDiscount], @ZeroDecimal)
		,[strItemTermDiscountBy]				= IE.[strItemTermDiscountBy]
		,[dblItemTermDiscountAmount]			= [dbo].[fnARGetItemTermDiscount](	IE.[strItemTermDiscountBy]
																					,IE.[dblItemTermDiscount]
																					,IE.[dblQtyShipped]
																					,(CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],@ZeroDecimal) <> 0) THEN ISNULL(IE.[dblPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1) ELSE ISNULL(IE.[dblPrice], @ZeroDecimal) END)
																					,1.000000)
		,[dblBaseItemTermDiscountAmount]		 = [dbo].[fnARGetItemTermDiscount](	IE.[strItemTermDiscountBy]
																					,IE.[dblItemTermDiscount]
																					,IE.[dblQtyShipped]
																					,(CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],0) <> 0) THEN ISNULL(IE.[dblPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1) ELSE ISNULL(IE.[dblPrice], @ZeroDecimal) END)
																					,(CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END))
		,[dblItemTermDiscountExemption]			= @ZeroDecimal
		,[dblBaseItemTermDiscountExemption]		= @ZeroDecimal
		,[dblTermDiscountRate]					= @ZeroDecimal
		,[ysnTermDiscountExempt]				= 0
		,[dblPrice]								= (CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],@ZeroDecimal) <> @ZeroDecimal) THEN ISNULL(IE.[dblPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1.000000) ELSE ISNULL(IE.[dblPrice], @ZeroDecimal) END)
		,[dblBasePrice]							= (CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],@ZeroDecimal) <> @ZeroDecimal) THEN ISNULL(IE.[dblPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1.000000) ELSE ISNULL(IE.[dblPrice], @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END)
		,[dblUnitPrice]							= (CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],@ZeroDecimal) <> @ZeroDecimal) THEN ISNULL(IE.[dblUnitPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1.000000) ELSE ISNULL(IE.[dblUnitPrice], @ZeroDecimal) END)
		,[dblBaseUnitPrice]						= (CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],@ZeroDecimal) <> @ZeroDecimal) THEN ISNULL(IE.[dblUnitPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1.000000) ELSE ISNULL(IE.[dblUnitPrice], @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END)
		,[strPricing]							= CASE WHEN ISNULL(IE.[strPricing],'') = '' AND RTRIM(LTRIM(ISNULL(IE.[strSourceTransaction],''))) <> '' THEN 'Subsystem - ' COLLATE Latin1_General_CI_AS + IE.[strSourceTransaction] COLLATE Latin1_General_CI_AS ELSE IE.[strPricing] COLLATE Latin1_General_CI_AS END
		,[dblTotalTax]							= @ZeroDecimal
		,[dblBaseTotalTax]						= @ZeroDecimal
		,[dblTotal]								= @ZeroDecimal
		,[dblBaseTotal]							= @ZeroDecimal
		,[intCurrencyExchangeRateTypeId]		= IE.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]			= IE.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]				= CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END
		,[intSubCurrencyId]						= ISNULL(IE.[intSubCurrencyId], IE.[intCurrencyId])
		,[dblSubCurrencyRate]					= CASE WHEN ISNULL(IE.[intSubCurrencyId], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblSubCurrencyRate], 1.000000) END
		,[ysnRestricted]						= ISNULL(IE.[ysnRestricted], 0)
		,[ysnBlended]							= ISNULL(IE.[ysnBlended], 0)
		,[intAccountId]							= NULL
		,[intCOGSAccountId]						= NULL
		,[intSalesAccountId]					= IE.[intSalesAccountId]
		,[intInventoryAccountId]				= NULL
		,[intServiceChargeAccountId]			= NULL
		,[intLicenseAccountId]					= NULL
		,[intMaintenanceAccountId]				= NULL
		,[strMaintenanceType]					= IE.[strMaintenanceType]
		,[strFrequency]							= IE.[strFrequency]
		,[dtmMaintenanceDate]					= IE.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]					= IE.[dblMaintenanceAmount]
		,[dblBaseMaintenanceAmount]				= IE.[dblMaintenanceAmount] * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END)
		,[dblLicenseAmount]						= IE.[dblLicenseAmount]
		,[dblBaseLicenseAmount]					= IE.[dblLicenseAmount] * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1.000000) END)
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
		,[intContractHeaderId]					= IE.[intContractHeaderId]
		,[intContractDetailId]					= IE.[intContractDetailId]
		,[dblContractBalance]					= @ZeroDecimal
		,[dblContractAvailable]					= @ZeroDecimal
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
			,Source.[ysnRecomputeTax]				--[[ysnRecomputeTax]]
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