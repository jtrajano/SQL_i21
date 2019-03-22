CREATE PROCEDURE [dbo].[uspMFDeleteWorkOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@dtmCurrentDateTime DATETIME
		,@intUserId INT
		,@intExecutionOrder INT
		,@intManufacturingCellId INT
		,@dtmPlannedDate DATETIME

	SELECT @dtmCurrentDateTime = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intUserId = intUserId
		,@intWorkOrderId = intWorkOrderId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intUserId INT
			,intWorkOrderId INT
			)

	SELECT @intExecutionOrder = intExecutionOrder
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF EXISTS(SELECT *FROM tblMFScheduleWorkOrder WHERE intWorkOrderId=@intWorkOrderId)
	BEGIN
		RAISERROR (
			'Transaction exists for this record, record cannot be deleted.'
			,11
			,1
			)
		Return	
	END

	DELETE
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET intExecutionOrder = intExecutionOrder - 1
	WHERE intManufacturingCellId = @intManufacturingCellId
		AND dtmPlannedDate = @dtmPlannedDate
		AND intExecutionOrder > @intExecutionOrder

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


