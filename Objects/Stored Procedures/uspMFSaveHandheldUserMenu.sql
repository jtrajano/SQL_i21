CREATE PROCEDURE uspMFSaveHandheldUserMenu @intUserSecurityId INT
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

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	BEGIN TRANSACTION

	DELETE
	FROM tblMFHaldheldUserMenuItemMap
	WHERE intUserSecurityId = @intUserSecurityId
		AND intHandheldMenuItemId NOT IN (
			SELECT intHandheldMenuItemId
			FROM OPENXML(@idoc, 'root/MenuPermission', 2) WITH (intHandheldMenuItemId INT)
			)

	INSERT INTO tblMFHaldheldUserMenuItemMap (
		intConcurrencyId
		,intUserSecurityId
		,intHandheldMenuItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intUserSecurityId
		,intHandheldMenuItemId
		,@intUserId
		,GETDATE()
		,@intUserId
		,GETDATE()
	FROM OPENXML(@idoc, 'root/MenuPermission', 2) WITH (intHandheldMenuItemId INT)
	WHERE intHandheldMenuItemId NOT IN (
			SELECT intHandheldMenuItemId
			FROM tblMFHaldheldUserMenuItemMap
			WHERE intUserSecurityId = @intUserSecurityId
			)

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
