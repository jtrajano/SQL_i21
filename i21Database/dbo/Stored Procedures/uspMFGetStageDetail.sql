CREATE PROCEDURE uspMFGetStageDetail (@intWorkOrderId INT)
AS
BEGIN
	Declare @intAttributeId int
			,@strAttributeValue nvarchar(50)
			,@intManufacturingProcessId int
			,@intLocationId int
			,@intStatusId int

	Select @intManufacturingProcessId=intManufacturingProcessId, @intLocationId=intLocationId,@intStatusId=intStatusId  From dbo.tblMFWorkOrder Where intWorkOrderId =@intWorkOrderId 

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Display actual consumption in WM'

	Select @strAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	IF @strAttributeValue='True' OR @intStatusId=13
	BEGIN
		SELECT W.intWorkOrderConsumedLotId As intWorkOrderInputLotId,
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
			,ISNULL(W.intMachineId,0)intMachineId
			,ISNULL(M.strName,'') AS strMachineName
			,W.ysnConsumptionReversed
			,W.strReferenceNo
			,W.dtmActualInputDateTime
			,C.intContainerId
			,C.strContainerId
			,S.intShiftId
			,S.strShiftName
			,L.intParentLotId 
		FROM dbo.tblMFWorkOrderConsumedLot W
		JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblSMUserSecurity US ON US.[intEntityUserSecurityId] = W.intCreatedUserId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
		LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
		LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
		WHERE intWorkOrderId = @intWorkOrderId
		Order by W.intWorkOrderConsumedLotId
	END
	ELSE
	BEGIN
		SELECT W.intWorkOrderInputLotId,
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
			,W.intMachineId
			,M.strName AS strMachineName
			,W.ysnConsumptionReversed
			,W.strReferenceNo
			,W.dtmActualInputDateTime
			,C.intContainerId
			,C.strContainerId
			,S.intShiftId
			,S.strShiftName
			,L.intParentLotId 
		FROM dbo.tblMFWorkOrderInputLot W
		JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblSMUserSecurity US ON US.[intEntityUserSecurityId] = W.intCreatedUserId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
		LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
		LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
		WHERE intWorkOrderId = @intWorkOrderId
		Order by W.intWorkOrderInputLotId
	END
END

