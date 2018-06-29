CREATE PROCEDURE [dbo].uspMFSaveCalendar (
	@strXML NVARCHAR(MAX)
	,@intCalendarId INT OUTPUT
	,@intConcurrencyId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @strCalendarName NVARCHAR(50)
		,@intManufacturingCellId INT
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@dtmCalendarDate DATETIME
		,@intShiftId INT
		,@dtmShiftStartTime DATETIME
		,@dtmShiftEndTime DATETIME
		,@ysnStandardCalendar BIT
		,@intNoOfMachine INT
		,@intUserId INT
		,@intRecordId INT
		,@dtmCurrentDate DATETIME
		,@idoc INT
		,@intLocationId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intCalendarDetailId INT
		,@ysnHoliday BIT
		,@intShiftBreakTypeDuration INT
		,@intMachineId INT
		,@strCalendarDate NVARCHAR(50)
		,@strShiftName NVARCHAR(50)
		,@strName NVARCHAR(50)
		,@strShiftId NVARCHAR(50)

	SELECT @dtmCurrentDate = GETDATE()

	DECLARE @tblScheduleCalendar TABLE (
		intRecordId INT identity(1, 1)
		,dtmCalendarDate DATETIME
		,intShiftId INT
		,dtmShiftStartTime DATETIME
		,dtmShiftEndTime DATETIME
		,intNoOfMachine INT
		,ysnHoliday BIT
		,intConcurrencyId INT
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intCalendarId = intCalendarId
		,@strCalendarName = strCalendarName
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmFromDate = dtmFromDate
		,@dtmToDate = dtmToDate
		,@ysnStandardCalendar = ysnStandardCalendar
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@intConcurrencyId = intConcurrencyId
		,@strShiftId = strShiftIds
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intCalendarId INT
			,strCalendarName NVARCHAR(50)
			,intManufacturingCellId INT
			,dtmFromDate DATETIME
			,dtmToDate DATETIME
			,ysnStandardCalendar BIT
			,intUserId INT
			,intLocationId INT
			,intConcurrencyId INT
			,strShiftIds NVARCHAR(50)
			)

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFScheduleCalendar
			WHERE strName = @strCalendarName
				AND intManufacturingCellId = @intManufacturingCellId
				AND intLocationId = @intLocationId
				AND intCalendarId <> isNULL(@intCalendarId, 0)
			)
	BEGIN
		RAISERROR (
				'Calendar name ''%s'' already exists.'
				,11
				,1
				,@strCalendarName
				)
	END

	DECLARE @TRANSACTION_COUNT INT

	SET @TRANSACTION_COUNT = @@TRANCOUNT

	IF @TRANSACTION_COUNT = 0
		BEGIN TRANSACTION

	DELETE
	FROM dbo.tblMFScheduleCalendarDetail
	WHERE dtmCalendarDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND intCalendarId = @intCalendarId
		AND NOT EXISTS (
			SELECT *
			FROM dbo.fnSplitString(@strShiftId, ',') S
			WHERE S.Item = tblMFScheduleCalendarDetail.intShiftId
			)

	IF @ysnStandardCalendar = 1
	BEGIN
		UPDATE dbo.tblMFScheduleCalendar
		SET ysnStandard = 0
		WHERE intManufacturingCellId = @intManufacturingCellId
	END

	IF @intCalendarId IS NULL
	BEGIN
		INSERT INTO dbo.tblMFScheduleCalendar (
			strName
			,intManufacturingCellId
			,dtmFromDate
			,dtmToDate
			,ysnStandard
			,intLocationId
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,intConcurrencyId
			)
		SELECT @strCalendarName
			,@intManufacturingCellId
			,@dtmFromDate
			,@dtmToDate
			,@ysnStandardCalendar
			,@intLocationId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,1

		SELECT @intCalendarId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE dbo.tblMFScheduleCalendar
		SET strName = @strCalendarName
			,dtmToDate = CASE 
				WHEN @dtmToDate IS NOT NULL
					THEN @dtmToDate
				ELSE dtmToDate
				END
			,ysnStandard = CASE 
				WHEN @ysnStandardCalendar IS NOT NULL
					THEN @ysnStandardCalendar
				ELSE ysnStandard
				END
			,dtmLastModified = @dtmCurrentDate
			,intLastModifiedUserId = @intUserId
			,intConcurrencyId = intConcurrencyId + 1
		WHERE intCalendarId = @intCalendarId
	END

	SELECT @intConcurrencyId = intConcurrencyId
	FROM dbo.tblMFScheduleCalendar
	WHERE intCalendarId = @intCalendarId

	INSERT INTO @tblScheduleCalendar (
		dtmCalendarDate
		,intShiftId
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intNoOfMachine
		,ysnHoliday
		,intConcurrencyId
		)
	SELECT dtmCalendarDate
		,intShiftId
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intNoOfMachine
		,ysnHoliday
		,intConcurrencyId
	FROM OPENXML(@idoc, 'root/Calendars/Calendar', 2) WITH (
			dtmCalendarDate DATETIME
			,intShiftId INT
			,dtmShiftStartTime DATETIME
			,dtmShiftEndTime DATETIME
			,intNoOfMachine INT
			,ysnHoliday BIT
			,intConcurrencyId INT
			)

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblScheduleCalendar

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @dtmCalendarDate = NULL
			,@intShiftId = NULL
			,@dtmShiftStartTime = NULL
			,@dtmShiftEndTime = NULL
			,@intNoOfMachine = NULL
			,@ysnHoliday = NULL
			,@intShiftBreakTypeDuration = NULL
			,@intCalendarDetailId = NULL

		SELECT @dtmCalendarDate = dtmCalendarDate
			,@intShiftId = intShiftId
			,@dtmShiftStartTime = dtmShiftStartTime
			,@dtmShiftEndTime = dtmShiftEndTime
			,@intNoOfMachine = intNoOfMachine
			,@ysnHoliday = ysnHoliday
		FROM @tblScheduleCalendar
		WHERE intRecordId = @intRecordId

		SELECT @intCalendarDetailId = intCalendarDetailId
		FROM dbo.tblMFScheduleCalendarDetail
		WHERE intCalendarId = @intCalendarId
			AND dtmCalendarDate = @dtmCalendarDate
			AND intShiftId = @intShiftId

		SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
		FROM dbo.tblMFShiftDetail
		WHERE intShiftId = @intShiftId

		IF @intShiftBreakTypeDuration IS NULL
			SELECT @intShiftBreakTypeDuration = 0

		IF @intCalendarDetailId IS NULL
		BEGIN
			INSERT INTO dbo.tblMFScheduleCalendarDetail (
				intCalendarId
				,dtmCalendarDate
				,dtmShiftStartTime
				,dtmShiftEndTime
				,intDuration
				,intShiftId
				,intNoOfMachine
				,ysnHoliday
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intConcurrencyId
				)
			SELECT @intCalendarId
				,@dtmCalendarDate
				,@dtmShiftStartTime
				,@dtmShiftEndTime
				,DATEDIFF(mi, @dtmShiftStartTime, @dtmShiftEndTime) - @intShiftBreakTypeDuration
				,@intShiftId
				,@intNoOfMachine
				,@ysnHoliday
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intUserId
				,1

			SELECT @intCalendarDetailId = SCOPE_IDENTITY()

			INSERT INTO dbo.tblMFScheduleCalendarMachineDetail (
				intCalendarDetailId
				,intMachineId
				)
			SELECT @intCalendarDetailId
				,intMachineId
			FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
					intMachineId INT
					,intShiftId INT
					,dtmCalendarDate DATETIME
					)
			WHERE dtmCalendarDate = @dtmCalendarDate
				AND intShiftId = @intShiftId
		END
		ELSE
		BEGIN
			UPDATE dbo.tblMFScheduleCalendarDetail
			SET dtmShiftStartTime = @dtmShiftStartTime
				,dtmShiftEndTime = @dtmShiftEndTime
				,intDuration = DATEDIFF(mi, @dtmShiftStartTime, @dtmShiftEndTime) - @intShiftBreakTypeDuration
				,intNoOfMachine = @intNoOfMachine
				,ysnHoliday = @ysnHoliday
				,dtmLastModified = @dtmCurrentDate
				,intLastModifiedUserId = @intUserId
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intCalendarDetailId = @intCalendarDetailId

			IF EXISTS (
					SELECT *
					FROM dbo.tblMFScheduleMachineDetail MD
					JOIN dbo.tblMFScheduleCalendarMachineDetail CMD ON MD.intCalendarMachineId = CMD.intCalendarMachineId
					WHERE MD.intCalendarDetailId = @intCalendarDetailId
						AND NOT EXISTS (
							SELECT *
							FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
									intMachineId INT
									,intShiftId INT
									,dtmCalendarDate DATETIME
									) x
							WHERE dtmCalendarDate = @dtmCalendarDate
								AND intShiftId = @intShiftId
								AND x.intMachineId = CMD.intMachineId
							)
					)
			BEGIN
				SELECT @intMachineId = intMachineId
				FROM dbo.tblMFScheduleMachineDetail MD
				JOIN dbo.tblMFScheduleCalendarMachineDetail CMD ON MD.intCalendarMachineId = CMD.intCalendarMachineId
				WHERE MD.intCalendarDetailId = @intCalendarDetailId
					AND NOT EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
								intMachineId INT
								,intShiftId INT
								,dtmCalendarDate DATETIME
								) x
						WHERE dtmCalendarDate = @dtmCalendarDate
							AND intShiftId = @intShiftId
							AND x.intMachineId = CMD.intMachineId
						)

				SELECT @strName = strName
				FROM dbo.tblMFMachine
				WHERE intMachineId = @intMachineId

				SELECT @strCalendarDate = @dtmCalendarDate

				SELECT @strCalendarDate = Replace(@strCalendarDate, ' 12:00AM', '')

				SELECT @strShiftName = strShiftName
				FROM dbo.tblMFShift
				WHERE intShiftId = @intShiftId

				RAISERROR (
						'Machine: %s is used in the schedule for %s and %s.'
						,14
						,1
						,@strName
						,@strCalendarDate
						,@strShiftName
						)
			END

			DELETE
			FROM dbo.tblMFScheduleCalendarMachineDetail
			WHERE intCalendarDetailId = @intCalendarDetailId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
							intMachineId INT
							,intShiftId INT
							,dtmCalendarDate DATETIME
							) x
					WHERE dtmCalendarDate = @dtmCalendarDate
						AND intShiftId = @intShiftId
						AND x.intMachineId = tblMFScheduleCalendarMachineDetail.intMachineId
					)

			INSERT INTO dbo.tblMFScheduleCalendarMachineDetail (
				intCalendarDetailId
				,intMachineId
				)
			SELECT @intCalendarDetailId
				,intMachineId
			FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
					intMachineId INT
					,intShiftId INT
					,dtmCalendarDate DATETIME
					) x
			WHERE dtmCalendarDate = @dtmCalendarDate
				AND intShiftId = @intShiftId
				AND NOT EXISTS (
					SELECT *
					FROM tblMFScheduleCalendarMachineDetail MD
					WHERE MD.intCalendarDetailId = @intCalendarDetailId
						AND MD.intMachineId = x.intMachineId
					)
		END

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblScheduleCalendar
		WHERE intRecordId > @intRecordId
	END

	IF @TRANSACTION_COUNT = 0
		AND @@TRANCOUNT > 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @TRANSACTION_COUNT = 0
		AND @@TRANCOUNT > 0
		AND XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
