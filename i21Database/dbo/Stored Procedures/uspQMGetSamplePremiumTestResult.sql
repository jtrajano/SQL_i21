CREATE PROCEDURE uspQMGetSamplePremiumTestResult @intSampleId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT S.intSampleId
		,S.intContractDetailId
		,S.intItemId
		,PRT.intPropertyId
		,QCD.dblTargetValue
		,QCD.dblMinValue
		,QCD.dblMaxValue
		,QCD.dblFactorOverTarget
		,QCD.dblPremium
		,QCD.dblFactorUnderTarget
		,QCD.dblDiscount
		,QCD.strCostMethod
		,QCD.intCurrencyId
		,QCD.intUnitMeasureId
		,TR.strPropertyValue AS strActualValue

		,QCD.intQualityCriteriaId
		,QCD.intQualityCriteriaDetailId
		,S.strSampleNumber
		,PRT.strPropertyName
		,C.strCurrency
		,UOM.strUnitMeasure
	FROM dbo.tblQMTestResult TR
	JOIN dbo.tblQMSample S ON S.intSampleId = TR.intSampleId
		AND TR.intSampleId = @intSampleId
	JOIN dbo.tblQMProperty PRT ON PRT.intPropertyId = TR.intPropertyId
		AND PRT.intDataTypeId in (1,2)
	LEFT JOIN dbo.tblQMQualityCriteria QC ON QC.intItemId = S.intItemId
	LEFT JOIN dbo.tblQMQualityCriteriaDetail QCD ON QCD.intQualityCriteriaId = QC.intQualityCriteriaId
		AND QCD.intPropertyId = PRT.intPropertyId
	LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = QCD.intCurrencyId
	LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = QCD.intUnitMeasureId
	ORDER BY TR.intSequenceNo
END
