CREATE PROCEDURE uspIPProcessERPPOAck
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
		,@TrxSequenceNo BIGINT
		,@CompanyLocation NVARCHAR(6)
		,@CreatedDate DATETIME
		,@CreatedBy NVARCHAR(50)
		,@OriginalTrxSequenceNo INT
		,@ContractNo NVARCHAR(50)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intContractDetailId INT
		,@intContractHeaderId INT
		,@SequenceNo NVARCHAR(3)
		,@ERPPONumber NVARCHAR(50)
		,@ERPPOlineNo NVARCHAR(50)
		,@strContractNumber NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,TrxSequenceNo BIGINT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,OriginalTrxSequenceNo INT
		,ContractNo NVARCHAR(50)
		,StatusId INT
		,StatusText NVARCHAR(2048)
		,SequenceNo NVARCHAR(3)
		,ERPPONumber NVARCHAR(50)
		,ERPPOlineNo NVARCHAR(50)
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'PO Ack'
		AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

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
				,ContractNo
				,StatusId
				,StatusText
				,SequenceNo
				,ERPPONumber
				,ERPPOlineNo
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,OriginalTrxSequenceNo
				,ContractNo
				,StatusId
				,StatusText
				,SequenceNo
				,ERPPONumber
				,ERPPOlineNo
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					TrxSequenceNo BIGINT '../TrxSequenceNo'
					,CompanyLocation NVARCHAR(6) '../CompanyLocation'
					,CreatedDate DATETIME '../CreatedDate'
					,CreatedByUser NVARCHAR(50) '../CreatedByUser'
					,OriginalTrxSequenceNo INT '../OriginalTrxSequenceNo'
					,ContractNo NVARCHAR(50) '../ContractNo'
					,StatusId INT '../StatusId'
					,StatusText NVARCHAR(2048) '../StatusText'
					,SequenceNo NVARCHAR(3)
					,ERPPONumber NVARCHAR(50)
					,ERPPOlineNo NVARCHAR(50)
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
					,@ContractNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL
					,@intContractDetailId = NULL
					,@intContractHeaderId = NULL
					,@SequenceNo = NULL
					,@ERPPONumber = NULL
					,@ERPPOlineNo = NULL
					,@strContractNumber = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@OriginalTrxSequenceNo = OriginalTrxSequenceNo
					,@ContractNo = ContractNo
					,@StatusId = StatusId
					,@StatusText = StatusText
					,@SequenceNo = SequenceNo
					,@ERPPONumber = ERPPONumber
					,@ERPPOlineNo = ERPPOlineNo
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intContractDetailId = intContractDetailId
					,@intContractHeaderId = intContractHeaderId
					,@strContractNumber = strContractNumber
				FROM tblCTContractFeed
				WHERE intContractFeedId = @OriginalTrxSequenceNo

				IF ISNULL(@strContractNumber, '') <> ISNULL(@ContractNo, '')
				BEGIN
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
						,19
						,0
						,'Invalid OriginalTrxSequenceNo. '
				END
				ELSE
				BEGIN
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
						,19
						,1
						,'Success'

					UPDATE tblCTContractFeed
					SET intStatusId = 6
						,strMessage = 'Success'
						,strFeedStatus = 'Ack Rcvd'
						,strERPPONumber = @ERPPONumber
						,strERPItemNumber = @ERPPOlineNo
					WHERE intContractFeedId = @OriginalTrxSequenceNo

					--Update the PO Details in modified sequences
					UPDATE tblCTContractFeed
					SET strERPPONumber = @ERPPONumber
						,strERPItemNumber = @ERPPOlineNo
					WHERE intContractDetailId = @intContractDetailId
						AND intStatusId IS NULL
						AND strRowState <> 'Added'

					UPDATE tblCTContractDetail
					SET strERPPONumber = @ERPPONumber
						,strERPItemNumber = @ERPPOlineNo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intContractDetailId = @intContractDetailId

					UPDATE tblCTContractHeader
					SET intConcurrencyId = intConcurrencyId + 1
					WHERE intContractHeaderId = @intContractHeaderId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'PO Ack'
						,'Success'
						,@ContractNo + ' / ' + ISNULL(@SequenceNo, '')
						,@ERPPONumber
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
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	WHERE S.intStatusId = - 1

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
