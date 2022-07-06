CREATE VIEW vyuMFAdditionalBasisDetailNotMapped
AS
SELECT ABD.intAdditionalBasisDetailId
	,I.strItemNo
	,I.strDescription
	,C.strCurrency
	,UOM.strUnitMeasure AS strItemUOM
FROM tblMFAdditionalBasisDetail ABD
JOIN tblICItem I ON I.intItemId = ABD.intItemId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = ABD.intCurrencyId
LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ABD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
