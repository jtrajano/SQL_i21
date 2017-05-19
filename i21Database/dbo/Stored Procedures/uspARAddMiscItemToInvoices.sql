CREATE PROCEDURE [dbo].[uspARAddMiscItemToInvoices]
	 @InvoiceEntries	InvoiceStagingTable	READONLY
	,@IntegrationLogId	INT
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
AS

BEGIN


--SET QUOTED_IDENTIFIER OFF
--SET ANSI_NULLS ON
--SET NOCOUNT ON
--SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

--DECLARE @ZeroDecimal				NUMERIC(18, 6)
--		,@EntityCustomerId			INT
--		,@CompanyLocationId			INT
--		,@InvoiceDate				DATETIME
--		,@ServiceChargesAccountId	INT
--		,@CurrencyId				INT
		
--SET @ZeroDecimal = 0.000000

--IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @InvoiceId)
--	BEGIN		
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR('Invoice does not exists!', 16, 1);
--		RETURN 0;
--	END

--SELECT 
--	 @EntityCustomerId	= [intEntityCustomerId]
--	,@CompanyLocationId = [intCompanyLocationId]
--	,@InvoiceDate		= [dtmDate]
--	,@CurrencyId		= [intCurrencyId]
--FROM
--	tblARInvoice
--WHERE
--	intInvoiceId = @InvoiceId		
	
--IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
--	BEGIN		
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR('The company location from the target Invoice does not exists!', 16, 1);
--		SET @ErrorMessage = 'The company location from the target Invoice does not exists!'	
--		RETURN 0;
--	END	

--IF ISNULL(@ItemConversionAccountId,0) <> 0 AND NOT EXISTS(SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'General' AND [strAccountType] = 'Asset' AND [intAccountId] = @ItemConversionAccountId)
--	BEGIN
--		SET @ErrorMessage = 'Invalid Conversion Account Id! Must be of type ''Asset'' and of category ''General'''
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR(@ErrorMessage, 16, 1);
--		RETURN 0;
--	END
		
	
--SET @ServiceChargesAccountId = (SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)	
----IF ISNULL(@ServiceChargesAccountId,0) = 0
----	BEGIN
----		SET @ErrorMessage = 'The Service Charge account in the Company Preferences was not set.'
----		RETURN 0;
----	END	
		
--IF ISNULL(@RaiseError,0) = 0	
--	BEGIN TRANSACTION		

