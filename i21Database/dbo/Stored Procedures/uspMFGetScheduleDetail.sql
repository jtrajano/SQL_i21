CREATE PROC uspMFGetScheduleDetail (
	@intManufacturingCellId INT = 0
	,@dtmPlannedStartDate DATE
	,@dtmPlannedEndDate DATE
	,@intLocationId INT
	,@intScheduleId INT
	)
AS
DECLARE @ysnConsiderSumOfChangeoverTime BIT

DECLARE @tblMFScheduleConstraintDetail TABLE (
	intScheduleConstraintDetailId INT identity(1, 1)
	,intWorkOrderId INT
	,intScheduleRuleId INT
	,dtmChangeoverStartDate DATETIME
	,dtmChangeoverEndDate DATETIME
	,intDuration INT
		,intManufacturingCellId int
	,strCellName nvarchar(50) COLLATE Latin1_General_CI_AS
	,strWorkOrderNo nvarchar(50) COLLATE Latin1_General_CI_AS
	,strBackColorName nvarchar(50) COLLATE Latin1_General_CI_AS
	,strName nvarchar(50) COLLATE Latin1_General_CI_AS
	,intExecutionOrder int
	,strRowId nvarchar(50) COLLATE Latin1_General_CI_AS
	)

SELECT @ysnConsiderSumOfChangeoverTime = ysnConsiderSumOfChangeoverTime
FROM dbo.tblMFCompanyPreference

INSERT INTO @tblMFScheduleConstraintDetail (
	intWorkOrderId
	,intScheduleRuleId
	,dtmChangeoverStartDate
	,dtmChangeoverEndDate
	,intDuration
	,intManufacturingCellId
	,strCellName
	,strWorkOrderNo
	,strBackColorName
	,strName
	,intExecutionOrder
	,strRowId
	)
SELECT SC.intWorkOrderId
	,SC.intScheduleRuleId
	,SC.dtmChangeoverStartDate
	,SC.dtmChangeoverEndDate
	,SC.intDuration
	,MC.intManufacturingCellId
	,MC.strCellName
	,W.strWorkOrderNo
	,SR.strBackColorName
	,SR.strName
	,W.intExecutionOrder
	,Ltrim(W.intWorkOrderId)+Ltrim(SR.intScheduleRuleId)
FROM tblMFScheduleConstraintDetail SC
JOIN tblMFWorkOrder W ON W.intWorkOrderId = SC.intWorkOrderId
JOIN dbo.tblMFScheduleRule SR ON SR.intScheduleRuleId = SC.intScheduleRuleId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
WHERE ((SC.dtmChangeoverStartDate >= @dtmPlannedStartDate
    AND SC.dtmChangeoverEndDate <= @dtmPlannedEndDate)
	OR @dtmPlannedStartDate BETWEEN SC.dtmChangeoverStartDate AND SC.dtmChangeoverEndDate OR @dtmPlannedEndDate BETWEEN SC.dtmChangeoverStartDate AND SC.dtmChangeoverEndDate)
	AND SC.intScheduleId = (
		CASE 
			WHEN @intScheduleId = 0
				THEN SC.intScheduleId
			ELSE @intScheduleId
			END
		)
	AND W.intLocationId = @intLocationId
	AND W.intManufacturingCellId = (
		CASE 
			WHEN @intManufacturingCellId = 0
				THEN W.intManufacturingCellId
			ELSE @intManufacturingCellId
			END
		)

IF @ysnConsiderSumOfChangeoverTime = 0
BEGIN
	WITH RemoveUnusedData (RowNumber)
	AS (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY intWorkOrderId ORDER BY intDuration DESC
				)
		FROM @tblMFScheduleConstraintDetail
		)
	DELETE
	FROM RemoveUnusedData
	WHERE RowNumber > 1
END

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
	,CONVERT(BIT, 0) AS ysnAlternateLine
	,0 AS intByWhichDate
	,'' AS strCustOrderNo
	,'' AS strChangeover
	,0 AS intLeadTime
	,'' AS strCustomer
	,Ltrim(W.intWorkOrderId) AS strRowId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	AND IU.ysnStockUnit = 1
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	AND intScheduleId = (
		CASE 
			WHEN @intScheduleId = 0
				THEN SL.intScheduleId
			ELSE @intScheduleId
			END
		)
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
WHERE W.intLocationId = @intLocationId
	AND MC.intManufacturingCellId = (
		CASE 
			WHEN @intManufacturingCellId = 0
				THEN MC.intManufacturingCellId
			ELSE @intManufacturingCellId
			END
		)
	AND (@dtmPlannedStartDate BETWEEN SL.dtmPlannedStartDate AND SL.dtmPlannedEndDate 
		OR @dtmPlannedEndDate BETWEEN SL.dtmPlannedStartDate AND SL.dtmPlannedEndDate
		    OR (SL.dtmPlannedStartDate >= @dtmPlannedStartDate
			AND SL.dtmPlannedEndDate <= @dtmPlannedEndDate))

UNION

SELECT SC.intManufacturingCellId
	,SC.strCellName
	,SC.intWorkOrderId
	,SC.strWorkOrderNo
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
	,SC.strBackColorName
	,SC.intDuration
	,SC.dtmChangeoverStartDate
	,SC.dtmChangeoverEndDate
	,NULL strScheduleComment
	,SC.intExecutionOrder
	,CONVERT(BIT, 0) ysnFrozen
	,NULL intShiftId
	,NULL strShiftName
	,NULL OrderLineItemId
	,CONVERT(BIT, 0) AS ysnAlternateLine
	,0 AS intByWhichDate
	,NULL AS strCustOrderNo
	,SC.strName AS strChangeover
	,SC.intDuration AS intLeadTime
	,NULL AS strCustomer
	,strRowId
FROM @tblMFScheduleConstraintDetail SC
ORDER BY intExecutionOrder
