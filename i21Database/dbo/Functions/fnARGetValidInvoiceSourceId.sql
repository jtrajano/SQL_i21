﻿CREATE FUNCTION [dbo].[fnARGetValidInvoiceSourceId]
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

-- 2. "Invoice", "Provisional Invoice", 	
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
IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId AND ISNULL([intSiteId], 0) <> 0)
	RETURN 11			
	

	RETURN @SourceId
END



