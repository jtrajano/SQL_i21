CREATE VIEW dbo.vyuGRStorageHistory
AS
SELECT DISTINCT TOP 100 PERCENT
	 intStorageHistoryId				= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN (SELECT top 1 intStorageHistoryId FROM tblGRStorageHistory WHERE intCustomerStorageId = TSplit.intTransferToCustomerStorageId AND strType = 'From Transfer')
											ELSE SH.intStorageHistoryId
										END
	,intEntityId						= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN TSplit.intEntityId
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN TSource.intEntityId
											ELSE CS.intEntityId
										END
	,strName							= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN TSplit.strEntityName
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN TSource.strName
											ELSE E.strName
										END COLLATE Latin1_General_CI_AS
	,intCompanyLocationId				= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN TSplit.intCompanyLocationId
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN TSource.intCompanyLocationId
											ELSE CS.intCompanyLocationId
										END
	,strLocationName					= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN TSplit.strLocationName
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN TSource.strLocationName
											ELSE LOC.strLocationName
										END
	,intCustomerStorageId				= SH.intCustomerStorageId
	,intTransferCustomerStorageId		= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN CASE WHEN CSTO.intCustomerStorageId IS NOT NULL THEN CSTO.intCustomerStorageId ELSE  TSplit.intTransferToCustomerStorageId END
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN CASE WHEN CSFRM.intCustomerStorageId IS NOT NULL THEN CSFRM.intCustomerStorageId ELSE TSource.intSourceCustomerStorageId END
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Reversed Transfer' THEN CSTO.intCustomerStorageId
											ELSE NULL
										END
	,strStorageTicket					= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN CASE WHEN CSTO.intCustomerStorageId IS NOT NULL THEN CSTO.strStorageTicketNumber ELSE TSplit.strStorageTicketNumber END
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN CASE WHEN CSFRM.intCustomerStorageId IS NOT NULL THEN CSFRM.strStorageTicketNumber ELSE TSource.strStorageTicketNumber END
											ELSE CS.strStorageTicketNumber
										END
	,intTicketId						= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN NULL
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN CS.intTicketId
											ELSE SH.intTicketId
										END
	,strScaleTicket						= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN NULL
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN (SELECT strTicketNumber FROM tblSCTicket WHERE intTicketId = CS.intTicketId)
											ELSE SC.strTicketNumber
										END
	,intInvoiceId						= SH.intInvoiceId
	,strInvoice							= Inv.strInvoiceNumber
	,intSettleStorageId					= SH.intSettleStorageId
	,strSettleTicket					= SH.strSettleTicket
	,intBillId							= SH.intBillId
	,strVoucher							= SH.strVoucher
	,intContractHeaderId				= SH.intContractHeaderId
	,strContractNo						= CH.strContractNumber
	,intDeliverySheetId					= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN NULL
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN CS.intDeliverySheetId
											ELSE SH.intDeliverySheetId
										END
	,strDeliverySheetNumber				= CASE 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN NULL
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN (SELECT strDeliverySheetNumber FROM tblSCDeliverySheet WHERE intDeliverySheetId = CS.intDeliverySheetId)
											ELSE DS.strDeliverySheetNumber
										END
	,intInventoryShipmentId				= SH.intInventoryShipmentId
	,strShipmentNumber					= Shipment.strShipmentNumber	
	,intTransactionTypeId				= SH.intTransactionTypeId
	,strTransferTicket					= (SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = SH.intTransferStorageId)
	,intTransferStorageId				= SH.intTransferStorageId
	,intInventoryReceiptId				= CASE 
	 										WHEN SH.intTransactionTypeId = 1 OR SH.intTransactionTypeId = 5 THEN SH.intInventoryReceiptId 
	 										ELSE NULL 
	 									END
	,strReceiptNumber					= Receipt.strReceiptNumber
	,intInventoryAdjustmentId			= IA.intInventoryAdjustmentId
	,strAdjustmentNo					= IA.strAdjustmentNo
	,strSplitNumber						= EMSplit.strSplitNumber
	,dblSplitPercent					= CASE
	 										WHEN ISNULL(CS.intDeliverySheetId,0) > 0 THEN DSSplit.dblSplitPercent
	 										WHEN ISNULL(SCTicketSplit.dblSplitPercent,0) > 0 THEN SCTicketSplit.dblSplitPercent
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN TSplit.dblSplitPercent
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN (SELECT dblSplitPercent FROM tblGRTransferStorageSplit WHERE intTransferToCustomerStorageId = CS.intCustomerStorageId AND intTransferStorageId = SH.intTransferStorageId)
											ELSE 100
	 									END
	,strUserName						= US.strUserName	
	,strType							= SH.strType
	,dblUnits							= CASE
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'Transfer' THEN   -(ISNULL(TSR.dblUnitQty,TSplit.dblUnits)) 
											WHEN SH.intTransactionTypeId = 3 AND SH.strType = 'From Transfer' THEN CS.dblOriginalBalance
											ELSE SH.dblUnits
	 									END
	,dtmHistoryDate						= CASE 
											WHEN SH.strType = 'Invoice' OR SH.strType = 'Generated Storage Invoice' THEN SH.dtmDistributionDate
											ELSE SH.dtmHistoryDate
										END
	,dblPaidAmount						= case when ISNULL(CH.intPricingTypeId, 0) = 2 then 0 else ISNULL(SH.dblPaidAmount,0) end
	,strPaidDescription					= CASE 
											WHEN SH.intTransactionTypeId = 3 THEN SH.strType 
											ELSE ISNULL(SH.strPaidDescription,SH.strType) 
										END
	,dblCurrencyRate					= SH.dblCurrencyRate
	,SH.strTransactionId
	,REPLACE(STUFF
	(
		(
			SELECT ', ' + B.strBillId
			FROM tblGRSettleStorageBillDetail SSB
				INNER JOIN tblAPBill B ON B.intBillId = SSB.intBillId
			WHERE SSB.intSettleStorageId = SH.intSettleStorageId
			GROUP BY SSB.intSettleStorageId, B.strBillId
			FOR xml path('')
		)
	, 1
	, 1
	, ''
	), ' ', '')  COLLATE Latin1_General_CI_AS AS  strVoucherNumbers
	,REPLACE(STUFF
	(
		(
			SELECT ', ' + CONVERT(NVARCHAR(20), B.intBillId)
			FROM tblGRSettleStorageBillDetail SSB
				INNER JOIN tblAPBill B ON B.intBillId = SSB.intBillId
			WHERE SSB.intSettleStorageId = SH.intSettleStorageId
			GROUP BY SSB.intSettleStorageId, B.intBillId
			FOR xml path('')
		)
	, 1
	, 1
	, ''
	), ' ', '')  COLLATE Latin1_General_CI_AS AS strBillIds  
	,SH.intUserId
	,SH.dtmDistributionDate
