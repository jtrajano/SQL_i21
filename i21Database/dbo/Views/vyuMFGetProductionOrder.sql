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
	,ISNULL(CD.dtmCalendarDate, W.dtmPlannedDate) dtmPlannedDate
	,ISNULL(Round(SWD.dblPlannedQty, 0), W.dblQuantity) dblPlannedQty
	,S.intShiftId
	,S.strShiftName AS strPlannedShiftName
	,MP.intManufacturingProcessId
	,MP.strProcessName
	,OH.intOrderHeaderId
	,OH.strOrderNo
	,OS.strOrderStatus
	,Convert(INT, ROW_NUMBER() OVER (
			ORDER BY W.intWorkOrderId DESC
			)) AS intRecordId
	,SW1.strComments AS strScheduleComments
	,W.intPickListId 
	,CL.strLocationName
	,PL.strPickListNo
	,WS1.strName as strPickListStatus
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblSMCompanyLocation CL on CL.intCompanyLocationId =W.intLocationId 
INNER JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	AND W.intStatusId <> 13
INNER JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
INNER JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
INNER JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
INNER JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
INNER JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
INNER JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
LEFT JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON W.intWorkOrderId = SWD.intWorkOrderId
LEFT JOIN dbo.tblMFScheduleWorkOrder SW1 ON SW1.intScheduleWorkOrderId = SWD.intScheduleWorkOrderId
LEFT JOIN dbo.tblMFSchedule S1 ON S1.intScheduleId = SW1.intScheduleId
	AND S1.ysnStandard = 1
LEFT JOIN tblMFScheduleCalendarDetail CD ON CD.intCalendarDetailId = SWD.intCalendarDetailId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = IsNULL(SWD.intPlannedShiftId,W.intPlannedShiftId)
LEFT JOIN dbo.tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
	AND SW.dtmPlannedDate = ISNULL(CD.dtmCalendarDate, W.dtmPlannedDate)
	AND CASE 
		WHEN ISNULL(SW.intPlannnedShiftId, 0) = 0
			THEN ISNULL(SWD.intPlannedShiftId, 0)
		ELSE ISNULL(SW.intPlannnedShiftId, 0)
		END = ISNULL(SWD.intPlannedShiftId, 0)
LEFT JOIN dbo.tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
LEFT JOIN dbo.tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
LEFT JOIN dbo.tblMFBlendRequirement BR ON W.intBlendRequirementId = BR.intBlendRequirementId
Left JOIN dbo.tblMFPickList PL on PL.intPickListId=W.intPickListId
Left JOIN dbo.tblMFWorkOrderStatus WS1 ON WS1.intStatusId = W.intKitStatusId
WHERE W.intStatusId IN (
		9
		,10
		,11
		)
