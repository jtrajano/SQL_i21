﻿CREATE PROCEDURE [dbo].uspMFSaveCalendar (@strXML NVARCHAR(MAX),@intCalendarId INT OUTPUT,@intConcurrencyId INT OUTPUT)
AS
BEGIN Try
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
		,@intShiftBreakTypeDuration int

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
			)

	DECLARE @TRANSACTION_COUNT INT

	SET @TRANSACTION_COUNT = @@TRANCOUNT

	IF @TRANSACTION_COUNT = 0
		BEGIN TRANSACTION

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
		IF @ysnStandardCalendar = 1
		BEGIN
			UPDATE tblMFScheduleCalendar
			SET ysnStandard = 0
			WHERE intManufacturingCellId = @intManufacturingCellId
		END

		UPDATE tblMFScheduleCalendar
		SET dtmToDate = CASE 
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
			,intConcurrencyId=intConcurrencyId+1
		WHERE intCalendarId = @intCalendarId
	END

	SELECT @intConcurrencyId=intConcurrencyId
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
			,@intShiftBreakTypeDuration=NULL

		SELECT @dtmCalendarDate = dtmCalendarDate
			,@intShiftId = intShiftId
			,@dtmShiftStartTime = dtmShiftStartTime
			,@dtmShiftEndTime = dtmShiftEndTime
			,@intNoOfMachine = intNoOfMachine
			,@ysnHoliday = ysnHoliday
		FROM @tblScheduleCalendar
		WHERE intRecordId = @intRecordId

		SELECT @intCalendarDetailId = intCalendarDetailId
		FROM tblMFScheduleCalendarDetail
		WHERE intCalendarId = @intCalendarId
			AND dtmCalendarDate = @dtmCalendarDate
			AND intShiftId = @intShiftId

		SELECT @intShiftBreakTypeDuration=SUM(intShiftBreakTypeDuration) 
		FROM dbo.tblMFShiftDetail
		WHERE intShiftId=@intShiftId 

		IF @intShiftBreakTypeDuration IS NULL
		SELECT @intShiftBreakTypeDuration=0

		IF @intCalendarDetailId IS NULL
		BEGIN
			INSERT INTO tblMFScheduleCalendarDetail (
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
				,DATEDIFF(mi, @dtmShiftStartTime, @dtmShiftEndTime)-@intShiftBreakTypeDuration
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
			WHERE dtmCalendarDate=@dtmCalendarDate AND intShiftId=@intShiftId

		END
		ELSE
		BEGIN
			UPDATE dbo.tblMFScheduleCalendarDetail
			SET dtmShiftStartTime = @dtmShiftStartTime
				,dtmShiftEndTime = @dtmShiftEndTime
				,intDuration = DATEDIFF(mi, @dtmShiftStartTime, @dtmShiftEndTime)-@intShiftBreakTypeDuration
				,intNoOfMachine = @intNoOfMachine
				,ysnHoliday = @ysnHoliday
				,dtmLastModified = @dtmCurrentDate
				,intLastModifiedUserId = @intUserId
				,intConcurrencyId=intConcurrencyId+1
			WHERE intCalendarDetailId = @intCalendarDetailId

			DELETE
			FROM dbo.tblMFScheduleCalendarMachineDetail
			WHERE intCalendarDetailId = @intCalendarDetailId
			AND NOT EXISTS(SELECT *
			FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
					intMachineId INT
					,intShiftId INT
					,dtmCalendarDate DATETIME
					)
			WHERE dtmCalendarDate=@dtmCalendarDate AND intShiftId=@intShiftId AND intMachineId=tblMFScheduleCalendarMachineDetail.intMachineId)

			INSERT INTO dbo.tblMFScheduleCalendarMachineDetail (
				intCalendarDetailId
				,intMachineId
				)
			SELECT @intCalendarDetailId,intMachineId
			FROM OPENXML(@idoc, 'root/Calendars/Calendar/Machines/Machine', 2) WITH (
					intMachineId INT
					,intShiftId INT
					,dtmCalendarDate DATETIME
					)
			WHERE dtmCalendarDate=@dtmCalendarDate AND intShiftId=@intShiftId 
			AND NOT EXISTS(SELECT *FROM tblMFScheduleCalendarMachineDetail MD WHERE MD.intCalendarDetailId=@intCalendarDetailId AND MD.intMachineId=intMachineId)
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

