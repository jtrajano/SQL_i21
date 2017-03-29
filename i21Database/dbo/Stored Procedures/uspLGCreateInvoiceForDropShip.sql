CREATE PROCEDURE uspLGCreateInvoiceForDropShip 
	 @intLoadId INT
	,@intUserId INT
	,@Post BIT = NULL
	,@NewInvoiceId INT = NULL OUTPUT		
AS
BEGIN
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @LineItemTaxEntries AS LineItemTaxDetailStagingTable
	DECLARE @strInvoiceNumber NVARCHAR(100)
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ErrorMessage NVARCHAR(250)

	IF EXISTS(SELECT TOP 1 1 FROM tblARInvoice WHERE intLoadId = @intLoadId)
	BEGIN
		SELECT TOP 1
			@strInvoiceNumber		= ARI.[strInvoiceNumber]
		   ,@strLoadNumber			= L.strLoadNumber 
		FROM tblARInvoice ARI
		JOIN tblLGLoad L ON L.intLoadId = ARI.intLoadId
		WHERE ARI.intLoadId = @intLoadId 

		SET @ErrorMessage = 'Invoice(' + @strInvoiceNumber + ') was already created for ' + @strLoadNumber;

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

	INSERT INTO @EntriesForInvoice (
		 [strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[intInvoiceId]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intCurrencyId]
		,[intTermId]
		,[intPeriodsToAccrue]
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
		,[intLoadId]
		,[intEntityId]
		,[ysnResetDetails]
		,[ysnRecap]
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
		,[dblItemWeight]
		,[intItemWeightUOMId]
		,[dblPrice]
		,[strPricing]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[intStorageLocationId]
		--,[intCompanyLocationSubLocationId]
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
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]
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
		,[ysnClearDetailTaxes]
		,[intTempDetailIdForTaxes]
		,[ysnBlended]
		,[intStorageScheduleTypeId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]
		,[intSubCurrencyId] 
		,[dblSubCurrencyRate] 
		)
	SELECT
		 [strSourceTransaction]					= 'Load Schedule'
		,[intSourceId]							= L.intLoadId
		,[strSourceId]							= L.strLoadNumber
		,[intInvoiceId]							= NULL
		,[intEntityCustomerId]					= LD.intCustomerEntityId 
		,[intCompanyLocationId]					= LD.intSCompanyLocationId 
		,[intCurrencyId]						= C.intCurrencyId 
		,[intTermId]							= CH.intTermId 
		,[intPeriodsToAccrue]					= 1 
		,[dtmDate]								= CAST(GETDATE() AS DATE) 
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= CAST(ISNULL(L.dtmScheduledDate, GETDATE()) AS DATE) 
		,[intEntitySalespersonId]				= C.intSalespersonId 
		,[intFreightTermId]						= CD.intFreightTermId 
		,[intShipViaId]							= L.intHaulerEntityId 
		,[intPaymentMethodId]					= NULL 
		,[strInvoiceOriginId]					= NULL 
		,[strPONumber]							= '' 
		,[strBOLNumber]							= L.strBLNumber 
		,[strDeliverPickup]						= NULL 
		,[strComments]							= L.strComments 
		,[intShipToLocationId]					= ISNULL(LD.intCustomerEntityLocationId, EL.[intEntityLocationId]) 
		,[intBillToLocationId]					= ISNULL(LD.intCustomerEntityLocationId, EL.[intEntityLocationId])
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[intDistributionHeaderId]				= NULL
		,[strActualCostId]						= NULL
		,[intShipmentId]						= NULL
		,[intTransactionId]						= NULL
		,[intOriginalInvoiceId]					= NULL
		,[intLoadId]							= L.intLoadId
		,[intEntityId]							= @intUserId		
		,[ysnResetDetails]						= 1
		,[ysnRecap]								= 0
		,[ysnPost]								= @Post
																																																		
		,[intInvoiceDetailId]					= ID.intInvoiceDetailId
		,[intItemId]							= LD.intItemId
		,[ysnInventory]							= 1
		,[strDocumentNumber]					= L.strLoadNumber
		,[strItemDescription]					= ITM.strDescription
		,[intOrderUOMId]						= CD.[intOrderUOMId] 
		,[dblQtyOrdered]						= CD.[dblOrderQuantity] 
		,[intItemUOMId]							= CD.[intItemUOMId] 
		,[dblQtyShipped]						= CD.[dblShipQuantity] 
		,[dblDiscount]							= 0 
		,[dblItemWeight]						= 0 
		,[intItemWeightUOMId]					= 0
		,[dblPrice]								= CD.[dblCashPrice] 
		,[strPricing]							= 'Contract Pricing'
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= NULL
		,[strFrequency]							= NULL
		,[dtmMaintenanceDate]					= NULL
		,[dblMaintenanceAmount]					= 0 
		,[dblLicenseAmount]						= 0
		,[intTaxGroupId]						= NULL 
		,[intStorageLocationId]					= NULL
		,[ysnRecomputeTax]						= 1
		,[intSCInvoiceId]						= NULL
		,[strSCInvoiceNumber]					= NULL
		,[intSCBudgetId]						= NULL
		,[strSCBudgetDescription]				= NULL
		,[intInventoryShipmentItemId]			= NULL
		,[intInventoryShipmentChargeId]			= NULL
		,[strShipmentNumber]					= NULL
		,[intRecipeItemId]						= NULL
		,[intRecipeId]							= NULL
		,[intSubLocationId]						= NULL
		,[intCostTypeId]						= NULL
		,[intMarginById]						= NULL
		,[intCommentTypeId]						= NULL
		,[dblMargin]							= NULL
		,[dblRecipeQuantity]					= NULL
		,[intSalesOrderDetailId]				= NULL
		,[strSalesOrderNumber]					= NULL
		,[intContractHeaderId]					= CH.[intContractHeaderId] 
		,[intContractDetailId]					= CD.[intContractDetailId] 
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[dblShipmentGrossWt]					= LD.dblGross
		,[dblShipmentTareWt]					= LD.dblTare
		,[dblShipmentNetWt]						= LD.dblNet
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intOriginalInvoiceDetailId]			= NULL
		,[intSiteId]							= NULL
		,[strBillingBy]							= NULL
		,[dblPercentFull]						= NULL
		,[dblNewMeterReading]					= 0
		,[dblPreviousMeterReading]				= 0
		,[dblConversionFactor]					= 0
		,[intPerformerId]						= NULL
		,[ysnLeaseBilling]						= 0
		,[ysnVirtualMeterReading]				= 0
		,[ysnClearDetailTaxes]					= 0
		,[intTempDetailIdForTaxes]				= NULL
		,[ysnBlended]							= 0
		,[intStorageScheduleTypeId]				= NULL
		,[intDestinationGradeId]				= NULL
		,[intDestinationWeightId]				= NULL
		,[intSubCurrencyId]						= CD.[intSubCurrencyId]
		,[dblSubCurrencyRate]					= CD.[dblSubCurrencyRate]			
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblICItem ITM ON ITM.intItemId = LD.intItemId
	JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId = LD.intAllocationDetailId
	JOIN vyuARCustomerContract CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblARInvoiceDetail ID ON ID.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
	LEFT JOIN tblARCustomer C ON C.[intEntityId] = LD.intCustomerEntityId
	LEFT OUTER JOIN (
		SELECT [intEntityLocationId]
			,[strLocationName]
			,[strAddress]
			,[intEntityId]
			,[strCountry]
			,[strState]
			,[strCity]
			,[strZipCode]
			,[intTermsId]
			,[intShipViaId]
		FROM [tblEMEntityLocation]
		WHERE ysnDefaultLocation = 1
		) EL ON C.[intEntityId] = EL.intEntityId
	LEFT OUTER JOIN [tblEMEntityLocation] SL1 ON C.intShipToId = SL1.intEntityLocationId
	LEFT OUTER JOIN [tblEMEntityLocation] BL1 ON C.intShipToId = BL1.intEntityLocationId
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	WHERE LD.intLoadId = @intLoadId

	DECLARE @CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)

	EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries = @EntriesForInvoice
		,@UserId = @intUserId
		,@GroupingOption = 11
		,@RaiseError = 1
		,@LineItemTaxEntries = @LineItemTaxEntries
		,@ErrorMessage = @ErrorMessage OUTPUT
		,@CreatedIvoices = @CreatedIvoices OUTPUT
		,@UpdatedIvoices = @UpdatedIvoices OUTPUT

	SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))			
	RETURN @NewInvoiceId
END