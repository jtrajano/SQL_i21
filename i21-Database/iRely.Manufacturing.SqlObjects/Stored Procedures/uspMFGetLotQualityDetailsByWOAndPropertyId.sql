CREATE PROCEDURE uspMFGetLotQualityDetailsByWOAndPropertyId @intWorkOrderId INT
	,@intPropertyId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intProductTypeId INT

SELECT @intProductTypeId = MPA.strAttributeValue
FROM tblMFWorkOrder W
JOIN tblMFManufacturingProcessAttribute MPA ON MPA.intManufacturingProcessId = W.intManufacturingProcessId
	AND MPA.intAttributeId = 94 -- Process Attribute: Quality Line Chart By
WHERE W.intWorkOrderId = @intWorkOrderId

IF @intProductTypeId = 11 -- Parent Lot
BEGIN
	SELECT L.intLotId
		,L.strLotNumber
		,P.intPropertyId
		,P.strPropertyName
		,CONVERT(NUMERIC(18, 6), TR.strPropertyValue) AS dblPropertyValue
		,MIN(TR.dblMinValue) OVER () AS dblMinValue
		,MAX(TR.dblMaxValue) OVER () AS dblMaxValue
		,S.strSampleNumber
	FROM tblQMTestResult TR
	JOIN tblICParentLot PL ON PL.intParentLotId = TR.intProductValueId
		AND TR.intProductTypeId = 11
		AND ISNUMERIC(TR.strPropertyValue) = 1
	JOIN tblICLot L ON L.intParentLotId = PL.intParentLotId
	JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
		AND WPL.intWorkOrderId = @intWorkOrderId
	JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE P.intPropertyId = @intPropertyId
	ORDER BY S.intSampleId
END
ELSE IF @intProductTypeId = 12 -- Work Order (Line / WIP)
BEGIN
	SELECT NULL AS intLotId
		,'' AS strLotNumber
		,P.intPropertyId
		,P.strPropertyName
		,CONVERT(NUMERIC(18, 6), TR.strPropertyValue) AS dblPropertyValue
		,MIN(TR.dblMinValue) OVER () AS dblMinValue
		,MAX(TR.dblMaxValue) OVER () AS dblMaxValue
		,S.strSampleNumber
	FROM tblQMTestResult TR
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = TR.intProductValueId
		AND TR.intProductTypeId = 12
		AND ISNUMERIC(TR.strPropertyValue) = 1
		AND W.intWorkOrderId = @intWorkOrderId
	JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE P.intPropertyId = @intPropertyId
	ORDER BY S.intSampleId
END
ELSE -- Lot
BEGIN
	SELECT L.intLotId
		,L.strLotNumber
		,P.intPropertyId
		,P.strPropertyName
		,CONVERT(NUMERIC(18, 6), TR.strPropertyValue) AS dblPropertyValue
		,MIN(TR.dblMinValue) OVER () AS dblMinValue
		,MAX(TR.dblMaxValue) OVER () AS dblMaxValue
		,S.strSampleNumber
	FROM tblQMTestResult TR
	JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = TR.intProductValueId
		AND TR.intProductTypeId = 6
		AND ISNUMERIC(TR.strPropertyValue) = 1
		AND WPL.intWorkOrderId = @intWorkOrderId
	JOIN tblICLot L ON L.intLotId = WPL.intLotId
	JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE P.intPropertyId = @intPropertyId
	ORDER BY S.intSampleId
END
