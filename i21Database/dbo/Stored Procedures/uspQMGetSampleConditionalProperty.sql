CREATE PROCEDURE uspQMGetSampleConditionalProperty
	@intProductId INT
	,@intProductTypeId INT
	,@intProductValueId INT
	,@intItemId INT
	,@intControlPointId INT
	,@intSampleTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @intValidDate INT

	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	SELECT DISTINCT 0 AS intSampleId
		,0 AS intTestResultId
		,CAST(ROW_NUMBER() OVER (
				ORDER BY DT.intSequenceNo
				) AS INT) AS intSequenceNo
		,@intProductId AS intProductId
		,@intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,T.intTestId
		,T.strTestName
		,PRT.intPropertyId
		,PRT.strPropertyName
		,PRT.strDescription
		,'' AS strPropertyValue
		,GETDATE() AS dtmCreateDate
		,'' AS strResult
		,cast(0 AS BIT) AS ysnFinal
		,'' AS strComment
		,PV.dtmValidFrom
		,PV.dtmValidTo
		,PV.strPropertyRangeText
		,PV.dblMinValue
		,PV.dblMaxValue
		,PV.dblLowValue
		,PV.dblHighValue
		,U.intUnitMeasureId AS intUnitMeasureId
		,U.strUnitMeasure AS strUnitMeasure
		,PPV.intProductPropertyValidityPeriodId
		,PC.intControlPointId
		,0 AS intRepNo
		,DT.strIsMandatory
		,PRT.intDataTypeId
		,PRT.intDecimalPlaces
		,PRT.intListId
		,L.strListName
		,T.intReplications
		,ISNULL((
				SELECT strFormula
				FROM tblQMProperty
				WHERE intPropertyId = TP.intPropertyId
				), '') AS strFormula
		,ISNULL((
				SELECT strFormulaParser
				FROM tblQMProperty
				WHERE intPropertyId = TP.intPropertyId
				), '') AS strFormulaParser
		,DT.MainPropertyId AS intParentPropertyId
		,DT.strConditionalResult
		,PV.intPropertyValidityPeriodId
	FROM (
		SELECT PP.intPropertyId AS MainPropertyId
			,CPP.intOnFailurePropertyId
			,CPP.intOnSuccessPropertyId
			,CPP.intOnFailurePropertyId AS ConPropertyId
			,PRT.strIsMandatory
			,PP.intSequenceNo
			,PP.intProductId
			,PP.intTestId
			,PP.intPropertyId
			,PP.intProductPropertyId
			,'Failure' AS strConditionalResult
		FROM tblQMConditionalProductProperty CPP
		JOIN tblQMProductProperty PP ON PP.intProductPropertyId = CPP.intProductPropertyId
		JOIN tblQMProduct PRD ON PRD.intProductId = PP.intProductId
		JOIN tblQMProperty PRT ON PRT.intPropertyId = CPP.intOnFailurePropertyId
		WHERE PRD.intProductId = @intProductId
			AND CPP.intOnFailurePropertyId IS NOT NULL
		
		UNION
		
		SELECT PP.intPropertyId AS MainPropertyId
			,CPP.intOnFailurePropertyId
			,CPP.intOnSuccessPropertyId
			,CPP.intOnSuccessPropertyId AS ConPropertyId
			,PRT.strIsMandatory
			,PP.intSequenceNo
			,PP.intProductId
			,PP.intTestId
			,PP.intPropertyId
			,PP.intProductPropertyId
			,'Success' AS strConditionalResult
		FROM tblQMConditionalProductProperty CPP
		JOIN tblQMProductProperty PP ON PP.intProductPropertyId = CPP.intProductPropertyId
		JOIN tblQMProduct PRD ON PRD.intProductId = PP.intProductId
		JOIN tblQMProperty PRT ON PRT.intPropertyId = CPP.intOnSuccessPropertyId
		WHERE PRD.intProductId = @intProductId
			AND CPP.intOnSuccessPropertyId IS NOT NULL
		) DT
	JOIN dbo.tblQMProduct AS PRD ON PRD.intProductId = DT.intProductId
	JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
		AND PC.intSampleTypeId = @intSampleTypeId
	JOIN dbo.tblQMTest AS T ON T.intTestId = DT.intTestId
	JOIN dbo.tblQMTestProperty AS TP ON TP.intPropertyId = DT.intPropertyId
		AND TP.intTestId = DT.intTestId
	JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = DT.ConPropertyId
	JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = DT.intProductPropertyId
	JOIN dbo.tblQMPropertyValidityPeriod AS PV ON PV.intPropertyId = PRT.intPropertyId
	LEFT JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = PV.intUnitMeasureId
	LEFT JOIN dbo.tblQMList AS L ON L.intListId = PRT.intListId
	WHERE PRD.intProductId = @intProductId
		AND @intValidDate BETWEEN DATEPART(dy, PV.dtmValidFrom)
			AND DATEPART(dy, PV.dtmValidTo)
		AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
			AND DATEPART(dy, PPV.dtmValidTo)
END
