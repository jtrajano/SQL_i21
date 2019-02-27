CREATE VIEW vyuMFGetWorkOrderTransactionView
AS
SELECT intAdjustmentId As intRowNo 
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,IsNULL(W.dtmOrderDate, IA.dtmDate) AS dtmOrderDate
	,I3.intItemId AS intTargetItemId
	,I3.strType AS strTargetItemType
	,I3.strItemNo AS strTargetItemNo
	,I3.strDescription AS strTargetItemDesc
	,I3.strShortName AS strTargetItemShortDesc
	,W.dblQuantity AS dblPlannedQty
	,UM3.strUnitMeasure AS strTargetUnitMeasure
	,WS.strName AS strStatusName
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.strShiftName AS strPlannedShiftName
	,MP.strProcessName
	,I1.intItemId
	,I1.strType
	,I1.strItemNo
	,I1.strDescription
	,I1.strShortName AS strShortDesc
	,IA.dblQty AS dblQuantity
	,UM.strUnitMeasure
	,IA.dtmBusinessDate
	,S.strShiftName AS strBusinessShiftName
	,SL1.strName AS [strFromTo]
	,ISNULL(M.strName, '') AS strMachineName
	,IsNULL(WI.strReferenceNo, WP.strReferenceNo) strReferenceNo
	,IsNULL(WI.dtmActualInputDateTime, IA.dtmDate) AS dtmActualTransactionDateTime
	,C.strContainerId
	,CT.strDisplayMember AS strContainerType
	,IA.dtmDateCreated AS dtmLastModified
	,US.strUserName
	,CASE 
		WHEN IA.intTransactionTypeId = 104
			AND IA.dblQty > 0
			THEN 'STAGE'
		WHEN IA.intTransactionTypeId = 104
			AND IA.dblQty < 0
			THEN 'STAGE REVERSAL'
		WHEN IA.intTransactionTypeId = 8
			AND IA.dblQty > 0
			THEN 'CONSUME'
		WHEN IA.intTransactionTypeId = 8
			AND IA.dblQty < 0
			THEN 'CONSUME REVERSAL'
		WHEN IA.intTransactionTypeId = 9
			AND IA.dblQty > 0
			THEN 'PRODUCE'
		WHEN IA.intTransactionTypeId = 9
			AND IA.dblQty < 0
			THEN 'PRODUCE REVERSAL'
		ELSE TT.strName
		END AS strTransactionName
	,ISNULL(ISNULL(WP.strComment, W.strComment), IA.strNote) AS strComment
	,L1.intLotId
	,L1.strLotNumber
	,L1.strLotAlias
	,S.strShiftName
	,IA.dtmDate AS dtmProductionDate
	,IsNULL(WC.strBatchId, WP.strBatchId) AS strBatchId
	,PL.strParentLotNumber
	,L3.strLotNumber AS strSpecialPalletId
	,L2.strLotNumber AS [strRelatedPalletNo]
	,SL2.strName AS [strRelatedStorageLocation]
	,I2.strItemNo AS [strOldItemNo]
	,dtmOldExpiryDate AS [dtmOldExpiryDate]
	,dtmNewExpiryDate AS [dtmNewExpiryDate]
	,LS1.strSecondaryStatus AS [strOldPalletStatus]
	,LS2.strSecondaryStatus AS [strNewPalletStatus]
	,E1.strName AS [strOldOwnerName]
	,E2.strName AS [strNewOwnerName]
	,IA.strReason AS [strReason]
	,IA.intLocationId
FROM tblMFInventoryAdjustment IA
JOIN tblICItem I1 ON I1.intItemId = IA.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IA.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = IA.intStorageLocationId
Left JOIN tblICLot L1 ON L1.intLotId = IA.intSourceLotId
Left JOIN tblICParentLot PL ON PL.intParentLotId = L1.intParentLotId
LEFT JOIN tblICLot L2 ON L2.intLotId = IA.intDestinationLotId
LEFT JOIN tblICStorageLocation SL2 ON SL2.intStorageLocationId = IA.intDestinationStorageLocationId
LEFT JOIN tblICInventoryTransactionType TT ON TT.intTransactionTypeId = IA.intTransactionTypeId
LEFT JOIN tblICItem I2 ON I2.intItemId = IA.intOldItemId
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = IA.intOldLotStatusId
LEFT JOIN tblICLotStatus LS2 ON LS2.intLotStatusId = IA.intNewLotStatusId
JOIN tblSMUserSecurity US ON US.intEntityId = IA.intUserId
LEFT JOIN tblMFShift S ON S.intShiftId = IA.intBusinessShiftId
LEFT JOIN tblICItemOwner IO1 ON IO1.intItemOwnerId = IA.intOldItemOwnerId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = IO1.intOwnerId
LEFT JOIN tblICItemOwner IO2 ON IO2.intItemOwnerId = IA.intNewItemOwnerId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = IO2.intOwnerId
LEFT JOIN tblMFWorkOrder W ON W.intWorkOrderId = IA.intWorkOrderId
LEFT JOIN dbo.tblICItem I3 ON I3.intItemId = W.intItemId
LEFT JOIN dbo.tblICItemUOM IU3 ON IU3.intItemUOMId = W.intItemUOMId
LEFT JOIN dbo.tblICUnitMeasure UM3 ON UM3.intUnitMeasureId = IU3.intUnitMeasureId
LEFT JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
LEFT JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
LEFT JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
LEFT JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderProducedLotId = IA.intWorkOrderProducedLotId
LEFT JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderInputLotId = IA.intWorkOrderInputLotId
LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = IsNULL(WP.intMachineId, WI.intMachineId)
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WP.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
LEFT JOIN dbo.tblICItemOwner O ON O.intItemOwnerId = L1.intItemOwnerId
LEFT JOIN dbo.tblICLot L3 ON L3.intLotId = WP.intSpecialPalletLotId
LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intWorkOrderConsumedLotId = IA.intWorkOrderConsumedLotId
