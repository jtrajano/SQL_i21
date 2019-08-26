CREATE PROCEDURE [dbo].[uspMBCreateInvoice]
@intMeterReadingId INT
	,@intUserEntityId INT
	,@intCurrency INT
	,@Post INT
	,@intInvoiceId INT

AS
BEGIN	

	DECLARE @EntriesForInvoice InvoiceIntegrationStagingTable

	INSERT INTO @EntriesForInvoice(
		[strType]
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
		,[strPONumber]
		,[strBOLNumber]
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
		,[ysnClearDetailTaxes]					
		,[intTempDetailIdForTaxes]
		,[intMeterReadingId]
		,[ysnUseOriginIdAsInvoiceNumber]
		,[strInvoiceOriginId]
	)
	SELECT
		[strType]								= 'Meter Billing'
		,[strSourceTransaction]					= 'Meter Billing'
		,[intSourceId]							= MRDetail.intMeterReadingId
		,[strSourceId]							= MRDetail.strTransactionId
		,[intInvoiceId]							= @intInvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= MRDetail.intEntityCustomerId
		,[intCompanyLocationId]					= MRDetail.intCompanyLocationId
		,[intCurrencyId]						= @intCurrency
		,[intTermId]							= MADetail.intTermId
		,[dtmDate]								= MRDetail.dtmTransaction
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= MRDetail.dtmTransaction
		,[intEntitySalespersonId]				= Customer.intSalespersonId
		,[intFreightTermId]						= NULL 
		,[intShipViaId]							= NULL 
		,[intPaymentMethodId]					= NULL
		,[strPONumber]							= NULL
		,[strBOLNumber]							= ''
		,[strComments]							= MRDetail.strInvoiceComment
		,[intShipToLocationId]					= MRDetail.intEntityLocationId
		,[intBillToLocationId]					= NULL
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0  --0 OS
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[intLoadDistributionHeaderId]			= NULL
		,[strActualCostId]						= ''
		,[intShipmentId]						= NULL
		,[intTransactionId]						= NULL
		,[intEntityId]							= @intUserEntityId
		,[ysnResetDetails]						= 1
		,[ysnPost]								= @Post
		,[intInvoiceDetailId]					= NULL
		,[intItemId]							= MRDetail.intItemId
		,[ysnInventory]							= 1
		,[strItemDescription]					= MRDetail.strItemDescription
		,[intItemUOMId]							= MRDetail.intItemUOMId
		,[dblQtyOrdered]						= 0
		,[dblQtyShipped]						= SUM(MRDetail.dblQuantitySold)
		,[dblDiscount]							= 0
		,[dblPrice]								= MIN(MRDetail.dblNetPrice)
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= ''
		,[strFrequency]							= ''
		,[dtmMaintenanceDate]					= NULL
		,[dblMaintenanceAmount]					= NULL
		,[dblLicenseAmount]						= NULL
		,[intTaxGroupId]						= EntityLocation.intTaxGroupId
		,[ysnRecomputeTax]						= 1
		,[intSCInvoiceId]						= NULL
		,[strSCInvoiceNumber]					= ''
		,[intInventoryShipmentItemId]			= NULL
		,[strShipmentNumber]					= ''
		,[intSalesOrderDetailId]				= NULL
		,[strSalesOrderNumber]					= ''
		,[intContractHeaderId]					= NULL
		,[intContractDetailId]					= NULL
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intSiteId]							= NULL
		,[strBillingBy]							= ''
		,[dblPercentFull]						= NULL
		,[dblNewMeterReading]					= NULL
		,[dblPreviousMeterReading]				= NULL
		,[dblConversionFactor]					= NULL
		,[intPerformerId]						= NULL
		,[ysnLeaseBilling]						= NULL
		,[ysnVirtualMeterReading]				= NULL
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= @intMeterReadingId
		,[intMeterReadingId]					= @intMeterReadingId
		,[ysnUseOriginIdAsInvoiceNumber]		= 1
		,[strInvoiceOriginId]					= MRDetail.strTransactionId
	FROM vyuMBGetMeterReadingDetail MRDetail
	LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId
	LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = MRDetail.intEntityCustomerId
	LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MRDetail.intEntityLocationId AND MRDetail.intEntityCustomerId = EntityLocation.intEntityId
	WHERE MRDetail.intMeterReadingId = @intMeterReadingId
	AND MRDetail.dblQuantitySold > 0
	GROUP BY MRDetail.intMeterReadingId
		, MRDetail.strTransactionId
		, MRDetail.intEntityCustomerId
		, MRDetail.intEntityLocationId
		, MRDetail.intCompanyLocationId
		, MRDetail.intItemId
		, MRDetail.strItemDescription
		, MRDetail.intItemUOMId
		, MADetail.intTermId
		, MRDetail.dtmTransaction
		, Customer.intSalespersonId
		, MRDetail.strInvoiceComment
		, EntityLocation.intTaxGroupId

	SELECT [strType]
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
		,[strPONumber]
		,[strBOLNumber]
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
		,[ysnClearDetailTaxes]					
		,[intTempDetailIdForTaxes]
		,[intMeterReadingId]
		,[ysnUseOriginIdAsInvoiceNumber]
		,[strInvoiceOriginId]
	FROM @EntriesForInvoice

END