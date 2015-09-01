CREATE VIEW vyuMFGetWorkOrderTransactionView
AS
SELECT W.intWorkOrderId,
	W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId as intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity AS dblPlannedQty
	,UM.intUnitMeasureId as intTargetUnitMeasureId
	,UM.strUnitMeasure AS strTargetUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId as intPlannedShiftId
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
	,BS.intShiftId as intBusinessShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [strFromTo]
	,M.intMachineId
	,M.strName AS strMachineName
	,WI.strReferenceNo
	,WI.dtmActualInputDateTime as dtmActualTransactionDateTime
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WI.dtmLastModified
	,US.intUserSecurityID
	,US.strUserName
	,'CONSUME' AS strTransactionName
	,NULL as dblReadingQty
	,NULL as dblTotalizerStartReading
	,NULL as dblTotalizerEndReading
	,NULL as dblTotalizerQty
	,NULL as dblPulseStartReading
	,NULL as dblPulseEndReading
	,NULL as dblPulseQty
	,W.strComment
	,NULL as strFormulaUsedForTotalizerReading
	,NULL as strFormulaUsedForPulseReading
	,NULL as dblMinMoisture
	,NULL as dblMoisture
	,NULL as dblMaxMoisture
	,NULL as dblMinDensity
	,NULL as dblDensity
	,NULL as dblMaxDensity
	,NULL as dblMinColor
	,NULL as dblColor
	,NULL as dblMaxColor
	,L.intLotId 
	,L.strLotNumber 
	,L.strLotAlias 
	,S.intShiftId 
	,S.strShiftName 
	,WI.dtmProductionDate 
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
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WI.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
JOIN dbo.tblMFMachine M ON M.intMachineId = WI.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WI.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.intUserSecurityID = WI.intLastModifiedUserId
WHERE WI.ysnConsumptionReversed = 0

UNION
SELECT W.intWorkOrderId,
	W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId as intTargetItemId
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,W.dblQuantity AS dblPlannedQty
	,UM.intUnitMeasureId as intTargetUnitMeasureId
	,UM.strUnitMeasure AS strTargetUnitMeasure
	,WS.strName AS strStatusName
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.intShiftId As intPlannedShiftId
	,PS.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,II.intItemId
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,-WI.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WI.dtmBusinessDate
	,BS.intShiftId as intBusinessShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [strFromTo]
	,M.intMachineId
	,M.strName AS strMachineName
	,WI.strReferenceNo
	,WI.dtmActualInputDateTime as dtmActualTransactionDateTime
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WI.dtmLastModified
	,US.intUserSecurityID
	,US.strUserName
	,'REVERSAL' AS strTransactionName
	,NULL as dblReadingQty
	,NULL as dblTotalizerStartReading
	,NULL as dblTotalizerEndReading
	,NULL as dblTotalizerQty
	,NULL as dblPulseStartReading
	,NULL as dblPulseEndReading
	,NULL as dblPulseQty
	,W.strComment
	,NULL as strFormulaUsedForTotalizerReading
	,NULL as strFormulaUsedForPulseReading
	,NULL as dblMinMoisture
	,NULL as dblMoisture
	,NULL as dblMaxMoisture
	,NULL as dblMinDensity
	,NULL as dblDensity
	,NULL as dblMaxDensity
	,NULL as dblMinColor
	,NULL as dblColor
	,NULL as dblMaxColor
		,L.intLotId 
	,L.strLotNumber 
	,L.strLotAlias
	,S.intShiftId 
	,S.strShiftName 
	,WI.dtmProductionDate 
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
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WI.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
JOIN dbo.tblMFMachine M ON M.intMachineId = WI.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WI.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.intUserSecurityID = WI.intLastModifiedUserId
WHERE WI.ysnConsumptionReversed = 1

UNION
SELECT W.intWorkOrderId,
	W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId as intTargetItemId
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
	,M.intMachineId
	,M.strName AS strMachineName
	,WP.strReferenceNo
	,WP.dtmLastModified
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WP.dtmLastModified
	,US.intUserSecurityID
	,US.strUserName
	,'PRODUCE' AS strTransactionName
	,NULL as dblReadingQty
	,NULL as dblTotalizerStartReading
	,NULL as dblTotalizerEndReading
	,NULL as dblTotalizerQty
	,NULL as dblPulseStartReading
	,NULL as dblPulseEndReading
	,NULL as dblPulseQty
	,W.strComment
	,NULL as strFormulaUsedForTotalizerReading
	,NULL as strFormulaUsedForPulseReading
	,NULL as dblMinMoisture
	,NULL as dblMoisture
	,NULL as dblMaxMoisture
	,NULL as dblMinDensity
	,NULL as dblDensity
	,NULL as dblMaxDensity
	,NULL as dblMinColor
	,NULL as dblColor
	,NULL as dblMaxColor
		,L.intLotId 
	,L.strLotNumber 
	,L.strLotAlias
	,S.intShiftId 
	,S.strShiftName 
	,WP.dtmProductionDate 
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
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WP.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WP.intStorageLocationId
JOIN dbo.tblMFMachine M ON M.intMachineId = WP.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WP.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.intUserSecurityID = WP.intLastModifiedUserId
WHERE WP.ysnProductionReversed = 0
UNION
SELECT W.intWorkOrderId,
	W.strWorkOrderNo
	,W.dtmOrderDate
	,I.intItemId as intTargetItemId
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
	,-WP.dblQuantity
	,IUM.intUnitMeasureId
	,IUM.strUnitMeasure
	,WP.dtmBusinessDate
	,BS.intShiftId
	,BS.strShiftName AS strBusinessShiftName
	,SL.intStorageLocationId
	,SL.strName AS [FROM/To]
	,M.intMachineId
	,M.strName AS strMachineName
	,WP.strReferenceNo
	,WP.dtmLastModified
	,C.intContainerId
	,C.strContainerId
	,CT.intContainerTypeId
	,CT.strDisplayMember AS strContainerType
	,WP.dtmLastModified
	,US.intUserSecurityID
	,US.strUserName
	,'REVERSAL' AS TransactionName
	,NULL as dblReadingQty
	,NULL as dblTotalizerStartReading
	,NULL as dblTotalizerEndReading
	,NULL as dblTotalizerQty
	,NULL as dblPulseStartReading
	,NULL as dblPulseEndReading
	,NULL as dblPulseQty
	,W.strComment
	,NULL as strFormulaUsedForTotalizerReading
	,NULL as strFormulaUsedForPulseReading
	,NULL as dblMinMoisture
	,NULL as dblMoisture
	,NULL as dblMaxMoisture
	,NULL as dblMinDensity
	,NULL as dblDensity
	,NULL as dblMaxDensity
	,NULL as dblMinColor
	,NULL as dblColor
	,NULL as dblMaxColor
		,L.intLotId 
	,L.strLotNumber 
	,L.strLotAlias
		,S.intShiftId 
	,S.strShiftName 
	,WP.dtmProductionDate 
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
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = WP.intShiftId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WP.intStorageLocationId
JOIN dbo.tblMFMachine M ON M.intMachineId = WP.intMachineId
LEFT JOIN dbo.tblICContainer C ON C.intContainerId = WP.intContainerId
LEFT JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
JOIN dbo.tblSMUserSecurity US ON US.intUserSecurityID = WP.intLastModifiedUserId
WHERE WP.ysnProductionReversed = 1

