CREATE PROCEDURE uspQMImportAttribute @intUserId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	DECLARE @intRowId INT
		,@strAttributeName NVARCHAR(50)
		,@strDescription NVARCHAR(100)
		,@strDataTypeName NVARCHAR(30)
		,@strListName NVARCHAR(50)
		,@strAttributeValue NVARCHAR(50)
		,@intListId INT
		,@intDataTypeId INT

	IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE LOWER(strUserName) = 'irelyadmin'
	END

	SELECT @intRowId = MIN(intImportId)
	FROM tblQMAttributeImport
	WHERE ISNULL(ysnProcessed, 0) = 0

	WHILE (ISNULL(@intRowId, 0) > 0)
	BEGIN
		BEGIN TRY
			SELECT @strAttributeName = ''
				,@strDescription = ''
				,@strDataTypeName = ''
				,@strListName = ''
				,@strAttributeValue = ''
				,@intListId = NULL
				,@intDataTypeId = NULL

			SELECT @strAttributeName = strAttributeName
				,@strDescription = strDescription
				,@strDataTypeName = strDataTypeName
				,@strListName = strListName
				,@strAttributeValue = strAttributeValue
			FROM tblQMAttributeImport
			WHERE intImportId = @intRowId

			IF ISNULL(@strAttributeName, '') = ''
			BEGIN
				RAISERROR (
						'Attribute Name cannot be empty. '
						,16
						,1
						)
			END

			IF ISNULL(@strDataTypeName, '') = ''
			BEGIN
				RAISERROR (
						'Data Type cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intDataTypeId = intDataTypeId
				FROM tblQMAttributeDataType
				WHERE LOWER(strDataTypeName) = LOWER(@strDataTypeName)

				IF ISNULL(@intDataTypeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Data Type. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strListName, '') <> ''
			BEGIN
				SELECT @intListId = intListId
				FROM tblQMList
				WHERE LOWER(strListName) = LOWER(@strListName)

				IF ISNULL(@intListId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid List Name. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strAttributeValue, '') <> ''
			BEGIN
				IF @intDataTypeId = 1 -- Integer
				BEGIN
					IF (@strAttributeValue LIKE '%[^0-9]%')
					BEGIN
						RAISERROR (
								'Default Value should be Whole Number. '
								,16
								,1
								)
					END
				END
				ELSE IF @intDataTypeId = 2 -- Float
				BEGIN
					IF ISNUMERIC(@strAttributeValue) <> 1
					BEGIN
						RAISERROR (
								'Default Value should be Whole Number / Decimal Number. '
								,16
								,1
								)
					END
				END
				ELSE IF @intDataTypeId = 3 -- DateTime
				BEGIN
					IF ISDATE(@strAttributeValue) = 0
					BEGIN
						RAISERROR (
								'Default Value should be a Date. '
								,16
								,1
								)
					END
				END
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblQMAttribute
					WHERE strAttributeName = @strAttributeName
					)
			BEGIN
				INSERT INTO tblQMAttribute (
					[intConcurrencyId]
					,[strAttributeName]
					,[strDescription]
					,[intDataTypeId]
					,[intListId]
					,[strAttributeValue]
					,[intListItemId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@strAttributeName
					,@strDescription
					,@intDataTypeId
					,@intListId
					,@strAttributeValue
					,NULL
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ' ' + ERROR_MESSAGE()

			UPDATE tblQMAttributeImport
			SET strErrorMsg = @ErrMsg
			WHERE intImportId = @intRowId
		END CATCH

		UPDATE tblQMAttributeImport
		SET ysnProcessed = 1
		WHERE intImportId = @intRowId

		SELECT @intRowId = MIN(intImportId)
		FROM tblQMAttributeImport
		WHERE intImportId > @intRowId
			AND ISNULL(ysnProcessed, 0) = 0
	END

	SELECT 'Error'
		,*
	FROM tblQMAttributeImport
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
