CREATE PROCEDURE uspMFUndoStartCycleCount @intWorkOrderId INT
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intCycleCountSessionId INT
		,@strErrMsg NVARCHAR(MAX)

	SELECT @intCycleCountSessionId = intCycleCountSessionId
	FROM tblMFProcessCycleCountSession
	WHERE intWorkOrderId = @intWorkOrderId

	BEGIN TRAN

	DELETE
	FROM tblMFProcessCycleCount
	WHERE intCycleCountSessionId = @intCycleCountSessionId

	DELETE
	FROM tblMFProcessCycleCountSession
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFWorkOrder
	SET intCountStatusId = NULL
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GetDate()
	WHERE intWorkOrderId = @intWorkOrderId

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
