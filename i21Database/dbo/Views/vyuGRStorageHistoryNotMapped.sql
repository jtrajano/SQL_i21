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
								WHEN SH.intTransactionTypeId =1 THEN SH.intInventoryReceiptId 
								ELSE NULL 
						  END
,strReceiptNumber		= Receipt.strReceiptNumber
,intInventoryShipmentId = SH.intInventoryShipmentId
,strShipmentNumber      = Shipment.strShipmentNumber 
FROM tblGRStorageHistory SH
LEFT JOIN tblEMEntity E ON E.intEntityId = SH.intEntityId
LEFT JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = SH.intCompanyLocationId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId=SH.intContractHeaderId
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId=SH.intInvoiceId
LEFT JOIN tblAPBill Bill ON Bill.intBillId=SH.intBillId
LEFT JOIN tblGRSettleStorage SettleStorage ON SettleStorage.intSettleStorageId=SH.intSettleStorageId
LEFT JOIN tblSCDeliverySheet DS ON DS.intDeliverySheetId=SH.intDeliverySheetId
LEFT JOIN  tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId=SH.intInventoryReceiptId
LEFT JOIN  tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId=SH.intInventoryShipmentId