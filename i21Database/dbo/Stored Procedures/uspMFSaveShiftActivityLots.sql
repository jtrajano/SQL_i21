CREATE PROCEDURE uspMFSaveShiftActivityLots
	@strXML NVARCHAR(MAX)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc INT
	DECLARE @strErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	DECLARE @intShiftActivityId INT
		,@dtmShiftDate DATETIME
		,@intShiftId INT
		,@intManufacturingCellId INT
		,@intUserId INT

	SELECT @dtmShiftDate = dtmShiftDate
		,@intManufacturingCellId = intManufacturingCellId
		,@intUserId = intUserId
		,@intShiftActivityId = intShiftActivityId
		,@intShiftId = intShiftId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			dtmShiftDate DATETIME
			,intManufacturingCellId INT
			,intUserId INT
			,intShiftActivityId INT
			,intShiftId INT
			)

	BEGIN TRANSACTION

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET intShiftActivityId = @intShiftActivityId
	WHERE intLotId IN (
			SELECT intLotId
			FROM OPENXML(@idoc, 'root/AllocateLot', 2) WITH (intLotId INT)
			)

	COMMIT TRANSACTION

	DECLARE @intLocationId INT

	SELECT @intLocationId = intLocationId
	FROM dbo.tblMFManufacturingCell
	WHERE intManufacturingCellId = @intManufacturingCellId

	EXEC dbo.uspMFEndShiftActivity @intManufacturingCellId
		,@intShiftActivityId
		,@intUserId
		,'Manually Closed'
		,@intLocationId

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
