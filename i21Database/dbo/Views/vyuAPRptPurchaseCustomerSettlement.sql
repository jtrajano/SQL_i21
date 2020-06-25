CREATE VIEW [dbo].[vyuAPRptPurchaseCustomerSettlement]

AS
	SELECT
	BNKTRN.intBankAccountId,
	BNKTRN.intTransactionId,
	BNKTRN.strTransactionId,
	strCompanyName = COMPANY.strCompanyName,
	strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState,COMPANY.strZip) COLLATE Latin1_General_CI_AS,
	Item.strItemNo,
	strCommodity = (SELECT strCommodityCode FROM tblICCommodity WHERE intCommodityId = Item.intCommodityId),
	dtmPaymentDate = PYMT.dtmDatePaid,
	strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber) COLLATE Latin1_General_CI_AS ,
	strCheckNo = BNKTRN.strReferenceNo,
	strVendorName = ENTITY.strName,
	strVendorAddress = dbo.fnConvertToFullAddress(NULL, Bill.strShipFromCity, Bill.strShipFromState, NULL) COLLATE Latin1_General_CI_AS,
	intTicketId = 
		(CASE 
		WHEN INVRCPT.intSourceType IS NULL 
			THEN (SELECT TOP 1 SC.intTicketId FROM tblSCTicket SC WHERE intTicketId = GRH.intTicketId)
		ELSE INVRCPTITEM.intSourceId
		END),
	strTicketNumber =
		(CASE 
		WHEN INVRCPT.intSourceType = 5 
			THEN (SELECT TOP 1 SCD.strDeliverySheetNumber FROM tblSCDeliverySheet SCD WHERE intDeliverySheetId = INVRCPTITEM.intSourceId)
		WHEN INVRCPT.intSourceType = 4 
			THEN (SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		WHEN INVRCPT.intSourceType IS NULL 
			THEN (SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = GRH.intTicketId)
		ELSE 
		(SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	INVRCPT.strReceiptNumber,
	INVRCPTITEM.intInventoryReceiptItemId,
	Bill.strBillId as RecordId,
	strSourceType = 
		(CASE 
		 WHEN INVRCPT.intSourceType = 5 
		 THEN 'Scale'
		 WHEN INVRCPT.intSourceType = 4 
		 THEN 'Settle Storage'
	     WHEN INVRCPT.intSourceType = 3 
		 THEN 'Transport'
		 WHEN INVRCPT.intSourceType = 2 
		 THEN 'Inboud Shipment' 
		 WHEN INVRCPT.intSourceType = 1 
		 THEN 'Scale'
		 WHEN INVRCPT.intSourceType IS NULL
		 THEN 'Settlement'
	     ELSE 'None'
		END) COLLATE Latin1_General_CI_AS,
	strSplitNumber = 
		(CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
			WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblSCTicket SC
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0 
			WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	strCustomerReference = (CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1  SC.strCustomerReference  FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strCustomerReference FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	strTicketComment = (CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1  SC.strTicketComment  FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strTicketComment FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	strFarmField = (CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT strFarmNumber + '\' + strFieldNumber FROM tblEMEntityFarm WHERE intEntityId = VENDOR.intEntityId AND intFarmFieldId = (SELECT TOP 1 ISNULL(SC.intFarmFieldId,0) FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId 
			WHERE intCustomerStorageId = INVRCPTITEM.intSourceId))
		ELSE
		(SELECT strFarmNumber + '\' + strFieldNumber FROM tblEMEntityFarm WHERE intEntityId = VENDOR.intEntityId AND intFarmFieldId = (SELECT TOP 1 ISNULL(SC.intFarmFieldId,0) FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId))
		END),
	dtmBillDate = Bill.dtmDate,
	dblGrossWeight =
		(CASE 
		WHEN INVRCPT.intSourceType = 5  --DS
		THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) FROM tblGRCustomerStorage GR LEFT JOIN tblSCTicket SC ON INVRCPTITEM.intSourceId = SC.intDeliverySheetId )
		WHEN INVRCPT.intSourceType = 4  --OPEN STORAGE
		THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		WHEN  INVRCPT.intSourceType IS NULL
		THEN  (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GRH.intTicketId = SC.intTicketId)    
		ELSE (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	dblTareWeight = 
		(CASE 
		WHEN INVRCPT.intSourceType = 5 --DS
		THEN (SELECT TOP 1 ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR LEFT JOIN tblSCTicket SC ON INVRCPTITEM.intSourceId = SC.intDeliverySheetId )
		WHEN INVRCPT.intSourceType = 4 --OPEN STORAGE
		THEN (SELECT TOP 1 ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)	
		WHEN  INVRCPT.intSourceType IS NULL
		THEN  (SELECT TOP 1 ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GRH.intTicketId = SC.intTicketId)    
		ELSE (SELECT TOP 1 ISNULL(SC.dblTareWeight,0) FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	dblNetWeight = 
		(CASE 
		WHEN INVRCPT.intSourceType = 5 --DS
		THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR LEFT JOIN tblSCTicket SC ON INVRCPTITEM.intSourceId = SC.intDeliverySheetId )
		WHEN INVRCPT.intSourceType = 4 --OPEN STORAGE
		THEN (SELECT TOP 1  ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		WHEN  INVRCPT.intSourceType IS NULL
		THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GRH.intTicketId = SC.intTicketId)  
		ELSE (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END),
	BillDtl.dblCost,
	BillDtl.dblQtyOrdered as Net,
	UOM.strUnitMeasure,
	BillDtl.dblTotal,
	BillDtl.dblTax,
	CNTRCT.strContractNumber,
	TotalDiscount = ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0),
	NetDue = (BillDtl.dblTotal + BillDtl.dblTax) ,
	Bill.strBillId as strId,
	PYMT.intPaymentId,
	PYMT.dblAmountPaid as CheckAmount,
	CASE WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL 
		THEN 'True'
		ELSE 'False'
		END COLLATE Latin1_General_CI_AS as IsAdjustment 
	FROM tblCMBankTransaction BNKTRN
	INNER JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId =  PYMT.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId --AND BillDtl.intInventoryReceiptChargeId is null
	INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
	LEFT JOIN tblGRStorageHistory GRH ON GRH.intCustomerStorageId = BillDtl.intCustomerStorageId AND GRH.strType = 'From Scale'
	LEFT JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--LEFT JOIN dbo.tblSCDeliverySheet SS ON SS.intDeliverySheetId = INVRCPTITEM.intSourceId
	OUTER APPLY (
				SELECT 
					SUM(dblTotal) AS dblTotal,
					SUM(D.dblTax) AS dblTax
				FROM tblAPBillDetail D
				WHERE D.intBillId = Bill.intBillId														
			) detailTransaction
	WHERE Bill.ysnPosted = 1
	UNION ALL 
	
	SELECT
	BNKTRN.intBankAccountId,
	BNKTRN.intTransactionId,
	BNKTRN.strTransactionId,
	strCompanyName = COMPANY.strCompanyName,
	strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState,COMPANY.strZip),
	Item.strItemNo,
	strCommodity = (SELECT strCommodityCode FROM tblICCommodity WHERE intCommodityId = Item.intCommodityId),
	dtmPaymentDate = PYMT.dtmDatePaid,
	strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber),
	strCheckNo = BNKTRN.strReferenceNo,
	strVendorName = ENTITY.strName,
	strVendorAddress = '',
	intTicketId =
		(CASE WHEN INVSHIP.intSourceType = 4 
		THEN (SELECT TOP 1 SC.intTicketId FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE (SELECT TOP 1 SC.intTicketId FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	strTicketNumber =
		(CASE WHEN INVSHIP.intSourceType = 4 
		THEN (SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE (SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	INVSHIP.strShipmentNumber,
	strReceiptNumber = 0,
	INV.strInvoiceNumber as RecordId,
	CASE
		WHEN 
		INVSHIP.intSourceType = 5 THEN 
		'Scale'
		WHEN 
		INVSHIP.intSourceType = 4 THEN
		'Settle Storage'
		WHEN INVSHIP.intSourceType = 3 THEN
		'Transport'
		WHEN INVSHIP.intSourceType = 2 THEN
		'Inboud Shipment' 
		WHEN INVSHIP.intSourceType = 1 THEN
		'Scale'
		WHEN INVSHIP.intSourceType IS NULL
		 THEN 'Settlement'
		ELSE
		'None'
		END AS strSourceType,
	strSplitNumber = 
		(CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
			WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblSCTicket SC
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0 
			WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	strCustomerReference =
		(CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  SC.strCustomerReference  FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strCustomerReference FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	strTicketComment = 
		(CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  SC.strTicketComment  FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strTicketComment FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	strFarmField = 
		(CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT strFarmNumber + '\' + strFieldNumber FROM tblEMEntityFarm WHERE intEntityId = VENDOR.intEntityId AND intFarmFieldId = (SELECT TOP 1 ISNULL(SC.intFarmFieldId,0) FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId 
			WHERE intCustomerStorageId = INVSHIPITEM.intSourceId))
		ELSE
		(SELECT TOP 1 strFarmNumber + '\' + strFieldNumber FROM tblEMEntityFarm WHERE intEntityId = VENDOR.intEntityId AND intFarmFieldId = (SELECT TOP 1 ISNULL(SC.intFarmFieldId,0) FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId))
		END),
	dtmBillDate = INV.dtmDate,
	dblGrossWeight = 
		(CASE WHEN INVSHIP.intSourceType = 4 
		THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),

	dblTareWeight = 
		(CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 ISNULL(SC.dblTareWeight,0) FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	dblNetWeight =
		(CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END),
	INVDTL.dblPrice as dblCost,
	INVDTL.dblQtyShipped as Net,
	UOM.strUnitMeasure,
	INVDTL.dblTotal,
	INVDTL.dblTotalTax,
	CNTRCT.strContractNumber,
	TotalDiscount = ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0),
	NetDue = (INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)),
	INV.strInvoiceNumber as strId,
	PYMT.intPaymentId,
	PYMT.dblAmountPaid as CheckAmount,
	CASE WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL 
		THEN 'True' 
		ELSE 'False'
		END as IsAdjustment
	FROM tblCMBankTransaction BNKTRN
	INNER JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId =  PYMT.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	INNER JOIN tblARInvoice INV ON PYMTDTL.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblARInvoiceDetail INVDTL ON INV.intInvoiceId = INVDTL.intInvoiceId  AND INVDTL.intInventoryShipmentChargeId is null
	INNER JOIN tblICItem Item ON INVDTL.intItemId = Item.intItemId
	LEFT JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVDTL.intInventoryShipmentItemId = INVSHIPITEM.intInventoryShipmentItemId
	LEFT JOIN tblICInventoryShipment INVSHIP ON INVSHIPITEM.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
	LEFT JOIN tblCTContractHeader CNTRCT ON INVDTL.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON INVDTL.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId