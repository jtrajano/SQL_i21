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
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intLotStatusId INT
		,@dtmTestedOn DATETIME
		,@intTestedById INT
		,@dtmLastModified DATETIME
		,@intLastModifiedUserId INT
		,@intSampleTypeId INT
		,@intProductId INT
		,@intTemplateLotStatusId INT
	DECLARE @strOldComment NVARCHAR(MAX)
		,@strOldSampleStatus NVARCHAR(30)
		,@dtmOldTestedOn DATETIME
		,@strOldTestedUserName NVARCHAR(50)
		,@dtmOldLastModified DATETIME
		,@strOldModifiedUserName NVARCHAR(50)
		,@strTestedUserName NVARCHAR(50)
		,@strModifiedUserName NVARCHAR(50)
	DECLARE @tblQMTestResultChanges TABLE (
		strOldPropertyValue NVARCHAR(MAX)
		,strOldResult NVARCHAR(20)
		,strNewPropertyValue NVARCHAR(MAX)
		,strNewResult NVARCHAR(20)
		,intTestResultId INT
		,strPropertyName NVARCHAR(100)
		)
	DECLARE @strOldPropertyValue NVARCHAR(MAX)
		,@strOldResult NVARCHAR(20)
		,@strNewPropertyValue NVARCHAR(MAX)
		,@strNewResult NVARCHAR(20)
		,@intTestResultId INT
		,@strPropertyName NVARCHAR(100)
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
				,@intProductTypeId = NULL
				,@intProductValueId = NULL
				,@intLotStatusId = NULL
				,@dtmTestedOn = NULL
				,@intTestedById = NULL
				,@dtmLastModified = NULL
				,@intLastModifiedUserId = NULL
				,@intSampleTypeId = NULL
				,@intProductId = NULL
				,@intTemplateLotStatusId = NULL

			SELECT @strOldComment = NULL
				,@strOldSampleStatus = NULL
				,@dtmOldTestedOn = NULL
				,@strOldTestedUserName = NULL
				,@dtmOldLastModified = NULL
				,@strOldModifiedUserName = NULL
				,@strTestedUserName = NULL
				,@strModifiedUserName = NULL

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
				,@intSampleTypeId = t.intSampleTypeId
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

			SELECT TOP 1 @intProductId = TR.intProductId
			FROM tblQMTestResult TR WITH (NOLOCK)
			WHERE TR.intSampleId = @intSampleId

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
					--AND t.strEntityNo <> ''
			END

			IF ISNULL(@intCuppedUserId, 0) = 0
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intCuppedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intCuppedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
			END

			IF ISNULL(@strUpdatedBy, '') <> ''
			BEGIN
				SELECT @intUpdatedUserId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'User'
					AND t.strName = @strUpdatedBy
					--AND t.strEntityNo <> ''
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

			SELECT @strOldComment = S.strComment
				,@strOldSampleStatus = SS.strStatus
				,@dtmOldTestedOn = S.dtmTestedOn
				,@strOldTestedUserName = ISNULL(TE.strName, '')
				,@dtmOldLastModified = S.dtmLastModified
				,@strOldModifiedUserName = UE.strName
			FROM tblQMSample S WITH (NOLOCK)
			JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
			LEFT JOIN tblEMEntity TE ON TE.intEntityId = S.intTestedById
			LEFT JOIN tblEMEntity UE ON UE.intEntityId = S.intLastModifiedUserId
			WHERE S.intSampleId = @intSampleId

			DELETE
			FROM @tblQMTestResultChanges

			INSERT INTO @tblQMTestResultChanges (
				strOldPropertyValue
				,strOldResult
				,intTestResultId
				,strPropertyName
				)
			SELECT TR.strPropertyValue
				,TR.strResult
				,TR.intTestResultId
				,P.strPropertyName
			FROM tblQMTestResult TR WITH (NOLOCK)
			JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = TR.intPropertyId
				AND TR.intSampleId = @intSampleId
				AND (
					TR.intPropertyId = @intCuppingPropertyId
					OR TR.intPropertyId = @intGradingPropertyId
					)

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

			UPDATE @tblQMTestResultChanges
			SET strNewPropertyValue = TR.strPropertyValue
				,strNewResult = TR.strResult
			FROM @tblQMTestResultChanges OLD
			JOIN tblQMTestResult TR ON TR.intTestResultId = OLD.intTestResultId

			SELECT @intProductTypeId = intProductTypeId
				,@intProductValueId = intProductValueId
				,@intLotStatusId = intLotStatusId
				,@dtmTestedOn = dtmTestedOn
				,@intTestedById = intTestedById
				,@dtmLastModified = dtmLastModified
				,@intLastModifiedUserId = intLastModifiedUserId
				,@strTestedUserName = TE.strName
				,@strModifiedUserName = UE.strName
			FROM tblQMSample S
			LEFT JOIN tblEMEntity TE ON TE.intEntityId = S.intTestedById
			LEFT JOIN tblEMEntity UE ON UE.intEntityId = S.intLastModifiedUserId
			WHERE S.intSampleId = @intSampleId

			-- Construct Approve / reject XML
			IF @intPreviousSampleStatusId <> @intSampleStatusId
			BEGIN
				IF @intProductTypeId = 6
					OR @intProductTypeId = 11
				BEGIN
					SELECT TOP 1 @intTemplateLotStatusId = (
							CASE 
								WHEN @strSampleStatus = 'Approved'
									THEN ISNULL(P.intApprovalLotStatusId, ST.intApprovalLotStatusId)
								WHEN @strSampleStatus = 'Rejected'
									THEN ISNULL(P.intRejectionLotStatusId, ST.intRejectionLotStatusId)
								ELSE NULL
								END
							)
					FROM tblQMProduct P
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
						AND P.intProductId = @intProductId
						AND PC.intSampleTypeId = @intSampleTypeId
					LEFT JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId

					IF ISNULL(@intTemplateLotStatusId, 0) > 0
					BEGIN
						UPDATE tblQMSample
						SET intLotStatusId = @intTemplateLotStatusId
						WHERE intSampleId = @intSampleId

						SELECT @intLotStatusId = @intTemplateLotStatusId
					END
				END

				SELECT @strXml = '<root>'

				SELECT @strXml += '<intSampleId>' + LTRIM(@intSampleId) + '</intSampleId>'

				SELECT @strXml += '<intProductTypeId>' + LTRIM(@intProductTypeId) + '</intProductTypeId>'

				SELECT @strXml += '<intProductValueId>' + LTRIM(@intProductValueId) + '</intProductValueId>'

				IF @intLotStatusId IS NOT NULL
					SELECT @strXml += '<intLotStatusId>' + LTRIM(@intLotStatusId) + '</intLotStatusId>'

				SELECT @strXml += '<intTestedById>' + LTRIM(@intTestedById) + '</intTestedById>'

				SELECT @strXml += '<dtmTestedOn>' + CONVERT(VARCHAR(33), @dtmTestedOn, 126) + '</dtmTestedOn>'

				SELECT @strXml += '<intLastModifiedUserId>' + LTRIM(@intLastModifiedUserId) + '</intLastModifiedUserId>'

				SELECT @strXml += '<dtmLastModified>' + CONVERT(VARCHAR(33), @dtmLastModified, 126) + '</dtmLastModified>'

				SELECT @strXml += '</root>'

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
			END

			-- Audit Log
			IF (@intSampleId > 0)
			BEGIN
				DECLARE @strDetails NVARCHAR(MAX) = ''

				IF (@strOldSampleStatus <> @strSampleStatus)
					SET @strDetails += '{"change":"strSampleStatus","iconCls":"small-gear","from":"' + LTRIM(@strOldSampleStatus) + '","to":"' + LTRIM(@strSampleStatus) + '","leaf":true,"changeDescription":"Sample Status"},'

				IF (@strOldComment <> @strComments)
					SET @strDetails += '{"change":"strComment","iconCls":"small-gear","from":"' + LTRIM(@strOldComment) + '","to":"' + LTRIM(@strComments) + '","leaf":true,"changeDescription":"Comments"},'

				IF (@dtmOldTestedOn <> @dtmTestedOn)
					SET @strDetails += '{"change":"dtmTestedOn","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldTestedOn, '')) + '","to":"' + LTRIM(ISNULL(@dtmTestedOn, '')) + '","leaf":true,"changeDescription":"Tested On"},'

				IF (@strOldTestedUserName <> @strTestedUserName)
					SET @strDetails += '{"change":"strTestedUserName","iconCls":"small-gear","from":"' + LTRIM(@strOldTestedUserName) + '","to":"' + LTRIM(@strTestedUserName) + '","leaf":true,"changeDescription":"Tested By"},'

				IF (@dtmOldLastModified <> @dtmLastModified)
					SET @strDetails += '{"change":"dtmLastModified","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldLastModified, '')) + '","to":"' + LTRIM(ISNULL(@dtmLastModified, '')) + '","leaf":true,"changeDescription":"Last Modified On"},'

				IF (@strOldModifiedUserName <> @strModifiedUserName)
					SET @strDetails += '{"change":"strModifiedUserName","iconCls":"small-gear","from":"' + LTRIM(@strOldModifiedUserName) + '","to":"' + LTRIM(@strModifiedUserName) + '","leaf":true,"changeDescription":"Last Modified By"},'

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intSampleId
						,@screenName = 'Quality.view.QualitySample'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END

				-- Test Result Audit Log
				DECLARE @details NVARCHAR(MAX) = ''

				WHILE EXISTS (
						SELECT TOP 1 NULL
						FROM @tblQMTestResultChanges
						)
				BEGIN
					SELECT @strOldPropertyValue = NULL
						,@strOldResult = NULL
						,@strNewPropertyValue = NULL
						,@strNewResult = NULL
						,@intTestResultId = NULL
						,@strPropertyName = NULL

					SELECT TOP 1 @strOldPropertyValue = strOldPropertyValue
						,@strOldResult = strOldResult
						,@strNewPropertyValue = strNewPropertyValue
						,@strNewResult = strNewResult
						,@intTestResultId = intTestResultId
						,@strPropertyName = strPropertyName
					FROM @tblQMTestResultChanges

					SET @details = '{  
							"action":"Updated",
							"change":"Updated - Record: ' + LTRIM(@intSampleId) + '",
							"keyValue":' + LTRIM(@intSampleId) + ',
							"iconCls":"small-tree-modified",
							"children":[  
								{  
									"change":"tblQMTestResults",
									"children":[  
										{  
										"action":"Updated",
										"change":"Updated - Record: ' + LTRIM(@strPropertyName) + '",
										"keyValue":' + LTRIM(@intTestResultId) + ',
										"iconCls":"small-tree-modified",
										"children":
											[   
												'

					IF @strOldPropertyValue <> @strNewPropertyValue
						SET @details = @details + '
												{  
												"change":"strPropertyValue",
												"from":"' + LTRIM(@strOldPropertyValue) + '",
												"to":"' + LTRIM(@strNewPropertyValue) + '",
												"leaf":true,
												"iconCls":"small-gear",
												"isField":true,
												"keyValue":' + LTRIM(@intTestResultId) + ',
												"associationKey":"tblQMTestResults",
												"changeDescription":"Actual Value",
												"hidden":false
												},'

					IF @strOldResult <> @strNewResult
						SET @details = @details + '
												{  
												"change":"strResult",
												"from":"' + LTRIM(@strOldResult) + '",
												"to":"' + LTRIM(@strNewResult) + '",
												"leaf":true,
												"iconCls":"small-gear",
												"isField":true,
												"keyValue":' + LTRIM(@intTestResultId) + ',
												"associationKey":"tblQMTestResults",
												"changeDescription":"Result",
												"hidden":false
												},'

					IF RIGHT(@details, 1) = ','
						SET @details = SUBSTRING(@details, 0, LEN(@details))
					SET @details = @details + '
										]
									}
								],
								"iconCls":"small-tree-grid",
								"changeDescription":"Test Detail"
								}
							]
							}'

					IF @strOldPropertyValue <> @strNewPropertyValue
						OR @strOldResult <> @strNewResult
					BEGIN
						EXEC uspSMAuditLog @keyValue = @intSampleId
							,@screenName = 'Quality.view.QualitySample'
							,@entityId = @intUserId
							,@actionType = 'Updated'
							,@actionIcon = 'small-tree-modified'
							,@details = @details
					END

					DELETE
					FROM @tblQMTestResultChanges
					WHERE intTestResultId = @intTestResultId
				END
			END

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
