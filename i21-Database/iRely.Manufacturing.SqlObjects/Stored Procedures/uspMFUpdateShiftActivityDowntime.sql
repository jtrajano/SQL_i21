CREATE PROCEDURE uspMFUpdateShiftActivityDowntime
	@intShiftActivityId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @intTotalDowntime INT = 0
	DECLARE @intReduceAvailableTime INT = 0
	DECLARE @intDuration INT = 0
	DECLARE @strErrMsg NVARCHAR(MAX)

	SELECT @intTotalDowntime = ISNULL(SUM(intDowntime), 0)
	FROM dbo.tblMFDowntimeMachines DM
	JOIN dbo.tblMFDowntime D ON D.intDowntimeId = DM.intDowntimeId
	WHERE D.intShiftActivityId = @intShiftActivityId

	SELECT @intReduceAvailableTime = ISNULL(SUM(intDowntime) / 60, 0)
	FROM dbo.tblMFDowntimeMachines DM
	JOIN dbo.tblMFDowntime D ON D.intDowntimeId = DM.intDowntimeId
	JOIN dbo.tblMFReasonCode RC ON RC.intReasonCodeId = D.intReasonCodeId
	WHERE RC.ysnReduceavailabletime = 1
		AND D.intShiftActivityId = @intShiftActivityId

	SELECT @intDuration = ISNULL(intScheduledRuntime, 0)
	FROM dbo.tblMFShiftActivity
	WHERE intShiftActivityId = @intShiftActivityId

	IF (@intTotalDowntime > @intDuration)
	BEGIN
		SET @strErrMsg = 'Downtime cannot be greater than the shift duration.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	UPDATE dbo.tblMFShiftActivity
	SET intTotalDowntime = @intTotalDowntime
		,intReduceAvailableTime = @intReduceAvailableTime
	WHERE intShiftActivityId = @intShiftActivityId
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
