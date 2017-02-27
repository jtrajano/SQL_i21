CREATE PROCEDURE [dbo].[uspARProcessProvisionalInvoice]
	 @InvoiceId		INT
	,@UserId		INT	
	,@RaiseError	BIT				= 0
	,@NewInvoiceId	INT				= NULL	OUTPUT
	,@ErrorMessage	NVARCHAR(250)	= NULL	OUTPUT
AS

SET NOCOUNT ON

IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION


DECLARE @UserEntityId INT
SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserId),@UserId)

--BEGIN TRY
--EXEC [dbo].[uspARPostInvoice]
--	 @post				= 1
--	,@recap				= 0
--	,@param				= @InvoiceId
--	,@userId			= @UserId
--	,@beginDate			= NULL
--	,@endDate			= NULL
--	,@beginTransaction	= NULL
--	,@endTransaction	= NULL
--	,@exclude			= NULL
--	,@raiseError		= @RaiseError

--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

DECLARE  @InvoiceNumber			NVARCHAR(25)
		,@EntityCustomerId		INT
		,@CompanyLocationId		INT
		,@AccountId				INT
		,@CurrencyId			INT
		,@TermId				INT
		,@Date					DATETIME
		,@ShipDate				DATETIME
		,@EntitySalespersonId	INT
		,@FreightTermId			INT
		,@ShipViaId				INT
		,@PaymentMethodId		INT
		,@InvoiceOriginId		NVARCHAR(8)
		,@PONumber				NVARCHAR(25)
		,@BOLNumber				NVARCHAR(50)
		,@DeliverPickup			NVARCHAR(100)
		,@Comments				NVARCHAR(500)
		,@ShipToLocationId		INT
		,@BillToLocationId		INT
		,@ShipmentId			INT
		,@OriginalInvoiceId		INT
		
SELECT
	 @InvoiceNumber			= [strInvoiceNumber]
	,@EntityCustomerId		= [intEntityCustomerId]
	,@CompanyLocationId		= [intCompanyLocationId]
	,@AccountId				= ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference),[intAccountId])
	,@CurrencyId			= [intCurrencyId]
	,@TermId				= [intTermId]
	,@Date					= CAST(GETDATE() AS DATE)
	,@ShipDate				= [dtmShipDate]
	,@EntitySalespersonId	= [intEntitySalespersonId]
	,@FreightTermId			= [intFreightTermId]
	,@ShipViaId				= [intShipViaId]
	,@PaymentMethodId		= [intPaymentMethodId]
	,@InvoiceOriginId		= [strInvoiceNumber]
	,@PONumber				= [strPONumber]
	,@BOLNumber				= [strBOLNumber]
	,@DeliverPickup			= [strDeliverPickup]
	,@Comments				= [strComments]
	,@ShipToLocationId		= [intShipToLocationId]
	,@BillToLocationId		= [intBillToLocationId]
	,@ShipmentId			= [intShipmentId]
	,@OriginalInvoiceId		= [intInvoiceId]
FROM
	tblARInvoice
