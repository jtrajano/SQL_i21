CREATE VIEW [dbo].[vyuAPRptCashRequirementDetail]

AS
SELECT DISTINCT
	 strVendorName = E.strName 
	,Item.strDescription
	,CH.strContractNumber
	,strTicketNumber =
		(CASE 
		WHEN IR.intSourceType = 5 --DP
			THEN (SELECT TOP 1 SCD.strDeliverySheetNumber FROM tblSCDeliverySheet SCD WHERE intDeliverySheetId = IRI.intSourceId)
		WHEN IR.intSourceType = 4 --STORAGE
			THEN (SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = IRI.intSourceId)
		WHEN IR.intSourceType IS NULL --LOAD IN
			THEN (SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = GRH.intTicketId)
		ELSE 
			SC.strTicketNumber
		END)	
	, strTicketStatus = (CASE WHEN SC.strTicketStatus = 'C' THEN 'Completed'
							 WHEN SC.strTicketStatus = 'V' THEN 'Voided'
							 WHEN SC.strTicketStatus = 'O' THEN 'Open'
							 WHEN SC.strTicketStatus = 'R' THEN 'Reopen'
							 WHEN SC.strTicketStatus = 'H' THEN 'Hold'
						ELSE ''
						END) COLLATE Latin1_General_CI_AS
	,strSourceType = 
		(CASE 
		 WHEN IR.intSourceType = 5 
		 THEN 'Scale'
		 WHEN IR.intSourceType = 4 
		 THEN 'Settle Storage'
	     WHEN IR.intSourceType = 3 
		 THEN 'Transport'
		 WHEN IR.intSourceType = 2 
		 THEN 'Inboud Shipment' 
		 WHEN IR.intSourceType = 1 
		 THEN 'Scale'
		 WHEN IR.intSourceType IS NULL
		 THEN 'Settlement'
	     ELSE 'None'
		END) COLLATE Latin1_General_CI_AS
	,strLocation = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, NULL, APB.strShipToCity, APB.strShipToState,NULL, NULL, NULL)) COLLATE Latin1_General_CI_AS
	,ISNULL(IR.strReceiptNumber,IR2.strReceiptNumber) AS strReceiptNumber
	,APB.intBillId
	,APB.strBillId
	,strFarmField = EML.strLocationName
	,APB.dtmDueDate
	,ISNULL(IR.dtmCreated,IR2.dtmCreated) as dtmCreated
	,dblNetWeight = (CASE WHEN APBD.intInventoryReceiptChargeId > 0 THEN APBD.dblQtyReceived ELSE  
							(CASE WHEN APBD.intWeightUOMId > 0 THEN APBD.dblNetWeight ELSE APBD.dblQtyReceived END)  END)
		--ISNULL((CASE 
		--WHEN IR.intSourceType = 5 --DS
		--THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR LEFT JOIN tblSCTicket SC ON IRI.intSourceId = SC.intDeliverySheetId )
		--WHEN IR.intSourceType = 4 --OPEN STORAGE
		--THEN (SELECT TOP 1  ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = IRI.intSourceId)
		--WHEN  IR.intSourceType IS NULL
		--THEN (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GRH.intTicketId = SC.intTicketId)  
		--ELSE (SELECT TOP 1 ISNULL(SC.dblGrossWeight,0) - ISNULL(SC.dblTareWeight,0) FROM tblSCTicket SC WHERE intTicketId = IRI.intSourceId)
		--END),0)
	,dblTax = APBD.dblTax
	,dblCharges = ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = APBD.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0)
	,dblTotal = (APBD.dblTotal + APBD.dblTax)
	,GETDATE() as dtmCurrentDate
	,C.strCompanyName
	,strCompanyAddress = dbo.fnConvertToFullAddress(C.strAddress, C.strCity, C.strState,C.strZip) COLLATE Latin1_General_CI_AS
	,ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode
	FROM  tblAPBill APB 
	INNER JOIN tblAPBillDetail APBD 
		ON APB.intBillId = APBD.intBillId 
	INNER JOIN tblICItem Item 
		ON APBD.intItemId = Item.intItemId
	LEFT JOIN tblICCommodity commodity 
		ON Item.intCommodityId = commodity.intCommodityId
	LEFT JOIN tblGRStorageHistory GRH 
		ON GRH.intCustomerStorageId = APBD.intCustomerStorageId AND GRH.strType = 'From Scale'
	LEFT JOIN tblICInventoryReceiptItem IRI 
		ON APBD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt IR 
		ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	LEFT JOIN tblICInventoryReceipt IR2
		ON IR2.intInventoryReceiptId = GRH.intInventoryReceiptId
	LEFT JOIN tblCTContractHeader CH 
		ON APBD.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblAPVendor V 
		ON V.[intEntityId] = APB.intEntityVendorId
	LEFT JOIN tblEMEntity E 
		ON V.[intEntityId] = E.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT 
		ON E.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	LEFT JOIN tblSMCompanySetup C 
		ON C.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM 
		ON APBD.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM 
		ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN vyuSCGetScaleDistribution SD 
		ON IR.intInventoryReceiptId = SD.intInventoryReceiptItemId
	INNER JOIN tblICCommodityUnitMeasure CUM
		ON CUM.intCommodityId = commodity.intCommodityId AND CUM.ysnStockUnit = 1
	LEFT JOIN tblSCTicket SC 
		ON SC.intTicketId = ISNULL(IRI.intSourceId, GRH.intTicketId)
	LEFT JOIN tblEMEntityLocation EML
		ON V.intEntityId = EML.intEntityId and strLocationType = 'Farm' AND EML.intEntityLocationId = SC.intFarmFieldId
	OUTER APPLY (
				SELECT 
					SUM(dblTotal) AS dblTotal,
					SUM(D.dblTax) AS dblTax
				FROM tblAPBillDetail D
				WHERE D.intBillId = APB.intBillId														
			) detailTransaction
	
	WHERE APB.ysnPosted = 1  AND APBD.intItemId IS NOT NULL 
		  AND APBD.intContractHeaderId IS NOT NULL --WILL SHOW ALL CONTRACT RELATED TRANSACTIONS 
		  AND APB.intBillId NOT IN ( --WILL SHOW NOT PAID TRANSACTIONS ONLY
			SELECT A.intBillId FROM [vyuAPBillPayment] A
		  )
	
