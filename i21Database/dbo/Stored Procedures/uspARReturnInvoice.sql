CREATE PROCEDURE [dbo].[uspARReturnInvoice]
	 @intInvoiceId			INT	
	,@intUserId				INT	
	,@strInvoiceDetailIds	NVARCHAR(500)	= NULL
	,@ysnRaiseError			BIT				= 0
	,@intNewInvoiceId		INT				= NULL	OUTPUT
	,@strErrorMessage		NVARCHAR(250)	= NULL	OUTPUT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON

BEGIN TRANSACTION

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
DECLARE @InvoiceDetails AS TABLE (intInvoiceId INT, intInvoiceDetailId INT)
DECLARE @dblZeroDecimal NUMERIC(18, 6) = 0
	  , @dtmDateOnly	DATETIME = CAST(GETDATE() AS DATE)

IF ISNULL(@strInvoiceDetailIds, '') = ''
	BEGIN
		INSERT INTO @InvoiceDetails
		SELECT intInvoiceId
			 , intInvoiceDetailId 
		FROM tblARInvoiceDetail 
		WHERE intInvoiceId = @intInvoiceId
	END
ELSE
	BEGIN
		INSERT INTO @InvoiceDetails
		SELECT intInvoiceId
			 , intInvoiceDetailId 
		FROM tblARInvoiceDetail ID
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strInvoiceDetailIds) DV ON ID.intInvoiceDetailId = DV.intID
		WHERE intInvoiceId = @intInvoiceId
	END

