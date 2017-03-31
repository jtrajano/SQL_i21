CREATE VIEW vyuMFGetWorkOrderTransactionView
AS
SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId AS intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity AS dblPlannedQty
	,UM.intUnitMeasureId AS intTargetUnitMeasureId
	,UM.strUnitMeasure AS strTargetUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId AS intPlannedShiftId
	,PS.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,II.intItemId
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,WI.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WI.dtmBusinessDate
	,BS.intShiftId AS intBusinessShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [strFromTo]
	,M.intMachineId
	,M.strName AS strMachineName
	,WI.strReferenceNo
	,WI.dtmActualInputDateTime AS dtmActualTransactionDateTime
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WI.dtmLastModified
	,US.[intEntityId]
	,US.strUserName
	,'STAGE' AS strTransactionName
	,NULL AS dblReadingQty
	,NULL AS dblTotalizerStartReading
	,NULL AS dblTotalizerEndReading
	,NULL AS dblTotalizerQty
	,NULL AS dblPulseStartReading
	,NULL AS dblPulseEndReading
	,NULL AS dblPulseQty
	,W.strComment
	,NULL AS strFormulaUsedForTotalizerReading
	,NULL AS strFormulaUsedForPulseReading
	,NULL AS dblMinMoisture
	,NULL AS dblMoisture
	,NULL AS dblMaxMoisture
	,NULL AS dblMinDensity
	,NULL AS dblDensity
	,NULL AS dblMaxDensity
	,NULL AS dblMinColor
	,NULL AS dblColor
	,NULL AS dblMaxColor
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,S.intShiftId
	,S.strShiftName
	,WI.dtmProductionDate
	,1 AS intSequenceNo
	,'' AS strBatchId
	,O.intOwnerId 
	,PL.strParentLotNumber
	,Convert(nvarchar(50),'') As strSpecialPalletId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFShift BS ON BS.intShiftId = WI.intBusinessShiftId
JOIN dbo.tblICItem II ON II.intItemId = WI.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WI.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WI.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
JOIN dbo.tblMFMachine M ON M.intMachineId = WI.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WI.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = WI.intLastModifiedUserId
Left JOIN tblICItemOwner O on O.intItemOwnerId=L.intItemOwnerId
WHERE WI.ysnConsumptionReversed = 0

UNION

SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId AS intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity AS dblPlannedQty
	,UM.intUnitMeasureId AS intTargetUnitMeasureId
	,UM.strUnitMeasure AS strTargetUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId AS intPlannedShiftId
	,PS.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,II.intItemId
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,WI.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WP.dtmBusinessDate
	,BS.intShiftId AS intBusinessShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [strFromTo]
	,M.intMachineId
	,M.strName AS strMachineName
	,WI.strReferenceNo
	,WI.dtmActualInputDateTime AS dtmActualTransactionDateTime
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WI.dtmLastModified
	,US.[intEntityId]
	,US.strUserName
	,'CONSUME' AS strTransactionName
	,NULL AS dblReadingQty
	,NULL AS dblTotalizerStartReading
	,NULL AS dblTotalizerEndReading
	,NULL AS dblTotalizerQty
	,NULL AS dblPulseStartReading
	,NULL AS dblPulseEndReading
	,NULL AS dblPulseQty
	,W.strComment
	,NULL AS strFormulaUsedForTotalizerReading
	,NULL AS strFormulaUsedForPulseReading
	,NULL AS dblMinMoisture
	,NULL AS dblMoisture
	,NULL AS dblMaxMoisture
	,NULL AS dblMinDensity
	,NULL AS dblDensity
	,NULL AS dblMaxDensity
	,NULL AS dblMinColor
	,NULL AS dblColor
	,NULL AS dblMaxColor
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,S.intShiftId
	,S.strShiftName
	,IsNULL(WP.dtmProductionDate,W.dtmPlannedDate )
	,1 AS intSequenceNo
	,WI.strBatchId
	,O.intOwnerId
	,PL.strParentLotNumber
	,Convert(nvarchar(50),'') As strSpecialPalletId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderConsumedLot WI ON WI.intWorkOrderId = W.intWorkOrderId
Left JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intBatchId = WI.intBatchId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFShift BS ON BS.intShiftId = WP.intBusinessShiftId
JOIN dbo.tblICItem II ON II.intItemId = WI.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WI.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WI.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = WI.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WI.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = WI.intLastModifiedUserId
Left JOIN dbo.tblICItemOwner O on O.intItemOwnerId=L.intItemOwnerId
UNION

SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId AS intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity AS dblPlannedQty
	,UM.intUnitMeasureId AS intTargetUnitMeasureId
	,UM.strUnitMeasure AS strTargetUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId AS intPlannedShiftId
	,PS.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,II.intItemId
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,- WI.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WI.dtmBusinessDate
	,BS.intShiftId AS intBusinessShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [strFromTo]
	,M.intMachineId
	,M.strName AS strMachineName
	,WI.strReferenceNo
	,WI.dtmActualInputDateTime AS dtmActualTransactionDateTime
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WI.dtmLastModified
	,US.[intEntityId]
	,US.strUserName
	,'STAGE REVERSAL' AS strTransactionName
	,NULL AS dblReadingQty
	,NULL AS dblTotalizerStartReading
	,NULL AS dblTotalizerEndReading
	,NULL AS dblTotalizerQty
	,NULL AS dblPulseStartReading
	,NULL AS dblPulseEndReading
	,NULL AS dblPulseQty
	,W.strComment
	,NULL AS strFormulaUsedForTotalizerReading
	,NULL AS strFormulaUsedForPulseReading
	,NULL AS dblMinMoisture
	,NULL AS dblMoisture
	,NULL AS dblMaxMoisture
	,NULL AS dblMinDensity
	,NULL AS dblDensity
	,NULL AS dblMaxDensity
	,NULL AS dblMinColor
	,NULL AS dblColor
	,NULL AS dblMaxColor
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,S.intShiftId
	,S.strShiftName
	,WI.dtmProductionDate
	,2 AS intSequenceNo
	,'' AS strBatchId
	,O.intOwnerId
	,PL.strParentLotNumber
	,Convert(nvarchar(50),'') As strSpecialPalletId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFShift BS ON BS.intShiftId = WI.intBusinessShiftId
