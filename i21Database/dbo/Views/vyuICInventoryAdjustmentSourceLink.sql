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
		strInvoiceNumber = case when a.intInvoiceId is null then inv_backup.strInvoiceNumber else Inv.strInvoiceNumber end,
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
	LEFT JOIN (
			select distinct c.strInvoiceNumber, a.intInventoryShipmentItemId from tblARInvoiceDetail as a				
				join tblARInvoice as c
					on c.intInvoiceId = a.intInvoiceId				
				where a.intInventoryShipmentItemId is not null
	) as inv_backup
		on inv_backup.intInventoryShipmentItemId= invsi.intInventoryShipmentItemId
	LEFT JOIN tblICInventoryReceipt as irs
		on a.intInventoryReceiptId = irs.intInventoryReceiptId




