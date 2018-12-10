CREATE PROCEDURE uspQMImportList @intUserId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	DECLARE @intRowId INT
		,@strListName NVARCHAR(50)
		,@strListItemName NVARCHAR(50)
		,@strSQL NVARCHAR(MAX)
		,@intListId INT
		,@ysnIsDefault BIT
		,@ysnActive BIT

	IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE LOWER(strUserName) = 'irelyadmin'
	END

	SELECT @intRowId = MIN(intListImportId)
	FROM tblQMListImport
	WHERE ISNULL(ysnProcessed, 0) = 0

	WHILE (ISNULL(@intRowId, 0) > 0)
	BEGIN
		BEGIN TRY
			SELECT @strListName = ''
				,@strListItemName = ''
				,@strSQL = ''
				,@ysnIsDefault = 0
				,@ysnActive = 0
				,@intListId = NULL

			SELECT @strListName = strListName
				,@strListItemName = strListItemName
				,@strSQL = strSQL
				,@ysnIsDefault = ysnIsDefault
				,@ysnActive = ysnActive
			FROM tblQMListImport
			WHERE intListImportId = @intRowId

			IF ISNULL(@strListName, '') = ''
			BEGIN
				RAISERROR (
						'List Name cannot be empty. '
						,16
						,1
						)
			END

			IF ISNULL(@strListItemName, '') = ''
			BEGIN
				RAISERROR (
						'List Item Name cannot be empty. '
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblQMList
					WHERE strListName = @strListName
					)
			BEGIN
				INSERT INTO tblQMList (
					[intConcurrencyId]
					,[strListName]
					,[strSQL]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@strListName
					,@strSQL
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				SELECT @intListId = SCOPE_IDENTITY()

				INSERT INTO tblQMListItem (
					[intListId]
					,[intConcurrencyId]
					,[strListItemName]
					,[ysnIsDefault]
					,[ysnActive]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT @intListId
					,1
					,@strListItemName
					,@ysnIsDefault
					,@ysnActive
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()
			END
			ELSE
			BEGIN
				SELECT @intListId = intListId
				FROM tblQMList
				WHERE strListName = @strListName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMListItem
						WHERE intListId = @intListId
							AND strListItemName = @strListItemName
						)
				BEGIN
					INSERT INTO tblQMListItem (
						[intListId]
						,[intConcurrencyId]
						,[strListItemName]
						,[ysnIsDefault]
						,[ysnActive]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT @intListId
						,1
						,@strListItemName
						,@ysnIsDefault
						,@ysnActive
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
				END
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ' ' + ERROR_MESSAGE()

			UPDATE tblQMListImport
			SET strErrorMsg = @ErrMsg
			WHERE intListImportId = @intRowId
		END CATCH

		UPDATE tblQMListImport
		SET ysnProcessed = 1
		WHERE intListImportId = @intRowId

		SELECT @intRowId = MIN(intListImportId)
		FROM tblQMListImport
		WHERE intListImportId > @intRowId
			AND ISNULL(ysnProcessed, 0) = 0
	END

	SELECT 'Error'
		,*
	FROM tblQMListImport
	WHERE ISNULL(ysnProcessed, 0) = 1
		AND ISNULL(strErrorMsg, '') <> ''
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
