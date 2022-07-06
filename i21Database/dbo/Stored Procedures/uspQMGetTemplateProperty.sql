CREATE PROCEDURE uspQMGetTemplateProperty @intItemId INT
	,@intSampleTypeId INT
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
	SET @intProductId = (
			SELECT P.intProductId
			FROM tblQMProduct AS P
			JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
			WHERE P.intProductTypeId = 2 -- Item
				AND P.intProductValueId = @intItemId
				AND PC.intSampleTypeId = @intSampleTypeId
				AND P.ysnActive = 1
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
					AND PC.intSampleTypeId = @intSampleTypeId
					AND P.ysnActive = 1
				)
	END

	SELECT DISTINCT PP.intProductPropertyId
		,@intProductId AS intProductId
		,PRT.intPropertyId
		,PRT.strPropertyName
		,PRT.strDescription
		,PP.intSequenceNo
		,PPV.dblMinValue
		,PPV.dblMaxValue
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
	WHERE PRD.intProductId = @intProductId
		AND PC.intSampleTypeId = @intSampleTypeId
		AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
			AND DATEPART(dy, PPV.dtmValidTo)
	ORDER BY PP.intSequenceNo
END
