CREATE PROC uspMFGetScheduleDetail (
	@intManufacturingCellId int= NULL
	,@dtmPlannedStartDate DATE
	,@dtmPlannedEndDate DATE
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
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	AND IU.ysnStockUnit = 1
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
JOIN tblMFSchedule S ON S.intScheduleId = SL.intScheduleId
	AND S.ysnStandard = 1
JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
WHERE W.intLocationId = 1
	AND MC.intManufacturingCellId = (
		CASE 
			WHEN @intManufacturingCellId IS NULL
				THEN MC.intManufacturingCellId
			ELSE @intManufacturingCellId
			END
		)
	AND SL.dtmPlannedStartDate >= @dtmPlannedStartDate
	AND SL.dtmPlannedEndDate <= @dtmPlannedEndDate
