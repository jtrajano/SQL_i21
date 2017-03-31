CREATE PROCEDURE uspMFGetStageDetail (@intWorkOrderId INT)
AS
BEGIN
	SELECT W.intWorkOrderInputLotId
		,L.intLotId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,W.dblQuantity
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,W.dtmProductionDate AS dtmCreated
		,W.intCreatedUserId
		,US.strUserName
		,W.intWorkOrderId
		,SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,IsNULL(W.intMachineId, 0) AS intMachineId
		,IsNULL(M.strName, '') AS strMachineName
		,W.ysnConsumptionReversed
		,W.strReferenceNo
		,W.dtmActualInputDateTime
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,L.intParentLotId
		,'STAGE' AS strTransactionName
		,PL.strParentLotNumber
	FROM dbo.tblMFWorkOrderInputLot W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	WHERE intWorkOrderId = @intWorkOrderId
	
	UNION
	
	SELECT W.intWorkOrderConsumedLotId AS intWorkOrderInputLotId
		,IsNULL(L.intLotId, 0) AS intLotId
		,IsNULL(L.strLotNumber, '') AS strLotNumber
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
		,ISNULL(W.intMachineId, 0) intMachineId
		,ISNULL(M.strName, '') AS strMachineName
		,W.ysnConsumptionReversed
		,W.strReferenceNo
		,W.dtmActualInputDateTime
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,IsNULL(L.intParentLotId, 0) AS intParentLotId
		,'CONSUME' AS strTransactionName
		,PL.strParentLotNumber
	FROM dbo.tblMFWorkOrderConsumedLot W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	WHERE intWorkOrderId = @intWorkOrderId
	ORDER BY strTransactionName DESC
		,W.intWorkOrderInputLotId
END
