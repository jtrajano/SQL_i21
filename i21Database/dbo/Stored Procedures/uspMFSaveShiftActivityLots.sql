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
		,@strUserName NVARCHAR(50)

	SELECT @dtmShiftDate = dtmShiftDate
		,@intManufacturingCellId = intManufacturingCellId
		,@strUserName = strUserName
		,@intShiftActivityId = intShiftActivityId
		,@intShiftId = intShiftId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			dtmShiftDate DATETIME
			,intManufacturingCellId INT
			,strUserName NVARCHAR(50)
			,intShiftActivityId INT
			,intShiftId INT
			)

	BEGIN TRANSACTION

	UPDATE tblMFWorkOrderProducedLot
	SET intShiftActivityId = @intShiftActivityId
	WHERE intLotId IN (
			SELECT intLotId
			FROM OPENXML(@idoc, 'root/AllocateLot', 2) WITH (intLotId INT)
			)

	COMMIT TRANSACTION

	--EXEC dbo.uspMFEndShiftActivity @intManufacturingCellId
	--	,@dtmShiftDate
	--	,@intShiftId
	--	,@intShiftActivityId
	--	,@strUserName
	--	,'Manually Closed'
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
