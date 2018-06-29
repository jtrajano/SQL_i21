CREATE VIEW vyuMFShiftActivityProductionSummaryByLine
AS
SELECT CONVERT(INT, ROW_NUMBER() OVER (
			ORDER BY MC.intLocationId
				,MC.strCellName
			)) AS intRowNo
	,MC.strCellName
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
	,CASE 
		WHEN ISNULL(SUM(SA.intScheduledRuntime), 0) - ISNULL((SUM(SA.intReduceAvailableTime) * 60), 0) = 0
			OR SA.dblStdCapacity = 0
			THEN 0
		ELSE ROUND((SUM(SA.dblTotalProducedQty) / (((ISNULL(SUM(SA.intScheduledRuntime), 0) - ISNULL((SUM(SA.intReduceAvailableTime) * 60), 0)) / 60) * SA.dblStdCapacity)) * 100, 4)
		END AS dblEfficiencyPercentage
	,CASE 
		WHEN ISNULL(SUM(SA.intScheduledRuntime), 0) = 0
			OR SA.dblStdCapacity = 0
			THEN 0
		ELSE ROUND((SUM(SA.dblTotalProducedQty) / (((ISNULL(SUM(SA.intScheduledRuntime), 0)) / 60) * SA.dblStdCapacity)) * 100, 4)
		END AS dblEfficiencyWithOutDowntimePercentage
FROM dbo.tblMFShiftActivity SA
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
	AND SA.intShiftActivityStatusId = 3
GROUP BY MC.strCellName
	,SA.dblTargetEfficiency
	,SA.dblStdCapacity
	,MC.intLocationId
