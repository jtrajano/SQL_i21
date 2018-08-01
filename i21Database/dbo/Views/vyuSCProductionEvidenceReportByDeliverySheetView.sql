CREATE VIEW [dbo].[vyuSCProductionEvidenceReportByDeliverySheetView]
AS 
SELECT 
	SCD.intDeliverySheetId
	,SCD.strDeliverySheetNumber
	,SCD.dtmDeliverySheetDate
	,SCD.intCompanyLocationId
	,SCD.intEntityId
	,SCD.strCountyProducer
	,EMEntity.strName
	,EMLocation.strAddress
	,EMLocation.strCity
	,EMLocation.strCountry
	,EMLocation.strPhone
	
	,EMSplit.strSplitNumber
	
	,IC.strCommodityCode
	
	,EMHauler.strName AS strHaulerName

	,QM.strDiscountCode
	,QM.dblGradeReading
	
	,ReceiptItem.intInventoryReceiptId
	,ReceiptItem.strReceiptNumber
	,ReceiptItem.dtmReceiptDate
	,ReceiptItem.strDistributionType

	,SMCompanyLoc.strLocationName
	,tblSMCompanySetup.strCompanyName
	,tblSMCompanySetup.strCompanyAddress
	,tblSMCompanySetup.strCompanyPhone
	,tblSMCompanySetup.strCompanyCity
	,tblSMCompanySetup.strCompanyCountry
	,CompanyPref.intCurrencyDecimal
FROM tblSCDeliverySheet SCD
INNER JOIN (
	SELECT ICI.intItemId
		,ICI.strItemNo
		,ICC.intCommodityId
		,ICC.strCommodityCode
	FROM tblICItem ICI 
	INNER JOIN tblICCommodity ICC ON ICC.intCommodityId = ICI.intCommodityId
) IC ON IC.intItemId = SCD.intItemId
INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
INNER JOIN tblEMEntity EMEntity on EMEntity.intEntityId = SCDS.intEntityId
INNER JOIN tblEMEntityLocation EMLocation ON EMLocation.intEntityId = SCD.intEntityId AND EMLocation.ysnDefaultLocation = 1
INNER JOIN tblEMEntitySplit EMSplit on EMSplit.intSplitId = SCD.intSplitId
INNER JOIN tblSMCompanyLocation SMCompanyLoc on SMCompanyLoc.intCompanyLocationId = SCD.intCompanyLocationId
INNER JOIN tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = SCD.intDiscountId
INNER JOIN (
	SELECT 
	IRI.intInventoryReceiptItemId
	,IRI.intInventoryReceiptId
	,IR.strReceiptNumber
	,IR.dtmReceiptDate
	,SCD.intDeliverySheetId
	,(
		CASE 
			WHEN CTD.intContractDetailId > 0 AND CTD.intPricingTypeId != 5 THEN -2
			WHEN ISNULL(CTD.intContractDetailId,0) = 0 AND IRI.intOwnershipType = 1 THEN -3
			ELSE GRT.intStorageScheduleTypeId 
		END
	) AS intStorageScheduleTypeId
	,(
		CASE 
			WHEN CTD.intContractDetailId > 0 AND CTD.intPricingTypeId != 5 THEN 'CNT'
			WHEN ISNULL(CTD.intContractDetailId,0) = 0 AND IRI.intOwnershipType = 1 THEN 'SPT'
			ELSE GRT.strStorageTypeCode 
		END
	) AS strDistributionCode
	,(
		CASE 
			WHEN CTD.intContractDetailId > 0 AND CTD.intPricingTypeId != 5 THEN 'Contract'
			WHEN ISNULL(CTD.intContractDetailId,0) = 0 AND IRI.intOwnershipType = 1 THEN 'Spot Sale'
			ELSE GRT.strStorageTypeDescription 
		END
	) AS strDistributionType
	,CTD.intContractDetailId
	,CTD.intPricingTypeId 
	,GRS.intCustomerStorageId
	,IR.intEntityVendorId
	from tblICInventoryReceiptItem IRI 
	LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = IRI.intSourceId
	LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = IRI.intLineNo
	LEFT JOIN tblGRCustomerStorage GRS ON GRS.intDeliverySheetId = SCD.intDeliverySheetId AND GRS.intEntityId = IR.intEntityVendorId
	LEFT JOIN tblGRStorageType GRT ON GRT.intStorageScheduleTypeId = GRS.intStorageTypeId
	WHERE IR.intSourceType = 5
) ReceiptItem ON ReceiptItem.intDeliverySheetId = SCD.intDeliverySheetId AND ReceiptItem.intEntityVendorId = SCDS.intEntityId
INNER JOIN (
	 SELECT 
		GR.intDiscountScheduleCodeId
		, GR.intItemId
		, IC.strItemNo AS strDiscountCode
		, IC.strDescription AS strDiscountCodeDescription
		, GR.intDiscountCalculationOptionId
		, GR.strDiscountChargeType
		, QM.dblGradeReading
		, QM.dblDiscountAmount
		, QM.dblShrinkPercent
		, QM.strShrinkWhat
		, QM.intTicketFileId
		, QM.strSourceType
		, GR.ysnDryingDiscount
		FROM tblGRDiscountScheduleCode GR 
		LEFT JOIN tblICItem IC on GR.intItemId = IC.intItemId 
		LEFT JOIN tblQMTicketDiscount QM on QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		WHERE QM.strSourceType = 'Delivery Sheet' AND GR.ysnDryingDiscount = 1
) QM ON QM.intTicketFileId = SCD.intDeliverySheetId 
LEFT JOIN (
	SELECT TOP 1
		SC.intDeliverySheetId
		,SC.intHaulerId
		,EM.strName
	FROM tblSCTicket SC
	LEFT JOIN vyuEMSearchShipVia EM on EM.intEntityId = SC.intHaulerId
	WHERE intDeliverySheetId > 0 AND dblFreightRate != 0
) EMHauler ON EMHauler.intDeliverySheetId = SCD.intDeliverySheetId
OUTER APPLY(
	 SELECT strCompanyName
		,strAddress AS strCompanyAddress
		,strPhone AS strCompanyPhone
		,strCity AS strCompanyCity
		,strCountry AS strCompanyCountry
	 FROM tblSMCompanySetup
  ) AS tblSMCompanySetup
CROSS APPLY(
	SELECT TOP 1 * FROM tblSMCompanyPreference
) CompanyPref
WHERE SCD.ysnPost = 1