WHERE 
	[intInvoiceId] = @InvoiceId 

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
		,[intCurrencyId]
		,[intTermId]
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strPONumber]
		,[strBOLNumber]
		,[strDeliverPickup]
		,[strComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
		,[intLoadDistributionHeaderId]
		,[strActualCostId]
		,[intShipmentId]
		,[intTransactionId]
		,[intOriginalInvoiceId]
		,[intEntityId]
		,[ysnResetDetails]
		,[ysnPost]
		,[intInvoiceDetailId]
		,[intItemId]
		,[ysnInventory]
		,[strDocumentNumber]
		,[strItemDescription]
		,[intOrderUOMId]
		,[dblQtyOrdered]
		,[intItemUOMId]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[strShipmentNumber]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]
		,[intItemWeightUOMId]
		,[dblItemWeight]
		,[dblShipmentGrossWt]
		,[dblShipmentTareWt]
		,[dblShipmentNetWt]
		,[intTicketId]
		,[intTicketHoursWorkedId]
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
		,[intDestinationGradeId]
		,[intDestinationWeightId]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId] 
		,[dblSubCurrencyRate]
	)
	SELECT
		 [strTransactionType]				= 'Invoice'
		,[strType]							= 'Standard'
		,[strSourceTransaction]				= 'Provisional Invoice'
		,[intSourceId]						= @InvoiceId   
		,[strSourceId]						= @InvoiceNumber
		,[intInvoiceId]						= NULL
		,[intEntityCustomerId]				= @EntityCustomerId
		,[intCompanyLocationId]				= @CompanyLocationId
		,[intCurrencyId]					= @CurrencyId
		,[intTermId]						= @TermId
		,[dtmDate]							= @Date 
		,[dtmDueDate]						= NULL
		,[dtmShipDate]						= CAST(ISNULL(@ShipDate, GETDATE()) AS DATE)
		,[intEntitySalespersonId]			= @EntitySalespersonId
		,[intFreightTermId]					= @FreightTermId
		,[intShipViaId]						= @ShipViaId
		,[intPaymentMethodId]				= @PaymentMethodId
		,[strInvoiceOriginId]				= @InvoiceNumber
		,[strPONumber]						= @PONumber
		,[strBOLNumber]						= @BOLNumber
		,[strDeliverPickup]					= @DeliverPickup
		,[strComments]						= @Comments
		,[intShipToLocationId]				= @ShipToLocationId
		,[intBillToLocationId]				= @BillToLocationId
		,[ysnTemplate]						= 0
		,[ysnForgiven]						= 0
		,[ysnCalculated]					= 0
		,[ysnSplitted]						= 0
		,[intPaymentId]						= NULL
		,[intSplitId]						= NULL
		,[intLoadDistributionHeaderId]		= NULL
		,[strActualCostId]					= NULL
		,[intShipmentId]					= NULL
		,[intTransactionId]					= NULL
		,[intOriginalInvoiceId]				= @OriginalInvoiceId
		,[intEntityId]						= @UserEntityId
		,[ysnResetDetails]					= 1
		,[ysnPost]							= NULL
	
		,[intInvoiceDetailId]				= NULL 
		,[intItemId]						= ARSID.[intItemId] 
		,[ysnInventory]						= 1
		,[strDocumentNumber]				= @InvoiceNumber
		,[strItemDescription]				= ARSID.[strItemDescription] 
		,[intOrderUOMId]					= ARSID.[intShipmentItemUOMId]
		,[dblQtyOrdered]					= ARSID.dblShipmentQuantity 
		,[intItemUOMId]						= ARSID.[intShipmentItemUOMId]
		,[dblQtyShipped]					= ARSID.dblShipmentQuantity
		,[dblDiscount]						= ARSID.[dblDiscount]
		,[dblPrice]							= ARSID.[dblPrice] 
		,[ysnRefreshPrice]					= 0
		,[strMaintenanceType]				= ARID.[strMaintenanceType]
		,[strFrequency]						= ARID.[strFrequency]
		,[dtmMaintenanceDate]				= ARID.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]				= ARID.[dblMaintenanceAmount]
		,[dblLicenseAmount]					= ARID.[dblLicenseAmount]
		,[intTaxGroupId]					= ARID.[intTaxGroupId]
		,[ysnRecomputeTax]					= 1
		,[intSCInvoiceId]					= ARID.[intSCInvoiceId]
		,[strSCInvoiceNumber]				= ARID.[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]		= ARID.[intInventoryShipmentItemId]
		,[strShipmentNumber]				= ARID.[strShipmentNumber]
		,[intSalesOrderDetailId]			= ARID.[intSalesOrderDetailId]
		,[strSalesOrderNumber]				= ARID.[strSalesOrderNumber] 
		,[intContractHeaderId]				= ARSID.[intContractHeaderId] 
		,[intContractDetailId]				= ARSID.[intContractDetailId] 
		,[intShipmentPurchaseSalesContractId]	= ARSID.[intShipmentPurchaseSalesContractId] 
		,[intItemWeightUOMId]				= ARSID.[intWeightUOMId]
		,[dblItemWeight]					= ARSID.[dblWeight] 
		,[dblShipmentGrossWt]				= ARSID.[dblGrossWt]
		,[dblShipmentTareWt]				= ARSID.[dblTareWt]
		,[dblShipmentNetWt]					= ARSID.[dblNetWt]
		,[intTicketId]						= ARID.[intTicketId]
		,[intTicketHoursWorkedId]			= ARID.[intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]		= ARID.[intInvoiceDetailId] 
		,[intSiteId]						= ARID.[intSiteId]
		,[strBillingBy]						= ARID.[strBillingBy]
		,[dblPercentFull]					= ARID.[dblPercentFull]
		,[dblNewMeterReading]				= ARID.[dblNewMeterReading]
		,[dblPreviousMeterReading]			= ARID.[dblPreviousMeterReading]
		,[dblConversionFactor]				= ARID.[dblConversionFactor]
		,[intPerformerId]					= ARID.[intPerformerId]
		,[ysnLeaseBilling]					= ARID.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]			= ARID.[ysnVirtualMeterReading]
		,[intDestinationGradeId]			= ARSID.[intDestinationGradeId]
		,[intDestinationWeightId]			= ARSID.[intDestinationWeightId]
		,[intCurrencyExchangeRateTypeId]	= ARSID.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]		= ARSID.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]			= ARSID.[dblCurrencyExchangeRate]
		,[intSubCurrencyId]					= ARSID.[intSubCurrencyId]
		,[dblSubCurrencyRate]				= ARSID.[dblSubCurrencyRate]
	FROM
		vyuARShippedItemDetail ARSID
	INNER JOIN
		vyuLGShipmentHeader ARSI
			ON ARSID.[intShipmentId] = ARSI.[intShipmentId] 
	LEFT OUTER JOIN		
		tblARInvoiceDetail ARID
			ON ARSID.[intShipmentPurchaseSalesContractId] = ARID.[intShipmentPurchaseSalesContractId]
			AND ARID.[intInvoiceId] = @InvoiceId
	WHERE
		ARSI.[intShipmentId] IN	(	SELECT LG.[intShipmentId] 
									FROM vyuLGDropShipmentDetails LG 
										INNER JOIN tblARInvoiceDetail AR 
											ON LG.[intShipmentPurchaseSalesContractId] = AR.[intShipmentPurchaseSalesContractId] 
									WHERE AR.[intInvoiceId] = @InvoiceId
								)
								
