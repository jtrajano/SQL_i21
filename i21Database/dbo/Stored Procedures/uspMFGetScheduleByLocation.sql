CREATE PROCEDURE uspMFGetScheduleByLocation (@intLocationId INT)
AS
SELECT W.intManufacturingCellId
	,W.intWorkOrderId
	,ISNULL(SL.intScheduleId, 0) intScheduleId
	,W.dblQuantity
	,W.dtmEarliestDate
	,W.dtmExpectedDate
	,W.dtmLatestDate
	,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	,I.intItemId
	,IU.intItemUOMId
	,IU.intUnitMeasureId
	,WS.intStatusId
	,SL.intScheduleWorkOrderId
	,Convert(INT, Row_number() OVER (
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
	,SL.ysnFrozen
	,I.intPackTypeId
	,Isnull(SL.intConcurrencyId, 0) AS intConcurrencyId
	,CONVERT(BIT, 0) AS ysnEOModified
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	AND W.intStatusId <> 13
	AND W.intLocationId = @intLocationId
	AND W.intManufacturingCellId IS NOT NULL
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	AND SL.intScheduleId IN (
		SELECT S.intScheduleId
		FROM dbo.tblMFSchedule S
		WHERE S.intScheduleId = SL.intScheduleId
			AND S.ysnStandard = 1
			AND intLocationId = @intLocationId
		)
LEFT JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = IsNULL(SL.intStatusId, W.intStatusId)
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

