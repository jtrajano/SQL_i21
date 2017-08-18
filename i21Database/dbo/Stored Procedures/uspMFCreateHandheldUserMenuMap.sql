CREATE PROCEDURE uspMFCreateHandheldUserMenuMap @strUserName NVARCHAR(50)
	,@strHandheldMenuItemName NVARCHAR(100) = ''
	,@ysnCreate BIT = 1
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intUserSecurityId INT
		,@intHandheldMenuItemId INT

	SELECT TOP 1 @intUserSecurityId = intEntityId
	FROM tblSMUserSecurity
	WHERE strUserName = @strUserName

	IF ISNULL(@intUserSecurityId, 0) = 0
	BEGIN
		RAISERROR (
				'User name does not exists.'
				,16
				,1
				)
	END

	SELECT @intHandheldMenuItemId = intHandheldMenuItemId
	FROM tblMFHandheldMenuItem
	WHERE strHandheldMenuItemName = @strHandheldMenuItemName

	IF ISNULL(@intHandheldMenuItemId, 0) = 0
		AND ISNULL(@strHandheldMenuItemName, '') <> 'ALL'
	BEGIN
		RAISERROR (
				'Menu name does not exists.'
				,16
				,1
				)
	END

	IF ISNULL(@strHandheldMenuItemName, '') = 'ALL'
	BEGIN
		IF @ysnCreate = 1 -- Create
		BEGIN
			DELETE
			FROM tblMFHaldheldUserMenuItemMap
			WHERE intUserSecurityId = @intUserSecurityId

			INSERT INTO tblMFHaldheldUserMenuItemMap (
				intUserSecurityId
				,intHandheldMenuItemId
				)
			SELECT @intUserSecurityId
				,intHandheldMenuItemId
			FROM tblMFHandheldMenuItem
		END
		ELSE -- Delete
		BEGIN
			DELETE
			FROM tblMFHaldheldUserMenuItemMap
			WHERE intUserSecurityId = @intUserSecurityId
		END

		RETURN;
	END

	IF @ysnCreate = 1 -- Create
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM tblMFHaldheldUserMenuItemMap
				WHERE intUserSecurityId = @intUserSecurityId
					AND intHandheldMenuItemId = @intHandheldMenuItemId
				)
		BEGIN
			INSERT INTO tblMFHaldheldUserMenuItemMap (
				intUserSecurityId
				,intHandheldMenuItemId
				)
			SELECT @intUserSecurityId
				,@intHandheldMenuItemId
		END
	END
	ELSE -- Delete
	BEGIN
		DELETE
		FROM tblMFHaldheldUserMenuItemMap
		WHERE intUserSecurityId = @intUserSecurityId
			AND intHandheldMenuItemId = @intHandheldMenuItemId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