--BEGIN TRY
--	INSERT INTO [tblARInvoiceDetail]
--		([intInvoiceId]
--		,[intItemId]
--		,[intPrepayTypeId]
--		,[dblPrepayRate]
--		,[strItemDescription]
--		,[strDocumentNumber]
--		,[intItemUOMId]
--		,[dblQtyOrdered]
--		,[dblQtyShipped]
--		,[dblDiscount]
--		,[dblPrice]
--		,[dblTotalTax]
--		,[dblTotal]
--		,[intCurrencyExchangeRateTypeId]
--		,[intCurrencyExchangeRateId]
--		,[dblCurrencyExchangeRate]
--		,[intSubCurrencyId]
--		,[dblSubCurrencyRate]
--		,[intAccountId]
--		,[intCOGSAccountId]
--		,[intInventoryAccountId]
--		,[intServiceChargeAccountId]
--		,[strMaintenanceType]
--		,[strFrequency]
--		,[dtmMaintenanceDate]
--		,[dblMaintenanceAmount]
--		,[dblLicenseAmount]
--		,[intTaxGroupId]
--		,[intSCInvoiceId]
--		,[strSCInvoiceNumber]
--		,[intInventoryShipmentItemId]
--		,[strShipmentNumber]
--		,[intSalesOrderDetailId]
--		,[strSalesOrderNumber]
--		,[intContractHeaderId]
--		,[intContractDetailId]
--		,[intShipmentId]
--		,[intShipmentPurchaseSalesContractId]
--		,[intTicketId]
--		,[intTicketHoursWorkedId]
--		,[intSiteId]
--		,[strBillingBy]
--		,[dblPercentFull]
--		,[dblNewMeterReading]
--		,[dblPreviousMeterReading]
--		,[dblConversionFactor]
--		,[intPerformerId]
--		,[ysnLeaseBilling]
--		,[ysnVirtualMeterReading]
--		,[intEntitySalespersonId]
--		,[intRecipeItemId]
--		,[intRecipeId]
--		,[intSubLocationId]
--		,[intCostTypeId]
--		,[intMarginById]
--		,[intCommentTypeId]
--		,[dblMargin]
--		,[dblRecipeQuantity]
--		,[intConversionAccountId]
--		,[intSalesAccountId]
--		,[intConcurrencyId]
--		,[intStorageScheduleTypeId]
--		,[intDestinationGradeId]
--		,[intDestinationWeightId]
--		,[dblItemTermDiscount]
--		,[strItemTermDiscountBy])
--	SELECT
--		 [intInvoiceId]						= @InvoiceId
--		,[intItemId]						= @ItemId
--		,[intPrepayTypeId]					= @ItemPrepayTypeId 
--		,[dblPrepayRate]					= @ItemPrepayRate 
--		,[strItemDescription]				= ISNULL(@ItemDescription, '')
--		,[strDocumentNumber]				= @ItemDocumentNumber
--		,[intItemUOMId]						= NULL
--		,[dblQtyOrdered]					= ISNULL(@ItemQtyOrdered, @ZeroDecimal)
--		,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
--		,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
--		,[dblPrice]							= ISNULL(@ItemPrice, @ZeroDecimal)			
--		,[dblTotalTax]						= @ZeroDecimal
--		,[dblTotal]							= @ZeroDecimal
--		,[intCurrencyExchangeRateTypeId]	= @ItemCurrencyExchangeRateTypeId
--		,[intCurrencyExchangeRateId]		= @ItemCurrencyExchangeRateId
--		,[dblCurrencyExchangeRate]			= CASE WHEN ISNULL(@ItemCurrencyExchangeRate, 0) = 0 THEN 1 ELSE ISNULL(@ItemCurrencyExchangeRate, 1) END
--		,[intSubCurrencyId]					= ISNULL(@ItemSubCurrencyId, @CurrencyId)
--		,[dblSubCurrencyRate]				= CASE WHEN ISNULL(@ItemSubCurrencyId, 0) = 0 THEN 1 ELSE ISNULL(@ItemSubCurrencyRate, 1) END
--		,[intAccountId]						= NULL 
--		,[intCOGSAccountId]					= NULL
--		,[intInventoryAccountId]			= NULL
--		,[intServiceChargeAccountId]		= NULL
--		,[strMaintenanceType]				= NULL
--		,[strFrequency]						= NULL
--		,[dtmMaintenanceDate]				= NULL
--		,[dblMaintenanceAmount]				= NULL
--		,[dblLicenseAmount]					= NULL
--		,[intTaxGroupId]					= @ItemTaxGroupId
--		,[intSCInvoiceId]					= NULL
--		,[strSCInvoiceNumber]				= NULL 
--		,[intInventoryShipmentItemId]		= NULL 
--		,[strShipmentNumber]				= NULL 
--		,[intSalesOrderDetailId]			= @ItemSalesOrderDetailId 
--		,[strSalesOrderNumber]				= NULL 
--		,[intContractHeaderId]				= NULL
--		,[intContractDetailId]				= NULL
--		,[intShipmentId]					= NULL
--		,[intShipmentPurchaseSalesContractId] =	NULL 
--		,[intTicketId]						= NULL
--		,[intTicketHoursWorkedId]			= NULL 
--		,[intSiteId]						= NULL
--		,[strBillingBy]						= NULL
--		,[dblPercentFull]					= NULL
--		,[dblNewMeterReading]				= NULL
--		,[dblPreviousMeterReading]			= NULL
--		,[dblConversionFactor]				= NULL
--		,[intPerformerId]					= NULL
--		,[ysnLeaseBilling]					= NULL
--		,[ysnVirtualMeterReading]			= NULL
--		,[intEntitySalespersonId]			= @EntitySalespersonId
--		,[intRecipeItemId]					= @ItemRecipeItemId
--		,[intRecipeId]						= @ItemRecipeId
--		,[intSubLocationId]					= @ItemSublocationId
--		,[intCostTypeId]					= @ItemCostTypeId
--		,[intMarginById]					= @ItemMarginById
--		,[intCommentTypeId]					= @ItemCommentTypeId
--		,[dblMargin]						= @ItemMargin
--		,[dblRecipeQuantity]				= @ItemRecipeQty
--		,[intConversionAccountId]			= @ItemConversionAccountId
--		,[intSalesAccountId]				= @ItemSalesAccountId
--		,[intConcurrencyId]					= 0
--		,[intStorageScheduleTypeId]			= @ItemStorageScheduleTypeId
--		,[intDestinationGradeId]			= @ItemDestinationGradeId
--		,[intDestinationWeightId]			= @ItemDestinationWeightId
--		,[dblItemTermDiscount]				= @ItemTermDiscount
--		,[strItemTermDiscountBy]			= @ItemTermDiscountBy
			
--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0	
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH
	
--DECLARE @NewId INT
--SET @NewId = SCOPE_IDENTITY()
		
