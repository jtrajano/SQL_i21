CREATE PROCEDURE uspMFGetQualityPropertiesByWO @intWorkOrderId INT
	,@strPropertyName NVARCHAR(100)
	,@intPropertyId INT = 0
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
	SELECT DISTINCT P.intPropertyId
		,P.strPropertyName
	FROM tblQMTestResult TR
	JOIN tblICParentLot PL ON PL.intParentLotId = TR.intProductValueId
		AND TR.intProductTypeId = 11
	JOIN tblICLot L ON L.intParentLotId = PL.intParentLotId
	JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE ISNUMERIC(TR.strPropertyValue) = 1
		AND P.strPropertyName LIKE '%'
		AND WPL.intWorkOrderId = @intWorkOrderId
		AND P.intPropertyId = (
			CASE 
				WHEN @intPropertyId = 0
					THEN P.intPropertyId
				ELSE @intPropertyId
				END
			)
END
ELSE IF @intProductTypeId = 12 -- Work Order (Line / WIP)
BEGIN
	SELECT DISTINCT P.intPropertyId
		,P.strPropertyName
	FROM tblQMTestResult TR
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = TR.intProductValueId
		AND TR.intProductTypeId = 12
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE ISNUMERIC(TR.strPropertyValue) = 1
		AND P.strPropertyName LIKE '%'
		AND W.intWorkOrderId = @intWorkOrderId
		AND P.intPropertyId = (
			CASE 
				WHEN @intPropertyId = 0
					THEN P.intPropertyId
				ELSE @intPropertyId
				END
			)
END
ELSE -- Lot
BEGIN
	SELECT DISTINCT P.intPropertyId
		,P.strPropertyName
	FROM tblQMTestResult TR
	JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = TR.intProductValueId
		AND TR.intProductTypeId = 6
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE ISNUMERIC(TR.strPropertyValue) = 1
		AND P.strPropertyName LIKE '%'
		AND WPL.intWorkOrderId = @intWorkOrderId
		AND P.intPropertyId = (
			CASE 
				WHEN @intPropertyId = 0
					THEN P.intPropertyId
				ELSE @intPropertyId
				END
			)
END
