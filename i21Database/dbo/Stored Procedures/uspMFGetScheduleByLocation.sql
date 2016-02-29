﻿CREATE PROCEDURE uspMFGetScheduleByLocation (
	@intManufacturingCellId INT = 0
	,@dtmPlannedStartDate DATE
	,@dtmPlannedEndDate DATE
	,@intLocationId INT
	)
AS
BEGIN
	SELECT W.intManufacturingCellId
		,W.intWorkOrderId
		,W.strWorkOrderNo
		,SL.intScheduleId
		,W.dblQuantity
		,ISNULL(W.dtmEarliestDate, W.dtmExpectedDate) AS dtmEarliestDate
		,W.dtmExpectedDate
		,ISNULL(W.dtmLatestDate, W.dtmExpectedDate) AS dtmLatestDate
		,ISNULL(SL.dtmTargetDate, W.dtmExpectedDate) AS dtmTargetDate
		,CASE 
			WHEN W.dblQuantity - W.dblProducedQuantity > 0
				THEN W.dblQuantity - W.dblProducedQuantity
			ELSE 0
			END AS dblBalanceQuantity
		,I.intItemId
		,IU.intItemUOMId
		,IU.intUnitMeasureId
		,CASE WHEN W.intStatusId=1 THEN 3 ELSE W.intStatusId END AS intStatusId
		,SL.intScheduleWorkOrderId
		,CONVERT(INT, ROW_NUMBER() OVER (
				ORDER BY CASE 
						WHEN W.intStatusId IN (
								1
								,3
								)
							THEN W.intManufacturingCellId
						ELSE SL.intExecutionOrder
						END
					,CASE 
						WHEN W.intStatusId IN (
								1
								,3
								)
							THEN W.dtmExpectedDate
						ELSE SL.intExecutionOrder
						END
					,CASE 
						WHEN W.intStatusId IN (
								1
								,3
								)
							THEN W.intItemId
						ELSE SL.intExecutionOrder
						END
				)) AS intExecutionOrder
		,ISNULL(SL.ysnFrozen, 0) AS ysnFrozen
		,I.intPackTypeId
		,ISNULL(SL.intConcurrencyId, 0) AS intConcurrencyId
		,CONVERT(BIT, 0) AS ysnEOModified
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		AND W.intStatusId <> 13
		AND W.intLocationId = @intLocationId
		AND W.intManufacturingCellId IS NOT NULL
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
		AND MC.ysnIncludeSchedule = 1
	LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
		AND SL.intScheduleId IN (
			SELECT S.intScheduleId
			FROM dbo.tblMFSchedule S
			WHERE S.intScheduleId = SL.intScheduleId
				AND S.ysnStandard = 1
				AND intLocationId = @intLocationId
			)
	ORDER BY W.intManufacturingCellId,CASE 
			WHEN W.intStatusId IN (
					1
					,3
					)
				THEN W.intManufacturingCellId
			ELSE SL.intExecutionOrder
			END
		,CASE 
			WHEN W.intStatusId IN (
					1
					,3
					)
				THEN W.dtmExpectedDate
			ELSE SL.intExecutionOrder
			END
		,CASE 
			WHEN W.intStatusId IN (
					1
					,3
					)
				THEN W.intItemId
			ELSE SL.intExecutionOrder
			END

	EXEC dbo.uspMFGetScheduleDetail @intManufacturingCellId = @intManufacturingCellId
		,@dtmPlannedStartDate = @dtmPlannedStartDate
		,@dtmPlannedEndDate = @dtmPlannedEndDate
		,@intLocationId = @intLocationId
		,@intScheduleId = 0
END