BEGIN TRY
	INSERT INTO @EntriesForInvoice(
		 [strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[intInvoiceId]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intAccountId]
		,[intCurrencyId]
		,[intTermId]
		,[intPeriodsToAccrue]
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[dtmPostDate]
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[ysnUseOriginIdAsInvoiceNumber]
		,[strPONumber]
		,[strBOLNumber]
		,[strComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[ysnImpactInventory]
		,[intPaymentId]
		,[intSplitId]
		,[intLoadDistributionHeaderId]
		,[strActualCostId]
		,[intShipmentId]
		,[intTransactionId]
		,[intMeterReadingId]
		,[intContractHeaderId]
		,[intLoadId]
		,[intOriginalInvoiceId]
		,[intEntityId]
		,[intTruckDriverId]
		,[intTruckDriverReferenceId]
		,[ysnResetDetails]
		,[ysnRecap]
		,[ysnPost]
		,[ysnUpdateAvailableDiscount]
		--Detail																																															
		,[intInvoiceDetailId]
		,[intItemId]
		,[intPrepayTypeId]
		,[dblPrepayRate]
		,[ysnInventory]
		,[strDocumentNumber]
		,[strItemDescription]
		,[intOrderUOMId]
		,[dblQtyOrdered]
		,[intItemUOMId]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblItemTermDiscount]
		,[strItemTermDiscountBy]
		,[dblItemWeight]
		,[intItemWeightUOMId]
		,[dblPrice]
		,[dblUnitPrice]
		,[strPricing]
		,[strVFDDocumentNumber]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[intStorageLocationId]
		,[intCompanyLocationSubLocationId]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intSCBudgetId]
		,[strSCBudgetDescription]
		,[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]
		,[strShipmentNumber]
		,[intRecipeItemId]
		,[intRecipeId]
		,[intSubLocationId]
		,[intCostTypeId]
		,[intMarginById]
		,[intCommentTypeId]
		,[dblMargin]
		,[dblRecipeQuantity]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractDetailId]
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
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblNewMeterReading]
		,[dblPreviousMeterReading]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[ysnClearDetailTaxes]
		,[intTempDetailIdForTaxes]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[ysnBlended]
		,[strImportFormat]
		,[dblCOGSAmount]
		,[intConversionAccountId]
		,[intSalesAccountId]
		,[intStorageScheduleTypeId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]
	)
	SELECT
		 [strTransactionType]					= 'Credit Memo'
		,[strType]								= ARI.[strType]
		,[strSourceTransaction]					= 'Direct'
		,[intSourceId]							= NULL 
		,[strSourceId]							= ARI.[strInvoiceNumber]
		,[intInvoiceId]							= NULL
		,[intEntityCustomerId]					= ARI.[intEntityCustomerId]
		,[intCompanyLocationId]					= ARI.[intCompanyLocationId]
		,[intAccountId]							= ARI.[intAccountId]
		,[intCurrencyId]						= ARI.[intCurrencyId]
		,[intTermId]							= ARI.[intTermId]
		,[intPeriodsToAccrue]					= ARI.[intPeriodsToAccrue]
		,[dtmDate]								= @dtmDateOnly
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= @dtmDateOnly
		,[dtmPostDate]							= @dtmDateOnly
		,[intEntitySalespersonId]				= ARI.[intEntitySalespersonId]
		,[intFreightTermId]						= ARI.[intFreightTermId]
		,[intShipViaId]							= ARI.[intShipViaId]
		,[intPaymentMethodId]					= ARI.[intPaymentMethodId]
		,[strInvoiceOriginId]					= ARI.[strInvoiceNumber]
		,[ysnUseOriginIdAsInvoiceNumber]		= 0
		,[strPONumber]							= ARI.[strPONumber]
		,[strBOLNumber]							= ARI.[strBOLNumber]
		,[strComments]							= ARI.[strComments]
		,[intShipToLocationId]					= ARI.[intShipToLocationId]
		,[intBillToLocationId]					= ARI.[intBillToLocationId]
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= ARI.[ysnForgiven]
		,[ysnCalculated]						= ARI.[ysnCalculated]
		,[ysnSplitted]							= ARI.[ysnSplitted]
		,[ysnImpactInventory]					= CAST(1 AS BIT)
		,[intPaymentId]							= ARI.[intPaymentId]
		,[intSplitId]							= ARI.[intSplitId]
		,[intLoadDistributionHeaderId]			= ARI.[intLoadDistributionHeaderId]
		,[strActualCostId]						= ARI.[strActualCostId]
		,[intShipmentId]						= ARI.[intShipmentId]
		,[intTransactionId]						= ARI.[intTransactionId]
		,[intMeterReadingId]					= ARI.[intMeterReadingId]
		,[intContractHeaderId]					= ARI.[intContractHeaderId]
		,[intLoadId]							= ARI.[intLoadId]
		,[intOriginalInvoiceId]					= ARI.[intInvoiceId]
		,[intEntityId]							= @intUserId
		,[intTruckDriverId]						= ARI.[intTruckDriverId]
		,[intTruckDriverReferenceId]			= ARI.[intTruckDriverReferenceId]
		,[ysnResetDetails]						= 0
		,[ysnRecap]								= NULL
		,[ysnPost]								= NULL
		,[ysnUpdateAvailableDiscount]			= 0
		--Detail																																															
		,[intInvoiceDetailId]					= NULL
		,[intItemId]							= ARID.[intItemId]
		,[intPrepayTypeId]						= ARID.[intPrepayTypeId]
		,[dblPrepayRate]						= ARID.[dblPrepayRate]
		,[ysnInventory]							= NULL
		,[strDocumentNumber]					= ARI.[strInvoiceNumber]
		,[strItemDescription]					= ARID.[strItemDescription]
		,[intOrderUOMId]						= ARID.[intOrderUOMId]
		,[dblQtyOrdered]						= ARID.[dblQtyOrdered]
		,[intItemUOMId]							= ARID.[intItemUOMId]
		,[dblQtyShipped]						= ARID.[dblQtyShipped]
		,[dblDiscount]							= ARID.[dblDiscount]
		,[dblItemTermDiscount]					= ARID.[dblItemTermDiscount]
		,[strItemTermDiscountBy]				= ARID.[strItemTermDiscountBy]
		,[dblItemWeight]						= ARID.[dblItemWeight]
		,[intItemWeightUOMId]					= ARID.[intItemWeightUOMId]
		,[dblPrice]								= ARID.[dblPrice]
		,[dblUnitPrice]							= ARID.[dblUnitPrice]
		,[strPricing]							= ARID.[strPricing]
		,[strVFDDocumentNumber]					= ARID.[strVFDDocumentNumber]
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= ARID.[strMaintenanceType]
		,[strFrequency]							= ARID.[strFrequency]
		,[dtmMaintenanceDate]					= ARID.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]					= ARID.[dblMaintenanceAmount]
		,[dblLicenseAmount]						= ARID.[dblLicenseAmount]
		,[intTaxGroupId]						= ARID.[intTaxGroupId]
		,[intStorageLocationId]					= ARID.[intStorageLocationId]
		,[intCompanyLocationSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
		,[ysnRecomputeTax]						= 0
		,[intSCInvoiceId]						= ARID.[intSCInvoiceId]
		,[strSCInvoiceNumber]					= ARID.[strSCInvoiceNumber]
		,[intSCBudgetId]						= ARID.[intSCBudgetId]
		,[strSCBudgetDescription]				= ARID.[strSCBudgetDescription]
		,[intInventoryShipmentItemId]			= ARID.[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]			= ARID.[intInventoryShipmentChargeId]
		,[strShipmentNumber]					= ARID.[strShipmentNumber]
		,[intRecipeItemId]						= ARID.[intRecipeItemId]
		,[intRecipeId]							= ARID.[intRecipeId]
		,[intSubLocationId]						= ARID.[intSubLocationId]
		,[intCostTypeId]						= ARID.[intCostTypeId]
		,[intMarginById]						= ARID.[intMarginById]
		,[intCommentTypeId]						= ARID.[intCommentTypeId]
		,[dblMargin]							= ARID.[dblMargin]
		,[dblRecipeQuantity]					= ARID.[dblRecipeQuantity]
		,[intSalesOrderDetailId]				= ARID.[intSalesOrderDetailId]
		,[strSalesOrderNumber]					= ARID.[strSalesOrderNumber]
		,[intContractDetailId]					= ARID.[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]	= ARID.[intShipmentPurchaseSalesContractId]
		,[dblShipmentGrossWt]					= ARID.[dblShipmentGrossWt]
		,[dblShipmentTareWt]					= ARID.[dblShipmentTareWt]
		,[dblShipmentNetWt]						= ARID.[dblShipmentNetWt]
		,[intTicketId]							= ARID.[intTicketId]
		,[intTicketHoursWorkedId]				= ARID.[intTicketHoursWorkedId]
		,[intCustomerStorageId]					= ARID.[intCustomerStorageId]
		,[intSiteDetailId]						= ARID.[intSiteDetailId]
		,[intLoadDetailId]						= ARID.[intLoadDetailId]
		,[intLotId]								= ARID.[intLotId]
		,[intOriginalInvoiceDetailId]			= ARID.[intInvoiceDetailId]
		,[intSiteId]							= ARID.[intSiteId]
		,[strBillingBy]							= ARID.[strBillingBy]
		,[dblPercentFull]						= ARID.[dblPercentFull]
		,[dblNewMeterReading]					= ARID.[dblNewMeterReading]
		,[dblPreviousMeterReading]				= ARID.[dblPreviousMeterReading]
		,[dblConversionFactor]					= ARID.[dblConversionFactor]
		,[intPerformerId]						= ARID.[intPerformerId]
		,[ysnLeaseBilling]						= ARID.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]				= ARID.[ysnVirtualMeterReading]
		,[ysnClearDetailTaxes]					= 0
		,[intTempDetailIdForTaxes]				= ARID.[intInvoiceDetailId]
		,[intCurrencyExchangeRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]			= ARID.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]				= ARID.[dblCurrencyExchangeRate]
		,[intSubCurrencyId]						= ARID.[intSubCurrencyId]
		,[dblSubCurrencyRate]					= ARID.[dblSubCurrencyRate]
		,[ysnBlended]							= ARID.[ysnBlended]
		,[strImportFormat]						= NULL
		,[dblCOGSAmount]						= @dblZeroDecimal
		,[intConversionAccountId]				= ARID.[intConversionAccountId]
		,[intSalesAccountId]					= ARID.[intSalesAccountId]
		,[intStorageScheduleTypeId]				= ARID.[intStorageScheduleTypeId]
		,[intDestinationGradeId]				= ARID.[intDestinationGradeId]
		,[intDestinationWeightId]				= ARID.[intDestinationWeightId]
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN @InvoiceDetails ID ON ARID.intInvoiceDetailId = ID.intInvoiceDetailId
	WHERE ARI.[intInvoiceId] = @intInvoiceId

