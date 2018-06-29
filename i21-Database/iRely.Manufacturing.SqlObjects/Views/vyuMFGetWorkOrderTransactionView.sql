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
	,NULL AS [strRelatedPalletNo]
	,NULL AS [strRelatedStorageLocation]
	,NULL AS [strOldItemNo]
	,NULL AS [dtmOldExpiryDate]
	,NULL AS [dtmNewExpiryDate]
	,NULL AS [strOldPalletStatus]
	,NULL AS [strNewPalletStatus]
	,NULL AS [strOldOwnerName]
	,NULL AS [strNewOwnerName]
	,NULL AS [strReason]
	,L.dblLastCost 
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
	,NULL AS [strRelatedPalletNo]
	,NULL AS [strRelatedStorageLocation]
	,NULL AS [strOldItemNo]
	,NULL AS [dtmOldExpiryDate]
	,NULL AS [dtmNewExpiryDate]
	,NULL AS [strOldPalletStatus]
	,NULL AS [strNewPalletStatus]
	,NULL AS [strOldOwnerName]
	,NULL AS [strNewOwnerName]
	,NULL AS [strReason]
	,L.dblLastCost 
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
	,NULL AS [strRelatedPalletNo]
	,NULL AS [strRelatedStorageLocation]
	,NULL AS [strOldItemNo]
	,NULL AS [dtmOldExpiryDate]
	,NULL AS [dtmNewExpiryDate]
	,NULL AS [strOldPalletStatus]
	,NULL AS [strNewPalletStatus]
	,NULL AS [strOldOwnerName]
	,NULL AS [strNewOwnerName]
	,NULL AS [strReason]
	,L.dblLastCost 
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
	,ISNULL(WP.strComment, W.strComment) AS strComment
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
	,NULL AS [strRelatedPalletNo]
	,NULL AS [strRelatedStorageLocation]
	,NULL AS [strOldItemNo]
	,NULL AS [dtmOldExpiryDate]
	,NULL AS [dtmNewExpiryDate]
	,NULL AS [strOldPalletStatus]
	,NULL AS [strNewPalletStatus]
	,NULL AS [strOldOwnerName]
	,NULL AS [strNewOwnerName]
	,NULL AS [strReason]
	,L.dblLastCost 
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
LEFT JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
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
	,ISNULL(WP.strComment, W.strComment) AS strComment
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
	,NULL AS [strRelatedPalletNo]
	,NULL AS [strRelatedStorageLocation]
	,NULL AS [strOldItemNo]
	,NULL AS [dtmOldExpiryDate]
	,NULL AS [dtmNewExpiryDate]
	,NULL AS [strOldPalletStatus]
	,NULL AS [strNewPalletStatus]
	,NULL AS [strOldOwnerName]
	,NULL AS [strNewOwnerName]
	,NULL AS [strReason]
	,L.dblLastCost 
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
LEFT JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
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
UNION
SELECT -1 As  intWorkOrderId
	,NULL AS strWorkOrderNo
	,IA.dtmDate AS [Transaction Date]
	,NULL AS intTargetItemId
	,NULL AS strTargetItemType
	,NULL AS strTargetItemNo
	,NULL AS strTargetItemDesc
	,NULL AS strTargetItemShortDesc
	,NULL As dblQuantity
	,NULL As intUnitMeasureId
	,NULL As strUnitMeasure
	,NULL As strStatusName
	,NULL AS intManufacturingCellId
	,NULL AS strCellName
	,NULL AS dtmPlannedDate
	,NULL AS intShiftId
	,NULL AS strPlannedShiftName
	,NULL AS intManufacturingProcessId
	,NULL AS strProcessName
	,I1.intItemId
	,I1.strType
	,I1.strItemNo AS [Item No]
	,I1.strDescription AS [Item Desc]
	,I1.strShortName AS strShortDesc
	,IA.dblQty AS dblQuantity
	,UM.intUnitMeasureId
	,UM.strUnitMeasure 
	,dtmBusinessDate AS [Business Date]
	,S.intShiftId
	,S.strShiftName AS strBusinessShiftName
	,SL1.intStorageLocationId 
	,SL1.strName AS [FROM/To]
	,NULL As intMachineId
	,NULL As strMachineName
	,NULL As strReferenceNo
	,IA.dtmDate AS dtmLastModified
	,NULL As intContainerId
	,NULL As strContainerId
	,NULL As intContainerTypeId
	,NULL As strContainerType
	,IA.dtmDate AS dtmLastModified
	,US.intEntityId 
	,US.strUserName 
	,TT.strName AS TransactionName
	,NULL AS dblReadingQty
	,NULL AS dblTotalizerStartReading
	,NULL AS dblTotalizerEndReading
	,NULL AS dblTotalizerQty
	,NULL AS dblPulseStartReading
	,NULL AS dblPulseEndReading
	,NULL AS dblPulseQty
	,IA.strNote As strComment
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
	,L1.intLotId
	,L1.strLotNumber 
	,L1.strLotAlias 
	,S.intShiftId As intShiftId
	,S.strShiftName As strShiftName
	,IA.dtmDate AS dtmProductionDate
	,5 AS intSequenceNo
	,NULL As strBatchId
	,NULL As intOwnerId
	,PL.strParentLotNumber 
	,NULL As strSpecialPalletId
	,L2.strLotNumber AS [Related Pallet No]
	,SL2.strName AS [Related Storage Location]
	,I2.strItemNo AS [Old Item No]
	,dtmOldExpiryDate AS [Old Expiry Date]
	,dtmNewExpiryDate AS [New Expiry Date]
	,LS1.strSecondaryStatus AS [Old Pallet Status]
	,LS2.strSecondaryStatus AS [New Pallet Status]
	,E1.strName AS [Old Owner Name]
	,E2.strName AS [New Owner Name]
	,IA.strReason AS [Reason]
	,L1.dblLastCost 
FROM tblMFInventoryAdjustment IA
JOIN tblICItem I1 ON I1.intItemId = IA.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IA.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = IA.intStorageLocationId
JOIN tblICLot L1 ON L1.intLotId = IA.intSourceLotId
JOIN tblICParentLot PL On PL.intParentLotId =L1.intParentLotId 
LEFT JOIN tblICLot L2 ON L2.intLotId = IA.intDestinationLotId
LEFT JOIN tblICStorageLocation SL2 ON SL2.intStorageLocationId = IA.intDestinationStorageLocationId
JOIN tblICInventoryTransactionType TT ON TT.intTransactionTypeId = IA.intTransactionTypeId
LEFT JOIN tblICItem I2 ON I2.intItemId = IA.intOldItemId
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = IA.intOldLotStatusId
LEFT JOIN tblICLotStatus LS2 ON LS2.intLotStatusId = IA.intNewLotStatusId
JOIN tblSMUserSecurity US ON US.intEntityId = IA.intUserId
LEFT JOIN tblMFShift S ON S.intShiftId = IA.intBusinessShiftId
LEFT JOIN tblICItemOwner IO1 ON IO1.intItemOwnerId = IA.intOldItemOwnerId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = IO1.intOwnerId
LEFT JOIN tblICItemOwner IO2 ON IO2.intItemOwnerId = IA.intNewItemOwnerId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = IO2.intOwnerId