CREATE VIEW [dbo].[vyuSCDeliverySheetReport]
AS SELECT 
SCD.intDeliverySheetId
,SCD.intEntityId
,SCD.intCompanyLocationId
,SCD.intItemId
,SCD.intDiscountId
,SCD.strDeliverySheetNumber
,SCD.dtmDeliverySheetDate
,SCD.strName
,SCD.strLocationName
,SCD.strItemNo
,SCD.strDiscountId
,SCD.ysnPost
,SM.strCompanyName
,SM.strAddress
,SC.strItemUOM
,SC.strFieldNumber
,SC.strFarmNumber
,EM.strSplitNumber
,SCT.dblGrossUnits
,SCT.dblShrink
,SCT.dblNetUnits
,(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
FROM vyuSCDeliverySheetView SCD
OUTER APPLY (
	SELECT 
		strCompanyName, strAddress
	FROM tblSMCompanySetup
) SM
OUTER APPLY (
	SELECT DISTINCT SUM(dblGrossUnits) AS dblGrossUnits, SUM(dblShrink) AS dblShrink, SUM(dblNetUnits) AS dblNetUnits
	from tblSCTicket WHERE intDeliverySheetId = SCD.intDeliverySheetId
) SCT
OUTER APPLY (
	SELECT DISTINCT strFarmNumber,strFieldNumber,strItemUOM
	FROM tblSCTicket WHERE strFieldNumber != '' AND intDeliverySheetId = SCD.intDeliverySheetId
) SC
OUTER APPLY (
	SELECT DISTINCT intSplitId from tblSCTicket WHERE intDeliverySheetId = SCD.intDeliverySheetId AND intSplitId > 0
) SCS
OUTER APPLY (
	SELECT TOP 1 strSplitNumber from tblEMEntitySplit WHERE intSplitId = SCS.intSplitId
) EM