DECLARE @LineItemTaxes AS LineItemTaxDetailStagingTable

INSERT INTO @LineItemTaxes(
	 [intDetailId]
	,[intDetailTaxId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblBaseRate]
	,[intTaxAccountId]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[ysnTaxExempt]
	,[ysnTaxOnly]
	,[ysnInvalidSetup]
	,[strNotes]
	,[intTempDetailIdForTaxes]
)
SELECT
	 [intDetailId]				= NULL
	,[intDetailTaxId]			= NULL
	,[intTaxGroupId]			= ARIDT.[intTaxGroupId]
	,[intTaxCodeId]				= ARIDT.[intTaxCodeId]
	,[intTaxClassId]			= ARIDT.[intTaxClassId]
	,[strTaxableByOtherTaxes]	= ARIDT.[strTaxableByOtherTaxes] 
	,[strCalculationMethod]		= ARIDT.[strCalculationMethod]
	,[dblRate]					= ARIDT.[dblRate]
	,[dblBaseRate]				= ISNULL(ARIDT.[dblBaseRate], ARIDT.[dblRate])
	,[intTaxAccountId]			= ARIDT.[intSalesTaxAccountId]
	,[dblTax]					= ARIDT.[dblTax]
	,[dblAdjustedTax]			= ARIDT.[dblAdjustedTax]
	,[ysnTaxAdjusted]			= ARIDT.[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]		= ARIDT.[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]			= ARIDT.[ysnCheckoffTax]
	,[ysnTaxExempt]				= ARIDT.[ysnTaxExempt]
	,[ysnTaxOnly]				= ARIDT.[ysnTaxOnly]
	,[ysnInvalidSetup]			= ARIDT.[ysnInvalidSetup]
	,[strNotes]					= ARIDT.[strNotes]
	,[intTempDetailIdForTaxes]	= EFI.[intTempDetailIdForTaxes]
