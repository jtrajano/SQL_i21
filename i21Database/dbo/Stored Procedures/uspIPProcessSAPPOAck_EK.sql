CREATE PROCEDURE uspIPProcessSAPPOAck_EK
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@strMessage NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@DocNo NVARCHAR(50)
		,@MsgType NVARCHAR(50)
		,@Sender NVARCHAR(50)
		,@Receiver NVARCHAR(50)
		,@RefNo NVARCHAR(50)
		,@Status NVARCHAR(50)
		,@StatusText NVARCHAR(MAX)
		,@TrackingNo NVARCHAR(50)
		,@PONumber NVARCHAR(50)
		,@POLineItemNo NVARCHAR(50)
		,@intLoadId INT
		,@intLoadDetailId INT
		,@intContractFeedId INT
		,@strBatchId NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,DocNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,MsgType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Sender NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Receiver NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,RefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,[Status] NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,StatusText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,TrackingNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,PONumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,POLineItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
				DocNo
				,MsgType
				,Sender
				,Receiver
				,RefNo
				,[Status]
				,StatusText
				,TrackingNo
				,PONumber
				,POLineItemNo
				)
			SELECT DocNo
				,MsgType
				,Sender
				,Receiver
				,RefNo
				,[Status]
				,StatusText
				,TrackingNo
				,PONumber
				,POLineItemNo
			FROM OPENXML(@idoc, 'root/Header/Line', 2) WITH (
					DocNo BIGINT '../../DocNo'
					,MsgType NVARCHAR(50) '../../MsgType'
					,Sender NVARCHAR(50) '../../Sender'
					,Receiver NVARCHAR(50) '../../Receiver'
					,RefNo NVARCHAR(50) '../RefNo'
					,[Status] INT '../Status'
					,StatusText NVARCHAR(MAX) '../StatusText'
					,TrackingNo NVARCHAR(50)
					,PONumber NVARCHAR(50)
					,POLineItemNo NVARCHAR(50)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @DocNo = NULL
					,@MsgType = NULL
					,@Sender = NULL
					,@Receiver = NULL
					,@RefNo = NULL
					,@Status = NULL
					,@StatusText = NULL
					,@TrackingNo = NULL
					,@PONumber = NULL
					,@POLineItemNo = NULL

				SELECT @intLoadId = NULL
					,@intLoadDetailId = NULL
					,@intContractFeedId = NULL
					,@strBatchId = NULL

				SELECT @DocNo = DocNo
					,@MsgType = MsgType
					,@Sender = Sender
					,@Receiver = Receiver
					,@RefNo = RefNo
					,@Status = [Status]
					,@StatusText = StatusText
					,@TrackingNo = TrackingNo
					,@PONumber = PONumber
					,@POLineItemNo = POLineItemNo
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				IF @MsgType = 'Purchase_Order_Ack'
				BEGIN
					SELECT @intLoadId = L.intLoadId
					FROM dbo.tblLGLoad L
					WHERE L.strLoadNumber = @RefNo

					IF @intLoadId IS NULL
					BEGIN
						SELECT TOP 1 @intLoadId = CF.intLoadId
						FROM dbo.tblIPContractFeed CF
						WHERE CF.strLoadNumber = @RefNo
					END

					SELECT @intLoadDetailId = CF.intLoadDetailId
						,@intContractFeedId = CF.intContractFeedId
						,@strBatchId = CF.strBatchId
					FROM dbo.tblIPContractFeed CF
					WHERE CF.intLoadId = @intLoadId
						AND CF.intContractFeedId = @TrackingNo

					IF @Status = '1' --Success
					BEGIN
						IF (
								SELECT ISNULL(strExternalShipmentNumber, '')
								FROM tblLGLoad
								WHERE intLoadId = @intLoadId
								) <> @PONumber
						BEGIN
							UPDATE tblLGLoad
							SET strExternalShipmentNumber = @PONumber
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intLoadId = @intLoadId
						END

						IF (
								SELECT ISNULL(strExternalShipmentItemNumber, '')
								FROM tblLGLoadDetail
								WHERE intLoadDetailId = @intLoadDetailId
								) <> @POLineItemNo
						BEGIN
							UPDATE tblLGLoadDetail
							SET strExternalShipmentItemNumber = @POLineItemNo
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intLoadDetailId = @intLoadDetailId
						END
						
						--Add PO details in Batch
						UPDATE tblMFBatch
						SET strERPPONumber = @PONumber
							,strERPPOLineNo = @POLineItemNo
						WHERE strBatchId = @strBatchId

						--For Added PO
						UPDATE tblIPContractFeed
						SET strFeedStatus = 'Ack Rcvd'
							,strMessage = 'Success'
							,strERPPONumber = @PONumber
							,strERPItemNumber = @POLineItemNo
							,intStatusId = 4
						WHERE intContractFeedId = @intContractFeedId
							AND ISNULL(strFeedStatus, '') = 'Awt Ack'

						--Update the PO Details in modified sequences
						UPDATE tblIPContractFeed
						SET strERPPONumber = @PONumber
							,strERPItemNumber = @POLineItemNo
						WHERE intLoadDetailId = @intLoadDetailId
							AND ISNULL(strFeedStatus, '') = ''

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							'PO Ack'
							,'Success'
							,@RefNo + ' / ' + ISNULL(@PONumber, '')
							,@TrackingNo + ' / ' + ISNULL(LTRIM(@POLineItemNo), '')
							)
					END

					IF @Status = '0'
					BEGIN
						SET @strMessage = @Status + ' - ' + @StatusText

						UPDATE tblIPContractFeed
						SET strFeedStatus = 'Ack Rcvd'
							,strMessage = @strMessage
							,intStatusId = 3
						WHERE intContractFeedId = @intContractFeedId
							AND ISNULL(strFeedStatus, '') = 'Awt Ack'
							
						UPDATE tblLGLoad
						SET strComments = @StatusText
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intLoadId = @intLoadId
							AND ISNULL(strComments, '') <> ISNULL(@StatusText, '')

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							'PO Ack'
							,@strMessage
							,@RefNo + ' / ' + ISNULL(@PONumber, '')
							,@TrackingNo + ' / ' + ISNULL(LTRIM(@POLineItemNo), '')
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
