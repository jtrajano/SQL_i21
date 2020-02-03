﻿CREATE PROCEDURE uspIPAttributeProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intAttributeStageId INT
		,@intAttributeId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strListName NVARCHAR(50)
		,@strCreatedUserName NVARCHAR(100)
		,@strAttributeName NVARCHAR(50)
	DECLARE @intListId INT
		,@intCreatedUserId INT
		,@intLastModifiedUserId INT
		,@intNewAttributeId INT
		,@intAttributeRefId INT

	SELECT @intAttributeStageId = MIN(intAttributeStageId)
	FROM tblQMAttributeStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intAttributeStageId > 0
	BEGIN
		SELECT @intAttributeId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL

		SELECT @intAttributeId = intAttributeId
			,@strHeaderXML = strHeaderXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblQMAttributeStage
		WHERE intAttributeStageId = @intAttributeStageId

		BEGIN TRY
			SELECT @intAttributeRefId = @intAttributeId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strListName = NULL
				,@strCreatedUserName = NULL
				,@strAttributeName = NULL

			SELECT @strListName = strListName
				,@strCreatedUserName = strCreatedUserName
				,@strAttributeName = strAttributeName
			FROM OPENXML(@idoc, 'vyuIPGetAttributes/vyuIPGetAttribute', 2) WITH (
					strListName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCreatedUserName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strAttributeName NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			IF @strListName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMList t
					WHERE t.strListName = @strListName
					)
			BEGIN
				SELECT @strErrorMessage = 'List Name ' + @strListName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strCreatedUserName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity t
					WHERE t.strName = @strCreatedUserName
					)
			BEGIN
				SELECT @strErrorMessage = 'Created User ' + @strCreatedUserName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intListId = NULL
				,@intCreatedUserId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intListId = t.intListId
			FROM tblQMList t
			WHERE t.strListName = @strListName

			SELECT @intCreatedUserId = t.intEntityId
			FROM tblEMEntity t
			WHERE t.strName = @strCreatedUserName
				AND t.strEntityNo <> ''

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblQMAttribute
						WHERE intAttributeRefId = @intAttributeRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewAttributeId = @intAttributeRefId
					,@strAttributeName = ''

				DELETE
				FROM tblQMAttribute
				WHERE intAttributeRefId = @intAttributeRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblQMAttribute (
					intConcurrencyId
					,strAttributeName
					,strDescription
					,intDataTypeId
					,intListId
					,strAttributeValue
					,intListItemId
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intAttributeRefId
					)
				SELECT 1
					,strAttributeName
					,strDescription
					,intDataTypeId
					,@intListId
					,strAttributeValue
					,intListItemId
					,@intCreatedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,dtmLastModified
					,@intAttributeRefId
				FROM OPENXML(@idoc, 'vyuIPGetAttributes/vyuIPGetAttribute', 2) WITH (
						strAttributeName NVARCHAR(50)
						,strDescription NVARCHAR(100)
						,intDataTypeId INT
						,strAttributeValue NVARCHAR(50)
						,intListItemId INT
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						)

				SELECT @intNewAttributeId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMAttribute
				SET intConcurrencyId = intConcurrencyId + 1
					,strAttributeName = x.strAttributeName
					,strDescription = x.strDescription
					,intDataTypeId = x.intDataTypeId
					,intListId = @intListId
					,strAttributeValue = x.strAttributeValue
					,intListItemId = x.intListItemId
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = x.dtmLastModified
				FROM OPENXML(@idoc, 'vyuIPGetAttributes/vyuIPGetAttribute', 2) WITH (
						strAttributeName NVARCHAR(50)
						,strDescription NVARCHAR(100)
						,intDataTypeId INT
						,strAttributeValue NVARCHAR(50)
						,intListItemId INT
						,dtmLastModified DATETIME
						) x
				WHERE tblQMAttribute.intAttributeRefId = @intAttributeRefId

				SELECT @intNewAttributeId = intAttributeId
					,@strAttributeName = strAttributeName
				FROM tblQMAttribute
				WHERE intAttributeRefId = @intAttributeRefId
			END

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMAttributeStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intAttributeStageId = @intAttributeStageId

			-- Audit Log
			IF (@intNewAttributeId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewAttributeId
						,@screenName = 'Quality.view.Attribute'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strAttributeName
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewAttributeId
						,@screenName = 'Quality.view.Attribute'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strAttributeName
				END
			END

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblQMAttributeStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intAttributeStageId = @intAttributeStageId
		END CATCH

		SELECT @intAttributeStageId = MIN(intAttributeStageId)
		FROM tblQMAttributeStage
		WHERE intAttributeStageId > @intAttributeStageId
			AND ISNULL(strFeedStatus, '') = ''
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
