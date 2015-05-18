CREATE PROCEDURE [dbo].uspMFUpdateCycleCount (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	UPDATE dbo.tblMFProcessCycleCount
	SET dblQuantity = x.dblQuantity
		,dtmLastModified = GetDate()
		,intLastModifiedUserId = x.intUserId
	FROM OPENXML(@idoc, 'root/CycleCounts/CycleCount', 2) WITH (
			intCycleCountId INT
			,dblQuantity NUMERIC(18, 6)
			,intUserId INT
			) x
	WHERE tblMFProcessCycleCount.intCycleCountId = x.intCycleCountId

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

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