FROM @EntriesForInvoice  EFI
INNER JOIN tblARInvoiceDetailTax ARIDT ON EFI.[intTempDetailIdForTaxes] = ARIDT.[intInvoiceDetailId] 
ORDER BY EFI.[intInvoiceDetailId] ASC, ARIDT.[intInvoiceDetailTaxId] ASC
	
DECLARE	@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)	
				
EXEC [dbo].[uspARProcessInvoices]
	 @InvoiceEntries		= @EntriesForInvoice
	,@LineItemTaxEntries	= @LineItemTaxes
	,@UserId				= @intUserId
	,@GroupingOption		= 1--11
	,@RaiseError			= @ysnRaiseError
	,@ErrorMessage			= @CurrentErrorMessage	OUTPUT
	,@CreatedIvoices		= @CreatedIvoices		OUTPUT
	,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT


IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
	BEGIN
		IF ISNULL(@ysnRaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @strErrorMessage = @CurrentErrorMessage;
		IF ISNULL(@ysnRaiseError,0) = 1
			RAISERROR(@strErrorMessage, 16, 1);
			ROLLBACK TRANSACTION
		RETURN 0;
	END

END TRY
BEGIN CATCH
	IF ISNULL(@ysnRaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @strErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@ysnRaiseError,0) = 1
		BEGIN
			RAISERROR(@strErrorMessage, 16, 1);
			ROLLBACK TRANSACTION
		END
	RETURN 0;
END CATCH
		
SELECT TOP 1 @intNewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))

IF ISNULL(@strInvoiceDetailIds, '') = ''
	BEGIN
		UPDATE ARI
		SET ysnReturned = 1 
		  , dblDiscountAvailable = @dblZeroDecimal
		  , dblBaseDiscountAvailable = @dblZeroDecimal
		FROM tblARInvoice ARI
		WHERE ARI.intInvoiceId = @intInvoiceId
	END

UPDATE ARID 
SET ysnReturned = 1 
FROM tblARInvoiceDetail ARID
INNER JOIN @InvoiceDetails ID ON ARID.intInvoiceDetailId = ID.intInvoiceDetailId
WHERE ARID.intInvoiceId = @intInvoiceId

IF (SELECT COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId) = (SELECT COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId AND ysnReturned = 1)
	BEGIN
		UPDATE ARI
		SET ysnReturned = 1 
		FROM tblARInvoice ARI
		WHERE ARI.intInvoiceId = @intInvoiceId
	END

COMMIT TRANSACTION 
RETURN 1;