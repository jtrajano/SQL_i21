CREATE PROCEDURE uspMFGetCalendarDetail (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@strShiftId NVARCHAR(50)
	,@intManufacturingCellId INT
	,@intCalendarId INT
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intHolidayId INT
		,@strName NVARCHAR(50)
		,@intHolidayTypeId INT
		,@intDateDiff INT
		,@i INT
		,@strMachineName NVARCHAR(MAX)
		,@SQL NVARCHAR(MAX)
		,@dtmHolidayFromDate DATETIME
		,@dtmHolidayToDate DATETIME
	DECLARE @tblMFHolidayCalendar TABLE (dtmHolidayDate DATETIME)
	DECLARE @tblMFHoliday TABLE (
		intHolidayId INT
		,strName NVARCHAR(50)
		,intHolidayTypeId INT
		,dtmFromDate DATETIME
		,dtmToDate DATETIME
		)

	INSERT INTO @tblMFHoliday (
		intHolidayId
		,strName
		,intHolidayTypeId
		,dtmFromDate
		,dtmToDate
		)
	SELECT intHolidayId
		,strName
		,intHolidayTypeId
		,CASE 
			WHEN dtmFromDate > @dtmFromDate
				THEN dtmFromDate
			ELSE @dtmFromDate
			END dtmFromDate
		,CASE 
			WHEN dtmToDate > @dtmToDate
				THEN @dtmToDate
			ELSE dtmToDate
			END dtmToDate
	FROM tblMFHolidayCalendar
	WHERE intLocationId = @intLocationId

	SELECT @intHolidayId = MIN(intHolidayId)
	FROM @tblMFHoliday

	WHILE @intHolidayId IS NOT NULL
	BEGIN
		SELECT @dtmHolidayFromDate = dtmFromDate
			,@dtmHolidayToDate = dtmToDate
			,@intHolidayTypeId = intHolidayTypeId
			,@strName = strName
		FROM @tblMFHoliday
		WHERE intHolidayId = @intHolidayId

		SET @intDateDiff = 0
		SET @i = 0
		SET @intDateDiff = DATEDIFF(dd, @dtmHolidayFromDate, @dtmHolidayToDate)

		WHILE @i <= @intDateDiff
		BEGIN
			IF @intHolidayTypeId = 1
				INSERT INTO @tblMFHolidayCalendar
				SELECT @dtmHolidayFromDate
			ELSE IF @intHolidayTypeId = 2
				AND LEFT(DateName(dw, @dtmHolidayFromDate), 3) = RIGHT(@strName, 3)
				INSERT INTO @tblMFHolidayCalendar
				SELECT @dtmHolidayFromDate

			SET @dtmHolidayFromDate = @dtmHolidayFromDate + 1
			SET @i = @i + 1
		END

		SELECT @intHolidayId = MIN(intHolidayId)
		FROM @tblMFHoliday
		WHERE intHolidayId > @intHolidayId
	END

	IF OBJECT_ID('tempdb..#tblMFCalendarDetail') IS NOT NULL
		DROP TABLE #tblMFCalendarDetail

	CREATE TABLE #tblMFCalendarDetail (
		intCalendarDetailId INT
		,dtmCalendarDate DATETIME
		,intShiftId INT
		,dtmShiftStartTime DATETIME
		,dtmShiftEndTime DATETIME
		,intNoOfMachine INT
		,ysnHoliday BIT
		)

	INSERT INTO #tblMFCalendarDetail (
		intCalendarDetailId
		,dtmCalendarDate
		,intShiftId
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intNoOfMachine
		,ysnHoliday
		)
	SELECT intCalendarDetailId
		,dtmCalendarDate
		,intShiftId
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intNoOfMachine
		,ysnHoliday
	FROM dbo.tblMFScheduleCalendarDetail
	WHERE intCalendarId = @intCalendarId
		AND dtmCalendarDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND intShiftId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strShiftId, ',')
			)

	IF EXISTS (
			SELECT *
			FROM #tblMFCalendarDetail
			)
	BEGIN
		SELECT @dtmFromDate = MAX(dtmCalendarDate) + 1
		FROM tblMFScheduleCalendarDetail
	END

	WHILE @dtmToDate > @dtmFromDate
	BEGIN
		INSERT INTO #tblMFCalendarDetail (
			intCalendarDetailId
			,dtmCalendarDate
			,intShiftId
			,dtmShiftStartTime
			,dtmShiftEndTime
			,intNoOfMachine
			,ysnHoliday
			)
		SELECT NULL
			,@dtmFromDate
			,intShiftId
			,@dtmFromDate + dtmShiftStartTime
			,@dtmFromDate + dtmShiftEndTime
			,0
			,(
				CASE 
					WHEN EXISTS (
							SELECT *
							FROM @tblMFHolidayCalendar
							WHERE dtmHolidayDate = @dtmFromDate
							)
						THEN 1
					ELSE 0
					END
				)
		FROM dbo.tblMFShift
		WHERE intLocationId = @intLocationId
			AND intShiftId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strShiftId, ',')
				)

		SELECT @dtmFromDate = @dtmFromDate + 1
	END

	SELECT @strMachineName = STUFF((
				SELECT '],[' + M.strName
				FROM tblMFMachine M
				JOIN tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
				JOIN tblMFManufacturingCellPackType LP ON LP.intPackTypeId = MP.intPackTypeId
					AND LP.intManufacturingCellId = @intManufacturingCellId
				ORDER BY '],[' + M.strName
				FOR XML Path('')
				), 1, 2, '') + ']'

	SELECT @SQL = 'SELECT *
	FROM (
		SELECT CD.dtmCalendarDate,DATENAME(dw,CD.dtmCalendarDate) AS Day
			,CD.intShiftId
			,S.strShiftName
			,CD.dtmShiftStartTime
			,CD.dtmShiftEndTime
			,CD.intNoOfMachine
			,CD.ysnHoliday
			,M.intMachineId
			,M.strName
		FROM #tblMFCalendarDetail CD
		JOIN dbo.tblMFShift S ON S.intShiftId = CD.intShiftId
		LEFT JOIN dbo.tblMFScheduleCalendarMachineDetail MD ON MD.intCalendarDetailId = CD.intCalendarDetailId
		LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = MD.intMachineId
		) AS DT
	PIVOT(Count(DT.intMachineId) FOR strName IN (' + @strMachineName + ')) pvt'

	EXEC (@SQL)
END
