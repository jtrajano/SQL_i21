CREATE PROCEDURE uspIPListProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intListStageId INT
		,@intListId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strListName NVARCHAR(50)
	DECLARE @intLastModifiedUserId INT
		,@intNewListId INT
		,@intListRefId INT
	DECLARE @strListItemXML NVARCHAR(MAX)
		,@intListItemId INT
	DECLARE @tblQMListStage TABLE (intListStageId INT)

	INSERT INTO @tblQMListStage (intListStageId)
	SELECT intListStageId
	FROM tblQMListStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intListStageId = MIN(intListStageId)
	FROM @tblQMListStage

	IF @intListStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMListStage t
	JOIN @tblQMListStage pt ON pt.intListStageId = t.intListStageId

	WHILE @intListStageId > 0
	BEGIN
		SELECT @intListId = NULL
			,@strHeaderXML = NULL
			,@strListItemXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL

		SELECT @intListId = intListId
			,@strHeaderXML = strHeaderXML
			,@strListItemXML = strListItemXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblQMListStage
		WHERE intListStageId = @intListStageId

		BEGIN TRY
			SELECT @intListRefId = @intListId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strListName = NULL

			SELECT @strListName = strListName
			FROM OPENXML(@idoc, 'tblQMLists/tblQMList', 2) WITH (strListName NVARCHAR(50) Collate Latin1_General_CI_AS) x

			SELECT @intLastModifiedUserId = NULL

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
						FROM tblQMList
						WHERE intListRefId = @intListRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewListId = @intListRefId
					,@strListName = ''

				DELETE
				FROM tblQMList
				WHERE intListRefId = @intListRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblQMList (
					intConcurrencyId
					,strListName
					,strSQL
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intListRefId
					)
				SELECT 1
					,strListName
					,strSQL
					,@intLastModifiedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,dtmLastModified
					,@intListRefId
				FROM OPENXML(@idoc, 'tblQMLists/tblQMList', 2) WITH (
						strListName NVARCHAR(50)
						,strSQL NVARCHAR(MAX)
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						)

				SELECT @intNewListId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMList
				SET intConcurrencyId = intConcurrencyId + 1
					,strListName = x.strListName
					,strSQL = x.strSQL
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = x.dtmLastModified
				FROM OPENXML(@idoc, 'tblQMLists/tblQMList', 2) WITH (
						strListName NVARCHAR(50)
						,strSQL NVARCHAR(MAX)
						,dtmLastModified DATETIME
						) x
				WHERE tblQMList.intListRefId = @intListRefId

				SELECT @intNewListId = intListId
					,@strListName = strListName
				FROM tblQMList
				WHERE intListRefId = @intListRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------List Item--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strListItemXML

			DECLARE @tblQMListItem TABLE (intListItemId INT)

			INSERT INTO @tblQMListItem (intListItemId)
			SELECT intListItemId
			FROM OPENXML(@idoc, 'tblQMListItems/tblQMListItem', 2) WITH (intListItemId INT)

			SELECT @intListItemId = MIN(intListItemId)
			FROM @tblQMListItem

			WHILE @intListItemId IS NOT NULL
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblQMListItem
						WHERE intListId = @intNewListId
							AND intListItemRefId = @intListItemId
						)
				BEGIN
					INSERT INTO tblQMListItem (
						intConcurrencyId
						,intListId
						,strListItemName
						,ysnIsDefault
						,ysnActive
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intListItemRefId
						)
					SELECT 1
						,@intNewListId
						,strListItemName
						,ysnIsDefault
						,ysnActive
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intListItemId
					FROM OPENXML(@idoc, 'tblQMListItems/tblQMListItem', 2) WITH (
							strListItemName NVARCHAR(50)
							,ysnIsDefault BIT
							,ysnActive BIT
							,dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intListItemId INT
							) x
					WHERE x.intListItemId = @intListItemId
				END
				ELSE
				BEGIN
					UPDATE tblQMListItem
					SET intConcurrencyId = intConcurrencyId + 1
						,strListItemName = x.strListItemName
						,ysnIsDefault = x.ysnIsDefault
						,ysnActive = x.ysnActive
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'tblQMListItems/tblQMListItem', 2) WITH (
							strListItemName NVARCHAR(50)
							,ysnIsDefault BIT
							,ysnActive BIT
							,dtmLastModified DATETIME
							,intListItemId INT
							) x
					JOIN tblQMListItem D ON D.intListItemRefId = x.intListItemId
						AND D.intListId = @intNewListId
					WHERE x.intListItemId = @intListItemId
				END

				SELECT @intListItemId = MIN(intListItemId)
				FROM @tblQMListItem
				WHERE intListItemId > @intListItemId
			END

			DELETE
			FROM tblQMListItem
			WHERE intListId = @intNewListId
				AND intListItemRefId NOT IN (
					SELECT intListItemId
					FROM @tblQMListItem
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMListStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intListStageId = @intListStageId

			-- Audit Log
			IF (@intNewListId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewListId
						,@screenName = 'Quality.view.List'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strListName
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewListId
						,@screenName = 'Quality.view.List'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strListName
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

			UPDATE tblQMListStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intListStageId = @intListStageId
		END CATCH

		SELECT @intListStageId = MIN(intListStageId)
		FROM @tblQMListStage
		WHERE intListStageId > @intListStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMListStage t
	JOIN @tblQMListStage pt ON pt.intListStageId = t.intListStageId
		AND t.strFeedStatus = 'In-Progress'
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
