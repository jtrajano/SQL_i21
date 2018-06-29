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

	DECLARE @intLocationId INT
	DECLARE @intShiftActivityId INT
		,@dtmShiftDate DATETIME
		,@intShiftId INT
		,@intManufacturingCellId INT
		,@intUserId INT
		,@dtmToShiftDate DATETIME
		,@intToShiftId INT
		,@intToShiftActivityId INT
		,@intShiftActivityStatusId INT

	SELECT @dtmShiftDate = dtmShiftDate
		,@intManufacturingCellId = intManufacturingCellId
		,@intUserId = intUserId
		,@intShiftActivityId = intShiftActivityId
		,@intShiftId = intShiftId
		,@dtmToShiftDate = dtmToShiftDate
		,@intToShiftId = intToShiftId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			dtmShiftDate DATETIME
			,intManufacturingCellId INT
			,intUserId INT
			,intShiftActivityId INT
			,intShiftId INT
			,dtmToShiftDate DATETIME
			,intToShiftId INT
			)

	SELECT @intLocationId = intLocationId
	FROM tblMFManufacturingCell
	WHERE intManufacturingCellId = @intManufacturingCellId

	BEGIN TRANSACTION

	IF (CONVERT(CHAR, @dtmShiftDate, 101) <> CONVERT(CHAR, @dtmToShiftDate, 101))
		OR (@intShiftId <> @intToShiftId)
	BEGIN
		SELECT @intToShiftActivityId = intShiftActivityId
		FROM tblMFShiftActivity SA
		WHERE CONVERT(CHAR, SA.dtmShiftDate, 101) = CONVERT(CHAR, @dtmToShiftDate, 101)
			AND SA.intManufacturingCellId = @intManufacturingCellId
			AND SA.intShiftId = @intToShiftId

		IF @intToShiftActivityId IS NULL
		BEGIN
			SET @strErrMsg = 'There is no Shift Activity available for the selected Date and Shift.'

			RAISERROR (
					@strErrMsg
					,16
					,1
					)
		END
		ELSE
		BEGIN
			-- De-Allocate the lots from current shift
			UPDATE tblMFWorkOrderProducedLot
			SET intShiftActivityId = NULL
			WHERE intLotId IN (
					SELECT x.intLotId
					FROM OPENXML(@idoc, 'root/AllocateLot', 2) WITH (intLotId INT) x
					)
				AND intShiftActivityId = @intShiftActivityId

			SELECT @intShiftActivityStatusId = intShiftActivityStatusId
			FROM tblMFShiftActivity
			WHERE intShiftActivityId = @intShiftActivityId

			IF (@intShiftActivityStatusId = 3) -- Completed
			BEGIN
				EXEC uspMFEndShiftActivity @intManufacturingCellId
					,@intShiftActivityId
					,@intUserId
					,'Manually Closed'
					,@intLocationId
			END

			SELECT @intShiftActivityStatusId = NULL

			SELECT @intShiftActivityId = @intToShiftActivityId -- Re-assigning for Allocating lots
		END
	END

	-- Allocate the lots
	UPDATE tblMFWorkOrderProducedLot
	SET intShiftActivityId = @intShiftActivityId
	WHERE intLotId IN (
			SELECT x.intLotId
			FROM OPENXML(@idoc, 'root/AllocateLot', 2) WITH (intLotId INT) x
			)

	SELECT @intShiftActivityStatusId = intShiftActivityStatusId
	FROM tblMFShiftActivity
	WHERE intShiftActivityId = @intShiftActivityId

	IF (@intShiftActivityStatusId = 3) -- Completed
	BEGIN
		EXEC uspMFEndShiftActivity @intManufacturingCellId
			,@intShiftActivityId
			,@intUserId
			,'Manually Closed'
			,@intLocationId
	END

	COMMIT TRANSACTION

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
