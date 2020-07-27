CREATE PROCEDURE uspIPTestProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intTestStageId INT
		,@intTestId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strTestName NVARCHAR(50)
	DECLARE @intLastModifiedUserId INT
		,@intNewTestId INT
		,@intTestRefId INT
	DECLARE @strTestPropertyXML NVARCHAR(MAX)
		,@intTestPropertyId INT
	DECLARE @strPropertyName NVARCHAR(100)
		,@intPropertyId INT
	DECLARE @tblQMTestStage TABLE (intTestStageId INT)

	INSERT INTO @tblQMTestStage (intTestStageId)
	SELECT intTestStageId
	FROM tblQMTestStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intTestStageId = MIN(intTestStageId)
	FROM @tblQMTestStage

	IF @intTestStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMTestStage t
	JOIN @tblQMTestStage pt ON pt.intTestStageId = t.intTestStageId

	WHILE @intTestStageId > 0
	BEGIN
		SELECT @intTestId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strTestPropertyXML = NULL

		SELECT @intTestId = intTestId
			,@strHeaderXML = strHeaderXML
			,@strTestPropertyXML = strTestPropertyXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblQMTestStage
		WHERE intTestStageId = @intTestStageId

		BEGIN TRY
			SELECT @intTestRefId = @intTestId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strTestName = NULL

			SELECT @strTestName = strTestName
			FROM OPENXML(@idoc, 'tblQMTests/tblQMTest', 2) WITH (strTestName NVARCHAR(50)) x

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
						FROM tblQMTest
						WHERE intTestRefId = @intTestRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewTestId = @intTestRefId
					,@strTestName = @strTestName

				DELETE
				FROM tblQMTest
				WHERE intTestRefId = @intTestRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblQMTest (
					intAnalysisTypeId
					,intConcurrencyId
					,strTestName
					,strDescription
					,strTestMethod
					,strIndustryStandards
					,intReplications
					,strSensComments
					,ysnAutoCapture
					,ysnIgnoreSubSample
					,ysnActive
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intTestRefId
					)
				SELECT intAnalysisTypeId
					,1
					,strTestName
					,strDescription
					,strTestMethod
					,strIndustryStandards
					,intReplications
					,strSensComments
					,ysnAutoCapture
					,ysnIgnoreSubSample
					,ysnActive
					,@intLastModifiedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,dtmLastModified
					,@intTestRefId
				FROM OPENXML(@idoc, 'tblQMTests/tblQMTest', 2) WITH (
						intAnalysisTypeId INT
						,strTestName NVARCHAR(50)
						,strDescription NVARCHAR(100)
						,strTestMethod NVARCHAR(50)
						,strIndustryStandards NVARCHAR(50)
						,intReplications INT
						,strSensComments NVARCHAR(100)
						,ysnAutoCapture BIT
						,ysnIgnoreSubSample BIT
						,ysnActive BIT
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						)

				SELECT @intNewTestId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMTest
				SET intConcurrencyId = intConcurrencyId + 1
					,intAnalysisTypeId = x.intAnalysisTypeId
					,strTestName = x.strTestName
					,strDescription = x.strDescription
					,strTestMethod = x.strTestMethod
					,strIndustryStandards = x.strIndustryStandards
					,intReplications = x.intReplications
					,strSensComments = x.strSensComments
					,ysnAutoCapture = x.ysnAutoCapture
					,ysnIgnoreSubSample = x.ysnIgnoreSubSample
					,ysnActive = x.ysnActive
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = x.dtmLastModified
				FROM OPENXML(@idoc, 'tblQMTests/tblQMTest', 2) WITH (
						intAnalysisTypeId INT
						,strTestName NVARCHAR(50)
						,strDescription NVARCHAR(100)
						,strTestMethod NVARCHAR(50)
						,strIndustryStandards NVARCHAR(50)
						,intReplications INT
						,strSensComments NVARCHAR(100)
						,ysnAutoCapture BIT
						,ysnIgnoreSubSample BIT
						,ysnActive BIT
						,dtmLastModified DATETIME
						) x
				WHERE tblQMTest.intTestRefId = @intTestRefId

				SELECT @intNewTestId = intTestId
				FROM tblQMTest
				WHERE intTestRefId = @intTestRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Test Property--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strTestPropertyXML

			DECLARE @tblQMTestProperty TABLE (intTestPropertyId INT)

			INSERT INTO @tblQMTestProperty (intTestPropertyId)
			SELECT intTestPropertyId
			FROM OPENXML(@idoc, 'vyuIPGetTestPropertys/vyuIPGetTestProperty', 2) WITH (intTestPropertyId INT)

			SELECT @intTestPropertyId = MIN(intTestPropertyId)
			FROM @tblQMTestProperty

			WHILE @intTestPropertyId IS NOT NULL
			BEGIN
				SELECT @strPropertyName = NULL
					,@intPropertyId = NULL

				SELECT @strPropertyName = strPropertyName
				FROM OPENXML(@idoc, 'vyuIPGetTestPropertys/vyuIPGetTestProperty', 2) WITH (
						strPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intTestPropertyId INT
						) SD
				WHERE intTestPropertyId = @intTestPropertyId

				IF @strPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t
						WHERE t.strPropertyName = @strPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Property ' + @strPropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intPropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @strPropertyName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMTestProperty
						WHERE intTestId = @intNewTestId
							AND intTestPropertyRefId = @intTestPropertyId
						)
				BEGIN
					INSERT INTO tblQMTestProperty (
						intTestId
						,intPropertyId
						,intConcurrencyId
						,intFormulaID
						,intSequenceNo
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intTestPropertyRefId
						)
					SELECT @intNewTestId
						,@intPropertyId
						,1
						,intFormulaID
						,intSequenceNo
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intTestPropertyId
					FROM OPENXML(@idoc, 'vyuIPGetTestPropertys/vyuIPGetTestProperty', 2) WITH (
							intFormulaID INT
							,intSequenceNo INT
							,dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intTestPropertyId INT
							) x
					WHERE x.intTestPropertyId = @intTestPropertyId
				END
				ELSE
				BEGIN
					UPDATE tblQMTestProperty
					SET intConcurrencyId = intConcurrencyId + 1
						,intPropertyId = @intPropertyId
						,intFormulaID = x.intFormulaID
						,intSequenceNo = x.intSequenceNo
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetTestPropertys/vyuIPGetTestProperty', 2) WITH (
							intFormulaID INT
							,intSequenceNo INT
							,dtmLastModified DATETIME
							,intTestPropertyId INT
							) x
					JOIN tblQMTestProperty D ON D.intTestPropertyRefId = x.intTestPropertyId
						AND D.intTestId = @intNewTestId
					WHERE x.intTestPropertyId = @intTestPropertyId
				END

				SELECT @intTestPropertyId = MIN(intTestPropertyId)
				FROM @tblQMTestProperty
				WHERE intTestPropertyId > @intTestPropertyId
			END

			DELETE
			FROM tblQMTestProperty
			WHERE intTestId = @intNewTestId
				AND intTestPropertyRefId NOT IN (
					SELECT intTestPropertyId
					FROM @tblQMTestProperty
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMTestStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intTestStageId = @intTestStageId

			-- Audit Log
			IF (@intNewTestId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewTestId
						,@screenName = 'Quality.view.Test'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strTestName
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewTestId
						,@screenName = 'Quality.view.Test'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strTestName
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

			UPDATE tblQMTestStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intTestStageId = @intTestStageId
		END CATCH

		SELECT @intTestStageId = MIN(intTestStageId)
		FROM @tblQMTestStage
		WHERE intTestStageId > @intTestStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMTestStage t
	JOIN @tblQMTestStage pt ON pt.intTestStageId = t.intTestStageId
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