FROM tblGRStorageHistory SH
JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SH.intCustomerStorageId
JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
LEFT JOIN tblEMEntity E
	ON E.intEntityId = CS.intEntityId
LEFT JOIN tblSMCompanyLocation LOC
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId
LEFT JOIN tblCTContractHeader CH
	ON CH.intContractHeaderId = SH.intContractHeaderId
LEFT JOIN tblARInvoice Inv
	ON Inv.intInvoiceId = SH.intInvoiceId
--LEFT JOIN tblAPBill Bill
--	ON Bill.intBillId = SH.intBillId
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
	ON Receipt.intInventoryReceiptId = SH.intInventoryReceiptId
LEFT JOIN tblEMEntitySplit EMSplit 
	ON EMSplit.intSplitId = ISNULL(SC.intSplitId,DS.intSplitId)
LEFT JOIN tblSCDeliverySheetSplit DSSplit
	ON DS.intDeliverySheetId = DSSplit.intDeliverySheetId
		AND DSSplit.intEntityId = CS.intEntityId
		AND DSSplit.intStorageScheduleTypeId = CS.intStorageTypeId
		AND DSSplit.intStorageScheduleRuleId = CS.intStorageScheduleId
LEFT JOIN tblSMUserSecurity US
	ON US.intEntityId = SH.intUserId
LEFT JOIN tblICInventoryAdjustment IA
	ON IA.intInventoryAdjustmentId = SH.intInventoryAdjustmentId
LEFT JOIN vyuGRTransferStorageSourceSplit TSource
	ON TSource.intTransferStorageId = SH.intTransferStorageId
LEFT JOIN vyuGRTransferStorageSplit TSplit
	ON TSplit.intTransferStorageId = SH.intTransferStorageId
--LEFT JOIN 
LEFT JOIN (
	tblGRTransferStorageReference TSR
	JOIN tblGRCustomerStorage CSFRM
		ON CSFRM.intCustomerStorageId = TSR.intSourceCustomerStorageId
	JOIN tblGRCustomerStorage CSTO
		ON CSTO.intCustomerStorageId = TSR.intToCustomerStorageId
) ON CASE WHEN SH.strType = 'From Transfer' OR SH.strType = 'Reversed Transfer'
	    THEN 
			  CASE WHEN TSR.intToCustomerStorageId  = CS.intCustomerStorageId AND CSTO.intCustomerStorageId = CS.intCustomerStorageId  THEN 1
				  WHEN TSR.intToCustomerStorageId  = CS.intCustomerStorageId AND CSFRM.intCustomerStorageId = CS.intCustomerStorageId  THEN 1
				  WHEN TSR.intToCustomerStorageId  = CS.intCustomerStorageId THEN 0 
				  ELSE 0 
			 END 
	    ELSE 
			 CASE WHEN CSFRM.intCustomerStorageId = CS.intCustomerStorageId  AND CSTO.intCustomerStorageId = TSplit.intTransferToCustomerStorageId THEN 1 				  
				  WHEN CSFRM.intCustomerStorageId = CS.intCustomerStorageId AND TSR.intTransferStorageSplitId = TSplit.intTransferStorageSplitId THEN  1
				  WHEN CSFRM.intCustomerStorageId = CS.intCustomerStorageId THEN 0
				  ELSE 0 

			 END 
   END 
	=1
