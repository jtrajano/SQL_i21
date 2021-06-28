CREATE PROCEDURE uspQMProcessERPTestResult @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinRowNo INT
		,@ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
	DECLARE @strSampleNumber NVARCHAR(30)
		,@strSampleStatus NVARCHAR(30)
		,@dblCuppingScore NUMERIC(18, 6)
		,@dblGradingScore NUMERIC(18, 6)
		,@strComments NVARCHAR(MAX)
		,@dtmCuppingDate DATETIME
		,@strCuppedBy NVARCHAR(50)
		,@dtmUpdated DATETIME
		,@strUpdatedBy NVARCHAR(50)
	DECLARE @intSampleId INT
		,@intSampleStatusId INT
		,@intCuppedUserId INT
		,@intUpdatedUserId INT
		,@intPreviousSampleStatusId INT
		,@strCuppingPropertyName NVARCHAR(100)
		,@strGradingPropertyName NVARCHAR(100)
		,@intCuppingPropertyId INT
		,@intGradingPropertyId INT
		,@strXml NVARCHAR(MAX)
	DECLARE @tblIPTestResultStage TABLE (intTestResultStageId INT)

	IF NOT EXISTS (
			SELECT 1
			FROM tblIPTestResultStage
			)
	BEGIN
		RETURN
	END

	DELETE
	FROM @tblIPTestResultStage

	INSERT INTO @tblIPTestResultStage
	SELECT TOP 50 intTestResultStageId
	FROM tblIPTestResultStage WITH (NOLOCK)
	WHERE strImportStatus IS NULL

	UPDATE t
	SET t.strImportStatus = 'In-Progress'
	FROM tblIPTestResultStage t
	JOIN @tblIPTestResultStage pt ON pt.intTestResultStageId = t.intTestResultStageId

	SELECT @intMinRowNo = Min(intTestResultStageId)
	FROM @tblIPTestResultStage

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strSampleNumber = NULL
				,@strSampleStatus = NULL
				,@dblCuppingScore = NULL
				,@dblGradingScore = NULL
				,@strComments = NULL
				,@dtmCuppingDate = NULL
				,@strCuppedBy = NULL
				,@dtmUpdated = NULL
				,@strUpdatedBy = NULL

			SELECT @intSampleId = NULL
				,@intSampleStatusId = NULL
				,@intCuppedUserId = NULL
				,@intUpdatedUserId = NULL
				,@intPreviousSampleStatusId = NULL
				,@strCuppingPropertyName = NULL
				,@strGradingPropertyName = NULL
				,@intCuppingPropertyId = NULL
				,@intGradingPropertyId = NULL
				,@strXml = NULL

			SELECT @strSampleNumber = strSampleNumber
				,@strSampleStatus = ISNULL(strSampleStatus, '')
				,@dblCuppingScore = ISNULL(dblCuppingScore, 0)
				,@dblGradingScore = ISNULL(dblGradingScore, 0)
				,@strComments = strComments
				,@dtmCuppingDate = dtmCuppingDate
				,@strCuppedBy = strCuppedBy
				,@dtmUpdated = dtmUpdated
				,@strUpdatedBy = strUpdatedBy
			FROM tblIPTestResultStage WITH (NOLOCK)
			WHERE intTestResultStageId = @intMinRowNo

			SELECT @intSampleId = t.intSampleId
				,@intPreviousSampleStatusId = t.intSampleStatusId
			FROM tblQMSample t WITH (NOLOCK)
			WHERE t.strSampleNumber = @strSampleNumber

			IF ISNULL(@intSampleId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Sample Number. '
						,16
						,1
						)
			END

			IF @strSampleStatus = 'Passed'
				SELECT @strSampleStatus = 'Approved'
			ELSE IF @strSampleStatus = 'Failed'
				SELECT @strSampleStatus = 'Rejected'

			SELECT @intSampleStatusId = t.intSampleStatusId
			FROM tblQMSampleStatus t WITH (NOLOCK)
			WHERE t.strStatus = @strSampleStatus

			IF ISNULL(@intSampleStatusId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Sample Status. '
						,16
						,1
						)
			END

			IF ISNULL(@strComments, '') <> ''
			BEGIN
				SELECT @strComments = REPLACE(@strComments, CHAR(13) + CHAR(10), '.')
			END

			IF @dtmCuppingDate IS NULL
				SELECT @dtmCuppingDate = GETDATE()

			IF @dtmUpdated IS NULL
				SELECT @dtmUpdated = GETDATE()

			IF ISNULL(@strCuppedBy, '') <> ''
			BEGIN
				SELECT @intCuppedUserId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'User'
					AND t.strName = @strCuppedBy
					AND t.strEntityNo <> ''
			END

			IF ISNULL(@strUpdatedBy, '') <> ''
			BEGIN
				SELECT @intUpdatedUserId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'User'
					AND t.strName = @strUpdatedBy
					AND t.strEntityNo <> ''
			END

			SET @strInfo1 = ISNULL(@strSampleNumber, '')
			SET @strInfo2 = ISNULL(@strSampleStatus, '')

			SELECT @intUserId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			SELECT @strCuppingPropertyName = strCuppingPropertyName
				,@strGradingPropertyName = strGradingPropertyName
			FROM tblIPERPDetail WITH (NOLOCK)

			SELECT @intCuppingPropertyId = intPropertyId
			FROM tblQMProperty WITH (NOLOCK)
			WHERE strPropertyName = @strCuppingPropertyName

			SELECT @intGradingPropertyId = intPropertyId
			FROM tblQMProperty WITH (NOLOCK)
			WHERE strPropertyName = @strGradingPropertyName

			IF @intCuppingPropertyId IS NULL
				OR @intGradingPropertyId IS NULL
			BEGIN
				RAISERROR (
						'Invalid Cupping / Grading Property setup. '
						,16
						,1
						)
			END

			BEGIN TRAN

			IF @intPreviousSampleStatusId <> @intSampleStatusId
			BEGIN
				UPDATE tblQMSample
				SET intPreviousSampleStatusId = @intPreviousSampleStatusId
				WHERE intSampleId = @intSampleId
			END

			UPDATE tblQMSample
			SET intConcurrencyId = intConcurrencyId + 1
				,intSampleStatusId = @intSampleStatusId
				,strComment = @strComments
				,dtmTestedOn = @dtmCuppingDate
				,intTestedById = ISNULL(@intCuppedUserId, intTestedById)
				,dtmLastModified = @dtmUpdated
				,intLastModifiedUserId = ISNULL(@intUpdatedUserId, intLastModifiedUserId)
			WHERE intSampleId = @intSampleId

			UPDATE tblQMTestResult
			SET strPropertyValue = CONVERT(NUMERIC(18, 1), @dblCuppingScore)
			FROM tblQMTestResult TR
			WHERE TR.intSampleId = @intSampleId
				AND TR.intPropertyId = @intCuppingPropertyId

			UPDATE tblQMTestResult
			SET strPropertyValue = CONVERT(NUMERIC(18, 1), @dblGradingScore)
			FROM tblQMTestResult TR
			WHERE TR.intSampleId = @intSampleId
				AND TR.intPropertyId = @intGradingPropertyId

			-- Setting result for properties
			UPDATE tblQMTestResult
			SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
			FROM tblQMTestResult TR
			WHERE TR.intSampleId = @intSampleId
				AND (
					TR.intPropertyId = @intCuppingPropertyId
					OR TR.intPropertyId = @intGradingPropertyId
					)

			-- Construct Approve / reject XML
			SELECT @strXml = ''

			IF ISNULL(@strXml, '') <> ''
			BEGIN
				IF @strSampleStatus = 'Approved'
				BEGIN
					EXEC uspQMSampleApprove @strXml
				END
				ELSE IF @strSampleStatus = 'Rejected'
				BEGIN
					EXEC uspQMSampleReject @strXml
				END
			END

			-- Audit Log
			INSERT INTO tblIPTestResultArchive (
				strSampleNumber
				,strSampleStatus
				,dblCuppingScore
				,dblGradingScore
				,strComments
				,dtmCuppingDate
				,strCuppedBy
				,dtmUpdated
				,strUpdatedBy
				,intRecordStatus
				,strErrorMessage
				,strImportStatus
				)
			SELECT strSampleNumber
				,strSampleStatus
				,dblCuppingScore
				,dblGradingScore
				,strComments
				,dtmCuppingDate
				,strCuppedBy
				,dtmUpdated
				,strUpdatedBy
				,intRecordStatus
				,''
				,'Success'
			FROM tblIPTestResultStage
			WHERE intTestResultStageId = @intMinRowNo

			DELETE
			FROM tblIPTestResultStage
			WHERE intTestResultStageId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPTestResultError (
				strSampleNumber
				,strSampleStatus
				,dblCuppingScore
				,dblGradingScore
				,strComments
				,dtmCuppingDate
				,strCuppedBy
				,dtmUpdated
				,strUpdatedBy
				,intRecordStatus
				,strErrorMessage
				,strImportStatus
				)
			SELECT strSampleNumber
				,strSampleStatus
				,dblCuppingScore
				,dblGradingScore
				,strComments
				,dtmCuppingDate
				,strCuppedBy
				,dtmUpdated
				,strUpdatedBy
				,intRecordStatus
				,@ErrMsg
				,'Failed'
			FROM tblIPTestResultStage
			WHERE intTestResultStageId = @intMinRowNo

			DELETE
			FROM tblIPTestResultStage
			WHERE intTestResultStageId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intTestResultStageId)
		FROM @tblIPTestResultStage
		WHERE intTestResultStageId > @intMinRowNo
	END

	UPDATE t
	SET t.strImportStatus = NULL
	FROM tblIPTestResultStage t
	JOIN @tblIPTestResultStage pt ON pt.intTestResultStageId = t.intTestResultStageId
		AND t.strImportStatus = 'In-Progress'

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
