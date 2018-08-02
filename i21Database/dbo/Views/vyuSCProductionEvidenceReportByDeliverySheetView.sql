CREATE VIEW [dbo].[vyuSCProductionEvidenceReportByDeliverySheetView]
AS 
SELECT 
	SCD.intDeliverySheetId
	,SCD.strDeliverySheetNumber
	,SCD.dtmDeliverySheetDate
	,SCD.dtmDeliverySheetDate AS dtmReceiptDate
	,SCD.intCompanyLocationId
	,SCD.intEntityId
	,SCD.strCountyProducer
	,SCD.dblGross
	,SCD.dblShrink
	,SCD.dblNet
	,EMEntity.strName
	,EMLocation.strAddress
	,EMLocation.strCity
	,EMLocation.strCountry
	,EMLocation.strPhone
	
	,EMSplit.strSplitNumber
	
	,IC.strCommodityCode
	,IC.strItemNo
	,UOM.strUnitMeasure AS strItemUOM
	
	,EMHauler.strName AS strHaulerName

	,QM.strDiscountCode
	,QM.dblGradeReading
	
	,(CASE WHEN SCD.intSplitId > 0 THEN 'Split' ELSE GR.strStorageTypeCode END) AS strDistributionType

	,SMCompanyLoc.strLocationName
	,tblSMCompanySetup.strCompanyName
	,tblSMCompanySetup.strCompanyAddress
	,tblSMCompanySetup.strCompanyPhone
	,tblSMCompanySetup.strCompanyCity
	,tblSMCompanySetup.strCompanyCountry
	,CompanyPref.intCurrencyDecimal as intDecimalPrecision
FROM tblSCDeliverySheet SCD
INNER JOIN (
	SELECT ICI.intItemId
		,ICI.strItemNo
		,ICC.intCommodityId
		,ICC.strCommodityCode
	FROM tblICItem ICI 
	INNER JOIN tblICCommodity ICC ON ICC.intCommodityId = ICI.intCommodityId
) IC ON IC.intItemId = SCD.intItemId
INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = IC.intItemId AND ItemUOM.ysnStockUOM = 1
INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
INNER JOIN tblEMEntity EMEntity on EMEntity.intEntityId = SCD.intEntityId
INNER JOIN tblEMEntityLocation EMLocation ON EMLocation.intEntityId = SCD.intEntityId AND EMLocation.ysnDefaultLocation = 1
INNER JOIN tblEMEntitySplit EMSplit on EMSplit.intSplitId = SCD.intSplitId
INNER JOIN tblSMCompanyLocation SMCompanyLoc on SMCompanyLoc.intCompanyLocationId = SCD.intCompanyLocationId
INNER JOIN tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = SCD.intDiscountId
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
	SELECT SCDS.intDeliverySheetId
		,SCDS.intEntityId 
		,GR.strStorageTypeCode 
	FROM tblSCDeliverySheetSplit SCDS
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId
) GR ON GR.intDeliverySheetId = SCD.intDeliverySheetId AND GR.intEntityId = SCD.intEntityId
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