--BEGIN TRY
--IF @RecomputeTax = 1
--	EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId, @DetailId = @NewId
--ELSE
--	EXEC dbo.[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId

--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0	
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

--SET @NewInvoiceDetailId = @NewId

--IF ISNULL(@RaiseError,0) = 0	
--	COMMIT TRANSACTION
--SET @ErrorMessage = NULL;
--RETURN 1;
	

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
	,[strErrorMessage]		= 'Invalid Conversion Account Id! Must be of type ''Asset'' and of category ''General''.'
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
		,[strDocumentNumber]					= IE.[strDocumentNumber]
		,[intItemId]							= CASE WHEN (ISNULL(IE.[intCommentTypeId], 0) <> 0) THEN IE.[intItemId] ELSE NULL END 
		,[intPrepayTypeId]						= IE.[intPrepayTypeId]
		,[dblPrepayRate]						= IE.[dblPrepayRate]
		,[strItemDescription]					= ISNULL(IE.[strItemDescription], '')
		,[dblQtyOrdered]						= ISNULL(IE.[dblQtyOrdered], @ZeroDecimal)
		,[intOrderUOMId]						= IE.[intOrderUOMId]
		,[dblQtyShipped]						= ISNULL(IE.[dblQtyShipped], @ZeroDecimal)
		,[intItemUOMId]							= IE.[intItemUOMId]
		,[dblItemWeight]						= IE.[dblItemWeight]
		,[intItemWeightUOMId]					= IE.[intItemWeightUOMId]
		,[dblDiscount]							= ISNULL(IE.[dblDiscount], @ZeroDecimal)
		,[dblItemTermDiscount]					= ISNULL(IE.[dblItemTermDiscount], @ZeroDecimal)
		,[strItemTermDiscountBy]				= IE.[strItemTermDiscountBy]
		,[dblPrice]								= (CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],0) <> 0) THEN ISNULL(IE.[dblPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1) ELSE ISNULL(IE.[dblPrice], @ZeroDecimal) END)
		,[dblBasePrice]							= (CASE WHEN (ISNULL(IE.[dblSubCurrencyRate],0) <> 0) THEN ISNULL(IE.[dblPrice], @ZeroDecimal) * ISNULL(IE.[dblSubCurrencyRate], 1) ELSE ISNULL(IE.[dblPrice], @ZeroDecimal) END) * (CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END)
		,[strPricing]							= IE.[strPricing]
		,[dblTotalTax]							= @ZeroDecimal
		,[dblBaseTotalTax]						= @ZeroDecimal
		,[dblTotal]								= @ZeroDecimal
		,[dblBaseTotal]							= @ZeroDecimal
		,[intCurrencyExchangeRateTypeId]		= IE.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]			= IE.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]				= CASE WHEN ISNULL(IE.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblCurrencyExchangeRate], 1) END
		,[intSubCurrencyId]						= ISNULL(IE.[intSubCurrencyId], IE.[intCurrencyId])
		,[dblSubCurrencyRate]					= CASE WHEN ISNULL(IE.[intSubCurrencyId], 0) = 0 THEN 1 ELSE ISNULL(IE.[dblSubCurrencyRate], 1) END
		,[ysnRestricted]						= IE.[ysnRestricted]
		,[ysnBlended]							= IE.[ysnBlended]
		,[intAccountId]							= IE.[intAccountId]
		,[intCOGSAccountId]						= NULL
		,[intSalesAccountId]					= IE.[intSalesAccountId]
		,[intInventoryAccountId]				= NULL
		,[intServiceChargeAccountId]			= IE.[intAccountId]
		,[intLicenseAccountId]					= NULL
		,[intMaintenanceAccountId]				= NULL
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
)
	OUTPUT  
			@IntegrationLogId						--[intIntegrationLogId]
			,@DateOnly								--[dtmDate]
			,Source.[intEntityId]					--[intEntityId]
			,0										--[intGroupingOption]
			,'Line Item was successfully added.'	--[strErrorMessage]
			,''										--[strBatchIdForNewPost]
			,0										--[intPostedNewCount]
			,''										--[strBatchIdForNewPostRecap]
			,0										--[intRecapNewCount]
			,''										--[strBatchIdForExistingPost]
			,0										--[intPostedExistingCount]
			,''										--[strBatchIdForExistingRecap]
			,0										--[intRecapPostExistingCount]
			,''										--[strBatchIdForExistingUnPost]
			,0										--[intUnPostedExistingCount]
			,''										--[strBatchIdForExistingUnPostRecap]
			,0										--[intRecapUnPostedExistingCount]
			,NULL									--[intIntegrationLogDetailId]
			,INSERTED.[intInvoiceId]				--[intInvoiceId]
			,INSERTED.[intInvoiceDetailId]			--[intInvoiceDetailId]
			,Source.[intId]							--[intId]
			,Source.[strTransactionType]			--[strTransactionType]
			,Source.[strType]						--[strType]
			,Source.[strSourceTransaction]			--[strSourceTransaction]
			,Source.[intSourceId]					--[intSourceId]
			,Source.[strSourceId]					--[strSourceId]
			,Source.[ysnPost]						--[ysnPost]
			,0										--[ysnUpdateAvailableDiscount]
			,Source.[ysnRecomputeTax]				--[ysnRecomputeTax]
			,1										--[ysnInsert]
			,0										--[ysnHeader]
			,1										--[ysnSuccess]
		INTO @IntegrationLog(
			 [intIntegrationLogId]
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
			,[intId]
			,[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[ysnPost]
			,[ysnUpdateAvailableDiscount]
			,[ysnRecomputeTax]
			,[ysnInsert]
			,[ysnHeader]
			,[ysnSuccess]
		);					

	IF ISNULL(@IntegrationLogId, 0) <> 0 AND ISNULL(@RaiseError,0) = 0
		EXEC [uspARInsertInvoiceIntegrationLog] @IntegrationLogEntries = @IntegrationLog
			
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