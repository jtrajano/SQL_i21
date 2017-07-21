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
,(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
FROM vyuSCDeliverySheetView SCD
OUTER APPLY (
	SELECT 
		strCompanyName, strAddress
	FROM tblSMCompanySetup
) SM

