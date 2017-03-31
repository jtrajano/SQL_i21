CREATE PROCEDURE [dbo].[uspLGProcessShipmentToInvoice]
	 @ShipmentId	INT
	,@UserId		INT	
	,@Post			BIT	= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE @UserId INT
--DECLARE @ShipmentId INT
--DECLARE @Post BIT

--SET @UserId = 285
--SET @ShipmentId = 1
--SET @Post = NULL

DECLARE @UserEntityId INT
SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId)

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
)
SELECT
	 [strSourceTransaction]				= 'Inbound Shipment'
	,[intSourceId]						= D.intShipmentId 
	,[strSourceId]						= CAST(D.intShipmentId AS NVARCHAR(250))
	,[intInvoiceId]						= E.intInvoiceId
	,[intEntityCustomerId]				= D.intCustomerEntityId 
	,[intCompanyLocationId]				= D.intCompanyLocationId 
	,[intCurrencyId]					= C.intCurrencyId
	,[intTermId]						= C.intTermId
	,[dtmDate]							= CAST(GETDATE() AS DATE)
	,[dtmDueDate]						= NULL
	,[dtmShipDate]						= CAST(ISNULL(D.dtmShipmentDate, GETDATE()) AS DATE)
	,[intEntitySalespersonId]			= C.intSalespersonId
	,[intFreightTermId]					= C.intFreightTermId 
	,[intShipViaId]						= C.intShipViaId 
	,[intPaymentMethodId]				= NULL
	,[strInvoiceOriginId]				= NULL
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[strDeliverPickup]					= ''
	,[strComments]						= D.strComments
	,[intShipToLocationId]				= ISNULL(SL1.[intEntityLocationId], EL.[intEntityLocationId])
	,[intBillToLocationId]				= ISNULL(BL1.[intEntityLocationId], EL.[intEntityLocationId])
	,[ysnTemplate]						= 0
	,[ysnForgiven]						= 0
	,[ysnCalculated]					= 0
	,[ysnSplitted]						= 0
	,[intPaymentId]						= NULL
	,[intSplitId]						= NULL
	,[intLoadDistributionHeaderId]			= NULL
	,[strActualCostId]					= NULL
	,[intShipmentId]					= D.intShipmentId
	,[intTransactionId]					= NULL
	,[intEntityId]						= @UserEntityId
	,[ysnResetDetails]					= 1
	,[ysnPost]							= @Post
	
	,[intInvoiceDetailId]				= G.intInvoiceDetailId 
	,[intItemId]						= C.intItemId
	,[ysnInventory]						= 1
	,[strItemDescription]				= C.strContractBasisDescription 
	,[intItemUOMId]						= C.intItemUOMId 
	,[dblQtyOrdered]					= A.dblSAllocatedQty 
	,[dblQtyShipped]					= A.dblSAllocatedQty 
	,[dblDiscount]						= 0
	,[dblPrice]							= C.dblCashPrice
	,[ysnRefreshPrice]					= 0
	,[strMaintenanceType]				= NULL
    ,[strFrequency]						= NULL
    ,[dtmMaintenanceDate]				= NULL
    ,[dblMaintenanceAmount]				= NULL
    ,[dblLicenseAmount]					= NULL
	,[intTaxGroupId]					= NULL
	,[ysnRecomputeTax]					= 1
	,[intSCInvoiceId]					= NULL
	,[strSCInvoiceNumber]				= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[strShipmentNumber]				= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= NULL
	,[intContractHeaderId]				= C.intContractHeaderId 
	,[intContractDetailId]				= C.intContractDetailId 
	,[intShipmentPurchaseSalesContractId]	= A.intShipmentPurchaseSalesContractId 
	,[intTicketId]						= NULL
	,[intTicketHoursWorkedId]			= NULL
	,[intSiteId]						= NULL
	,[strBillingBy]						= NULL
	,[dblPercentFull]					= NULL
	,[dblNewMeterReading]				= NULL
	,[dblPreviousMeterReading]			= NULL
	,[dblConversionFactor]				= NULL
	,[intPerformerId]					= NULL
	,[ysnLeaseBilling]					= NULL
	,[ysnVirtualMeterReading]			= NULL
FROM
	tblLGShipmentPurchaseSalesContract AS A
INNER JOIN
	tblLGAllocationDetail B
		ON A.intAllocationDetailId = B.intAllocationDetailId
INNER JOIN
	vyuCTContractDetailView C
		ON B.intSContractDetailId = C.intContractDetailId
INNER JOIN
	tblLGShipment D
		ON A.intShipmentId = D.intShipmentId
LEFT OUTER JOIN
	tblARInvoice E
		ON D.intShipmentId = E.intShipmentId
LEFT OUTER JOIN
	tblARCustomer F
		ON D.intCustomerEntityId = F.[intEntityId] 
LEFT OUTER JOIN
		(	SELECT 
				 [intEntityLocationId]
				,[strLocationName]
				,[strAddress]
				,[intEntityId] 
				,[strCountry]
				,[strState]
				,[strCity]
				,[strZipCode]
				,[intTermsId]
				,[intShipViaId]
			FROM 
				[tblEMEntityLocation]
			WHERE
				ysnDefaultLocation = 1
		) EL
			ON F.[intEntityId] = EL.[intEntityId]
	LEFT OUTER JOIN
		[tblEMEntityLocation] SL1
			ON F.intShipToId = SL1.intEntityLocationId
	LEFT OUTER JOIN
		[tblEMEntityLocation] BL1
			ON F.intShipToId = BL1.intEntityLocationId			
LEFT OUTER JOIN
	tblARInvoiceDetail G
		ON E.intInvoiceId = G.intInvoiceId
		AND A.intShipmentPurchaseSalesContractId = G.intShipmentPurchaseSalesContractId 
WHERE
	D.intShipmentId = @ShipmentId
	
		

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