CREATE VIEW [dbo].[vyuSCDeliverySheetReport]
AS 
SELECT 
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
	,SCD.strCompanyLocationName
	,SCD.strAddress
	,SCD.dblGross
	,SCD.dblShrink
	,SCD.dblNet
	,SCD.ysnPost
	,EMS.strSplitNumber
	,ICC.strCommodityCode	
	,(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
FROM vyuSCDeliverySheetView SCD
LEFT JOIN tblEMEntitySplit EMS ON EMS.intSplitId = SCD.intSplitId
LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = SCD.intCommodityId