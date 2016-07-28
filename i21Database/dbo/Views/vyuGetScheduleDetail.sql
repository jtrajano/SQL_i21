CREATE VIEW vyuGetScheduleDetail
AS
SELECT W.strWorkOrderNo
	,I.strItemNo
	,I.strDescription
	,W.dtmExpectedDate
	,W.dblQuantity
	,U.strUnitMeasure
	,WS.strName AS strStatusName
	,ISNULL(SWD.dtmPlannedStartDate, W.dtmExpectedDate) dtmPlannedStartDate
	,ISNULL(Round(SWD.dblPlannedQty, 0), W.dblQuantity) dblPlannedQty
	,S.strShiftName AS strPlannedShiftName
	,MC.strCellName
	,MP.strProcessName
	,US.strUserName AS strCreatedBy
	,OH.strBOLNo AS strPickNo
	,OS.strOrderStatus
FROM dbo.tblMFWorkOrder W
INNER JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	AND W.intStatusId <> 13
INNER JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
INNER JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
INNER JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
INNER JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
INNER JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
INNER JOIN dbo.tblSMUserSecurity US ON US.intEntityUserSecurityId = W.intCreatedUserId
LEFT JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON W.intWorkOrderId = SWD.intWorkOrderId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = SWD.intPlannedShiftId
LEFT JOIN dbo.tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
	AND SW.dtmPlannedDate = ISNULL(SWD.dtmPlannedStartDate, W.dtmExpectedDate)
	AND ISNULL(SW.intPlannnedShiftId, 0) = ISNULL(SWD.intPlannedShiftId, 0)
LEFT JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
LEFT JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
