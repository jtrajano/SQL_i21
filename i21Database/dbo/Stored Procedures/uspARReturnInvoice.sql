CREATE PROCEDURE [dbo].[uspARReturnInvoice]
	 @InvoiceId		INT
	,@UserId		INT	
	,@RaiseError	BIT				= 0
	,@NewInvoiceId	INT				= NULL	OUTPUT
	,@ErrorMessage	NVARCHAR(250)	= NULL	OUTPUT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME

SET @ZeroDecimal = 0.000000
SELECT @DateOnly = CAST(GETDATE() AS DATE)

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

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
		,[strSourceTransaction]					= 'Direct'--'Invoice'
		,[intSourceId]							= NULL--ARI.[intInvoiceId] 
		,[strSourceId]							= ARI.[strInvoiceNumber]
		,[intInvoiceId]							= NULL
		,[intEntityCustomerId]					= ARI.[intEntityCustomerId]
		,[intCompanyLocationId]					= ARI.[intCompanyLocationId]
		,[intAccountId]							= ARI.[intAccountId]
		,[intCurrencyId]						= ARI.[intCurrencyId]
		,[intTermId]							= ARI.[intTermId]
		,[intPeriodsToAccrue]					= ARI.[intPeriodsToAccrue]
		,[dtmDate]								= @DateOnly
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= @DateOnly
		,[dtmPostDate]							= @DateOnly
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
		,[ysnImpactInventory]					= 1 --ARI.[ysnImpactInventory]
		,[intPaymentId]							= ARI.[intPaymentId]
		,[intSplitId]							= ARI.[intSplitId]
		,[intLoadDistributionHeaderId]			= ARI.[intLoadDistributionHeaderId]
		,[strActualCostId]						= ARI.[strActualCostId]
		,[intShipmentId]						= ARI.[intShipmentId]
		,[intTransactionId]						= ARI.[intTransactionId]
		,[intMeterReadingId]					= ARI.[intMeterReadingId]
		,[intContractHeaderId]					= ARI.[intContractHeaderId]
		,[intLoadId]							= ARI.[intLoadId]
		,[intOriginalInvoiceId]					= NULL--ARI.[intInvoiceId]
		,[intEntityId]							= @UserId
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
		,[dblCOGSAmount]						= @ZeroDecimal
		,[intConversionAccountId]				= ARID.[intConversionAccountId]
		,[intSalesAccountId]					= ARID.[intSalesAccountId]
		,[intStorageScheduleTypeId]				= ARID.[intStorageScheduleTypeId]
		,[intDestinationGradeId]				= ARID.[intDestinationGradeId]
		,[intDestinationWeightId]				= ARID.[intDestinationWeightId]
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	WHERE
		ARI.[intInvoiceId] = @InvoiceId


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
	,[intTaxAccountId]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[ysnTaxExempt]
	,[ysnTaxOnly]
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
	,[intTaxAccountId]			= ARIDT.[intSalesTaxAccountId]
	,[dblTax]					= ARIDT.[dblTax]
	,[dblAdjustedTax]			= ARIDT.[dblAdjustedTax]
	,[ysnTaxAdjusted]			= ARIDT.[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]		= ARIDT.[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]			= ARIDT.[ysnCheckoffTax]
	,[ysnTaxExempt]				= ARIDT.[ysnTaxExempt]
	,[ysnTaxOnly]				= ARIDT.[ysnTaxOnly]
	,[strNotes]					= ARIDT.[strNotes]
	,[intTempDetailIdForTaxes]	= EFI.[intTempDetailIdForTaxes]
FROM
	@EntriesForInvoice  EFI
INNER JOIN
	tblARInvoiceDetailTax ARIDT
		ON EFI.[intTempDetailIdForTaxes] = ARIDT.[intInvoiceDetailId] 
ORDER BY 
	 EFI.[intInvoiceDetailId] ASC
	,ARIDT.[intInvoiceDetailTaxId] ASC
									
	
DECLARE	@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)	

				
EXEC [dbo].[uspARProcessInvoices]
	 @InvoiceEntries		= @EntriesForInvoice
	,@LineItemTaxEntries	= @LineItemTaxes
	,@UserId				= @UserId
	,@GroupingOption		= 1--11
	,@RaiseError			= @RaiseError
	,@ErrorMessage			= @CurrentErrorMessage	OUTPUT
	,@CreatedIvoices		= @CreatedIvoices		OUTPUT
	,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT


	IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
		BEGIN
			IF ISNULL(@RaiseError,0) = 0
				ROLLBACK TRANSACTION
			SET @ErrorMessage = @CurrentErrorMessage;
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
		
SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))
UPDATE tblARInvoice SET ysnReturned = 1 WHERE intInvoiceId = @InvoiceId

--POS RETURN

DECLARE @creditMemoIntId AS NVARCHAR(10)
	   ,@creditMemoStrType VARCHAR(5)
	   ,@creditMemoStrTransactionType VARCHAR(20)

SELECT @creditMemoStrType = strType
	  ,@creditMemoStrTransactionType = strTransactionType
	  ,@creditMemoIntId = CAST(@NewInvoiceId AS NVARCHAR(10))
FROM @EntriesForInvoice

IF(@creditMemoStrType = 'POS' AND @creditMemoStrTransactionType = 'Credit Memo')
BEGIN

	--post credit memo created
	EXEC uspARPostInvoice @param = @creditMemoIntId, @post = 1

	DECLARE @posStrPayment VARCHAR(10)

	SELECT @posStrPayment = posPayment.strPaymentMethod
	FROM tblARPOSPayment posPayment
	INNER JOIN tblARPOS pos ON posPayment.intPOSId = pos.intPOSId
	WHERE pos.intInvoiceId = @InvoiceId

	IF(@posStrPayment != 'On Account')
	BEGIN
		--create cash refund
		EXEC uspARProcessRefund @intInvoiceId = @creditMemoIntId, @intUserId = @UserId
	END

	UPDATE tblARPOS
	SET ysnReturn = 1
	WHERE intInvoiceId = @InvoiceId

END

--END OF POS RETURN

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

GO
