CREATE PROCEDURE uspIPProcessSAPAcknowledgement_DA
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
		,@intContractHeaderId INT
		,@intMinRowNo INT
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@DOC_NO NVARCHAR(50)
		,@MSG_TYPE NVARCHAR(50)
		,@SENDER NVARCHAR(50)
		,@RECEIVER NVARCHAR(50)
		,@REF_NO NVARCHAR(50)
		,@STATUS_CODE NVARCHAR(50)
		,@STATUS_TEXT NVARCHAR(MAX)
		,@TRACKING_NO NVARCHAR(50)
		,@SEQUENCE_NO NVARCHAR(50)
		,@PO_NUMBER NVARCHAR(50)
		,@PO_LINE_ITEM_NO NVARCHAR(50)
		,@intContractDetailId INT
		,@strERPPONumber NVARCHAR(50)
		,@strERPItemNumber NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,DOC_NO NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,MSG_TYPE NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,SENDER NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,RECEIVER NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,REF_NO NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,STATUS_CODE NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,STATUS_TEXT NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,TRACKING_NO NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,SEQUENCE_NO NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,PO_NUMBER NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,PO_LINE_ITEM_NO NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
				DOC_NO
				,MSG_TYPE
				,SENDER
				,RECEIVER
				,REF_NO
				,STATUS_CODE
				,STATUS_TEXT
				,TRACKING_NO
				,SEQUENCE_NO
				,PO_NUMBER
				,PO_LINE_ITEM_NO
				)
			SELECT DOC_NO
				,MSG_TYPE
				,SENDER
				,RECEIVER
				,REF_NO
				,STATUS_CODE
				,STATUS_TEXT
				,TRACKING_NO
				,SEQUENCE_NO
				,PO_NUMBER
				,PO_LINE_ITEM_NO
			FROM OPENXML(@idoc, 'ROOT_ACK/LINE_ITEM', 2) WITH (
					DOC_NO NVARCHAR(50) '../CTRL_POINT/DOC_NO'
					,MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
					,SENDER NVARCHAR(50) '../CTRL_POINT/SENDER'
					,RECEIVER NVARCHAR(50) '../CTRL_POINT/RECEIVER'
					,REF_NO NVARCHAR(50) '../HEADER/REF_NO'
					,STATUS_CODE NVARCHAR(50) '../HEADER/STATUS_CODE'
					,STATUS_TEXT NVARCHAR(MAX) '../HEADER/STATUS_TEXT'
					,TRACKING_NO NVARCHAR(50) '../HEADER/TRACKING_NO'
					,SEQUENCE_NO NVARCHAR(50)
					,PO_NUMBER NVARCHAR(50)
					,PO_LINE_ITEM_NO NVARCHAR(50)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @DOC_NO = NULL
					,@MSG_TYPE = NULL
					,@SENDER = NULL
					,@RECEIVER = NULL
					,@REF_NO = NULL
					,@PO_NUMBER = NULL
					,@STATUS_CODE = NULL
					,@STATUS_TEXT = NULL
					,@TRACKING_NO = NULL
					,@SEQUENCE_NO = NULL
					,@PO_NUMBER = NULL
					,@PO_LINE_ITEM_NO = NULL

				SELECT @DOC_NO = DOC_NO
					,@MSG_TYPE = MSG_TYPE
					,@SENDER = SENDER
					,@RECEIVER = RECEIVER
					,@REF_NO = REF_NO
					,@PO_NUMBER = PO_NUMBER
					,@STATUS_CODE = STATUS_CODE
					,@STATUS_TEXT = STATUS_TEXT
					,@TRACKING_NO = TRACKING_NO
					,@SEQUENCE_NO = SEQUENCE_NO
					,@PO_NUMBER = PO_NUMBER
					,@PO_LINE_ITEM_NO = PO_LINE_ITEM_NO
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				--PO Create
				IF @MSG_TYPE = 'PO_CREATE_ACK'
				BEGIN
					SELECT @intContractHeaderId = NULL
						,@intContractDetailId = NULL

					SELECT @intContractHeaderId = intContractHeaderId
					FROM tblCTContractHeader
					WHERE strContractNumber = @TRACKING_NO

					SELECT @intContractDetailId = intContractDetailId
					FROM tblCTContractDetail
					WHERE intContractHeaderId = @intContractHeaderId
						AND intContractSeq = @SEQUENCE_NO

					IF @STATUS_CODE = 'S' --Success
					BEGIN
						IF (
								SELECT ISNULL(strERPPONumber, '')
								FROM tblCTContractDetail
								WHERE intContractDetailId = @intContractDetailId
								) <> @PO_NUMBER
						BEGIN
							UPDATE tblCTContractDetail
							SET strERPPONumber = @PO_NUMBER
								,strERPItemNumber = @PO_LINE_ITEM_NO
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intContractDetailId = @intContractDetailId

							UPDATE tblCTContractHeader
							SET intConcurrencyId = intConcurrencyId + 1
							WHERE intContractHeaderId = @intContractHeaderId
						END

						--For Added Contract
						UPDATE tblCTContractFeed
						SET strFeedStatus = 'Ack Rcvd'
							,strMessage = 'Success'
							,strERPPONumber = @PO_NUMBER
							,strERPItemNumber = @PO_LINE_ITEM_NO
							,ysnMailSent = 1
							,intStatusId = 4
						WHERE intContractDetailId = @intContractDetailId
							AND ISNULL(strFeedStatus, '') IN (
								'Awt Ack'
								,'Ack Rcvd'
								)

						--update the PO Details in modified sequences
						UPDATE tblCTContractFeed
						SET strERPPONumber = @PO_NUMBER
							,strERPItemNumber = @PO_LINE_ITEM_NO
						WHERE intContractDetailId = @intContractDetailId
							AND ISNULL(strFeedStatus, '') = ''

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							@MSG_TYPE
							,'Success'
							,@TRACKING_NO + ' / ' + LTRIM(@SEQUENCE_NO)
							,@PO_NUMBER
							)
					END

					IF @STATUS_CODE = 'F'
					BEGIN
						SET @strMessage = @STATUS_CODE + ' - ' + @STATUS_TEXT

						UPDATE tblCTContractFeed
						SET strFeedStatus = 'Ack Rcvd'
							,strMessage = @strMessage
							,intStatusId = 3
						WHERE intContractDetailId = @intContractDetailId
							AND ISNULL(strFeedStatus, '') = 'Awt Ack'

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							@MSG_TYPE
							,@strMessage
							,@TRACKING_NO + ' / ' + LTRIM(@SEQUENCE_NO)
							,@PO_NUMBER
							)
					END
				END

				--PO Update
				IF @MSG_TYPE = 'PO_UPDATE_ACK'
				BEGIN
					SELECT @intContractHeaderId = NULL
						,@intContractDetailId = NULL
						,@strERPPONumber = NULL
						,@strERPItemNumber = NULL

					SELECT @intContractHeaderId = intContractHeaderId
					FROM tblCTContractHeader
					WHERE strContractNumber = @TRACKING_NO

					SELECT @intContractDetailId = intContractDetailId
						,@strERPPONumber = strERPPONumber
						,@strERPItemNumber = strERPItemNumber
					FROM tblCTContractDetail
					WHERE intContractHeaderId = @intContractHeaderId
						AND intContractSeq = @SEQUENCE_NO

					IF @STATUS_CODE = 'S' --Success
					BEGIN
						IF @strERPPONumber = @PO_NUMBER
							AND @strERPItemNumber = @PO_LINE_ITEM_NO
						BEGIN
							UPDATE tblCTContractFeed
							SET strFeedStatus = 'Ack Rcvd'
								,strMessage = 'Success'
								,ysnMailSent = 1
							WHERE intContractDetailId = @intContractDetailId
								AND ISNULL(strFeedStatus, '') = 'Awt Ack'
								AND ISNULL(strERPPONumber, '') = @PO_NUMBER
						END
						ELSE
						BEGIN
							UPDATE tblCTContractDetail
							SET strERPPONumber = @PO_NUMBER
								,strERPItemNumber = @PO_LINE_ITEM_NO
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intContractDetailId = @intContractDetailId

							UPDATE tblCTContractFeed
							SET strFeedStatus = 'Ack Rcvd'
								,strMessage = 'Success'
								,strERPPONumber = @PO_NUMBER
								,strERPItemNumber = @PO_LINE_ITEM_NO
								,ysnMailSent = 1
							WHERE intContractDetailId = @intContractDetailId
								AND ISNULL(strFeedStatus, '') = 'Awt Ack'
						END

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							@MSG_TYPE
							,'Success'
							,@TRACKING_NO + ' / ' + LTRIM(@SEQUENCE_NO)
							,@PO_NUMBER
							)
					END

					IF @STATUS_CODE = 'F'
					BEGIN
						SET @strMessage = @STATUS_CODE + ' - ' + @STATUS_TEXT

						UPDATE tblCTContractFeed
						SET strFeedStatus = 'Ack Rcvd'
							,strMessage = @strMessage
							,intStatusId = 3
						WHERE intContractDetailId = @intContractDetailId
							AND ISNULL(strFeedStatus, '') = 'Awt Ack'

						-- To update Item Change, Delete entries
						--UPDATE tblCTContractFeed
						--SET strFeedStatus = 'Ack Rcvd'
						--	,strMessage = @strMessage
						--	,intStatusId = 3
						--WHERE intContractDetailId = @intContractDetailId
						--	AND ISNULL(strFeedStatus, '') = 'Awt Ack'
						--	AND ISNULL(strERPPONumber, '') = @PO_NUMBER

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							@MSG_TYPE
							,@strMessage
							,@TRACKING_NO + ' / ' + LTRIM(@SEQUENCE_NO)
							,@PO_NUMBER
							)
					END
				END

				SELECT @intMinRowNo = MIN(intRowNo)
				FROM @tblAcknowledgement
				WHERE intRowNo > @intMinRowNo
			END

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,strFileName
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
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
				,strFileName
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
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
