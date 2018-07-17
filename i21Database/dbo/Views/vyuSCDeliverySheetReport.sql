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
	,EM.strAddress AS strEntityAddress
	,EMS.strSplitNumber
	,ICC.strCommodityCode	
	,SMC.strCompanyName
	,(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
FROM vyuSCDeliverySheetView SCD
INNER JOIN tblEMEntityLocation EM ON EM.intEntityId = SCD.intEntityId AND EM.ysnDefaultLocation = 1
LEFT JOIN tblEMEntitySplit EMS ON EMS.intSplitId = SCD.intSplitId
LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = SCD.intCommodityId
OUTER APPLY(
	SELECT TOP 1 * FROM tblSMCompanySetup
) SMC