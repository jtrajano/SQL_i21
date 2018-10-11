CREATE VIEW dbo.vyuGRStorageHistory
AS
SELECT 
	 intStorageHistoryId				= SH.intStorageHistoryId
	, intEntityId						= CS.intEntityId  
	, strName							= E.strName
	, intCompanyLocationId				= CS.intCompanyLocationId
	, strLocationName					= LOC.strLocationName
	, intCustomerStorageId				= SH.intCustomerStorageId 
	, strStorageTicket					= CS.strStorageTicketNumber
	, intTicketId						= SH.intTicketId
	, strScaleTicket					= SC.strTicketNumber
	, intInvoiceId						= SH.intInvoiceId
	, strInvoice						= Inv.strInvoiceNumber
	, intSettleStorageId				= SH.intSettleStorageId
	, strSettleTicket					= SettleStorage.strStorageTicket
	, intBillId							= SH.intBillId
	, strVoucher						= Bill.strBillId
	, intContractHeaderId				= SH.intContractHeaderId
	, strContractNo						= CH.strContractNumber
	, intDeliverySheetId				= SH.intDeliverySheetId
	, strDeliverySheetNumber			= DS.strDeliverySheetNumber
	, intInventoryShipmentId			= SH.intInventoryShipmentId
	, strShipmentNumber					= Shipment.strShipmentNumber	
	, intTransactionTypeId				= SH.intTransactionTypeId
	, strTransferTicket					= TS.strTransferStorageTicket
	, intTransferStorageId				= SH.intTransferStorageId
	, intInventoryReceiptId				= CASE 
	 										WHEN SH.intTransactionTypeId = 1 OR SH.intTransactionTypeId = 5 THEN SC.intInventoryReceiptId 
	 										ELSE NULL 
	 									END
	, strReceiptNumber					= Receipt.strReceiptNumber
	, intInventoryAdjustmentId			= IA.intInventoryAdjustmentId
	, strAdjustmentNo					= IA.strAdjustmentNo
	, strSplitNumber					= EMSplit.strSplitNumber
	, dblSplitPercent					= CASE
	 										WHEN ISNULL(CS.intDeliverySheetId,0) > 0 THEN DSSplit.dblSplitPercent
	 										ELSE ISNULL(SCTicketSplit.dblSplitPercent,100)
	 									END
	, strUserName						= US.strUserName	
	, strType							= SH.strType
	, dblUnits							= SH.dblUnits
	, dtmHistoryDate					= SH.dtmHistoryDate
	, dblPaidAmount						= ISNULL(SH.dblPaidAmount, 0)
	, strPaidDescription				= SH.strPaidDescription
	, dblCurrencyRate					= SH.dblCurrencyRate	
FROM tblGRStorageHistory SH
JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SH.intCustomerStorageId
LEFT JOIN tblEMEntity E
	ON E.intEntityId = CS.intEntityId
LEFT JOIN tblSMCompanyLocation LOC
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId
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
LEFT JOIN tblICInventoryShipment Shipment
	ON Shipment.intInventoryShipmentId = SH.intInventoryShipmentId
LEFT JOIN tblSCTicket SC
	ON SC.intTicketId = SH.intTicketId
LEFT JOIN tblSCTicketSplit SCTicketSplit
	ON SCTicketSplit.intTicketId = CS.intTicketId 
		AND SCTicketSplit.intCustomerId = CS.intEntityId
LEFT JOIN tblICInventoryReceipt Receipt 
	ON Receipt.intInventoryReceiptId = SC.intInventoryReceiptId
LEFT JOIN tblEMEntitySplit EMSplit 
	ON EMSplit.intSplitId = ISNULL(SC.intSplitId,DS.intSplitId)
LEFT JOIN tblSCDeliverySheetSplit DSSplit
	ON DS.intDeliverySheetId = DSSplit.intDeliverySheetId
		AND CS.intEntityId = DSSplit.intEntityId
LEFT JOIN tblSMUserSecurity US
	ON US.intEntityId = SH.intUserId
LEFT JOIN tblICInventoryAdjustment IA
	ON IA.intInventoryAdjustmentId = SH.intInventoryAdjustmentId
LEFT JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = SH.intTransferStorageId