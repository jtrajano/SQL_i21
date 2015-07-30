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
	 [intInvoiceId]					= Header.[intInvoiceId]
	,[strInvoiceNumber]				= Header.[strInvoiceNumber]
	,[intEntityCustomerId]			= Header.[intEntityCustomerId]
	,[dtmDate]						= Header.[dtmDate]
	,[intCurrencyId]				= Header.[intCurrencyId]
	,[intCompanyLocationId]			= Header.[intCompanyLocationId]
	,[intDistributionHeaderId]		= Header.[intDistributionHeaderId]

	-- Detail 
	,[intInvoiceDetailId]			= Detail.[intInvoiceDetailId]			
	,[intItemId]					= Detail.[intItemId]					
	,[strItemDescription]			= Detail.[strItemDescription]			
	,[intSCInvoiceId]				= Detail.[intSCInvoiceId]				
	,[strSCInvoiceNumber]			= Detail.[strSCInvoiceNumber]			
	,[intItemUOMId]					= Detail.[intItemUOMId]					
	,[dblQtyOrdered]				= Detail.[dblQtyOrdered]				
	,[dblQtyShipped]				= Detail.[dblQtyShipped]				
	,[dblDiscount]					= Detail.[dblDiscount]					
	,[dblPrice]						= Detail.[dblPrice]						
	,[dblTotalTax]					= Detail.[dblTotalTax]					
	,[dblTotal]						= Detail.[dblTotal]						
	,[intServiceChargeAccountId]	= Detail.[intServiceChargeAccountId]	
	,[intInventoryShipmentItemId]	= Detail.[intInventoryShipmentItemId]	
	,[intSalesOrderDetailId]		= Detail.[intSalesOrderDetailId]		
	,[intSiteId]					= Detail.[intSiteId]					
	,[strBillingBy]                 = Detail.[strBillingBy]                 
	,[dblPercentFull]				= Detail.[dblPercentFull]				
	,[dblNewMeterReading]			= Detail.[dblNewMeterReading]			
	,[dblPreviousMeterReading]		= Detail.[dblPreviousMeterReading]		
	,[dblConversionFactor]			= Detail.[dblConversionFactor]			
	,[intPerformerId]				= Detail.[intPerformerId]				
	,[intContractHeaderId]			= Detail.[intContractHeaderId]			
	,[strMaintenanceType]           = Detail.[strMaintenanceType]           
	,[strFrequency]                 = Detail.[strFrequency]                 
	,[dtmMaintenanceDate]           = Detail.[dtmMaintenanceDate]           
	,[dblMaintenanceAmount]         = Detail.[dblMaintenanceAmount]         
	,[dblLicenseAmount]             = Detail.[dblLicenseAmount]             
	,[intContractDetailId]			= Detail.[intContractDetailId]			
	,[intTicketId]					= Detail.[intTicketId]					
	,[ysnLeaseBilling]				= Detail.[ysnLeaseBilling]				
FROM
	tblARInvoice Header
INNER JOIN
	tblARInvoiceDetail Detail	
		ON Header.[intInvoiceId] = Detail.[intInvoiceId]
WHERE
	Header.[intInvoiceId] = @intInvoiceId