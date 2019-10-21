--EXEC uspMFReportEfficiencySummaryByWeek '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>strLocationName</fieldname><condition>Equal To</condition><from>Pinnacle Premix - Visalia</from><to /><join>And</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>ProductionLine</fieldname><condition>Equal To</condition><from>_All</from><to /><join>And</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>Date</fieldname><condition>Between</condition><from>2016-05-16 00:00:00</from><to>2016-05-20 00:00:00</to><join>And</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspMFReportEfficiencySummaryByWeek
     @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc INT
		,@intLocationId INT
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@strCellName NVARCHAR(50)
		,@intManufacturingCellId NVARCHAR(MAX)
		,@strLocationName NVARCHAR(50)
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM dbo.tblSMCompanySetup

	IF ISNULL(@xmlParam, '') = ''
	BEGIN
		SELECT '' AS 'strShiftIndicator'
			,'' AS 'strCellName'
			,'' AS 'dblTargetEfficiency'
			,'' AS 'YTD'
			,'' AS 'MTD'
			,'' AS 'WTD'
			,'' AS '1'
			,'' AS '2'
			,'' AS '3'
			,'' AS '4'
			,'' AS '5'
			,'' AS '6'
			,'' AS '7'
			,'' AS '11'
			,'' AS '12'
			,'' AS '13'
			,'' AS '14'
			,'' AS '15'
			,'' AS '16'
			,'' AS '17'
			,'' AS '21'
			,'' AS '22'
			,'' AS '23'
			,'' AS '24'
			,'' AS '25'
			,'' AS '26'
			,'' AS '27'
			,'' AS '31'
			,'' AS '32'
			,'' AS '33'
			,'' AS '34'
			,'' AS '35'
			,'' AS '36'
			,'' AS '37'
			,'' AS ID1
			,'' AS ID2
			,'' AS ID3
			,'' AS ID4
			,'' AS ID5
			,'' AS ID6
			,'' AS ID7
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	DECLARE @temp_EfficiencySummaryWeekly TABLE (
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	INSERT INTO @temp_EfficiencySummaryWeekly
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
			fieldname NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strLocationName = [from]
	FROM @temp_EfficiencySummaryWeekly
	WHERE [fieldname] = 'strLocationName'

	SELECT @dtmFromDate = [from]
		,@dtmToDate = [to]
	FROM @temp_EfficiencySummaryWeekly
	WHERE [fieldname] = 'Date'

	SELECT @strCellName = [from]
	FROM @temp_EfficiencySummaryWeekly
	WHERE [fieldname] = 'ProductionLine'

	SET @dtmFromDate = @dtmToDate - 6
	SET @intLocationId = (
			SELECT intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLocationName = @strLocationName
			)

	IF @strCellName = '_All'
	BEGIN
		SELECT @intManufacturingCellId = COALESCE(@intManufacturingCellId + ',', '') + CONVERT(NVARCHAR(50), intManufacturingCellId)
		FROM dbo.tblMFManufacturingCell
		WHERE intLocationId = @intLocationId
	END
	ELSE
	BEGIN
		SELECT @intManufacturingCellId = CONVERT(NVARCHAR(50), intManufacturingCellId)
		FROM dbo.tblMFManufacturingCell
		WHERE intLocationId = @intLocationId
			AND strCellName = @strCellName
	END

	DECLARE @SQL NVARCHAR(MAX)
		,@strFieldName NVARCHAR(MAX)
		,@strColumnName NVARCHAR(MAX)
		,@strFieldName1 NVARCHAR(MAX)
		,@strColumnName1 NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#datelist') IS NOT NULL
		DROP TABLE #datelist

	CREATE TABLE #datelist (
		dtmDate NVARCHAR(50)
		,dtmShiftDate DATETIME
		,intShiftId INT
		,strShiftName NVARCHAR(50)
		)

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 0, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 0, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 1, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 1, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 2, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 2, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 3, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 3, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 4, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 4, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 5, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 5, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	INSERT INTO #datelist (
		dtmDate
		,dtmShiftDate
		,intShiftId
		,strShiftName
		)
	SELECT CONVERT(NVARCHAR(20), DATEADD(d, 6, CONVERT(NVARCHAR, @dtmFromDate, 101))) + + CONVERT(NVARCHAR(10), intShiftId)
		,CONVERT(NVARCHAR(20), DATEADD(d, 6, CONVERT(NVARCHAR, @dtmFromDate, 101)))
		,CONVERT(NVARCHAR(10), intShiftId)
		,strShiftName
	FROM dbo.tblMFShift S
	WHERE intLocationId = @intLocationId

	SELECT @strFieldName = COALESCE(@strFieldName + ',', '') + '[' + CONVERT(NVARCHAR(20), dtmShiftDate) + CONVERT(NVARCHAR(10), intShiftId) + ']'
		,@strColumnName = COALESCE(@strColumnName + ',', '') + '[' + CONVERT(NVARCHAR(20), dtmShiftDate) + CONVERT(NVARCHAR(10), intShiftId) + ']' + '[' + CASE 
			WHEN strShiftName = 'Shift1'
				THEN '1'
			WHEN strShiftName = 'Shift2'
				THEN '2'
			WHEN strShiftName = 'Shift3'
				THEN '3'
			END + CONVERT(NVARCHAR(10), DATEPART(dw, dtmShiftDate)) + ']'
	FROM #datelist
	ORDER BY intShiftId
		,dtmShiftDate

	IF OBJECT_ID('TestPvtEff') IS NOT NULL
		DROP TABLE TestPvtEff

	SET @SQL = 'SELECT strShiftIndicator,strCellName,dblTargetEfficiency,0 YTD, 0 MTD,0 WTD, NULL [1] ,NULL [2] ,NULL [3] ,NULL [4] ,NULL [5] ,NULL [6] ,NULL [7] , ' + @strColumnName + '
	INTO TestPvtEff FROM ( '
	SET @SQL = @SQL + 
		'SELECT strCellName,dblTargetEfficiency,strShift,dblEfficiencyPercentage,
							CASE WHEN [intShiftId] IN (1,2,3) OR [intShiftId] IN (21,22,23)
										THEN ''GROUP1''
									WHEN [intShiftId] IN (8,9,10) OR [intShiftId] IN (24,25,26)
										THEN ''GROUP2''
									WHEN [intShiftId] IN (11,12,13) OR [intShiftId] IN (27,28,29)
										THEN ''GROUP3''
									WHEN [intShiftId] IN (14,15,16) OR [intShiftId] IN (31,32,33)
										THEN ''GROUP4''
							END AS strShiftIndicator FROM (
	SELECT MC.strCellName, SA.dblTargetEfficiency, SA.dtmShiftDate, S.strShiftName,
	CONVERT(NVARCHAR(20),SA.dtmShiftDate) + CONVERT(NVARCHAR(10),S.intShiftId) AS strShift,
	CASE WHEN ((((SA.intScheduledRuntime - ISNULL((SA.intReduceAvailableTime * 60),0)) / 60)* SA.dblStdCapacity)) = 0 THEN 0
	ELSE ROUND((SA.dblTotalProducedQty / ((((SA.intScheduledRuntime - ISNULL((SA.intReduceAvailableTime * 60),0)) / 60)* SA.dblStdCapacity))) * 100 ,0)
	END AS dblEfficiencyPercentage, S.intShiftId'
	SET @SQL = @SQL + ' FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFShiftActivityMachines SAM ON SAM.intShiftActivityId = SA.intShiftActivityId AND SA.intShiftActivityStatusId = 3
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
	LEFT JOIN dbo.tblICUnitMeasure UC ON UC.intUnitMeasureId = SA.intSKUUnitMeasureId
	JOIN dbo.tblMFShift S ON S.intShiftId = SA.intShiftId'
	SET @SQL = @SQL + ' WHERE MC.intLocationId =' + CONVERT(NVARCHAR, @intLocationId) + ' AND MC.intManufacturingCellId IN (' + @intManufacturingCellId + ')
	AND (dtmShiftDate BETWEEN ''' + CONVERT(NVARCHAR, @dtmFromDate, 101) + ''' AND ''' + CONVERT(NVARCHAR, @dtmToDate, 101) + ''')
	GROUP BY MC.strCellName,S.strShiftName,SA.dtmShiftDate,SA.dblTotalProducedQty,SA.intScheduledRuntime,SA.dblTotalSKUProduced,
	MC.dblStdCapacity,SA.dblTargetEfficiency,dbo.fnRemoveTrailingZeroes(MC.dblStdCapacity),MC.strCellName,SA.intReduceAvailableTime,
	MC.intManufacturingCellId,SA.intTotalDowntime,SA.intReduceAvailableTime,UC.strUnitMeasure
	,S.strShiftName,S.intShiftId,SA.dtmShiftStartTime,SA.dtmShiftEndTime,SA.dblStdCapacity
	)t)t1'
	SET @SQL = @SQL + ' PIVOT(SUM(dblEfficiencyPercentage) FOR strShift IN (' + @strFieldName + '))
	AS PVT'

	--PRINT @SQL
	EXEC sp_executesql @SQL

	DECLARE @m CHAR(2)
		,@yy CHAR(10)
		,@d DATETIME

	SET @m = DATEPART(mm, @dtmFromDate)
	SET @yy = DATEPART(yy, @dtmFromDate)
	SET @d = DATEADD(d, DATEDIFF(d, @dtmToDate, CONVERT(NVARCHAR(10), '1 Jan ' + @yy, 101)), @dtmToDate)

	IF OBJECT_ID('tempdb..#YearEff') IS NOT NULL
		DROP TABLE #YearEff

	CREATE TABLE #YearEff (
		strCellName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblTargetEfficiency DECIMAL(24, 10)
		,YearEfficiency DECIMAL(24, 10)
		)

	SET @SQL = 'INSERT INTO #YearEff
	SELECT t.strCellName,
	AVG(dblTargetEfficiency) AS dblTargetEfficiency,
	ROUND((SUM(dblTotalProducedQty) / CASE WHEN ISNULL(SUM(dblTargetQtyLessDowntime),0) = 0 THEN 1 ELSE ISNULL(SUM(dblTargetQtyLessDowntime),0) END) * 100,0)
	AS YearEfficiency '
	SET @SQL = @SQL + ' FROM
	(SELECT MC.strCellName,SA.dtmShiftDate
	,SUM(SA.intScheduledRuntime / 60) AS intTotalScheduledRuntime
	,SUM(SA.intTotalDowntime / 60) AS intTotalDowntime
	,SUM(SA.intReduceAvailableTime) AS intTotalReduceAvailableTime
	,(SUM(SA.intScheduledRuntime / 60) - SUM(SA.intReduceAvailableTime)) AS intRuntimeLessDowntime
	,SUM(dblTotalSKUProduced) AS dblTotalSKUProduced
	,SUM(dblTotalProducedQty) AS dblTotalProducedQty
	,(SUM(SA.intScheduledRuntime / 60) * SA.dblStdCapacity) AS dblTargetQty
	,(SUM(SA.intScheduledRuntime / 60) - SUM(SA.intReduceAvailableTime)) * SA.dblStdCapacity AS dblTargetQtyLessDowntime
	,SA.dblTargetEfficiency
	,SA.dblStdCapacity '
	SET @SQL = @SQL + ' FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId AND SA.intShiftActivityStatusId = 3
	WHERE intLocationId =' + CONVERT(NVARCHAR, @intLocationId) + ' AND (dtmShiftDate BETWEEN ''' + CONVERT(NVARCHAR, @d, 101) + ''' AND ''' + CONVERT(NVARCHAR, @dtmToDate, 101) + ''')
	AND MC.intManufacturingCellId IN (' + @intManufacturingCellId + ')
	GROUP BY SA.dtmShiftDate,MC.strCellName,SA.dblTargetEfficiency,SA.dblStdCapacity) AS t
    GROUP BY t.strCellName'

	EXEC sp_executesql @SQL

	SET @d = DATEADD(d, DATEDIFF(d, @dtmToDate, CONVERT(NVARCHAR(10), @m + '/1/' + @yy, 101)), @dtmToDate)

	IF OBJECT_ID('tempdb..#MonthEff') IS NOT NULL
		DROP TABLE #MonthEff

	CREATE TABLE #MonthEff (
		strCellName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,MonthEfficiency DECIMAL(24, 10)
		)

	SET @SQL = 'INSERT INTO #MonthEff
	SELECT t.strCellName,
	ROUND((SUM(dblTotalProducedQty) / CASE WHEN ISNULL(SUM(dblTargetQtyLessDowntime),0) = 0 THEN 1 ELSE ISNULL(SUM(dblTargetQtyLessDowntime),0) END) * 100,0)
	AS MonthEfficiency '
	SET @SQL = @SQL + ' FROM
	(SELECT MC.strCellName,SA.dtmShiftDate
	,SUM(SA.intScheduledRuntime / 60) AS intTotalScheduledRuntime
	,SUM(SA.intTotalDowntime / 60) AS intTotalDowntime
	,SUM(SA.intReduceAvailableTime) AS intTotalReduceAvailableTime
	,(SUM(SA.intScheduledRuntime / 60) - SUM(SA.intReduceAvailableTime)) AS intRuntimeLessDowntime
	,SUM(dblTotalSKUProduced) AS dblTotalSKUProduced
	,SUM(dblTotalProducedQty) AS dblTotalProducedQty
	,(SUM(SA.intScheduledRuntime / 60) * SA.dblStdCapacity) AS dblTargetQty
	,(SUM(SA.intScheduledRuntime / 60) - SUM(SA.intReduceAvailableTime)) * SA.dblStdCapacity AS dblTargetQtyLessDowntime
	,SA.dblTargetEfficiency
	,SA.dblStdCapacity '
	SET @SQL = @SQL + ' FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId AND SA.intShiftActivityStatusId = 3
	WHERE intLocationId =' + CONVERT(NVARCHAR, @intLocationId) + ' AND (dtmShiftDate BETWEEN ''' + CONVERT(NVARCHAR, @d, 101) + ''' AND ''' + CONVERT(NVARCHAR, @dtmToDate, 101) + ''')
	AND MC.intManufacturingCellId IN (' + @intManufacturingCellId + ')
	GROUP BY SA.dtmShiftDate,MC.strCellName,SA.dblTargetEfficiency,SA.dblStdCapacity) AS t
    GROUP BY t.strCellName'

	EXEC sp_executesql @SQL

	IF OBJECT_ID('tempdb..#WeeklyEff') IS NOT NULL
		DROP TABLE #WeeklyEff

	CREATE TABLE #WeeklyEff (
		strCellName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,WeeklyEfficiency DECIMAL(24, 10)
		)

	SET @SQL = 'INSERT INTO #WeeklyEff
	SELECT t.strCellName,
	ROUND((SUM(dblTotalProducedQty) / CASE WHEN ISNULL(SUM(dblTargetQtyLessDowntime),0) = 0 THEN 1 ELSE ISNULL(SUM(dblTargetQtyLessDowntime),0) END) * 100,0)
	AS WeeklyEfficiency '
	SET @SQL = @SQL + ' FROM
	(SELECT MC.strCellName,SA.dtmShiftDate
	,SUM(SA.intScheduledRuntime / 60) AS intTotalScheduledRuntime
	,SUM(SA.intTotalDowntime / 60) AS intTotalDowntime
	,SUM(SA.intReduceAvailableTime) AS intTotalReduceAvailableTime
	,(SUM(SA.intScheduledRuntime / 60) - SUM(SA.intReduceAvailableTime)) AS intRuntimeLessDowntime
	,SUM(dblTotalSKUProduced) AS dblTotalSKUProduced
	,SUM(dblTotalProducedQty) AS dblTotalProducedQty
	,(SUM(SA.intScheduledRuntime / 60) * SA.dblStdCapacity) AS dblTargetQty
	,(SUM(SA.intScheduledRuntime / 60) - SUM(SA.intReduceAvailableTime)) * SA.dblStdCapacity AS dblTargetQtyLessDowntime
	,SA.dblTargetEfficiency
	,SA.dblStdCapacity '
	SET @SQL = @SQL + ' FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId AND SA.intShiftActivityStatusId = 3
	WHERE intLocationId =' + CONVERT(NVARCHAR, @intLocationId) + ' AND (dtmShiftDate BETWEEN ''' + CONVERT(NVARCHAR, @dtmFromDate, 101) + ''' AND ''' + CONVERT(NVARCHAR, @dtmToDate, 101) + ''')
	AND MC.intManufacturingCellId IN (' + @intManufacturingCellId + ')
	GROUP BY SA.dtmShiftDate,MC.strCellName,SA.dblTargetEfficiency,SA.dblStdCapacity) AS t
    GROUP BY t.strCellName'

	EXEC sp_executesql @SQL

	IF OBJECT_ID('tempdb..#DayTemp') IS NOT NULL
		DROP TABLE #DayTemp

	CREATE TABLE #DayTemp (
		strCellName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmShiftDate DATETIME
		,dblEfficiencyPercentage DECIMAL(24, 10)
		)

	SELECT @strFieldName1 = COALESCE(@strFieldName1 + ',', '') + '[' + CONVERT(NVARCHAR(20), dtmShiftDate) + ']'
		,@strColumnName1 = COALESCE(@strColumnName1 + ',', '') + 'SUM([' + CONVERT(NVARCHAR(20), dtmShiftDate) + '])' + '[' + CONVERT(NVARCHAR(10), DATEPART(dw, dtmShiftDate)) + ']'
	FROM #datelist
	GROUP BY dtmShiftDate
	ORDER BY dtmShiftDate

	SET @SQL = 'INSERT INTO #DayTemp
	SELECT MC.strCellName,SA.dtmShiftDate
	,CASE WHEN ISNULL(SUM(SA.intScheduledRuntime),0) - ISNULL(SUM(SA.intReduceAvailableTime * 60),0) = 0 THEN 0
	ELSE ROUND((SUM(SA.dblTotalProducedQty) / ((((ISNULL(SUM(SA.intScheduledRuntime),0) - ISNULL(SUM(SA.intReduceAvailableTime * 60),0)) / 60) * SA.dblStdCapacity))) * 100,0)
	END AS dblEfficiencyPercentage '
	SET @SQL = @SQL + ' FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId AND SA.intShiftActivityStatusId = 3
	WHERE intLocationId =' + CONVERT(NVARCHAR, @intLocationId) + ' AND MC.intManufacturingCellId IN (' + @intManufacturingCellId + ')
	AND SA.dtmShiftDate BETWEEN ''' + CONVERT(NVARCHAR, @dtmFromDate, 101) + ''' AND ''' + CONVERT(NVARCHAR, @dtmToDate, 101) + ''' '
	SET @SQL = @SQL + 'GROUP BY MC.strCellName,SA.dtmShiftDate,SA.dblTargetEfficiency,SA.dblStdCapacity'

	EXEC sp_executesql @SQL

	IF OBJECT_ID('DailyAvgTemp') IS NOT NULL
		DROP TABLE DailyAvgTemp

	SET @SQL = 'SELECT strCellName, ' + @strColumnName1 + ' INTO DailyAvgTemp
	FROM (SELECT * FROM #DayTemp) P
	PIVOT
	(
	SUM(dblEfficiencyPercentage)
	FOR dtmShiftDate IN ( ' + @strFieldName1 + ' )
	) AS PVT
	GROUP BY strCellName'

	EXEC sp_executesql @SQL

	IF OBJECT_ID('TestPvtEff') IS NULL
	BEGIN
		SELECT '' AS 'strShiftIndicator'
			,'' AS 'strCellName'
			,'' AS 'dblTargetEfficiency'
			,'' AS 'YTD'
			,'' AS 'MTD'
			,'' AS 'WTD'
			,'' AS '1'
			,'' AS '2'
			,'' AS '3'
			,'' AS '4'
			,'' AS '5'
			,'' AS '6'
			,'' AS '7'
			,'' AS '11'
			,'' AS '12'
			,'' AS '13'
			,'' AS '14'
			,'' AS '15'
			,'' AS '16'
			,'' AS '17'
			,'' AS '21'
			,'' AS '22'
			,'' AS '23'
			,'' AS '24'
			,'' AS '25'
			,'' AS '26'
			,'' AS '27'
			,'' AS '31'
			,'' AS '32'
			,'' AS '33'
			,'' AS '34'
			,'' AS '35'
			,'' AS '36'
			,'' AS '37'
			,'' AS ID1
			,'' AS ID2
			,'' AS ID3
			,'' AS ID4
			,'' AS ID5
			,'' AS ID6
			,'' AS ID7
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

	UPDATE TestPvtEff
	SET YTD = a.YearEfficiency
		,MTD = b.MonthEfficiency
		,WTD = d.WeeklyEfficiency
		,[1] = c.[1]
		,[2] = c.[2]
		,[3] = c.[3]
		,[4] = c.[4]
		,[5] = c.[5]
		,[6] = c.[6]
		,[7] = c.[7]
	FROM TestPvtEff t
	JOIN #YearEff a ON t.strCellName = a.strCellName
	JOIN #MonthEff b ON t.strCellName = b.strCellName
	JOIN #WeeklyEff d ON t.strCellName = d.strCellName
	JOIN DailyAvgTemp c ON t.strCellName = c.strCellName

	ALTER TABLE TestPvtEff ADD ID1 FLOAT

	ALTER TABLE TestPvtEff ADD ID2 FLOAT

	ALTER TABLE TestPvtEff ADD ID3 FLOAT

	ALTER TABLE TestPvtEff ADD ID4 FLOAT

	ALTER TABLE TestPvtEff ADD ID5 FLOAT

	ALTER TABLE TestPvtEff ADD ID6 FLOAT

	ALTER TABLE TestPvtEff ADD ID7 FLOAT

	IF OBJECT_ID('tempdb..#PlantEfficencyDaily') IS NOT NULL
		DROP TABLE #PlantEfficencyDaily

	CREATE TABLE #PlantEfficencyDaily (
		[1] INT
		,[2] INT
		,[3] INT
		,[4] INT
		,[5] INT
		,[6] INT
		,[7] INT
		)

	SET @SQL = 'uspMFReportEfficiencySummaryByDay ''' + CONVERT(NVARCHAR(50), @dtmFromDate) + ''',''' + CONVERT(NVARCHAR(50), @dtmToDate) + ''',''' + @intManufacturingCellId + ''',' + CONVERT(NVARCHAR(50), @intLocationId)

	INSERT INTO #PlantEfficencyDaily
	EXECUTE (@SQL);

	WITH TEMP
	AS (
		SELECT SUM(CONVERT(DECIMAL(24, 0), [1])) ID1
			,SUM(CONVERT(DECIMAL(24, 0), [2])) ID2
			,SUM(CONVERT(DECIMAL(24, 0), [3])) ID3
			,SUM(CONVERT(DECIMAL(24, 0), [4])) ID4
			,SUM(CONVERT(DECIMAL(24, 0), [5])) ID5
			,SUM(CONVERT(DECIMAL(24, 0), [6])) ID6
			,SUM(CONVERT(DECIMAL(24, 0), [7])) ID7
		FROM #PlantEfficencyDaily
		)
	UPDATE TOP (1) E
	SET E.ID1 = T.ID1
		,E.ID2 = T.ID2
		,E.ID3 = T.ID3
		,E.ID4 = T.ID4
		,E.ID5 = T.ID5
		,E.ID6 = T.ID6
		,E.ID7 = T.ID7
	FROM TestPvtEff E
		,TEMP T

	UPDATE TestPvtEff
	SET strShiftIndicator = 'GROUP1'

	IF NOT EXISTS (
			SELECT 1
			FROM TestPvtEff
			)
	BEGIN
		SELECT '' AS 'strShiftIndicator'
			,'' AS 'strCellName'
			,'' AS 'dblTargetEfficiency'
			,'' AS 'YTD'
			,'' AS 'MTD'
			,'' AS 'WTD'
			,'' AS '1'
			,'' AS '2'
			,'' AS '3'
			,'' AS '4'
			,'' AS '5'
			,'' AS '6'
			,'' AS '7'
			,'' AS '11'
			,'' AS '12'
			,'' AS '13'
			,'' AS '14'
			,'' AS '15'
			,'' AS '16'
			,'' AS '17'
			,'' AS '21'
			,'' AS '22'
			,'' AS '23'
			,'' AS '24'
			,'' AS '25'
			,'' AS '26'
			,'' AS '27'
			,'' AS '31'
			,'' AS '32'
			,'' AS '33'
			,'' AS '34'
			,'' AS '35'
			,'' AS '36'
			,'' AS '37'
			,'' AS ID1
			,'' AS ID2
			,'' AS ID3
			,'' AS ID4
			,'' AS ID5
			,'' AS ID6
			,'' AS ID7
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

	SELECT *
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
		,@strCountry AS strCompanyCountry
	FROM TestPvtEff
END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX)

	SET @ErrMsg = 'uspMFReportEfficiencySummaryByWeek - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
