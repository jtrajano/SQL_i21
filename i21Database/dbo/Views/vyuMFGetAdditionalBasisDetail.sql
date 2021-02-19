CREATE VIEW vyuMFGetAdditionalBasisDetail
AS
SELECT ABOC.intAdditionalBasisOtherChargesId
	,AB.intAdditionalBasisId
	,AB.dtmAdditionalBasisDate
	,AB.strComment
	,CL.strLocationName
	,I.strItemNo
	,I.strDescription
	,I1.strItemNo AS strOCItemNo
	,I1.strDescription AS strOCDescription
	,ABOC.dblBasis
	,C.strCurrency
	,UOM.strUnitMeasure AS strItemUOM
FROM tblMFAdditionalBasis AB
JOIN tblMFAdditionalBasisDetail ABD ON ABD.intAdditionalBasisId = AB.intAdditionalBasisId
JOIN tblMFAdditionalBasisOtherCharges ABOC ON ABOC.intAdditionalBasisDetailId = ABD.intAdditionalBasisDetailId
JOIN tblICItem I ON I.intItemId = ABD.intItemId
JOIN tblICItem I1 ON I1.intItemId = ABOC.intItemId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = ABD.intCurrencyId
LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ABD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = AB.intLocationId
