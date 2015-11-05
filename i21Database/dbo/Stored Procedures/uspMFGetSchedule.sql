﻿CREATE PROCEDURE uspMFGetSchedule (
	@intManufacturingCellId INT
	,@intScheduleId INT
	,@dtmFromDate datetime=NULL
	,@dtmToDate datetime=NULL
	)
AS
Declare @dtmCurrentDate datetime
Select @dtmCurrentDate=GETDATE()

IF @dtmFromDate IS NULL
BEGIN
	SELECT @dtmFromDate=@dtmCurrentDate
	SELECT @dtmToDate=@dtmFromDate+intDefaultGanttChartViewDuration from tblMFCompanyPreference
END

IF @intScheduleId >0
BEGIN
	SELECT S.intScheduleId
		,S.strScheduleNo
		,S.dtmScheduleDate
		,S.intCalendarId
		,SC.strName
		,S.intManufacturingCellId
		,MC.strCellName
		,S.ysnStandard
		,S.intLocationId
		,S.intConcurrencyId
		,S.dtmCreated
		,S.intCreatedUserId
		,S.dtmLastModified
		,S.intLastModifiedUserId
		,@dtmFromDate AS dtmFromDate
		,@dtmToDate AS dtmToDate
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
	JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = S.intCalendarId
	WHERE intScheduleId = @intScheduleId

	Select @intManufacturingCellId=S.intManufacturingCellId from dbo.tblMFSchedule S WHERE S.intScheduleId = @intScheduleId
END
ELSE
BEGIN
	SELECT 0 AS intScheduleId
		,'' AS strScheduleNo
		,@dtmCurrentDate AS dtmScheduleDate
		,0 AS intCalendarId
		,'' AS strName
		,@intManufacturingCellId AS intManufacturingCellId
		,'' AS strCellName
		,CONVERT(bit,0) AS ysnStandard
		,0 AS intLocationId
		,0 AS intConcurrencyId
		,@dtmCurrentDate AS dtmCreated
		,0 AS intCreatedUserId
		,@dtmCurrentDate AS dtmLastModified
		,0 AS intLastModifiedUserId
		,@dtmFromDate AS dtmFromDate
		,@dtmToDate AS dtmToDate
END

SELECT C.intManufacturingCellId
	,C.strCellName
	,W.intWorkOrderId
	,Isnull(S.intScheduleId, 0) intScheduleId
	,W.strWorkOrderNo
	,W.dblQuantity
	,W.dtmExpectedDate
	,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	,W.dblProducedQuantity
	,W.strComment AS strWorkOrderComments
	,W.dtmOrderDate
	,W.dtmLastProducedDate 
	,(
		SELECT TOP 1 strItemNo
		FROM dbo.tblMFRecipeItem RI
		JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
		WHERE RI.intRecipeId = R.intRecipeId
			AND WI.strType = 'Assembly/Blend'
		) AS strWIPItemNo
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,IU.intItemUOMId
	,U.intUnitMeasureId
	,U.strUnitMeasure
	,WS.intStatusId
	,WS.strName AS strStatusName
	,PT.intProductionTypeId
	,PT.strName AS strProductionType
	,SL.intScheduleWorkOrderId
	,SL.intDuration
	,SL.dtmChangeoverStartDate
	,SL.dtmChangeoverEndDate
	,SL.dtmPlannedStartDate
	,SL.dtmPlannedEndDate
	,ISNULL(SL.intExecutionOrder,W.intExecutionOrder) intExecutionOrder
	,SL.intChangeoverDuration
	,SL.intSetupDuration
	,SL.strComments
	,SL.strNote
	,SL.strAdditionalComments
	,SL.intNoOfSelectedMachine
	,SL.dtmEarliestStartDate
	,SL.intPlannedShiftId
	,SL.ysnFrozen
	,SH.strShiftName
	,P.intPackTypeId
	,P.strPackName
	,Isnull(SL.intConcurrencyId, 0) AS intConcurrencyId
	,SL.dtmCreated
	,SL.intCreatedUserId
	,SL.dtmLastModified
	,SL.intLastModifiedUserId
	,WS.intSequenceNo
	,W.ysnIngredientAvailable 
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = W.intManufacturingCellId
	AND W.intStatusId <> 13
	AND W.intManufacturingCellId = @intManufacturingCellId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
LEFT JOIN dbo.tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
LEFT JOIN dbo.tblMFSchedule S ON S.intScheduleId = @intScheduleId
	--AND S.ysnStandard = 1
LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	AND S.intScheduleId = SL.intScheduleId
LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
LEFT JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = IsNULL(SL.intStatusId,W.intStatusId)
JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
	AND R.intLocationId = C.intLocationId
	AND R.ysnActive = 1
ORDER BY WS.intSequenceNo DESC
	,SL.intExecutionOrder

SELECT WD.intScheduleWorkOrderDetailId
	,WD.intScheduleWorkOrderId
	,WD.intWorkOrderId
	,WD.intScheduleId
	,WD.dtmPlannedStartDate
	,WD.dtmPlannedEndDate
	,WD.intPlannedShiftId
	,WD.intDuration
	,WD.dblPlannedQty
	,WD.intSequenceNo
	,WD.intCalendarDetailId
	,WD.intConcurrencyId
FROM dbo.tblMFScheduleWorkOrderDetail WD
WHERE WD.intScheduleId = @intScheduleId

SELECT M.intScheduleMachineDetailId
	,M.intScheduleWorkOrderDetailId
	,M.intWorkOrderId
	,M.intScheduleId
	,M.intCalendarMachineId
	,M.intCalendarDetailId
	,M.intConcurrencyId
FROM dbo.tblMFScheduleMachineDetail M
WHERE M.intScheduleId = @intScheduleId

SELECT C.intScheduleConstraintDetailId
	,C.intScheduleWorkOrderId
	,C.intWorkOrderId
	,C.intScheduleId
	,C.intScheduleRuleId
	,C.dtmChangeoverStartDate
	,C.dtmChangeoverEndDate
	,C.intDuration
	,C.intConcurrencyId
FROM dbo.tblMFScheduleConstraintDetail C
WHERE C.intScheduleId = @intScheduleId

