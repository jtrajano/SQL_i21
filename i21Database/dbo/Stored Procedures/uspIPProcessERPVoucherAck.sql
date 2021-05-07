CREATE PROCEDURE uspIPProcessERPVoucherAck
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
		,@VoucherNo NVARCHAR(50)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@ERPVoucherNo NVARCHAR(50)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intBillId INT
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,TrxSequenceNo INT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,VoucherNo NVARCHAR(50)
		,StatusId INT
		,StatusText NVARCHAR(2048)
		,ERPVoucherNo NVARCHAR(50)
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Voucher Ack'

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
				,VoucherNo
				,StatusId
				,StatusText
				,ERPVoucherNo
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,VoucherNo
				,StatusId
				,StatusText
				,ERPVoucherNo
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					,VoucherNo NVARCHAR(50)
					,StatusId INT
					,StatusText NVARCHAR(2048)
					,ERPVoucherNo NVARCHAR(50)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @TrxSequenceNo = NULL
					,@CompanyLocation = NULL
					,@CreatedDate = NULL
					,@CreatedBy = NULL
					,@VoucherNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL
					,@intBillId = NULL
					,@ERPVoucherNo = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@VoucherNo = VoucherNo
					,@StatusId = StatusId
					,@StatusText = StatusText
					,@ERPVoucherNo = ERPVoucherNo
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intBillId = intBillId
				FROM tblAPBill
				WHERE strBillId = @VoucherNo

				IF @StatusId = 1
				BEGIN
					UPDATE tblAPBillPreStage
					SET intStatusId = 6
						,strMessage = 'Success'
						,strFeedStatus = 'Ack Rcvd'
						,strERPVoucherNo = @ERPVoucherNo
					WHERE intBillId = @intBillId
						AND intStatusId = 2

					--Update the ERP Voucher No in UnPost / Repost records
					UPDATE tblAPBillPreStage
					SET strERPVoucherNo = @ERPVoucherNo
					WHERE intBillId = @intBillId
						AND ISNULL(intStatusId, 1) = 1

					UPDATE tblAPBill
					SET intConcurrencyId = intConcurrencyId + 1
						,strComment = @ERPVoucherNo
					WHERE intBillId = @intBillId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Voucher Ack'
						,'Success'
						,@VoucherNo
						,@ERPVoucherNo
						)
				END
				ELSE
				BEGIN
					UPDATE tblAPBillPreStage
					SET intStatusId = 5
						,strMessage = @StatusText
						,strFeedStatus = 'Ack Rcvd'
					WHERE intBillId = @intBillId
						AND intStatusId = 2

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Voucher Ack'
						,@StatusText
						,@VoucherNo
						,@ERPVoucherNo
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
			AND strType = 'Voucher Ack'
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
