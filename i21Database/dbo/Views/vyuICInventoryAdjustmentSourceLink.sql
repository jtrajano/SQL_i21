CREATE VIEW [dbo].[vyuICInventoryAdjustmentSourceLink]
	AS 
	
	select 
		a.intInventoryAdjustmentId, 
		a.intSourceId, 
		a.intSourceTransactionTypeId,
		b.strName,
		strTransactionFrom =  b.strTransactionForm,
		strSource = c.strDeliverySheetNumber,

		strTicketNumber = Sc.strTicketNumber,
		strInvoiceNumber = Inv.strInvoiceNumber,
		strShipmentNumber = invs.strShipmentNumber,
		strReceiptNumber = irs.strReceiptNumber		

	 from tblICInventoryAdjustment a
	join tblICInventoryTransactionType b
		on a.intSourceTransactionTypeId = b.intTransactionTypeId
	left join (
		select intDeliverySheetId, strDeliverySheetNumber from tblSCDeliverySheet
	) c
		on b.intTransactionTypeId = 53 and c.intDeliverySheetId = a.intSourceId
	LEFT JOIN tblSCTicket as Sc
		on a.intTicketId = Sc.intTicketId
	LEFT JOIN tblARInvoice as Inv 
		on Inv.intInvoiceId = a.intInvoiceId 
	LEFT JOIN tblICInventoryShipment as invs
		on a.intInventoryShipmentId = invs.intInventoryShipmentId
	LEFT JOIN tblICInventoryShipmentItem as invsi
		on invsi.intInventoryShipmentId = invs.intInventoryShipmentId	
	LEFT JOIN tblICInventoryReceipt as irs
		on a.intInventoryReceiptId = irs.intInventoryReceiptId




