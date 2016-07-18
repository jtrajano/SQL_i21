CREATE PROCEDURE uspLGCreateInvoiceForDropShip @intLoadId INT
	,@intUserId INT
	,@Post BIT = NULL
AS
BEGIN
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @LineItemTaxEntries AS LineItemTaxDetailStagingTable

	INSERT INTO @EntriesForInvoice (
		[strSourceTransaction]
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
		,[intEntityId]
		,[ysnResetDetails]
		,[ysnPost]
		,[intInvoiceDetailId]
		,[intItemId]
		,[ysnInventory]
		,[strItemDescription]
		,[intItemUOMId]
		,[dblQtyOrdered]
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
		,[intTicketId]
		,[intTicketHoursWorkedId]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblNewMeterReading]
		,[dblPreviousMeterReading]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[intLoadDetailId]
		,[dblShipmentGrossWt]
		,[dblShipmentTareWt]
		,[dblShipmentNetWt]
		)
	SELECT [strSourceTransaction] = 'Load Schedule'
		,[intSourceId] = L.intLoadId
		,[strSourceId] = CAST(L.intLoadId AS NVARCHAR(250))
		,[intInvoiceId] = I.intInvoiceId
		,[intEntityCustomerId] = LD.intCustomerEntityId
		,[intCompanyLocationId] = LD.intSCompanyLocationId
		,[intCurrencyId] = C.intCurrencyId
		,[intTermId] = CH.intTermId
		,[dtmDate] = CAST(GETDATE() AS DATE)
		,[dtmDueDate] = NULL
		,[dtmShipDate] = CAST(ISNULL(L.dtmScheduledDate, GETDATE()) AS DATE)
		,[intEntitySalespersonId] = C.intSalespersonId
		,[intFreightTermId] = CD.intFreightTermId
		,[intShipViaId] = L.intHaulerEntityId
		,[intPaymentMethodId] = NULL
		,[strInvoiceOriginId] = NULL
		,[strPONumber] = ''
		,[strBOLNumber] = L.strBLNumber
		,[strDeliverPickup] = ''
		,[strComments] = L.strComments
		,[intShipToLocationId] = ISNULL(LD.intCustomerEntityLocationId, EL.[intEntityLocationId])
		,[intBillToLocationId] = ISNULL(LD.intCustomerEntityLocationId, EL.[intEntityLocationId])
		,[ysnTemplate] = 0
		,[ysnForgiven] = 0
		,[ysnCalculated] = 0
		,[ysnSplitted] = 0
		,[intPaymentId] = NULL
		,[intSplitId] = NULL
		,[intLoadDistributionHeaderId] = NULL
		,[strActualCostId] = NULL
		,[intShipmentId] = L.intLoadId
		,[intTransactionId] = NULL
		,[intEntityId] = @intUserId
		,[ysnResetDetails] = 1
		,[ysnPost] = 1 --@Post
		,[intInvoiceDetailId] = ID.intInvoiceDetailId
		,[intItemId] = LD.intItemId
		,[ysnInventory] = 1
		,[strItemDescription] = CB.strDescription
		,[intItemUOMId] = CD.intItemUOMId
		,[dblQtyOrdered] = LD.dblQuantity
		,[dblQtyShipped] = LD.dblQuantity
		,[dblDiscount] = 0
		,[dblPrice] = CD.dblCashPrice
		,[ysnRefreshPrice] = 0
		,[strMaintenanceType] = NULL
		,[strFrequency] = NULL
		,[dtmMaintenanceDate] = NULL
		,[dblMaintenanceAmount] = NULL
		,[dblLicenseAmount] = NULL
		,[intTaxGroupId] = NULL
		,[ysnRecomputeTax] = 1
		,[intSCInvoiceId] = NULL
		,[strSCInvoiceNumber] = NULL
		,[intInventoryShipmentItemId] = NULL
		,[strShipmentNumber] = L.strLoadNumber
		,[intSalesOrderDetailId] = NULL
		,[strSalesOrderNumber] = NULL
		,[intContractHeaderId] = CH.intContractHeaderId
		,[intContractDetailId] = CD.intContractDetailId
		,[intShipmentPurchaseSalesContractId] = NULL --A.intShipmentPurchaseSalesContractId 
		,[intTicketId] = NULL
		,[intTicketHoursWorkedId] = NULL
		,[intSiteId] = NULL
		,[strBillingBy] = NULL
		,[dblPercentFull] = NULL
		,[dblNewMeterReading] = NULL
		,[dblPreviousMeterReading] = NULL
		,[dblConversionFactor] = NULL
		,[intPerformerId] = NULL
		,[ysnLeaseBilling] = NULL
		,[ysnVirtualMeterReading] = NULL
		,LD.intLoadDetailId
		,LD.dblGross
		,LD.dblTare
		,LD.dblNet
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId = LD.intAllocationDetailId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblARInvoiceDetail ID ON ID.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
	LEFT JOIN tblARCustomer C ON C.intEntityCustomerId = LD.intCustomerEntityId
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
		) EL ON C.intEntityCustomerId = EL.intEntityId
	LEFT OUTER JOIN [tblEMEntityLocation] SL1 ON C.intShipToId = SL1.intEntityLocationId
	LEFT OUTER JOIN [tblEMEntityLocation] BL1 ON C.intShipToId = BL1.intEntityLocationId
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	WHERE LD.intLoadId = @intLoadId

	DECLARE @ErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)

	EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries = @EntriesForInvoice
		,@UserId = @intUserId
		,@GroupingOption = 11
		,@RaiseError = 1
		,@LineItemTaxEntries = @LineItemTaxEntries
		,@ErrorMessage = @ErrorMessage OUTPUT
		,@CreatedIvoices = @CreatedIvoices OUTPUT
		,@UpdatedIvoices = @UpdatedIvoices OUTPUT

	SELECT intShipmentId
		,*
	FROM tblARInvoice
	WHERE intInvoiceId IN (
			SELECT intID
			FROM fnGetRowsFromDelimitedValues(@CreatedIvoices)
			)

	SELECT intShipmentPurchaseSalesContractId
		,*
	FROM tblARInvoiceDetail
	WHERE intInvoiceId IN (
			SELECT intInvoiceId
			FROM tblARInvoice
			WHERE intInvoiceId IN (
					SELECT intID
					FROM fnGetRowsFromDelimitedValues(@CreatedIvoices)
					)
			)

	SELECT intShipmentId
		,*
	FROM tblARInvoice
	WHERE intInvoiceId IN (
			SELECT intID
			FROM fnGetRowsFromDelimitedValues(@UpdatedIvoices)
			)

	SELECT intShipmentPurchaseSalesContractId
		,*
	FROM tblARInvoiceDetail
	WHERE intInvoiceId IN (
			SELECT intInvoiceId
			FROM tblARInvoice
			WHERE intInvoiceId IN (
					SELECT intID
					FROM fnGetRowsFromDelimitedValues(@UpdatedIvoices)
					)
			)
END