CREATE PROCEDURE uspMFShiftActivity_Create
     @intShiftId INT
	,@dtmShiftDate DATETIME
	,@strXML NVARCHAR(MAX)
	,@intLocationId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intManufacturingCellId INT
		,@intCreatedUserId INT
		,@intLastModifiedUserId INT
		,@dtmActualShiftStTime DATETIME
		,@dtmActualShiftEdTime DATETIME
		,@dtmActualShiftStTime1 DATETIME
		,@dtmActualShiftEdTime1 DATETIME
		,@ysnUseProductionLine BIT
		,@intDuration INT
		,@strShiftActivityNumber NVARCHAR(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SET @dtmShiftDate = CONVERT(NVARCHAR, @dtmShiftDate, 101)

	SELECT @intCreatedUserId = intCreatedUserId
		,@intLastModifiedUserId = intLastModifiedUserId
		,@ysnUseProductionLine = ysnProductionLine
		,@dtmActualShiftStTime = CASE 
			WHEN YEAR(dtmActualShiftStTime) = 1900
				THEN @dtmShiftDate + dtmActualShiftStTime
			ELSE dtmActualShiftStTime
			END
		,@dtmActualShiftEdTime = CASE 
			WHEN YEAR(dtmActualShiftEdTime) = 1900
				THEN @dtmShiftDate + dtmActualShiftEdTime
			ELSE dtmActualShiftEdTime
			END
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intCreatedUserId NVARCHAR(50)
			,intLastModifiedUserId NVARCHAR(50)
			,ysnProductionLine BIT
			,dtmActualShiftStTime DATETIME
			,dtmActualShiftEdTime DATETIME
			)

	SET @dtmActualShiftStTime1 = @dtmActualShiftStTime
	SET @dtmActualShiftEdTime1 = @dtmActualShiftEdTime
	SET @intManufacturingCellId = (
			SELECT TOP 1 (intManufacturingCellId)
			FROM OPENXML(@idoc, 'root/ManufacturingCell', 2) WITH (intManufacturingCellId INT)
			ORDER BY intManufacturingCellId
			)

	WHILE (@intManufacturingCellId IS NOT NULL)
	BEGIN
		/*if the supplied Downtime already exists in the database THEN raise error*/
		IF EXISTS (
				SELECT SA.intShiftActivityId
				FROM dbo.tblMFShiftActivity SA
				JOIN dbo.tblMFShift S ON S.intShiftId = SA.intShiftId
				WHERE SA.intManufacturingCellId = @intManufacturingCellId
					AND S.intLocationId = @intLocationId
					AND SA.intShiftId = @intShiftId
					AND CONVERT(NVARCHAR, SA.dtmShiftDate, 101) = @dtmShiftDate
				)
		BEGIN
			SET @strErrMsg = 'There is already an existing ShiftActivityDetail in the database, should be unique.'

			RAISERROR (
					@strErrMsg
					,16
					,1
					)
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFShiftActivity
				WHERE intManufacturingCellId = @intManufacturingCellId
					AND (
						(
							@dtmActualShiftStTime1 BETWEEN dtmShiftStartTime
								AND DATEADD(mi, - 1, dtmShiftEndTime)
							)
						OR (
							DATEADD(mi, - 1, @dtmActualShiftEdTime1) BETWEEN dtmShiftStartTime
								AND DATEADD(mi, - 1, dtmShiftEndTime)
							)
						OR (
							dtmShiftStartTime BETWEEN @dtmActualShiftStTime1
								AND DATEADD(mi, - 1, @dtmActualShiftEdTime1)
							)
						OR (
							DATEADD(mi, - 1, dtmShiftEndTime) BETWEEN @dtmActualShiftStTime1
								AND DATEADD(mi, - 1, @dtmActualShiftEdTime1)
							)
						)
				)
		BEGIN
			RAISERROR (
					'Extended shift time is overlapping with an existing shift time.'
					,16
					,1
					)
		END

		SET @intDuration = DATEDIFF(ss, @dtmActualShiftStTime1, @dtmActualShiftEdTime1)

		IF @intDuration > 86400
		BEGIN
			RAISERROR (
					'Time difference should be within 24 hours.'
					,16
					,1
					)
		END

		BEGIN TRANSACTION

		IF (
				@strShiftActivityNumber = ''
				OR @strShiftActivityNumber IS NULL
				)
		BEGIN
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
				,@intItemId = NULL
				,@intManufacturingId = NULL
				,@intSubLocationId = NULL
				,@intLocationId = NULL
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 102
				,@ysnProposed = 0
				,@strPatternString = @strShiftActivityNumber OUTPUT
		END

		IF @ysnUseProductionLine = 0
		BEGIN
			INSERT INTO tblMFShiftActivity (
				strShiftActivityNumber
				,intManufacturingCellId
				,dtmShiftDate
				,intShiftId
				,dtmShiftStartTime
				,dtmShiftEndTime
				,dblPartialQtyProduced
				,intScheduledRuntime
				,intTotalDowntime
				,intShiftActivityStatusId
				,dblStdCapacity
				,dblTargetEfficiency
				,intLineUnitMeasureId
				,intLineRateUnitMeasureId
				,intConcurrencyId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT @strShiftActivityNumber
				,@intManufacturingCellId
				,@dtmShiftDate
				,@intShiftId
				,@dtmActualShiftStTime
				,@dtmActualShiftEdTime
				,0
				,(DATEDIFF(ss, @dtmActualShiftStTime, @dtmActualShiftEdTime) * COUNT(DISTINCT (SCM.intMachineId)))
				,0
				,2
				,MC.dblStdCapacity
				,MC.dblStdLineEfficiency
				,MC.intStdUnitMeasureId
				,MC.intStdCapacityRateId
				,1
				,@intCreatedUserId
				,GETDATE()
				,@intLastModifiedUserId
				,GETDATE()
			FROM dbo.tblMFScheduleCalendarDetail SCD
			JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = SCD.intCalendarId
				AND SC.ysnStandard = 1
				AND SC.intLocationId = @intLocationId
			JOIN dbo.tblMFScheduleCalendarMachineDetail AS SCM ON SCM.intCalendarDetailId = SCD.intCalendarDetailId
			JOIN dbo.tblMFShift S ON S.intShiftId = SCD.intShiftId
			JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SC.intManufacturingCellId
			WHERE CONVERT(NVARCHAR, SCD.dtmCalendarDate, 101) = @dtmShiftDate
				AND SCD.intShiftId = @intShiftId
				AND SCD.intNoOfMachine > 0
				AND MC.intManufacturingCellId = @intManufacturingCellId
				AND MC.ysnIncludeEfficiency = 1
			GROUP BY MC.dblStdCapacity
				,MC.dblStdLineEfficiency
				,MC.intStdUnitMeasureId
				,MC.intStdCapacityRateId

			INSERT INTO dbo.tblMFShiftActivityMachines (
				intShiftActivityId
				,intMachineId
				,intConcurrencyId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT SCOPE_IDENTITY()
				,SCM.intMachineId
				,1
				,@intCreatedUserId
				,GETDATE()
				,@intLastModifiedUserId
				,GETDATE()
			FROM dbo.tblMFScheduleCalendarDetail SCD
			JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = SCD.intCalendarId
				AND SC.ysnStandard = 1
				AND SC.intLocationId = @intLocationId
			JOIN dbo.tblMFScheduleCalendarMachineDetail AS SCM ON SCM.intCalendarDetailId = SCD.intCalendarDetailId
			WHERE CONVERT(NVARCHAR, SCD.dtmCalendarDate, 101) = @dtmShiftDate
				AND SCD.intShiftId = @intShiftId
				AND SCD.intNoOfMachine > 0
				AND SC.intManufacturingCellId = @intManufacturingCellId
		END

		IF @ysnUseProductionLine = 1
		BEGIN
			INSERT INTO dbo.tblMFShiftActivity (
				strShiftActivityNumber
				,intManufacturingCellId
				,dtmShiftDate
				,intShiftId
				,dtmShiftStartTime
				,dtmShiftEndTime
				,dblPartialQtyProduced
				,intScheduledRuntime
				,intTotalDowntime
				,intShiftActivityStatusId
				,dblStdCapacity
				,dblTargetEfficiency
				,intLineUnitMeasureId
				,intLineRateUnitMeasureId
				,intConcurrencyId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT @strShiftActivityNumber
				,@intManufacturingCellId
				,@dtmShiftDate
				,@intShiftId
				,@dtmActualShiftStTime
				,@dtmActualShiftEdTime
				,0
				,(DATEDIFF(ss, @dtmActualShiftStTime, @dtmActualShiftEdTime))
				,0
				,2
				,MC.dblStdCapacity
				,MC.dblStdLineEfficiency
				,MC.intStdUnitMeasureId
				,MC.intStdCapacityRateId
				,1
				,@intCreatedUserId
				,GETDATE()
				,@intLastModifiedUserId
				,GETDATE()
			FROM dbo.tblMFShift S
				,dbo.tblMFManufacturingCell MC
			WHERE S.intShiftId = @intShiftId
				AND MC.intManufacturingCellId = @intManufacturingCellId
				AND MC.ysnIncludeEfficiency = 1
		END

		COMMIT TRANSACTION

		SET @intManufacturingCellId = (
				SELECT TOP 1 (intManufacturingCellId)
				FROM OPENXML(@idoc, 'root/ManufacturingCell', 2) WITH (intManufacturingCellId INT)
				WHERE intManufacturingCellId > @intManufacturingCellId
				ORDER BY intManufacturingCellId
				)
	END

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
