CREATE PROCEDURE [dbo].[uspARProcessProvisionalInvoice]
	 @InvoiceId		INT
	,@UserId		INT	
	,@Post			BIT	= NULL
AS

SET NOCOUNT ON

DECLARE @UserEntityId INT
SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserId),@UserId)

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable


INSERT INTO @EntriesForInvoice(
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
	,[intDistributionHeaderId]
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
)
SELECT
	 [strSourceTransaction]				= 'Provisional Invoice'
	,[intSourceId]						= ARI.[intInvoiceId]  
	,[strSourceId]						= ARI.[strInvoiceNumber] 
	,[intInvoiceId]						= NULL
	,[intEntityCustomerId]				= ARI.[intEntityCustomerId] 
	,[intCompanyLocationId]				= ARI.[intCompanyLocationId] 
	,[intCurrencyId]					= ARI.[intCurrencyId] 
	,[intTermId]						= ARI.[intTermId] 
	,[dtmDate]							= CAST(GETDATE() AS DATE)
	,[dtmDueDate]						= NULL
	,[dtmShipDate]						= CAST(ISNULL(ARI.[dtmShipDate], GETDATE()) AS DATE)
	,[intEntitySalespersonId]			= ARI.[intEntitySalespersonId] 
	,[intFreightTermId]					= ARI.[intFreightTermId]  
	,[intShipViaId]						= ARI.[intShipViaId]
	,[intPaymentMethodId]				= ARI.[intPaymentMethodId]
	,[strInvoiceOriginId]				= ARI.[strInvoiceNumber]
	,[strPONumber]						= ARI.[strPONumber]
	,[strBOLNumber]						= ARI.[strBOLNumber]
	,[strDeliverPickup]					= ARI.[strDeliverPickup]
	,[strComments]						= ARI.[strComments]
	,[intShipToLocationId]				= ARI.[intShipToLocationId]
	,[intBillToLocationId]				= ARI.[intBillToLocationId]
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
	,[intOriginalInvoiceId]				= ARI.[intInvoiceId]
	,[intEntityId]						= @UserEntityId
	,[ysnResetDetails]					= 1
	,[ysnPost]							= @Post
	
	,[intInvoiceDetailId]				= NULL 
	,[intItemId]						= ARID.[intItemId] 
	,[ysnInventory]						= 1
	,[strDocumentNumber]				= ARI.[strInvoiceNumber]
	,[strItemDescription]				= ARID.[strItemDescription] 
	,[intItemUOMId]						= ARID.[intItemUOMId] 
	,[dblQtyOrdered]					= ARID.[dblQtyOrdered] 
	,[dblQtyShipped]					= ARID.[dblQtyShipped]  
	,[dblDiscount]						= ARID.[dblDiscount]
	,[dblPrice]							= ARID.[dblPrice]
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
	,[strSalesOrderNumber]				= ARID.[intContractHeaderId]
	,[intContractHeaderId]				= ARID.[intContractHeaderId] 
	,[intContractDetailId]				= ARID.[intContractDetailId] 
	,[intShipmentPurchaseSalesContractId]	= ARID.[intShipmentPurchaseSalesContractId] 
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
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
	
		

DECLARE	@ErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)
		
EXEC [dbo].[uspARProcessInvoices]
	 @InvoiceEntries	= @EntriesForInvoice
	,@UserId			= @UserId
	,@GroupingOption	= 11
	,@RaiseError		= 1
	,@ErrorMessage		= @ErrorMessage OUTPUT
	,@CreatedIvoices	= @CreatedIvoices OUTPUT
	,@UpdatedIvoices	= @UpdatedIvoices OUTPUT
	
	
SELECT intShipmentId, * FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))
SELECT intShipmentPurchaseSalesContractId, * FROM tblARInvoiceDetail WHERE intInvoiceId IN (SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices)))
SELECT intShipmentId, * FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@UpdatedIvoices))
SELECT intShipmentPurchaseSalesContractId, * FROM tblARInvoiceDetail WHERE intInvoiceId IN (SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@UpdatedIvoices)))