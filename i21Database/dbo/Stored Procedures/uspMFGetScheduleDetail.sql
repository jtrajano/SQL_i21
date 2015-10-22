CREATE PROC uspMFGetScheduleDetail (
	@intManufacturingCellId int= 0
	,@dtmPlannedStartDate DATE
	,@dtmPlannedEndDate DATE
	,@intLocationId int
	,@intScheduleId int
	)
AS
SELECT MC.intManufacturingCellId
	,MC.strCellName
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dblQuantity
	,W.dblQuantity - ISNULL(W.dblProducedQuantity, 0) AS dblBalanceQuantity
	,W.strComment AS strWorkOrderComment
	,W.dtmExpectedDate
	,W.dtmEarliestDate
	,W.dtmLatestDate
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,IU.intItemUOMId
	,U.intUnitMeasureId
	,U.strUnitMeasure
	,'' AS strAdditive
	,'' AS strAdditiveDesc
	,WS.intStatusId
	,WS.strName AS strStatusName
	,WS.strBackColorName
	,SL.intChangeoverDuration
	,SL.dtmPlannedStartDate
	,SL.dtmPlannedEndDate
	,SL.strComments AS strScheduleComment
	,SL.intExecutionOrder
	,SL.ysnFrozen
	,SH.intShiftId
	,SH.strShiftName
	,0 AS OrderLineItemId
	,CONVERT(BIT,0) AS ysnAlternateLine
	,0 AS intByWhichDate
	,'' AS strCustOrderNo
	,'' AS strChangeover
	,0 AS intLeadTime
	,'' AS strCustomer
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	AND IU.ysnStockUnit = 1
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId AND intScheduleId=(Case When @intScheduleId=0 Then SL.intScheduleId else @intScheduleId end)
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
WHERE W.intLocationId = @intLocationId
	AND MC.intManufacturingCellId = (
		CASE 
			WHEN @intManufacturingCellId =0
				THEN MC.intManufacturingCellId
			ELSE @intManufacturingCellId
			END
		)
	AND SL.dtmPlannedStartDate >= @dtmPlannedStartDate
	AND SL.dtmPlannedEndDate <= @dtmPlannedEndDate
UNION
SELECT W.intManufacturingCellId
	,MC.strCellName
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,NULL dblQuantity
	,NULL dblBalanceQuantity
	,NULL strWorkOrderComment
	,NULL dtmExpectedDate
	,NULL dtmEarliestDate
	,NULL dtmLatestDate
	,NULL intItemId
	,NULL strItemNo
	,NULL strDescription
	,NULL intItemUOMId
	,NULL intUnitMeasureId
	,NULL strUnitMeasure
	,NULL strAdditive
	,NULL strAdditiveDesc
	,NULL intStatusId
	,NULL strStatusName
	,SR.strBackColorName
	,SC.intDuration
	,SC.dtmChangeoverStartDate
	,SC.dtmChangeoverEndDate
	,NULL strScheduleComment
	,SL.intExecutionOrder
	,CONVERT(BIT,0) ysnFrozen
	,NULL intShiftId
	,NULL strShiftName
	,NULL OrderLineItemId
	,CONVERT(BIT,0) AS ysnAlternateLine
	,0 AS intByWhichDate
	,NULL AS strCustOrderNo
	,NULL AS strChangeover
	,SC.intDuration AS intLeadTime
	,NULL AS strCustomer
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId AND intScheduleId=(Case When @intScheduleId=0 Then SL.intScheduleId else @intScheduleId end)
JOIN dbo.tblMFScheduleConstraintDetail SC ON SC.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblMFScheduleRule SR on SR.intScheduleRuleId =SC.intScheduleRuleId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId 
WHERE W.intLocationId = @intLocationId
	AND W.intManufacturingCellId = (
		CASE 
			WHEN @intManufacturingCellId =0
				THEN W.intManufacturingCellId
			ELSE @intManufacturingCellId
			END
		)
	AND SC.dtmChangeoverStartDate >= @dtmPlannedStartDate
	AND SC.dtmChangeoverEndDate <= @dtmPlannedEndDate
	AND SC.intScheduleId=(Case When @intScheduleId=0 Then SC.intScheduleId else @intScheduleId end)
	Order by SL.intExecutionOrder