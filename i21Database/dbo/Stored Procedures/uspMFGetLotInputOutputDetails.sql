CREATE PROCEDURE uspMFGetLotInputOutputDetails 
	@intLotId INT
AS
BEGIN
	DECLARE @intBatchId INT

	SELECT @intBatchId = wopl.intBatchId
	FROM tblMFWorkOrderProducedLot wopl
	WHERE wopl.intLotId = @intLotId

	SELECT wopl.intLotId, 
		   wopl.intWorkOrderId, 
		   l.strLotNumber, 
		   'OUTPUT' AS strType, 
		   wo.strWorkOrderNo, 
		   i.strItemNo, 
		   i.strDescription AS strItemDescription, 
		   wopl.dblQuantity, 
		   um.strUnitMeasure, 
		   wopl.dtmCreated AS dtmTimeLogged, 
		   us.strUserName
	FROM tblMFWorkOrderProducedLot wopl
	JOIN tblMFWorkOrder wo ON wo.intWorkOrderId = wopl.intWorkOrderId
	JOIN tblICItem i ON i.intItemId = wopl.intItemId
	JOIN tblICItemUOM iu ON iu.intItemUOMId = wopl.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	JOIN tblSMUserSecurity us ON us.intUserSecurityID = wopl.intCreatedUserId
	JOIN tblICLot l ON l.intLotId = wopl.intLotId
	WHERE wopl.intLotId = @intLotId
	
	UNION ALL
	
	SELECT wocl.intLotId, 
		   wocl.intWorkOrderId, 
		   l.strLotNumber, 
		   'INPUT' AS strType, 
		   wo.strWorkOrderNo, 
		   i.strItemNo, 
		   i.strDescription AS strItemDescription, 
		   wocl.dblQuantity, 
		   um.strUnitMeasure, 
		   wocl.dtmCreated AS dtmTimeLogged, 
		   us.strUserName
	FROM tblMFWorkOrderConsumedLot wocl
	JOIN tblMFWorkOrder wo ON wo.intWorkOrderId = wocl.intWorkOrderId
	JOIN tblICItem i ON i.intItemId = wocl.intItemId
	JOIN tblICItemUOM iu ON iu.intItemUOMId = wocl.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	JOIN tblSMUserSecurity us ON us.intUserSecurityID = wocl.intCreatedUserId
	JOIN tblICLot l ON l.intLotId = wocl.intLotId
	WHERE wocl.intBatchId = @intBatchId
END