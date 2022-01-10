CREATE VIEW vyuQMQualityCriteriaDetailList
AS
SELECT QCD.intQualityCriteriaDetailId
	,QC.intQualityCriteriaId
	,QC.intItemId
	,I.strItemNo
	,ST.strSampleTypeName
	,QCD.dblTargetValue
	,QCD.dblMinValue
	,QCD.dblMaxValue
	,QCD.dblFactorOverTarget
	,QCD.dblPremium
	,QCD.dblFactorUnderTarget
	,QCD.dblDiscount
	,QCD.strCostMethod
	,P.strPropertyName
	,C.strCurrency
	,UOM.strUnitMeasure
FROM tblQMQualityCriteria AS QC
JOIN tblQMQualityCriteriaDetail QCD ON QCD.intQualityCriteriaId = QC.intQualityCriteriaId
JOIN tblICItem AS I ON I.intItemId = QC.intItemId
LEFT JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = QC.intSampleTypeId
LEFT JOIN tblQMProperty P ON P.intPropertyId = QCD.intPropertyId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = QCD.intCurrencyId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = QCD.intUnitMeasureId
