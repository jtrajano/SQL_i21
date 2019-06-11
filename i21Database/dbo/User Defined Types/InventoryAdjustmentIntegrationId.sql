CREATE TYPE [dbo].[InventoryAdjustmentIntegrationId] AS TABLE
(
	intInventoryShipmentId int null,
	intInventoryReceiptId int null,
	intTicketId int null,
	intInvoiceId int null,
	intBillId int null
)