UNION ALL

SELECT
		 [strTransactionType]				= 'Invoice'
		,[strType]							= 'Standard'
		,[strSourceTransaction]				= 'Provisional Invoice'
		,[intSourceId]						= @InvoiceId   
		,[strSourceId]						= @InvoiceNumber
		,[intInvoiceId]						= NULL
		,[intEntityCustomerId]				= @EntityCustomerId
		,[intCompanyLocationId]				= @CompanyLocationId
		,[intCurrencyId]					= @CurrencyId
		,[intTermId]						= @TermId
		,[dtmDate]							= @Date 
		,[dtmDueDate]						= NULL
		,[dtmShipDate]						= CAST(ISNULL(@ShipDate, GETDATE()) AS DATE)
		,[intEntitySalespersonId]			= @EntitySalespersonId
		,[intFreightTermId]					= @FreightTermId
		,[intShipViaId]						= @ShipViaId
		,[intPaymentMethodId]				= @PaymentMethodId
		,[strInvoiceOriginId]				= @InvoiceNumber
		,[strPONumber]						= @PONumber
		,[strBOLNumber]						= @BOLNumber
		,[strDeliverPickup]					= @DeliverPickup
		,[strComments]						= @Comments
		,[intShipToLocationId]				= @ShipToLocationId
		,[intBillToLocationId]				= @BillToLocationId
		,[ysnTemplate]						= 0
		,[ysnForgiven]						= 0
		,[ysnCalculated]					= 0
		,[ysnSplitted]						= 0
		,[intPaymentId]						= NULL
		,[intSplitId]						= NULL
		,[intDistributionHeaderId]			= NULL
		,[strActualCostId]					= NULL
		,[intShipmentId]					= NULL
		,[intTransactionId]					= NULL
		,[intOriginalInvoiceId]				= @OriginalInvoiceId
		,[intEntityId]						= @UserEntityId
		,[ysnResetDetails]					= 1
		,[ysnPost]							= NULL
	
		,[intInvoiceDetailId]				= NULL 
		,[intItemId]						= ISI.[intItemId] 
		,[ysnInventory]						= 1
		,[strDocumentNumber]				= @InvoiceNumber
		,[strItemDescription]				= I.[strDescription] 
		,[intOrderUOMId]					= ISI.[intItemUOMId]		
		,[dblQtyOrdered]					= ISI.[dblQuantity] 
		,[intItemUOMId]						= ISI.[intItemUOMId] 
		,[dblQtyShipped]					= ISI.[dblQuantity]  
		,[dblDiscount]						= 0.00
		,[dblPrice]							= ISI.[dblUnitPrice]
		,[ysnRefreshPrice]					= 0
		,[strMaintenanceType]				= ARID.[strMaintenanceType]
		,[strFrequency]						= ARID.[strFrequency]
		,[dtmMaintenanceDate]				= ARID.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]				= ARID.[dblMaintenanceAmount]
		,[dblLicenseAmount]					= ARID.[dblLicenseAmount]
		,[intTaxGroupId]					= ARID.[intTaxGroupId]
		,[ysnRecomputeTax]					= 1
		,[intSCInvoiceId]					= ARID.[intSCInvoiceId]
		,[strSCInvoiceNumber]				= ARID.[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]		= ISI.[intInventoryShipmentItemId]
		,[strShipmentNumber]				= ISH.[strShipmentNumber]
		,[intSalesOrderDetailId]			= NULL
		,[strSalesOrderNumber]				= NULL
		,[intContractHeaderId]				= ARID.[intContractHeaderId] 
		,[intContractDetailId]				= ARID.[intContractDetailId] 
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intItemWeightUOMId]				= NULL
		,[dblItemWeight]					= 0.00
		,[dblShipmentGrossWt]				= 0.00
		,[dblShipmentTareWt]				= 0.00
		,[dblShipmentNetWt]					= 0.00
		,[intTicketId]						= ARID.[intTicketId]
		,[intTicketHoursWorkedId]			= ARID.[intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]		= ARID.[intInvoiceDetailId] 
		,[intSiteId]						= ARID.[intSiteId]
		,[strBillingBy]						= ARID.[strBillingBy]
		,[dblPercentFull]					= ARID.[dblPercentFull]
		,[dblNewMeterReading]				= ARID.[dblNewMeterReading]
		,[dblPreviousMeterReading]			= ARID.[dblPreviousMeterReading]
		,[dblConversionFactor]				= ARID.[dblConversionFactor]
		,[intPerformerId]					= ARID.[intPerformerId]
		,[ysnLeaseBilling]					= ARID.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]			= ARID.[ysnVirtualMeterReading]
		,[intDestinationGradeId]			= ISI.[intDestinationGradeId]
		,[intDestinationWeightId]			= ISI.[intDestinationWeightId]
		,[intCurrencyExchangeRateTypeId]	= ISI.[intForexRateTypeId]
		,[intCurrencyExchangeRateId]		= NULL
		,[dblCurrencyExchangeRate]			= ISI.[dblForexRate]
		,[intSubCurrencyId]					= ARID.[intSubCurrencyId]
		,[dblSubCurrencyRate]				= ARID.[dblSubCurrencyRate]
	FROM
		tblICInventoryShipmentItem ISI
	INNER JOIN
		tblICItem I
			ON ISI.[intItemId] = I.[intItemId]
	INNER JOIN
		tblICInventoryShipment ISH
			ON ISI.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
	LEFT OUTER JOIN		
		tblARInvoiceDetail ARID
			ON ISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId] 
			AND ARID.[intInvoiceId] = @InvoiceId										 
		WHERE
			ISH.[ysnPosted] = 1
			--AND ISH.[intOrderType] <> 2
			AND ISH.[intInventoryShipmentId] IN	(	SELECT IC.[intInventoryShipmentId] 
													FROM tblICInventoryShipmentItem IC 
														INNER JOIN tblARInvoiceDetail AR 
															ON IC.[intInventoryShipmentItemId] = AR.[intInventoryShipmentItemId]  
													WHERE AR.[intInvoiceId] = @InvoiceId
												)


END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
DECLARE	@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)	

DECLARE @LineItemTaxes AS LineItemTaxDetailStagingTable
				
BEGIN TRY
EXEC [dbo].[uspARProcessInvoices]
	 @InvoiceEntries		= @EntriesForInvoice
	,@LineItemTaxEntries	= @LineItemTaxes
	,@UserId				= @UserId
	,@GroupingOption		= 11
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

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

GO