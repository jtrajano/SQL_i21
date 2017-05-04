CREATE FUNCTION [dbo].[fnARGetValidInvoiceSourceId]
(
	@InvoiceId	INT
)
RETURNS INT
AS
BEGIN

-- 0. "Direct"
DECLARE @SourceId INT = 0

-- 1. "Sales Order"
IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intSalesOrderDetailId],0) <> 0)
AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intInventoryShipmentItemId],0) <> 0)
	RETURN 2

-- 2. "Invoice", "Provisional", 	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intOriginalInvoiceId],0) <> 0)
AND EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intOriginalInvoiceDetailId],0) <> 0)
	RETURN 2	
	
-- 3. "Transport Load"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND (ISNULL([intDistributionHeaderId], 0) <> 0 OR ISNULL([intLoadDistributionHeaderId],0) <> 0))
	RETURN 3
	
-- 4. "Inbound Shipment"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL(intShipmentId, 0) <> 0)
--AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intInventoryShipmentItemId],0) <> 0)
	RETURN 4		
	
-- 5. "Inventory Shipment"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL(intShipmentId, 0) <> 0)
OR EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intInventoryShipmentItemId],0) <> 0)
	RETURN 5	
	
-- 6. "Card Fueling Transaction"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intTransactionId], 0) <> 0)
	RETURN 6	
	
-- 7. "Transfer Storage"
-- 8. "Sale OffSite"
-- 9. "Settle Storage"
-- 10. "Process Grain Storage"
-- 11. "Consumption Site"
IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intCustomerStorageId], 0) <> 0)
	RETURN 7	

-- 11. "Consumption Site"
IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intSiteId], 0) <> 0)
	RETURN 11	
	
-- 12. "Meter Billing"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intMeterReadingId], 0) <> 0)
	RETURN 12		
	
-- 13. "Load/Shipment Schedules"
IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intLoadDetailId], 0) <> 0)
	RETURN 13
	
-- 14. "Credit Card Reconciliation"
IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intSiteDetailId], 0) <> 0)
	RETURN 14

-- 15. "Sales Contract"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intContractHeaderId], 0) <> 0)
	RETURN 15

-- 16. "Load Schedule"
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intLoadId], 0) <> 0)
	RETURN 16
						
	

	RETURN @SourceId
END



