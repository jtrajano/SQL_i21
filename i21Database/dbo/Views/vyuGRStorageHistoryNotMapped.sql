CREATE VIEW [dbo].[vyuGRStorageHistoryNotMapped]
AS
SELECT    
	 intStorageHistoryId	= SH.intStorageHistoryId
	,intEntityId			= SH.intEntityId  
	,strName				= E.strName  
	,intCompanyLocationId	= SH.intCompanyLocationId  
	,strLocationName		= LOC.strLocationName
	,intContractHeaderId	= SH.intContractHeaderId
	,strContractNumber		= CH.strContractNumber
	,intInvoiceId			= SH.intInvoiceId
	,strInvoiceNumber		= Inv.strInvoiceNumber
	,intBillId				= SH.intBillId
	,strBillId				= Bill.strBillId
	,intSettleStorageId		= SH.intSettleStorageId
	,SettleStorageTicket	= SettleStorage.strStorageTicket
	,intDeliverySheetId		= SH.intDeliverySheetId
	,strDeliverySheetNumber = DS.strDeliverySheetNumber
	,intInventoryReceiptId  = CASE 
									WHEN SH.intTransactionTypeId = 1 THEN SH.intInventoryReceiptId 
									ELSE NULL 
							  END
	,strReceiptNumber		= Receipt.strReceiptNumber
	,intInventoryShipmentId = SH.intInventoryShipmentId
	,strShipmentNumber      = Shipment.strShipmentNumber
	,strSplitNumber			= EMSplit.strSplitNumber
	,dblSplitPercent	    = CASE
								WHEN SH.strType <> 'From Delivery Sheet' THEN ISNULL(SCTicketSplit.dblSplitPercent,100)
								ELSE DSSplit.dblSplitPercent
							END
FROM tblGRStorageHistory SH
JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SH.intCustomerStorageId
LEFT JOIN tblEMEntity E
	ON E.intEntityId = SH.intEntityId
LEFT JOIN tblSMCompanyLocation LOC
	ON LOC.intCompanyLocationId = SH.intCompanyLocationId
LEFT JOIN tblCTContractHeader CH
	ON CH.intContractHeaderId = SH.intContractHeaderId
LEFT JOIN tblARInvoice Inv
	ON Inv.intInvoiceId = SH.intInvoiceId
LEFT JOIN tblAPBill Bill
	ON Bill.intBillId = SH.intBillId
LEFT JOIN tblGRSettleStorage SettleStorage 
	ON SettleStorage.intSettleStorageId = SH.intSettleStorageId
LEFT JOIN tblSCDeliverySheet DS 
	ON DS.intDeliverySheetId = SH.intDeliverySheetId
LEFT JOIN tblICInventoryReceipt Receipt 
	ON Receipt.intInventoryReceiptId = SH.intInventoryReceiptId
LEFT JOIN tblICInventoryShipment Shipment
	ON Shipment.intInventoryShipmentId = SH.intInventoryShipmentId
LEFT JOIN tblSCTicket SC
	ON SC.intTicketId = SH.intTicketId AND SH.strType IN('From Scale','From Transfer','From Delivery Sheet')
LEFT JOIN tblSCTicketSplit SCTicketSplit
	ON SCTicketSplit.intTicketId = CS.intTicketId AND SCTicketSplit.intCustomerId = CS.intEntityId --AND SCTicketSplit.intStorageScheduleTypeId=CS.intStorageTypeId
LEFT JOIN tblEMEntitySplit EMSplit 
	ON EMSplit.intSplitId = ISNULL(SC.intSplitId,DS.intSplitId)
	--ON EMSplit.intSplitId = SC.intSplitId
LEFT JOIN tblSCDeliverySheetSplit DSSplit
	ON DS.intDeliverySheetId = DSSplit.intDeliverySheetId
		AND CS.intEntityId = DSSplit.intEntityId