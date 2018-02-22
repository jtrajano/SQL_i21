CREATE PROCEDURE uspMFGetLotInputOutputDetails @intLotId INT = NULL
	,@intBatchId INT = NULL
AS
BEGIN
	DECLARE @intWorkOrderId INT

	IF @intBatchId IS NULL
	BEGIN
		SELECT @intBatchId = wopl.intBatchId
			,@intWorkOrderId = intWorkOrderId
		FROM tblMFWorkOrderProducedLot wopl
		WHERE wopl.intLotId = @intLotId
	END
	ELSE
	BEGIN
		SELECT @intWorkOrderId = intWorkOrderId
		FROM tblMFWorkOrderProducedLot wopl
		WHERE wopl.intBatchId = @intBatchId
	END

	SELECT CONVERT(INT, Row_Number() OVER (
				ORDER BY strType DESC
				)) AS intRowNo
		,DT.*
	FROM (
		SELECT IsNULL(wopl.intLotId, 0) AS intLotId
			,wopl.intWorkOrderId
			,IsNULL(l.strLotNumber, '') AS strLotNumber
			,'OUTPUT' AS strType
			,wo.strWorkOrderNo
			,i.strItemNo
			,i.strDescription AS strItemDescription
			,CASE 
				WHEN iu.intItemUOMId = wopl.intItemUOMId
					THEN wopl.dblQuantity
				ELSE wopl.dblPhysicalCount
				END AS dblQuantity
			,um.strUnitMeasure
			,wopl.dtmCreated AS dtmTimeLogged
			,us.strUserName
		FROM tblMFWorkOrderProducedLot wopl
		JOIN tblMFWorkOrder wo ON wo.intWorkOrderId = wopl.intWorkOrderId
		JOIN tblICItem i ON i.intItemId = wopl.intItemId
		JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId
			AND ysnStockUnit = 1
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		JOIN tblSMUserSecurity us ON us.[intEntityId] = wopl.intCreatedUserId
		LEFT JOIN tblICLot l ON l.intLotId = wopl.intLotId
		WHERE wopl.intBatchId = @intBatchId
		
		UNION ALL
		
		SELECT IsNULL(wocl.intLotId, 0) AS intLotId
			,wocl.intWorkOrderId
			,IsNULL(l.strLotNumber, '') AS strLotNumber
			,'INPUT' AS strType
			,wo.strWorkOrderNo
			,i.strItemNo
			,i.strDescription AS strItemDescription
			,wocl.dblQuantity
			,um.strUnitMeasure
			,wocl.dtmCreated AS dtmTimeLogged
			,us.strUserName
		FROM tblMFWorkOrderConsumedLot wocl
		JOIN tblMFWorkOrder wo ON wo.intWorkOrderId = wocl.intWorkOrderId
		JOIN tblICItem i ON i.intItemId = wocl.intItemId
		JOIN tblICItemUOM iu ON iu.intItemUOMId = wocl.intItemUOMId
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		JOIN tblSMUserSecurity us ON us.[intEntityId] = wocl.intCreatedUserId
		JOIN tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = wo.intManufacturingProcessId
		LEFT JOIN tblICLot l ON l.intLotId = wocl.intLotId
		WHERE CASE 
				WHEN MP.intAttributeTypeId = 5
					THEN 1
				ELSE IsNULL(wocl.intBatchId, @intBatchId)
				END = CASE 
				WHEN MP.intAttributeTypeId = 5
					THEN 1
				ELSE @intBatchId
				END
			AND wocl.intWorkOrderId = @intWorkOrderId
		) AS DT
END
