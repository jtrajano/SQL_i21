﻿CREATE PROCEDURE uspMFSaveShiftActivityMachines
	@intShiftActivityId INT
	,@strXML NVARCHAR(MAX)
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intScheduledRuntime INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	BEGIN TRANSACTION

	DELETE
	FROM tblMFShiftActivityMachines
	WHERE intShiftActivityId = @intShiftActivityId
		AND intMachineId NOT IN (
			-- To ignore available Machines in XML
			SELECT intMachineId
			FROM OPENXML(@idoc, 'root/Machine', 2) WITH (intMachineId INT)
			)

	INSERT INTO tblMFShiftActivityMachines (
		intConcurrencyId
		,intShiftActivityId
		,intMachineId
		,dblMachCapacity
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intShiftActivityId
		,intMachineId
		,0
		,@intUserId
		,GETDATE()
		,@intUserId
		,GETDATE()
	FROM OPENXML(@idoc, 'root/Machine', 2) WITH (intMachineId INT)
	WHERE intMachineId NOT IN (
			-- To ignore available Machines in table
			SELECT intMachineId
			FROM tblMFShiftActivityMachines
			WHERE intShiftActivityId = @intShiftActivityId
			)

	SELECT @intScheduledRuntime = ISNULL((DATEDIFF(ss, SA.dtmShiftStartTime, SA.dtmShiftEndTime) * COUNT(SAM.intMachineId)),0)
	FROM tblMFShiftActivity SA
	JOIN tblMFShiftActivityMachines SAM ON SAM.intShiftActivityId = SA.intShiftActivityId
	WHERE SA.intShiftActivityId = @intShiftActivityId
	GROUP BY SA.dtmShiftStartTime
		,SA.dtmShiftEndTime

	UPDATE tblMFShiftActivity
	SET intScheduledRuntime = @intScheduledRuntime
	WHERE intShiftActivityId = @intShiftActivityId

	EXEC sp_xml_removedocument @idoc

	COMMIT TRANSACTION
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
