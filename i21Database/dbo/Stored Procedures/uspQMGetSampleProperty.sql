CREATE PROCEDURE uspQMGetSampleProperty
	@intProductTypeId INT
	,@intProductValueId INT
	,@intItemId INT
	,@intControlPointId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @intProductId INT
	DECLARE @intCategoryId INT
	DECLARE @intValidDate INT

	SET @intCategoryId = 0
	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	IF @intProductTypeId = 3
		OR @intProductTypeId = 4
		OR @intProductTypeId = 5
	BEGIN
		SET @intProductId = (
				SELECT P.intProductId
				FROM tblQMProduct AS P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = @intProductTypeId
					AND P.intProductValueId IS NULL
					AND PC.intControlPointId = @intControlPointId
				)
	END
	ELSE
	BEGIN
		SET @intProductId = (
				SELECT P.intProductId
				FROM tblQMProduct AS P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = 2 -- Item
					AND P.intProductValueId = @intItemId
					AND PC.intControlPointId = @intControlPointId
				)

		IF @intProductId IS NULL
		BEGIN
			SET @intCategoryId = (
					SELECT intCategoryId
					FROM dbo.tblICItem
					WHERE intItemId = @intItemId
					)
			SET @intProductId = (
					SELECT P.intProductId
					FROM tblQMProduct AS P
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
					WHERE P.intProductTypeId = 1 -- Item Category
						AND P.intProductValueId = @intCategoryId
						AND PC.intControlPointId = @intControlPointId
					)
		END
	END

	SELECT DISTINCT 0 AS intSampleId
		,0 AS intTestResultId
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
		,PP.intSequenceNo
		,PPV.dtmValidFrom
		,PPV.dtmValidTo
		,PPV.strPropertyRangeText
		,PPV.dblMinValue
		,PPV.dblMaxValue
		,PPV.dblLowValue
		,PPV.dblHighValue
		,U.intUnitMeasureId AS intUnitMeasureId
		,U.strUnitMeasure AS strUnitMeasure
		,PPV.intProductPropertyValidityPeriodId
		,PC.intControlPointId
		,0 AS intParentPropertyId
		,0 AS intRepNo
		,PP.strIsMandatory
		,PRT.intDataTypeId
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
		,0 AS intPropertyValidityPeriodId
		,'' AS strConditionalResult
	FROM dbo.tblQMProduct AS PRD
	JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
	JOIN dbo.tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
	JOIN dbo.tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
		AND PT.intProductId = PRD.intProductId
	JOIN dbo.tblQMTest AS T ON T.intTestId = PP.intTestId
		AND T.intTestId = PT.intTestId
	JOIN dbo.tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
		AND TP.intTestId = PP.intTestId
		AND TP.intTestId = T.intTestId
		AND TP.intTestId = PT.intTestId
	JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
		AND PRT.intPropertyId = TP.intPropertyId
	JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
	LEFT JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = PPV.intUnitMeasureId
	LEFT JOIN dbo.tblQMList AS L ON L.intListId = PRT.intListId
	WHERE PRD.intProductId = @intProductId
		AND PC.intControlPointId = @intControlPointId
		AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
			AND DATEPART(dy, PPV.dtmValidTo)
	ORDER BY PP.intSequenceNo
END
