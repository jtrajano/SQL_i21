CREATE VIEW dbo.vyuGRStorageHistory
AS
SELECT 
 SH.intStorageHistoryId
,SH.intCustomerStorageId 
,SH.intTicketId
,SH.intInvoiceId
,SH.intSettleStorageId
,SH.intBillId
,SH.intContractHeaderId
,SH.intDeliverySheetId
,SH.intInventoryShipmentId
,SH.strType
,SH.dblUnits
,SH.dtmHistoryDate
,SH.dblPaidAmount
,SH.strPaidDescription
,SH.dblCurrencyRate
,SH.strSettleTicket
,SH.strVoucher
,SH.intEntityId  
,SH.intTransactionTypeId
,SH.strTransferTicket
,E.strName  
,SH.intCompanyLocationId  
,LOC.strLocationName
,strContractNo = CH.strContractNumber
,strInvoice = Inv.strInvoiceNumber
,Bill.strBillId
,SettleStorage.strStorageTicket
,DS.strDeliverySheetNumber
,intInventoryReceiptId  = CASE 
								WHEN SH.intTransactionTypeId = 1 THEN SH.intInventoryReceiptId 
								ELSE NULL 
							END
,strReceiptNumber		= Receipt.strReceiptNumber
,strShipmentNumber      = Shipment.strShipmentNumber
,strSplitNumber			= EMSplit.strSplitNumber
,dblSplitPercent	    = CASE
							WHEN SH.strType <> 'From Delivery Sheet' THEN ISNULL(SCTicketSplit.dblSplitPercent,100)
							ELSE DSSplit.dblSplitPercent
						END
,strUserName			= US.strUserName
,strScaleTicket = CASE WHEN ISNULL(SC.intTicketId,0) > 0 AND intTransactionTypeId = 3 THEN SC.strTicketNumber ELSE NULL END
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
	ON SC.intTicketId = SH.intTicketId
LEFT JOIN tblSCTicketSplit SCTicketSplit
	ON SCTicketSplit.intTicketId = CS.intTicketId AND SCTicketSplit.intCustomerId = CS.intEntityId
LEFT JOIN tblEMEntitySplit EMSplit 
	ON EMSplit.intSplitId = ISNULL(SC.intSplitId,DS.intSplitId)
LEFT JOIN tblSCDeliverySheetSplit DSSplit
	ON DS.intDeliverySheetId = DSSplit.intDeliverySheetId
		AND CS.intEntityId = DSSplit.intEntityId
LEFT JOIN tblSMUserSecurity US
	ON US.intEntityId = SH.intEntityId