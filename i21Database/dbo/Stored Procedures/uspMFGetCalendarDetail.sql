CREATE PROCEDURE uspMFGetCalendarDetail (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@strShiftId NVARCHAR(50)
	,@strMachineId NVARCHAR(100)
	,@intManufacturingCellId INT
	,@intCalendarId INT
	,@intLocationId INT
	,@dtmMachineConfiguredAsOn DATETIME = NULL
	,@ysnIncludeHoliday bit=1
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
		,@strMachineName1 NVARCHAR(MAX)
		,@dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = GETDATE()

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
	FROM dbo.tblMFHolidayCalendar
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

	IF OBJECT_ID('tempdb..#tblMFScheduleCalendarMachineDetail') IS NOT NULL
		DROP TABLE #tblMFScheduleCalendarMachineDetail

	IF OBJECT_ID('tempdb..#tblMFScheduleCalendarMachineCountDetail') IS NOT NULL
		DROP TABLE #tblMFScheduleCalendarMachineCountDetail

	CREATE TABLE #tblMFCalendarDetail (
		intCalendarDetailId INT
		,dtmCalendarDate DATETIME
		,intShiftId INT
		,dtmShiftStartTime DATETIME
		,dtmShiftEndTime DATETIME
		,intNoOfMachine INT
		,ysnHoliday BIT
		,intConcurrencyId INT
		)

	CREATE TABLE #tblMFScheduleCalendarMachineDetail (
		dtmCalendarDate DATETIME
		,intShiftId INT
		,intMachineId INT
		)

	CREATE TABLE #tblMFScheduleCalendarMachineCountDetail (
		dtmCalendarDate DATETIME
		,intShiftId INT
		,intNoOfMachine INT
		)

	INSERT INTO #tblMFCalendarDetail (
		intCalendarDetailId
		,dtmCalendarDate
		,intShiftId
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intNoOfMachine
		,ysnHoliday
		,intConcurrencyId
		)
	SELECT CD.intCalendarDetailId
		,CD.dtmCalendarDate
		,CD.intShiftId
		,CD.dtmShiftStartTime
		,dtmShiftEndTime
		,ISNULL((
				SELECT COUNT(*)
				FROM dbo.tblMFScheduleCalendarMachineDetail MD
				JOIN dbo.fnSplitString(@strMachineId, ',') M ON M.Item = MD.intMachineId
				WHERE MD.intCalendarDetailId = CD.intCalendarDetailId
				), 0) AS intNoOfMachine
		,CD.ysnHoliday
		,CD.intConcurrencyId
	FROM dbo.tblMFScheduleCalendarDetail CD
	WHERE CD.intCalendarId = @intCalendarId
		AND CD.dtmCalendarDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND CD.intShiftId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strShiftId, ',')
			)

	INSERT INTO #tblMFScheduleCalendarMachineDetail (
		dtmCalendarDate
		,intShiftId
		,intMachineId
		)
	SELECT CD.dtmCalendarDate
		,CD.intShiftId
		,MD.intMachineId
	FROM dbo.tblMFScheduleCalendarDetail CD
	JOIN dbo.tblMFScheduleCalendarMachineDetail MD ON MD.intCalendarDetailId = CD.intCalendarDetailId
	WHERE CD.intCalendarId = @intCalendarId
		AND CD.dtmCalendarDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND CD.intShiftId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strShiftId, ',')
			)

	WHILE @dtmToDate >= @dtmFromDate
	BEGIN
		INSERT INTO #tblMFCalendarDetail (
			intCalendarDetailId
			,dtmCalendarDate
			,intShiftId
			,dtmShiftStartTime
			,dtmShiftEndTime
			,intNoOfMachine
			,ysnHoliday
			,intConcurrencyId
			)
		SELECT NULL
			,@dtmFromDate
			,intShiftId
			,@dtmFromDate + dtmShiftStartTime+intStartOffset 
			,@dtmFromDate + dtmShiftEndTime+intEndOffset 
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
			,0
		FROM dbo.tblMFShift S
		WHERE intLocationId = @intLocationId
			AND intShiftId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strShiftId, ',')
				)
			AND NOT EXISTS (
				SELECT *
				FROM #tblMFCalendarDetail CD
				WHERE CD.dtmCalendarDate = @dtmFromDate
					AND CD.intShiftId = S.intShiftId
				)

		SELECT @dtmFromDate = @dtmFromDate + 1
	END

	DELETE
	FROM #tblMFCalendarDetail
	WHERE @dtmCurrentDate > dtmShiftEndTime

	IF @dtmMachineConfiguredAsOn IS NULL
	BEGIN
		INSERT INTO #tblMFScheduleCalendarMachineDetail (
			dtmCalendarDate
			,intShiftId
			,intMachineId
			)
		SELECT CD.dtmCalendarDate
			,CD.intShiftId
			,MD.Item
		FROM dbo.#tblMFCalendarDetail CD
			,dbo.fnSplitString(@strMachineId, ',') MD
		WHERE CD.intCalendarDetailId IS NULL
			AND CD.ysnHoliday = 0
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblMFScheduleCalendar C
				JOIN dbo.tblMFScheduleCalendarDetail CD1 ON C.intCalendarId = CD1.intCalendarId
					AND C.intManufacturingCellId <> @intManufacturingCellId
				JOIN dbo.tblMFScheduleCalendarMachineDetail MD1 ON MD1.intCalendarDetailId = CD1.intCalendarDetailId
				WHERE CD1.dtmCalendarDate = CD.dtmCalendarDate
					AND CD1.intShiftId = CD.intShiftId
					AND MD1.intMachineId = MD.Item
				)
	END
	ELSE
	BEGIN
		INSERT INTO #tblMFScheduleCalendarMachineDetail (
			dtmCalendarDate
			,intShiftId
			,intMachineId
			)
		SELECT CD.dtmCalendarDate
			,CD.intShiftId
			,MD.Item
		FROM dbo.#tblMFCalendarDetail CD
			,dbo.fnSplitString(@strMachineId, ',') MD
		WHERE CD.intCalendarDetailId IS NULL
			AND CD.ysnHoliday = 0
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblMFScheduleCalendar C
				JOIN dbo.tblMFScheduleCalendarDetail CD1 ON C.intCalendarId = CD1.intCalendarId
					AND C.intManufacturingCellId <> @intManufacturingCellId
				JOIN dbo.tblMFScheduleCalendarMachineDetail MD1 ON MD1.intCalendarDetailId = CD1.intCalendarDetailId
				WHERE CD1.dtmCalendarDate = CD.dtmCalendarDate
					AND CD1.intShiftId = CD.intShiftId
					AND MD1.intMachineId = MD.Item
				)
			AND EXISTS (
				SELECT *
				FROM dbo.tblMFScheduleCalendarDetail CD2
				JOIN dbo.tblMFScheduleCalendarMachineDetail MD2 ON MD2.intCalendarDetailId = CD2.intCalendarDetailId
					AND CD2.intCalendarId = @intCalendarId
				WHERE CD2.dtmCalendarDate = @dtmMachineConfiguredAsOn
					AND CD2.intShiftId = CD.intShiftId
					AND MD2.intMachineId = MD.Item
				)
	END

	INSERT INTO #tblMFScheduleCalendarMachineCountDetail (
		dtmCalendarDate
		,intShiftId
		,intNoOfMachine
		)
	SELECT dtmCalendarDate
		,intShiftId
		,COUNT(intMachineId)
	FROM #tblMFScheduleCalendarMachineDetail
	GROUP BY dtmCalendarDate
		,intShiftId

	UPDATE #tblMFCalendarDetail
	SET intNoOfMachine = CMD.intNoOfMachine
	FROM #tblMFCalendarDetail CD
	JOIN #tblMFScheduleCalendarMachineCountDetail CMD ON CMD.dtmCalendarDate = CD.dtmCalendarDate
		AND CMD.intShiftId = CD.intShiftId
	WHERE CD.intCalendarDetailId IS NULL
		AND CD.ysnHoliday = 0

	SELECT @strMachineName = Isnull(@strMachineName, '') + '[' + DT.strName + '],'
		,@strMachineName1 = Isnull(@strMachineName1, '') + 'Convert(bit,[' + DT.strName + ']) as [' + DT.strName + '],'
	FROM (
		SELECT DISTINCT M.strName
		FROM dbo.tblMFMachine M
		JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
		JOIN dbo.tblMFManufacturingCellPackType LP ON LP.intPackTypeId = MP.intPackTypeId
			AND LP.intManufacturingCellId = @intManufacturingCellId
			AND M.intMachineId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strMachineId, ',')
				)
		) AS DT
	ORDER BY DT.strName

	IF Len(@strMachineName) > 0
		SELECT @strMachineName = Left(@strMachineName, Len(@strMachineName) - 1)

	IF Len(@strMachineName1) > 0
		SELECT @strMachineName1 = Left(@strMachineName1, Len(@strMachineName1) - 1)

	SELECT @SQL = 'SELECT dtmCalendarDate,Day,intShiftId,strShiftName,intStartOffset,intEndOffset,dtmShiftStartTime,dtmCalendarDate+CAST(dtmShiftEndTime - dtmShiftStartTime AS TIME) dtmDuration,dtmShiftEndTime,intNoOfMachine,ysnHoliday, intConcurrencyId,' + @strMachineName1 + '
		FROM (
			SELECT CD.dtmCalendarDate,DATENAME(dw,CD.dtmCalendarDate) AS Day
				,CD.intShiftId
				,S.strShiftName
				,S.intStartOffset
				,S.intEndOffset
				,S.intShiftSequence
				,CD.dtmShiftStartTime
				,CD.dtmShiftEndTime
				,CD.intNoOfMachine
				,CD.ysnHoliday
				,M.intMachineId
				,M.strName
				,CD.intConcurrencyId
			FROM #tblMFCalendarDetail CD
			JOIN dbo.tblMFShift S ON S.intShiftId = CD.intShiftId AND (CD.ysnHoliday=0 OR CD.ysnHoliday='+LTRIM(@ysnIncludeHoliday)+')
			LEFT JOIN #tblMFScheduleCalendarMachineDetail MD on MD.dtmCalendarDate=CD.dtmCalendarDate and MD.intShiftId=CD.intShiftId
			LEFT JOIN dbo.tblMFMachine M on M.intMachineId=MD.intMachineId
			) AS DT
		PIVOT(Count(DT.intMachineId) FOR strName IN (' + @strMachineName + 
		')) pvt Order by dtmCalendarDate,intShiftSequence'

	EXEC (@SQL)
END
