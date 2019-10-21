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
LEFT JOIN tblICItem I ON I.intItemId = OC.intItemId
LEFT JOIN tblEMEntity E ON E.intEntityId = OC.intVendorId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = OC.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM RU ON RU.intItemUOMId = OC.intRateUOMId
LEFT JOIN tblICUnitMeasure RM ON RM.intUnitMeasureId = RU.intUnitMeasureId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = OC.intRateCurrencyId
LEFT JOIN tblSMCurrency ACU ON ACU.intCurrencyID = OC.intCurrencyId