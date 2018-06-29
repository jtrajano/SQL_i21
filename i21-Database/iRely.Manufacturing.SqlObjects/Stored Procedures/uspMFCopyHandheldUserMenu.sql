CREATE PROCEDURE uspMFCopyHandheldUserMenu @intFromUserSecurityId INT
	,@strToUserSecurityId NVARCHAR(MAX)
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)

	BEGIN TRANSACTION

	DELETE
	FROM tblMFHaldheldUserMenuItemMap
	WHERE intUserSecurityId IN (
			SELECT *
			FROM dbo.fnSplitString(@strToUserSecurityId, ',')
			WHERE ISNULL(Item, '') <> ''
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
		,Item
		,intHandheldMenuItemId
		,@intUserId
		,GETDATE()
		,@intUserId
		,GETDATE()
	FROM tblMFHaldheldUserMenuItemMap
	CROSS APPLY dbo.fnSplitString(@strToUserSecurityId, ',')
	WHERE intUserSecurityId = @intFromUserSecurityId
		AND ISNULL(Item, '') <> ''
	ORDER BY Item
		,intHandheldMenuItemId

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
