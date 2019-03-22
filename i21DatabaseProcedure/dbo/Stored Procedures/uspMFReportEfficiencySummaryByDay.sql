--Exec [uspMFReportEfficiencySummaryByDay] 'Feb 23 2012 12:00AM','Feb 29 2012 12:00AM',1000013,1000000
CREATE PROCEDURE uspMFReportEfficiencySummaryByDay
     @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@strManufacturingCellId NVARCHAR(MAX)
	,@intLocationId INT
	,@strShiftName NVARCHAR(50) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @SQL NVARCHAR(MAX)
		,@strFieldName NVARCHAR(MAX)
		,@strcolumnName NVARCHAR(MAX)
		,@intShiftId INT

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND strShiftName = @strShiftName

	IF OBJECT_ID('tempdb..#datelist') IS NOT NULL
		DROP TABLE #datelist

	CREATE TABLE #datelist (dtmShiftDate DATETIME)

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 0, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 1, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 2, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 3, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 4, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 5, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	INSERT INTO #datelist (dtmShiftDate)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 6, CONVERT(NVARCHAR, @dtmFromDate, 101)))

	SELECT @strFieldName = COALESCE(@strFieldName + ',', '') + '[' + CONVERT(NVARCHAR(20), dtmShiftDate) + ']'
		,@strcolumnName = COALESCE(@strcolumnName + ',', '') + '[' + CONVERT(NVARCHAR(20), dtmShiftDate) + ']' + '[' + CONVERT(NVARCHAR(10), DATEPART(dw, dtmShiftDate)) + ']'
	FROM #datelist

	SET @SQL = ' SELECT ' + @strcolumnName + 
		'
 FROM (
	 SELECT CONVERT(NVARCHAR(20), dtmShiftDate) dtmShiftDate
		 ,dtmShiftDate AS dtmDate
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
			 ELSE ROUND((SUM(dblTotalProducedQty) / ISNULL(SUM(dblTargetQtyLessDowntime), 0)) * 100, 0)
			 END AS dblEfficiencyPercentage
	 FROM (
		 SELECT SA.dtmShiftDate
			 ,SUM(SA.intScheduledRuntime / 60) AS intTotalScheduledRuntime
			 ,SUM(SA.intTotalDowntime / 60) AS intTotalDowntime
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
		 WHERE SA.intShiftId =' 
		+ CONVERT(NVARCHAR, ISNULL(CONVERT(NVARCHAR, @intShiftId), 'SA.intShiftId')) + '
			 AND MC.intLocationId =' + CONVERT(NVARCHAR, @intLocationId) + '
			 AND MC.intManufacturingCellId IN (' + CONVERT(NVARCHAR(MAX), @strManufacturingCellId) + ')
			 AND SA.dtmShiftDate BETWEEN ''' + CONVERT(NVARCHAR, @dtmFromDate, 101) + ''' AND ''' + CONVERT(NVARCHAR, @dtmToDate, 101) + '''
		 GROUP BY SA.dtmShiftDate
			 ,MC.strCellName
			 ,SA.dblTargetEfficiency
			 ,SA.dblStdCapacity
		 ) AS t
	 GROUP BY dtmShiftDate
	 ) P
 PIVOT(SUM(dblEfficiencyPercentage) FOR dtmShiftDate IN (' + @strFieldName + ')
			 ) AS PVT'

	--PRINT @SQL
	EXEC sp_executesql @SQL
END
