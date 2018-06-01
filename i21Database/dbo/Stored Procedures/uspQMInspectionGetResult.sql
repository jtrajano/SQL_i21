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
	DECLARE @intSampleId INT

	IF ISNULL(@intProductValueId, 0) = 0
	BEGIN
		DECLARE @intValidDate INT

		SET @intValidDate = (
				SELECT DATEPART(dy, GETDATE())
				)

		SELECT DISTINCT PR.strPropertyName
			,PR.intPropertyId
			,'false' AS strPropertyValue
			,PP.intSequenceNo
			,'' AS strComment
		FROM tblQMProduct AS P
		JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
		JOIN tblQMProductTest PT ON PT.intProductId = P.intProductId
		JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId
		JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		JOIN tblQMProperty PR ON PR.intPropertyId = PP.intPropertyId
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
		SELECT @intSampleId = ISNULL(MIN(S.intSampleId), 0)
		FROM tblQMTestResult TR
		JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.intProductValueId = @intProductValueId
			AND TR.intControlPointId = @intControlPointId

		SELECT DISTINCT P.strPropertyName
			,TR.intPropertyId
			,TR.strPropertyValue
			,TR.intTestResultId AS intSequenceNo
			,ISNULL(TR.strComment, '') AS strComment
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		JOIN tblQMTest T ON T.intTestId = TR.intTestId
		WHERE TR.intSampleId = @intSampleId
			AND P.intDataTypeId = 4 -- Bit
		ORDER BY TR.intTestResultId
	END
END
