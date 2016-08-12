CREATE VIEW vyuMFGetProductionOrder
AS
SELECT IsNULL(BR.intBlendRequirementId, 0) AS intBlendRequirementId
	,IsNull(BR.strDemandNo, '') AS strDemandNo
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmCreated
	,W.dtmExpectedDate
	,W.intCreatedUserId
	,US.strUserName
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,W.dblQuantity
	,IU.intItemUOMId
	,UM.intUnitMeasureId
	,UM.strUnitMeasure
	,MC.intManufacturingCellId
	,MC.strCellName
	,WS.strName
	,W.strComment
	,W.intLocationId
	,W.intConcurrencyId
	,ISNULL(SWD.dtmPlannedStartDate, W.dtmExpectedDate) dtmPlannedDate
	,ISNULL(Round(SWD.dblPlannedQty, 0), W.dblQuantity) dblPlannedQty
	,S.intShiftId
	,S.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,OH.intOrderHeaderId
	,OH.strBOLNo
	,OS.strOrderStatus
	,ROW_NUMBER() OVER (
		ORDER BY W.intWorkOrderId DESC
		) AS intRecordId
	,SW1.strComments AS strScheduleComments
FROM dbo.tblMFWorkOrder W
INNER JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	AND W.intStatusId <> 13
INNER JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
INNER JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
INNER JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
INNER JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
INNER JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
INNER JOIN dbo.tblSMUserSecurity US ON US.intEntityUserSecurityId = W.intCreatedUserId
LEFT JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON W.intWorkOrderId = SWD.intWorkOrderId
LEFT JOIN dbo.tblMFScheduleWorkOrder SW1 ON SW1.intScheduleWorkOrderId = SWD.intScheduleWorkOrderId
LEFT JOIN dbo.tblMFSchedule S1 ON S1.intScheduleId = SW1.intScheduleId
	AND S1.ysnStandard = 1
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = SWD.intPlannedShiftId
LEFT JOIN dbo.tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
	AND SW.dtmPlannedDate = ISNULL(SWD.dtmPlannedStartDate, W.dtmExpectedDate)
	AND ISNULL(SW.intPlannnedShiftId, 0) = ISNULL(SWD.intPlannedShiftId, 0)
LEFT JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
LEFT JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
LEFT JOIN dbo.tblMFBlendRequirement BR ON W.intBlendRequirementId = BR.intBlendRequirementId
WHERE W.intStatusId IN (
		9
		,10
		,11
		)
