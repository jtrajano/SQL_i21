﻿CREATE PROCEDURE uspIPProcessERPCommitmentPricingAck
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@strMessage NVARCHAR(MAX)
		,@TrxSequenceNo INT
		,@CompanyLocation NVARCHAR(6)
		,@CreatedDate DATETIME
		,@CreatedBy NVARCHAR(50)
		,@OriginalTrxSequenceNo INT
		,@PricingNo NVARCHAR(50)
		,@ERPRefNo NVARCHAR(100)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@ActualBlend NVARCHAR(50)
		,@ERPBlend NVARCHAR(50)
		,@intCommitmentPricingId INT
		,@intCommitmentPricingRecipeId INT
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,TrxSequenceNo INT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,OriginalTrxSequenceNo INT
		,PricingNo NVARCHAR(50)
		,ERPRefNo NVARCHAR(100)
		,StatusId INT
		,StatusText NVARCHAR(2048)
		,ActualBlend NVARCHAR(50)
		,ERPBlend NVARCHAR(50)
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Commitment Pricing Ack'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblAcknowledgement

			INSERT INTO @tblAcknowledgement (
				TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,OriginalTrxSequenceNo
				,PricingNo
				,ERPRefNo
				,StatusId
				,StatusText
				,ActualBlend
				,ERPBlend
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,OriginalTrxSequenceNo
				,PricingNo
				,ERPRefNo
				,StatusId
				,StatusText
				,ActualBlend
				,ERPBlend
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					TrxSequenceNo INT '../TrxSequenceNo'
					,CompanyLocation NVARCHAR(6) '../CompanyLocation'
					,CreatedDate DATETIME '../CreatedDate'
					,CreatedByUser NVARCHAR(50) '../CreatedByUser'
					,OriginalTrxSequenceNo INT '../OriginalTrxSequenceNo'
					,PricingNo NVARCHAR(50) '../PricingNo'
					,ERPRefNo NVARCHAR(100) '../ERPRefNo'
					,StatusId INT '../StatusId'
					,StatusText NVARCHAR(2048) '../StatusText'
					,ActualBlend NVARCHAR(50)
					,ERPBlend NVARCHAR(50)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @TrxSequenceNo = NULL
					,@CompanyLocation = NULL
					,@CreatedDate = NULL
					,@CreatedBy = NULL
					,@OriginalTrxSequenceNo = NULL
					,@PricingNo = NULL
					,@ERPRefNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL
					,@ActualBlend = NULL
					,@ERPBlend = NULL
					,@intCommitmentPricingId = NULL
					,@intCommitmentPricingRecipeId = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@OriginalTrxSequenceNo = OriginalTrxSequenceNo
					,@PricingNo = PricingNo
					,@ERPRefNo = ERPRefNo
					,@StatusId = StatusId
					,@StatusText = StatusText
					,@ActualBlend = ActualBlend
					,@ERPBlend = ERPBlend
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intCommitmentPricingId = intCommitmentPricingId
				FROM tblMFCommitmentPricingStage
				WHERE intCommitmentPricingStageId = @OriginalTrxSequenceNo

				--SELECT @intCommitmentPricingId = P.intCommitmentPricingId
				--FROM tblMFCommitmentPricing P
				--WHERE P.strPricingNumber = @PricingNo
				SELECT @intCommitmentPricingRecipeId = PR.intCommitmentPricingRecipeId
				FROM tblMFCommitmentPricingRecipe PR
				JOIN tblMFRecipeItem RI ON RI.intRecipeItemId = PR.intActualRecipeItemId
				JOIN tblICItem I ON I.intItemId = RI.intItemId
				WHERE PR.intCommitmentPricingId = @intCommitmentPricingId
					AND I.strItemNo = @ActualBlend

				INSERT INTO tblIPInitialAck (
					intTrxSequenceNo
					,strCompanyLocation
					,dtmCreatedDate
					,strCreatedBy
					,intMessageTypeId
					,intStatusId
					,strStatusText
					)
				SELECT @TrxSequenceNo
					,@CompanyLocation
					,@CreatedDate
					,@CreatedBy
					,20
					,1
					,'Success'

				IF @StatusId = 1
				BEGIN
					UPDATE tblMFCommitmentPricingStage
					SET intStatusId = 6
						,strMessage = 'Success'
						,strFeedStatus = 'Ack Rcvd'
					WHERE intCommitmentPricingStageId = @OriginalTrxSequenceNo

					--WHERE intCommitmentPricingId = @intCommitmentPricingId
					--	AND intStatusId = 2
					UPDATE tblMFCommitmentPricing
					SET strERPNo = @ERPRefNo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intCommitmentPricingId = @intCommitmentPricingId

					UPDATE tblMFCommitmentPricingRecipe
					SET strBlendCode = @ERPBlend
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intCommitmentPricingRecipeId = @intCommitmentPricingRecipeId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Commitment Pricing Ack'
						,'Success'
						,@PricingNo + ' / ' + ISNULL(@ERPRefNo, '')
						,@ERPBlend
						)
				END
				ELSE
				BEGIN
					UPDATE tblMFCommitmentPricingStage
					SET intStatusId = 5
						,strMessage = @StatusText
						,strFeedStatus = 'Ack Rcvd'
					WHERE intCommitmentPricingStageId = @OriginalTrxSequenceNo

					--WHERE intCommitmentPricingId = @intCommitmentPricingId
					--	AND intStatusId = 2
					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Commitment Pricing Ack'
						,@StatusText
						,@PricingNo + ' / ' + ISNULL(@ERPRefNo, '')
						,@ERPBlend
						)
				END

				SELECT @intMinRowNo = MIN(intRowNo)
				FROM @tblAcknowledgement
				WHERE intRowNo > @intMinRowNo
			END

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Commitment Pricing Ack'
	END

	SELECT strMessageType
		,strMessage
		,ISNULL(strInfo1, '') AS strInfo1
		,ISNULL(strInfo2, '') AS strInfo2
	FROM @tblMessage
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
