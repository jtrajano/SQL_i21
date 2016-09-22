CREATE PROCEDURE [dbo].[uspQMInspectionGetResult]
	@intControlPointId INT -- 3 / 8 (Inspection / Shipping)
	,@intProductTypeId INT -- 3 (Receipt)
	,@intProductValueId INT -- 0 / intInventoryReceiptId
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
			,CASE 
				WHEN LOWER(PPV.strPropertyRangeText) = 'true'
					THEN 'true'
				ELSE 'false'
				END AS strPropertyValue
			,PP.intSequenceNo
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
		FROM dbo.tblQMTestResult TR
		JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		JOIN dbo.tblQMTest T ON T.intTestId = TR.intTestId
		JOIN dbo.tblICInventoryReceipt IR ON IR.intInventoryReceiptId = TR.intProductValueId
		WHERE TR.intProductTypeId = @intProductTypeId
			AND TR.intProductValueId = @intProductValueId
			AND TR.intControlPointId = @intControlPointId
		ORDER BY TR.intTestResultId
	END
END
