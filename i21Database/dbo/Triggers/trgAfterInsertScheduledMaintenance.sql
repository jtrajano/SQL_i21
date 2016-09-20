CREATE TRIGGER [dbo].[trgAfterInsertScheduledMaintenance] ON [dbo].[tblMFScheduledMaintenance]
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @intScheduledMaintenanceId INT
		,@dtmCalendarDate DATETIME
		,@intShiftId INT
		,@dtmStartTime DATETIME
		,@dtmEndTime DATETIME
		,@intDuration INT
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME
		,@intLocationId INT
	DECLARE @tblMFShift TABLE (
		intShiftId INT
		,dtmStartTime DATETIME
		,dtmEndTime DATETIME
		)

	SELECT @intScheduledMaintenanceId = intScheduledMaintenanceId
	FROM Deleted

	IF EXISTS (
			SELECT *
			FROM Deleted
			)
	BEGIN
		DELETE
		FROM dbo.tblMFScheduledMaintenanceDetail
		WHERE intScheduledMaintenanceId = @intScheduledMaintenanceId
	END

	SELECT @intScheduledMaintenanceId = intScheduledMaintenanceId
	FROM inserted

	SELECT @dtmStartDate = dtmStartDate
		,@dtmEndDate = dtmEndDate
		,@dtmStartTime = dtmStartTime
		,@dtmEndTime = dtmEndTime
		,@intLocationId = intLocationId
	FROM dbo.tblMFScheduledMaintenance
	WHERE intScheduledMaintenanceId = @intScheduledMaintenanceId

	INSERT INTO @tblMFShift (
		intShiftId
		,dtmStartTime
		,dtmEndTime
		)
	SELECT intShiftId
		,CASE 
			WHEN dtmShiftStartTime > @dtmStartTime
				THEN dtmShiftStartTime
			ELSE @dtmStartTime
			END
		,CASE 
			WHEN dtmShiftEndTime > @dtmEndTime
				THEN @dtmEndTime
			ELSE dtmShiftEndTime
			END
	FROM dbo.tblMFShift
	WHERE (Convert(TIME, @dtmStartTime) BETWEEN Convert(TIME, dtmShiftStartTime)
			AND Convert(TIME, dtmShiftEndTime)
		OR Convert(TIME, @dtmEndTime) BETWEEN Convert(TIME, dtmShiftStartTime)
			AND Convert(TIME, dtmShiftEndTime))
		AND intLocationId = @intLocationId

	WHILE @dtmEndDate >= @dtmStartDate
	BEGIN
		INSERT INTO dbo.tblMFScheduledMaintenanceDetail (
			intScheduledMaintenanceId
			,dtmCalendarDate
			,intShiftId
			,dtmStartTime
			,dtmEndTime
			,intDuration
			)
		SELECT @intScheduledMaintenanceId
			,@dtmStartDate
			,intShiftId
			,@dtmStartDate+dtmStartTime
			,@dtmStartDate+dtmEndTime
			,DateDiff(Minute, dtmStartTime, dtmEndTime)
		FROM @tblMFShift
		Where DateDiff(Minute, dtmStartTime, dtmEndTime)>0

		SELECT @dtmStartDate = @dtmStartDate + 1
	END
END
