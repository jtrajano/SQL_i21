CREATE PROCEDURE [dbo].[uspARGetItemsFromInvoice]
	@intInvoiceId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT
	-- Header
	 [intInvoiceId]					= I.[intInvoiceId]
	,[strInvoiceNumber]				= I.[strInvoiceNumber]
	,[intEntityCustomerId]			= I.[intEntityCustomerId]
	,[dtmDate]						= I.[dtmDate]
	,[intCurrencyId]				= I.[intCurrencyId]
	,[intCompanyLocationId]			= I.[intCompanyLocationId]
	,[intDistributionHeaderId]		= I.[intDistributionHeaderId]

	-- Detail 
	,[intInvoiceDetailId]			= ID.[intInvoiceDetailId]			
	,[intItemId]					= ID.[intItemId]		
	,[strItemNo]					= II.[strItemNo]
	,[strItemDescription]			= ID.[strItemDescription]			
	,[intSCInvoiceId]				= ID.[intSCInvoiceId]				
	,[strSCInvoiceNumber]			= ID.[strSCInvoiceNumber]			
	,[intItemUOMId]					= ID.[intItemUOMId]					
	,[dblQtyOrdered]				= ID.[dblQtyOrdered]				
	,[dblQtyShipped]				= ID.[dblQtyShipped]				
	,[dblDiscount]					= ID.[dblDiscount]					
	,[dblPrice]						= ID.[dblPrice]						
	,[dblTotalTax]					= ID.[dblTotalTax]					
	,[dblTotal]						= ID.[dblTotal]						
	,[intServiceChargeAccountId]	= ID.[intServiceChargeAccountId]	
	,[intInventoryShipmentItemId]	= ID.[intInventoryShipmentItemId]	
	,[intSalesOrderDetailId]		= ID.[intSalesOrderDetailId]
	,[intShipmentPurchaseSalesContractId]		= ID.[intShipmentPurchaseSalesContractId]		
	,[intSiteId]					= ID.[intSiteId]					
	,[strBillingBy]                 = ID.[strBillingBy]                 
	,[dblPercentFull]				= ID.[dblPercentFull]				
	,[dblNewMeterReading]			= ID.[dblNewMeterReading]			
	,[dblPreviousMeterReading]		= ID.[dblPreviousMeterReading]		
	,[dblConversionFactor]			= ID.[dblConversionFactor]			
	,[intPerformerId]				= ID.[intPerformerId]				
	,[intContractHeaderId]			= ID.[intContractHeaderId]
	,[strContractNumber]			= CH.[strContractNumber]
	,[strMaintenanceType]           = ID.[strMaintenanceType]           
	,[strFrequency]                 = ID.[strFrequency]                 
	,[dtmMaintenanceDate]           = ID.[dtmMaintenanceDate]           
	,[dblMaintenanceAmount]         = ID.[dblMaintenanceAmount]         
	,[dblLicenseAmount]             = ID.[dblLicenseAmount]             
	,[intContractDetailId]			= ID.[intContractDetailId]			
	,[intTicketId]					= ID.[intTicketId]
	,[intTicketHoursWorkedId]		= ID.[intTicketHoursWorkedId]
	,[intCustomerStorageId]			= ID.[intCustomerStorageId]
	,[intSiteDetailId]				= ID.[intSiteDetailId]
	,[intLoadDetailId]				= ID.[intLoadDetailId]
	,[intOriginalInvoiceDetailId]	= ID.[intOriginalInvoiceDetailId]
	,[ysnLeaseBilling]				= ID.[ysnLeaseBilling]				
FROM
	tblARInvoice I
INNER JOIN
	tblARInvoiceDetail ID	
		ON I.[intInvoiceId] = ID.[intInvoiceId]
LEFT JOIN
	tblICItem II
		ON ID.intItemId = II.intItemId
LEFT JOIN
	tblCTContractHeader CH
		ON ID.intContractHeaderId = CH.intContractHeaderId
WHERE
	I.[intInvoiceId] = @intInvoiceId