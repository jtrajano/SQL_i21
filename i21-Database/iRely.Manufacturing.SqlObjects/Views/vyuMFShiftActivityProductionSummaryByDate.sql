CREATE VIEW vyuMFShiftActivityProductionSummaryByDate
AS
SELECT CONVERT(INT, ROW_NUMBER() OVER (
			ORDER BY intLocationId
				,dtmShiftDate
			)) AS intRowNo
	,dtmShiftDate
	,intLocationId
	,SUM(intTotalScheduledRuntime) AS intTotalScheduledRuntime
	,SUM(intTotalDowntime) AS intTotalDowntime
	,SUM(intTotalReduceAvailableTime) AS intTotalReduceAvailableTime
	,SUM(intRuntimeLessDowntime) AS intRuntimeLessDowntime
	,SUM(dblTotalSKUProduced) AS dblTotalSKUProduced
	,SUM(dblTotalProducedQty) AS dblTotalProducedQty
	,SUM(dblTargetQty) AS dblTargetQty
	,SUM(dblTargetQtyLessDowntime) AS dblTargetQtyLessDowntime
	,SUM(dblTargetEfficiency) AS dblTargetEfficiency
	,CASE 
		WHEN ISNULL(SUM(dblTargetQtyLessDowntime), 0) = 0
			THEN 0
		ELSE ROUND((SUM(dblTotalProducedQty) / ISNULL(SUM(dblTargetQtyLessDowntime), 0)) * 100, 4)
		END AS dblEfficiencyPercentage
	,CASE 
		WHEN ISNULL(SUM(dblTargetQty), 0) = 0
			THEN 0
		ELSE ROUND((SUM(dblTotalProducedQty) / ISNULL(SUM(dblTargetQty), 0)) * 100, 4)
		END AS dblEfficiencyWithOutDowntimePercentage
FROM (
	SELECT SA.dtmShiftDate
		,MC.intLocationId
		,SUM(SA.intScheduledRuntime) / 60 AS intTotalScheduledRuntime
		,SUM(SA.intTotalDowntime) / 60 AS intTotalDowntime
		,SUM(SA.intReduceAvailableTime) AS intTotalReduceAvailableTime
		,((SUM(SA.intScheduledRuntime) / 60) - SUM(SA.intReduceAvailableTime)) AS intRuntimeLessDowntime
		,SUM(SA.dblTotalSKUProduced) AS dblTotalSKUProduced
		,SUM(SA.dblTotalProducedQty) AS dblTotalProducedQty
		,((SUM(SA.intScheduledRuntime) / 60) * SA.dblStdCapacity) AS dblTargetQty
		,(((SUM(SA.intScheduledRuntime) / 60) - SUM(SA.intReduceAvailableTime)) * SA.dblStdCapacity) AS dblTargetQtyLessDowntime
		,SA.dblTargetEfficiency
		,SA.dblStdCapacity
	FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
		AND SA.intShiftActivityStatusId = 3
	GROUP BY SA.dtmShiftDate
		,MC.strCellName
		,SA.dblTargetEfficiency
		,SA.dblStdCapacity
		,MC.intLocationId
	) AS t
GROUP BY dtmShiftDate
	,intLocationId