JOIN dbo.tblICItem II ON II.intItemId = WI.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WI.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WI.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
JOIN dbo.tblMFMachine M ON M.intMachineId = WI.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WI.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = WI.intLastModifiedUserId
Left JOIN dbo.tblICItemOwner O on O.intItemOwnerId=L.intItemOwnerId
WHERE WI.ysnConsumptionReversed = 1

UNION

SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,ISNULL(W.dtmOrderDate, W.dtmCreated) AS dtmOrderDate
	,I.intItemId AS intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity
	,UM.intUnitMeasureId
	,UM.strUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId
	,PS.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,II.intItemId
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,WP.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WP.dtmBusinessDate
	,BS.intShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [strFromTo]
	,ISNULL(M.intMachineId, 0) AS intMachineId
	,ISNULL(M.strName, '') AS strMachineName
	,WP.strReferenceNo
	,WP.dtmLastModified
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WP.dtmLastModified
	,US.[intEntityId]
	,US.strUserName
	,'PRODUCE' AS strTransactionName
	,NULL AS dblReadingQty
	,NULL AS dblTotalizerStartReading
	,NULL AS dblTotalizerEndReading
	,NULL AS dblTotalizerQty
	,NULL AS dblPulseStartReading
	,NULL AS dblPulseEndReading
	,NULL AS dblPulseQty
	,W.strComment
	,NULL AS strFormulaUsedForTotalizerReading
	,NULL AS strFormulaUsedForPulseReading
	,NULL AS dblMinMoisture
	,NULL AS dblMoisture
	,NULL AS dblMaxMoisture
	,NULL AS dblMinDensity
	,NULL AS dblDensity
	,NULL AS dblMaxDensity
	,NULL AS dblMinColor
	,NULL AS dblColor
	,NULL AS dblMaxColor
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,ISNULL(S.intShiftId, 0) AS intShiftId
	,ISNULL(S.strShiftName, '') AS strShiftName
	,WP.dtmProductionDate
	,3 AS intSequenceNo
	,WP.strBatchId 
	,O.intOwnerId
	,PL.strParentLotNumber
	,L1.strLotNumber AS strSpecialPalletId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFShift BS ON BS.intShiftId = WP.intBusinessShiftId
JOIN dbo.tblICItem II ON II.intItemId = WP.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WP.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WP.intStorageLocationId
LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = WP.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WP.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = WP.intLastModifiedUserId
Left JOIN dbo.tblICItemOwner O on O.intItemOwnerId=L.intItemOwnerId
LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = WP.intSpecialPalletLotId
WHERE WP.ysnProductionReversed = 0

UNION

SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,ISNULL(W.dtmOrderDate, W.dtmCreated) AS dtmOrderDate
	,I.intItemId AS intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity
	,UM.intUnitMeasureId
	,UM.strUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId
	,PS.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,II.intItemId
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,- WP.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WP.dtmBusinessDate
	,BS.intShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [FROM/To]
	,ISNULL(M.intMachineId, 0) AS intMachineId
	,ISNULL(M.strName, '') AS strMachineName
	,WP.strReferenceNo
	,WP.dtmLastModified
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WP.dtmLastModified
	,US.[intEntityId]
	,US.strUserName
	,'PRODUCE REVERSAL' AS TransactionName
	,NULL AS dblReadingQty
	,NULL AS dblTotalizerStartReading
	,NULL AS dblTotalizerEndReading
	,NULL AS dblTotalizerQty
	,NULL AS dblPulseStartReading
	,NULL AS dblPulseEndReading
	,NULL AS dblPulseQty
	,W.strComment
	,NULL AS strFormulaUsedForTotalizerReading
	,NULL AS strFormulaUsedForPulseReading
	,NULL AS dblMinMoisture
	,NULL AS dblMoisture
	,NULL AS dblMaxMoisture
	,NULL AS dblMinDensity
	,NULL AS dblDensity
	,NULL AS dblMaxDensity
	,NULL AS dblMinColor
	,NULL AS dblColor
	,NULL AS dblMaxColor
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,ISNULL(S.intShiftId, 0) AS intShiftId
	,ISNULL(S.strShiftName, '') AS strShiftName
	,WP.dtmProductionDate
	,4 AS intSequenceNo
	,WP.strBatchId
	,O.intOwnerId
	,PL.strParentLotNumber
	,L1.strLotNumber AS strSpecialPalletId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFShift BS ON BS.intShiftId = WP.intBusinessShiftId
JOIN dbo.tblICItem II ON II.intItemId = WP.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WP.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WP.intStorageLocationId
LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = WP.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WP.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = WP.intLastModifiedUserId
Left JOIN dbo.tblICItemOwner O on O.intItemOwnerId=L.intItemOwnerId
LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = WP.intSpecialPalletLotId
WHERE WP.ysnProductionReversed = 1
