CREATE PROCEDURE uspMFGetProductionDetail (@intWorkOrderId INT)
AS
BEGIN
	SELECT W.intWorkOrderProducedLotId,
		L.intLotId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,W.dblQuantity
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,W.dtmCreated
		,W.intCreatedUserId
		,US.strUserName
		,W.intWorkOrderId
		,SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,W.ysnProductionReversed
		,W.strReferenceNo
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,W.intBatchId 
	FROM dbo.tblMFWorkOrderProducedLot W
	JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.intUserSecurityID = W.intCreatedUserId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	WHERE intWorkOrderId = @intWorkOrderId
END