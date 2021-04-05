CREATE PROCEDURE uspIPProcessERPGoodsReceiptAck
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
		,@ReceiptNo NVARCHAR(50)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@ERPReferenceNo NVARCHAR(50)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intInventoryReceiptId INT
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,TrxSequenceNo INT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,ReceiptNo NVARCHAR(50)
		,StatusId INT
		,StatusText NVARCHAR(2048)
		,ERPReferenceNo NVARCHAR(50)
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Goods Receipt Ack'

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
				,ReceiptNo
				,StatusId
				,StatusText
				,ERPReferenceNo
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,ReceiptNo
				,StatusId
				,StatusText
				,ERPReferenceNo
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					,ReceiptNo NVARCHAR(50)
					,StatusId INT
					,StatusText NVARCHAR(2048)
					,ERPReferenceNo NVARCHAR(50)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @TrxSequenceNo = NULL
					,@CompanyLocation = NULL
					,@CreatedDate = NULL
					,@CreatedBy = NULL
					,@ReceiptNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL
					,@intInventoryReceiptId = NULL
					,@ERPReferenceNo = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@ReceiptNo = ReceiptNo
					,@StatusId = StatusId
					,@StatusText = StatusText
					,@ERPReferenceNo = ERPReferenceNo
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intInventoryReceiptId = intInventoryReceiptId
				FROM tblICInventoryReceipt
				WHERE strReceiptNumber = @ReceiptNo

				IF @StatusId = 1
				BEGIN
					UPDATE tblIPInvReceiptFeed
					SET intStatusId = 6
						,strMessage = 'Success'
						,strFeedStatus = 'Ack Rcvd'
						,strERPTransferOrderNo = @ERPReferenceNo
					WHERE intInventoryReceiptId = @intInventoryReceiptId
						AND intStatusId IS NULL

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Goods Receipt Ack'
						,'Success'
						,@ReceiptNo
						,@ERPReferenceNo
						)
				END
				ELSE
				BEGIN
					UPDATE tblIPInvReceiptFeed
					SET intStatusId = 5
						,strMessage = @StatusText
						,strFeedStatus = 'Ack Rcvd'
					WHERE intInventoryReceiptId = @intInventoryReceiptId
						AND intStatusId IS NULL

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Goods Receipt Ack'
						,@StatusText
						,@ReceiptNo
						,@ERPReferenceNo
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
			AND strType = 'Goods Receipt Ack'
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
