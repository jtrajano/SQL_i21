CREATE PROCEDURE uspIPProcessPBBSDetail_EK @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intActionId INT
	DECLARE @intPBBSStageId INT
		,@intPBBSID INT
		,@strBlendCode NVARCHAR(50)
		,@strMaterialCode NVARCHAR(50)
		,@dtmValidFrom DATETIME
		,@dtmValidTo DATETIME
		,@dblSieve1M NUMERIC(18, 6)
		,@dblSieve1T1 NUMERIC(18, 6)
		,@dblSieve1T2 NUMERIC(18, 6)
		,@strPDFFileName NVARCHAR(100)
		,@blbPDFContent VARBINARY(MAX)
		,@strFileContent NVARCHAR(MAX)
	DECLARE @intNewPBBSStageId INT
		,@intProductTypeId INT
		,@intProductValueId INT
		,@strSampleTypeName NVARCHAR(50)
		,@strControlPointName NVARCHAR(50)
		,@intSampleTypeId INT
		,@intControlPointId INT
		,@intProductId INT
		,@intTestId INT
		,@intApprovalLotStatusId INT
		,@intRejectionLotStatusId INT
		,@intSequenceNo INT
	DECLARE @intOrderNo INT
		,@stri21TestName NVARCHAR(100)
	DECLARE @Test TABLE (
		intOrderNo INT
		,stri21TestName NVARCHAR(100)
		)
	DECLARE @SingleAuditLogParam SingleAuditLogParam
	DECLARE @tblIPPBBSStage TABLE (intPBBSStageId INT)

	INSERT INTO @tblIPPBBSStage (intPBBSStageId)
	SELECT intPBBSStageId
	FROM tblIPPBBSStage
	WHERE intStatusId IS NULL

	SELECT @intPBBSStageId = MIN(intPBBSStageId)
	FROM @tblIPPBBSStage

	IF @intPBBSStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPPBBSStage S
	JOIN @tblIPPBBSStage TS ON TS.intPBBSStageId = S.intPBBSStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strBlendCode, '') + ', '
	FROM @tblIPPBBSStage a
	JOIN tblIPPBBSStage b ON a.intPBBSStageId = b.intPBBSStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(LTRIM(b.intPBBSID), '') + ', '
	FROM @tblIPPBBSStage a
	JOIN tblIPPBBSStage b ON a.intPBBSStageId = b.intPBBSStageId

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	DELETE
	FROM @Test

	INSERT INTO @Test (
		intOrderNo
		,stri21TestName
		)
	SELECT DISTINCT intSequenceNo
		,stri21TestName
	FROM tblIPSAPProperty
	ORDER BY intSequenceNo

	WHILE (@intPBBSStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intActionId = NULL

			SELECT @intPBBSID = NULL
				,@strBlendCode = NULL
				,@strMaterialCode = NULL
				,@dtmValidFrom = NULL
				,@dtmValidTo = NULL
				,@dblSieve1M = NULL
				,@dblSieve1T1 = NULL
				,@dblSieve1T2 = NULL
				,@strPDFFileName = NULL
				,@blbPDFContent = NULL
				,@strFileContent = NULL

			SELECT @intNewPBBSStageId = NULL
				,@intProductTypeId = NULL
				,@intProductValueId = NULL
				,@strSampleTypeName = NULL
				,@strControlPointName = NULL
				,@intSampleTypeId = NULL
				,@intControlPointId = NULL
				,@intProductId = NULL
				,@intTestId = NULL
				,@intApprovalLotStatusId = NULL
				,@intRejectionLotStatusId = NULL
				,@intSequenceNo = 0

			SELECT @intOrderNo = NULL

			SELECT @intPBBSID = intPBBSID
				,@strBlendCode = strBlendCode
				,@strMaterialCode = strMaterialCode
				,@dtmValidFrom = dtmValidFrom
				,@dtmValidTo = dtmValidTo
				,@dblSieve1M = ISNULL(dblSieve1M, 0)
				,@dblSieve1T1 = ISNULL(dblSieve1T1, 0)
				,@dblSieve1T2 = ISNULL(dblSieve1T2, 0)
				,@strPDFFileName = strPDFFileName
				,@blbPDFContent = blbPDFContent
				,@strFileContent = strFileContent
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			SELECT @intProductTypeId = 2
				,@strControlPointName = 'Production'
				,@strSampleTypeName = 'Production'

			SELECT @intApprovalLotStatusId = intLotStatusId
			FROM dbo.tblICLotStatus WITH (NOLOCK)
			WHERE strSecondaryStatus = 'Active'

			SELECT @intRejectionLotStatusId = intLotStatusId
			FROM dbo.tblICLotStatus WITH (NOLOCK)
			WHERE strSecondaryStatus = 'On Hold'

			SELECT @intSampleTypeId = intSampleTypeId
			FROM dbo.tblQMSampleType WITH (NOLOCK)
			WHERE strSampleTypeName = @strSampleTypeName

			IF @intSampleTypeId IS NULL
			BEGIN
				SELECT @strError = 'Sample Type not found. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intControlPointId = intControlPointId
			FROM dbo.tblQMControlPoint WITH (NOLOCK)
			WHERE strControlPointName = @strControlPointName

			IF @intControlPointId IS NULL
			BEGIN
				SELECT @strError = 'Control Point not found. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM @Test
					)
			BEGIN
				SELECT @strError = 'Test Mapping not found. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intProductValueId = I.intItemId
			FROM dbo.tblICItem I WITH (NOLOCK)
			JOIN dbo.tblICCategory C WITH (NOLOCK) ON C.intCategoryId = I.intCategoryId
				AND C.strCategoryCode = 'Blend'
			WHERE I.strItemNo = @strBlendCode

			IF @intProductValueId IS NULL
			BEGIN
				SELECT @strError = 'Blend Code not found. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intPBBSID IS NULL
			BEGIN
				SELECT @strError = 'Invalid PBBS Id. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @dtmValidFrom IS NULL
			BEGIN
				SELECT @strError = 'Valid From cannot be blank. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @dtmValidTo IS NULL
			BEGIN
				SELECT @strError = 'Valid To cannot be blank. '

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strPDFFileName, '') = ''
			BEGIN
				RAISERROR (
						'Invalid PDF File Name. '
						,16
						,1
						)
			END

			IF ISNULL(@strFileContent, '') = ''
			BEGIN
				RAISERROR (
						'Invalid PDF File Content. '
						,16
						,1
						)
			END

			SELECT TOP 1 @intProductId = P.intProductId
			FROM tblQMProduct P
			JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				AND P.ysnActive = 1
				AND PC.intControlPointId = @intControlPointId
				AND PC.intSampleTypeId = @intSampleTypeId
				AND P.intProductTypeId = @intProductTypeId
				AND P.intProductValueId = @intProductValueId
			ORDER BY P.intProductId DESC

			IF @intProductId IS NULL
				SELECT @intActionId = 1 --Create
			ELSE
				SELECT @intActionId = 2 --Update

			IF NOT EXISTS (
					SELECT 1
					FROM tblIPPBBSDetailStage
					WHERE intPBBSStageId = @intPBBSStageId
					)
			BEGIN
				SELECT @strError = 'Detail - Property is required.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			IF @intActionId = 1
			BEGIN
				INSERT INTO tblQMProduct (
					intConcurrencyId
					,intProductTypeId
					,intProductValueId
					,ysnActive
					,intApprovalLotStatusId
					,intRejectionLotStatusId
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					)
				SELECT 1
					,@intProductTypeId
					,@intProductValueId
					,1
					,@intApprovalLotStatusId
					,@intRejectionLotStatusId
					,@intUserId
					,@dtmDateCreated
					,@intUserId
					,@dtmDateCreated

				SELECT @intProductId = SCOPE_IDENTITY()

				INSERT INTO tblQMProductControlPoint (
					intConcurrencyId
					,intProductId
					,intControlPointId
					,intSampleTypeId
					)
				SELECT 1
					,@intProductId
					,@intControlPointId
					,@intSampleTypeId

				SELECT @intOrderNo = MIN(intOrderNo)
				FROM @Test

				WHILE @intOrderNo IS NOT NULL
				BEGIN
					SELECT @stri21TestName = NULL

					SELECT @stri21TestName = stri21TestName
					FROM @Test
					WHERE intOrderNo = @intOrderNo

					SELECT @intTestId = intTestId
					FROM tblQMTest
					WHERE strTestName = @stri21TestName

					IF ISNULL(@intTestId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Test Name. '
								,16
								,1
								)
					END

					INSERT INTO tblQMProductTest (
						intConcurrencyId
						,intProductId
						,intTestId
						)
					SELECT 1
						,@intProductId
						,@intTestId

					INSERT INTO tblQMProductProperty (
						intConcurrencyId
						,intProductId
						,intTestId
						,intPropertyId
						,intSequenceNo
						,intComputationTypeId
						,strIsMandatory
						,ysnPrintInLabel
						,ysnDocumentPrint
						,ysnPrintInCuppingForm
						)
					SELECT 1
						,@intProductId
						,@intTestId
						,TP.intPropertyId
						,TP.intSequenceNo
						,1
						,PR.strIsMandatory
						,0
						,1
						,1
					FROM tblQMTestProperty TP
					JOIN tblQMTest T ON T.intTestId = TP.intTestId
						AND TP.intTestId = @intTestId
					JOIN tblQMProperty PR ON PR.intPropertyId = TP.intPropertyId
					ORDER BY TP.intSequenceNo

					INSERT INTO tblQMProductPropertyValidityPeriod (
						intConcurrencyId
						,intProductPropertyId
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblPinpointValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,intUnitMeasureId
						,strFormula
						,strFormulaParser
						)
					SELECT 1
						,PP.intProductPropertyId
						,PV.dtmValidFrom
						,PV.dtmValidTo
						,PV.strPropertyRangeText
						,PV.dblMinValue
						,PV.dblPinpointValue
						,PV.dblMaxValue
						,PV.dblLowValue
						,PV.dblHighValue
						,PV.intUnitMeasureId
						,P.strFormula
						,P.strFormulaParser
					FROM tblQMPropertyValidityPeriod AS PV
					JOIN tblQMProductProperty AS PP ON PP.intPropertyId = PV.intPropertyId
					JOIN tblQMProperty AS P ON P.intPropertyId = PP.intPropertyId
						AND PV.intPropertyId = P.intPropertyId
						AND PP.intProductId = @intProductId
						AND PP.intTestId = @intTestId
					ORDER BY PP.intProductPropertyId

					UPDATE PPV
					SET intConcurrencyId = PPV.intConcurrencyId + 1
						,dblMinValue = PD.dblMinValue
						,dblMaxValue = PD.dblMaxValue
						,dblPinpointValue = PD.dblPinPoint
					FROM tblQMProductPropertyValidityPeriod PPV
					JOIN tblQMProductProperty PP ON PP.intProductPropertyId = PPV.intProductPropertyId
						AND PP.intProductId = @intProductId
						AND PP.intTestId = @intTestId
					JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
					JOIN tblIPSAPProperty SP ON SP.stri21PropertyName = P.strPropertyName
					JOIN tblIPPBBSDetailStage PD ON PD.intPBBSStageId = @intPBBSStageId
						AND PD.strSpecificationCode = SP.strSAPPropertyName

					SELECT @intOrderNo = MIN(intOrderNo)
					FROM @Test
					WHERE intOrderNo > @intOrderNo
				END

				UPDATE tblQMProductProperty
				SET @intSequenceNo = intSequenceNo = @intSequenceNo + 1
				WHERE intProductId = @intProductId

				IF @intProductId > 0
				BEGIN
					DELETE
					FROM @SingleAuditLogParam

					INSERT INTO @SingleAuditLogParam (
						[Id]
						,[Action]
						,[Change]
						)
					SELECT 1
						,'Created'
						,''

					EXEC uspSMSingleAuditLog @screenName = 'Quality.view.QualityTemplate'
						,@recordId = @intProductId
						,@entityId = @intUserId
						,@AuditLogParam = @SingleAuditLogParam
				END
			END
			ELSE IF @intActionId = 2
			BEGIN
				UPDATE PPV
				SET intConcurrencyId = PPV.intConcurrencyId + 1
					,dblMinValue = PD.dblMinValue
					,dblMaxValue = PD.dblMaxValue
					,dblPinpointValue = PD.dblPinPoint
				FROM tblQMProductPropertyValidityPeriod PPV
				JOIN tblQMProductProperty PP ON PP.intProductPropertyId = PPV.intProductPropertyId
					AND PP.intProductId = @intProductId
				--AND PP.intTestId = @intTestId
				JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
				JOIN tblIPSAPProperty SP ON SP.stri21PropertyName = P.strPropertyName
				JOIN tblIPPBBSDetailStage PD ON PD.intPBBSStageId = @intPBBSStageId
					AND PD.strSpecificationCode = SP.strSAPPropertyName
				WHERE ISNULL(PPV.dblMinValue, 0) <> ISNULL(PD.dblMinValue, 0)
					OR ISNULL(PPV.dblMaxValue, 0) <> ISNULL(PD.dblMaxValue, 0)
					OR ISNULL(PPV.dblPinpointValue, 0) <> ISNULL(PD.dblPinPoint, 0)
			END

			IF ISNULL(@strFileContent, '') <> ''
				AND ISNULL(@strPDFFileName, '') <> ''
				AND ISNULL(@intProductValueId, 0) > 0
			BEGIN
				DECLARE @newAttachmentId INT
					,@error NVARCHAR(1000)
				DECLARE @fileContent VARBINARY(MAX)
					,@fileExtension NVARCHAR(50)
					,@intScreenId INT
					,@intTransactionId INT
				DECLARE @blbfile NVARCHAR(MAX)

				SELECT @intScreenId = intScreenId
				FROM tblSMScreen
				WHERE strNamespace = 'Inventory.view.Item'

				SELECT @intTransactionId = intTransactionId
				FROM tblSMTransaction
				WHERE intScreenId = @intScreenId
					AND intRecordId = @intProductValueId

				SELECT @fileExtension = RIGHT(@strPDFFileName, 3)

				SELECT @strPDFFileName = SUBSTRING(@strPDFFileName, 1, LEN(@strPDFFileName) - 4)

				SELECT @blbfile = @strFileContent

				SET @fileContent = CAST('' AS XML).value('xs:base64Binary(sql:variable("@blbfile"))', 'varbinary(max)')

				EXEC uspSMCreateAttachmentFromDirectFile @transactionId = @intTransactionId
					,@blbFile = @fileContent
					,@fileName = @strPDFFileName
					,@fileExtension = @fileExtension
					,@screenNamespace = 'Inventory.view.Item'
					,@intEntityId = 1
					,@throwError = 1
					,@attachmentId = @newAttachmentId OUTPUT
					,@error = @error OUTPUT
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPPBBSArchive (
				intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,strFileContent
				,dtmTransactionDate
				,strErrorMessage
				)
			SELECT intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,strFileContent
				,dtmTransactionDate
				,''
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			SELECT @intNewPBBSStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPPBBSDetailArchive (
				intPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
				)
			SELECT @intNewPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
			FROM tblIPPBBSDetailStage
			WHERE intPBBSStageId = @intPBBSStageId

			DELETE
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPPBBSError (
				intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,strFileContent
				,dtmTransactionDate
				,strErrorMessage
				)
			SELECT intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,strFileContent
				,dtmTransactionDate
				,@ErrMsg
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			SELECT @intNewPBBSStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPPBBSDetailError (
				intPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
				)
			SELECT @intNewPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
			FROM tblIPPBBSDetailStage
			WHERE intPBBSStageId = @intPBBSStageId

			DELETE
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId
		END CATCH

		SELECT @intPBBSStageId = MIN(intPBBSStageId)
		FROM @tblIPPBBSStage
		WHERE intPBBSStageId > @intPBBSStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPPBBSStage S
	JOIN @tblIPPBBSStage TS ON TS.intPBBSStageId = S.intPBBSStageId
	WHERE S.intStatusId = - 1

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
