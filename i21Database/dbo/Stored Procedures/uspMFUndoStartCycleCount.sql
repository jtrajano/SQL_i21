CREATE PROCEDURE uspMFUndoStartCycleCount @intWorkOrderId INT
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intCycleCountSessionId INT
		,@strErrMsg NVARCHAR(MAX)

	BEGIN TRAN

	DELETE
	FROM tblMFProcessCycleCount
	WHERE intCycleCountSessionId IN (
			SELECT intCycleCountSessionId
			FROM tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intWorkOrderId
			)

	DELETE
	FROM tblMFProcessCycleCountSession
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFWorkOrder
	SET intCountStatusId = 1
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GetDate()
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFProductionSummary
	SET dblOpeningQuantity = 0
		,dblOpeningOutputQuantity = 0
		,dblOpeningConversionQuantity = 0
		,dblConsumedQuantity = 0
		,dblCountQuantity = 0
		,dblCountOutputQuantity = 0
		,dblCountConversionQuantity = 0
		,dblYieldQuantity = 0
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
