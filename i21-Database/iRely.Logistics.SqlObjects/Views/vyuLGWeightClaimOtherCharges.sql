CREATE VIEW vyuLGWeightClaimOtherCharges
AS
SELECT OC.*,WC.strReferenceNumber
	,I.strItemNo
	,E.strName AS strVendor
	,UM.strUnitMeasure AS strItemUOM
	,RM.strUnitMeasure AS strRateUOM
	,CU.strCurrency AS strRateCurrency
	,ACU.strCurrency AS strCurrency
FROM tblLGWeightClaimOtherCharges OC
JOIN tblLGWeightClaim WC ON WC.intWeightClaimId = OC.intWeightClaimId
JOIN tblICItem I ON I.intItemId = OC.intItemId
JOIN tblEMEntity E ON E.intEntityId = OC.intVendorId
JOIN tblICItemUOM IU ON IU.intItemUOMId = OC.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICItemUOM RU ON RU.intItemUOMId = OC.intRateUOMId
JOIN tblICUnitMeasure RM ON RM.intUnitMeasureId = RU.intUnitMeasureId
JOIN tblSMCurrency CU ON CU.intCurrencyID = OC.intRateCurrencyId
JOIN tblSMCurrency ACU ON ACU.intCurrencyID = OC.intCurrencyId