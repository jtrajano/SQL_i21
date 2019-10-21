CREATE PROCEDURE uspMFUndoStartCycleCount @intWorkOrderId INT
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intCycleCountSessionId INT
		,@strErrMsg NVARCHAR(MAX)
		,@strInstantConsumption NVARCHAR(50)
		,@intAttributeId INT
		,@intManufacturingProcessId INT
		,@intLocationId INT
		,@intCountStatusId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
		,@intCountStatusId = intCountStatusId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Instant Consumption'

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @intCountStatusId = 13
	BEGIN
		RAISERROR (
				'You cannot undo the cycle count since the data is already updated by another user. Please refresh.'
				,16
				,1
				)
	END

	BEGIN TRAN

	DELETE
	FROM tblMFProcessCycleCountMachine
	WHERE intCycleCountId IN (
			SELECT intCycleCountId
			FROM tblMFProcessCycleCount
			WHERE intCycleCountSessionId IN (
					SELECT intCycleCountSessionId
					FROM tblMFProcessCycleCountSession
					WHERE intWorkOrderId = @intWorkOrderId
					)
			)

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
		,dblConsumedQuantity = Case When @strInstantConsumption='False' Then  0 Else dblConsumedQuantity End
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
