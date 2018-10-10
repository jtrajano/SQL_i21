CREATE VIEW dbo.vyuGRStorageHistory
AS
SELECT 
	 intStorageHistoryId				= SH.intStorageHistoryId
	, intCustomerStorageId				= SH.intCustomerStorageId 
	, intTicketId						= SH.intTicketId
	, intInvoiceId						= SH.intInvoiceId
	, intSettleStorageId				= SH.intSettleStorageId
	, intBillId							= SH.intBillId
	, intContractHeaderId				= SH.intContractHeaderId
	, intDeliverySheetId				= SH.intDeliverySheetId
	, intInventoryShipmentId			= SH.intInventoryShipmentId
	, strType							= SH.strType
	, dblUnits							= SH.dblUnits
	, dtmHistoryDate					= SH.dtmHistoryDate
	, dblPaidAmount						= SH.dblPaidAmount
	, strPaidDescription				= SH.strPaidDescription
	, dblCurrencyRate					= SH.dblCurrencyRate
	, strSettleTicket					= SettleStorage.strStorageTicket
	, strVoucher						= Bill.strBillId
	, intEntityId						= CS.intEntityId  
	, intTransactionTypeId				= SH.intTransactionTypeId
	, strTransferTicket					= TS.strTransferStorageTicket
	, intTransferStorageId				= SH.intTransferStorageId
	, strName							= E.strName
	, intCompanyLocationId				= CS.intCompanyLocationId
	, strLocationName					= LOC.strLocationName
	, strContractNo						= CH.strContractNumber
	, strInvoice						= Inv.strInvoiceNumber
	, strStorageTicket					= CS.strStorageTicketNumber
	, strDeliverySheetNumber			= DS.strDeliverySheetNumber
	, intInventoryReceiptId				= CASE 
	 										WHEN SH.intTransactionTypeId = 1 THEN SH.intInventoryReceiptId 
	 										ELSE NULL 
	 									END
	, strReceiptNumber					= Receipt.strReceiptNumber
	, strShipmentNumber					= Shipment.strShipmentNumber
	, strSplitNumber					= EMSplit.strSplitNumber
	, dblSplitPercent					= CASE
	 										WHEN ISNULL(CS.intDeliverySheetId,0) > 0 THEN ISNULL(SCTicketSplit.dblSplitPercent,100)
	 										ELSE DSSplit.dblSplitPercent
	 									END
	, strUserName						= US.strUserName
	, strScaleTicket					= CASE 
											WHEN ISNULL(CS.intDeliverySheetId,0) > 0 AND SH.intTransactionTypeId = 3 THEN SC.strTicketNumber 
											ELSE NULL 
										END
	, strAdjustmentNo					= IA.strAdjustmentNo
	, intInventoryAdjustmentId			= IA.intInventoryAdjustmentId
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
	ON US.intEntityId = SH.intUserId
LEFT JOIN tblICInventoryAdjustment IA
	ON IA.intInventoryAdjustmentId = SH.intInventoryAdjustmentId
LEFT JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = SH.intTransferStorageId