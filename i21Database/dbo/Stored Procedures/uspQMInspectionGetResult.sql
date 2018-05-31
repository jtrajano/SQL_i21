CREATE PROCEDURE [dbo].[uspQMInspectionGetResult] @intControlPointId INT -- 3 (Inspection)
	,@intProductTypeId INT -- 3 / 4 (Receipt / Shipment)
	,@intProductValueId INT -- 0 / intInventoryReceiptId / intInventoryShipmentId
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	IF ISNULL(@intProductValueId, 0) = 0
	BEGIN
		DECLARE @intValidDate INT

		SET @intValidDate = (
				SELECT DATEPART(dy, GETDATE())
				)

		SELECT DISTINCT PR.strPropertyName
			,PR.intPropertyId
			--,CASE 
			--	WHEN LOWER(PPV.strPropertyRangeText) = 'true'
			--		THEN 'true'
			--	ELSE 'false'
			--	END AS strPropertyValue
			,'false' AS strPropertyValue
			,PP.intSequenceNo
			,'' AS strComment
		FROM dbo.tblQMProduct AS P
		JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
		JOIN dbo.tblQMProductTest PT ON PT.intProductId = P.intProductId
		JOIN dbo.tblQMProductProperty PP ON PP.intProductId = P.intProductId
		JOIN dbo.tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		JOIN dbo.tblQMProperty PR ON PR.intPropertyId = PP.intPropertyId
		WHERE P.intProductTypeId = @intProductTypeId
			AND PC.intControlPointId = @intControlPointId
			AND P.ysnActive = 1
			AND P.intProductValueId IS NULL
			AND PR.intDataTypeId = 4 -- Bit
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo
	END
	ELSE
	BEGIN
		SELECT DISTINCT P.strPropertyName
			,TR.intPropertyId
			,TR.strPropertyValue
			,TR.intTestResultId AS intSequenceNo
			,ISNULL(TR.strComment, '') AS strComment
		FROM dbo.tblQMTestResult TR
		JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		JOIN dbo.tblQMTest T ON T.intTestId = TR.intTestId
		WHERE TR.intProductTypeId = @intProductTypeId
			AND TR.intProductValueId = @intProductValueId
			AND TR.intControlPointId = @intControlPointId
			AND P.intDataTypeId = 4 -- Bit
		ORDER BY TR.intTestResultId
	END
END
