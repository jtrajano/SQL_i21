﻿CREATE PROCEDURE uspQMGetSampleTestResult
	@intSampleId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT TR.intSampleId
		,TR.intTestResultId
		,TR.intProductId
		,TR.intProductTypeId
		,TR.intProductValueId
		,T.intTestId
		,CASE WHEN TR.intParentPropertyId IS NOT NULL THEN NULL ELSE T.strTestName END AS strTestName
		,PRT.intPropertyId
		,PRT.strPropertyName
		,PRT.strDescription
		,TR.strPropertyValue
		,TR.dtmCreateDate
		,TR.strResult
		--,cast(TR.ysnFinal AS BIT) AS ysnFinal
		,TR.ysnFinal
		,TR.strComment
		,TR.intSequenceNo
		,TR.dtmValidFrom
		,TR.dtmValidTo
		,TR.strPropertyRangeText
		,TR.dblMinValue
		,TR.dblMaxValue
		,TR.dblLowValue
		,TR.dblHighValue
		,TR.intUnitMeasureId
		,U.strUnitMeasure
		--,cast(TR.dblCrdrPrice AS NUMERIC(18, 6)) AS dblCrdrPrice
		--,cast(TR.dblCrdrQty AS NUMERIC(18, 6)) AS dblCrdrQty
		,TR.dblCrdrPrice
		,TR.dblCrdrQty
		,TR.intProductPropertyValidityPeriodId
		,TR.intControlPointId
		,TR.intParentPropertyId
		,TR.intRepNo
		,TR.strFormula
		,TR.strFormulaParser
		,T.intReplications
		,PRT.intDataTypeId
		,PRT.intListId
		,L.strListName
		,ISNULL(PP.strIsMandatory,PRT.strIsMandatory) AS strIsMandatory
	FROM dbo.tblQMTestResult AS TR
	JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = TR.intPropertyId
	JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
	LEFT JOIN dbo.tblQMProductProperty AS PP ON PP.intProductId = TR.intProductId
		AND PP.intPropertyId = TR.intPropertyId
	LEFT JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = TR.intUnitMeasureId
	LEFT JOIN dbo.tblQMList AS L ON L.intListId = PRT.intListId
	WHERE TR.intSampleId = @intSampleId
	ORDER BY TR.intSequenceNo
END
