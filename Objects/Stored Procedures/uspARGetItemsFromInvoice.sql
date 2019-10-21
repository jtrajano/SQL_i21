CREATE PROCEDURE [dbo].[uspARGetItemsFromInvoice]
	  @intInvoiceId 	INT
	, @forContract 		BIT = 0
	, @InvoiceIds		InvoiceId READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @InvoiceIdToProcess	InvoiceId

IF ISNULL(@intInvoiceId, 0) <> 0 AND NOT EXISTS(SELECT TOP 1 NULL FROM @InvoiceIds)
	BEGIN
		INSERT INTO @InvoiceIdToProcess(intHeaderId)
		SELECT @intInvoiceId
	END
ELSE
	BEGIN
		INSERT INTO @InvoiceIdToProcess(intHeaderId)
		SELECT DISTINCT intHeaderId 
		FROM @InvoiceIds
	END	

SELECT [intInvoiceId]						= I.[intInvoiceId]
	, [strInvoiceNumber]					= I.[strInvoiceNumber]
	, [intEntityCustomerId]					= I.[intEntityCustomerId]
	, [strTransactionType]					= I.[strTransactionType]
	, [dtmDate]								= I.[dtmDate]
	, [intCurrencyId]						= I.[intCurrencyId]
	, [intCompanyLocationId]				= I.[intCompanyLocationId]
	, [intDistributionHeaderId]				= I.[intDistributionHeaderId]
	, [intTransactionId]					= I.[intTransactionId]	  
	-- Detail 
	, [intInvoiceDetailId]					= ID.[intInvoiceDetailId]			
	, [intItemId]							= ID.[intItemId]		
	, [strItemNo]							= II.[strItemNo]
	, [strItemDescription]					= ID.[strItemDescription]			
	, [intSCInvoiceId]						= ID.[intSCInvoiceId]				
	, [strSCInvoiceNumber]					= ID.[strSCInvoiceNumber]			
	, [intItemUOMId]						= ID.[intItemUOMId]					
	, [dblQtyOrdered]						= ID.[dblQtyOrdered]				
	, [dblQtyShipped]						= ID.[dblQtyShipped]				
	, [dblDiscount]							= ID.[dblDiscount]					
	, [dblPrice]							= ID.[dblPrice]						
	, [dblTotalTax]							= ID.[dblTotalTax]					
	, [dblTotal]							= ID.[dblTotal]						
	, [intServiceChargeAccountId]			= ID.[intServiceChargeAccountId]	
	, [intInventoryShipmentItemId]			= ID.[intInventoryShipmentItemId]	
	, [intSalesOrderDetailId]				= ID.[intSalesOrderDetailId]
	, [intShipmentPurchaseSalesContractId]	= ID.[intShipmentPurchaseSalesContractId]		
	, [intSiteId]							= ID.[intSiteId]					
	, [strBillingBy]						= ID.[strBillingBy]                 
	, [dblPercentFull]						= ID.[dblPercentFull]				
	, [dblNewMeterReading]					= ID.[dblNewMeterReading]			
	, [dblPreviousMeterReading]				= ID.[dblPreviousMeterReading]		
	, [dblConversionFactor]					= ID.[dblConversionFactor]			
	, [intPerformerId]						= ID.[intPerformerId]				
	, [intContractHeaderId]					= ID.[intContractHeaderId]
	, [strContractNumber]					= CH.[strContractNumber]
	, [strMaintenanceType]					= ID.[strMaintenanceType]           
	, [strFrequency]						= ID.[strFrequency]                 
	, [dtmMaintenanceDate]					= ID.[dtmMaintenanceDate]           
	, [dblMaintenanceAmount]				= ID.[dblMaintenanceAmount]         
	, [dblLicenseAmount]					= ID.[dblLicenseAmount]             
	, [intContractDetailId]					= ID.[intContractDetailId]			
	, [intTicketId]							= ID.[intTicketId]
	, [intTicketHoursWorkedId]				= ID.[intTicketHoursWorkedId]
	, [intCustomerStorageId]				= ID.[intCustomerStorageId]
	, [intSiteDetailId]						= ID.[intSiteDetailId]
	, [intLoadDetailId]						= ID.[intLoadDetailId]
	, [intOriginalInvoiceDetailId]			= ID.[intOriginalInvoiceDetailId]
	, [ysnLeaseBilling]						= ID.[ysnLeaseBilling]				
FROM tblARInvoice I
INNER JOIN @InvoiceIdToProcess INVOICEIDS ON I.intInvoiceId = INVOICEIDS.intHeaderId
INNER JOIN tblARInvoiceDetail ID ON I.[intInvoiceId] = ID.[intInvoiceId]
LEFT JOIN tblICItem II ON ID.intItemId = II.intItemId
LEFT JOIN tblCTContractHeader CH ON ID.intContractHeaderId = CH.intContractHeaderId
WHERE I.strType NOT IN ('CF Tran', 'Transport Delivery')
  AND (ISNULL(@forContract,0) = 0
	   OR
			(
				ISNULL(@forContract,0) = 1
				AND
				ID.[intInventoryShipmentItemId] IS NULL
				AND
				ID.[intInventoryShipmentChargeId] IS NULL
				AND
				I.strTransactionType <> 'Credit Memo'
			)
	  )