CREATE PROCEDURE [dbo].[uspIPProcessVoucherAttachment]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @tblIPBillStage TABLE (intBillStageId INT)
	DECLARE @intScreenId INT
		,@strVendorInvoiceFilePath NVARCHAR(500)
		,@intBillStageId INT
		,@isPresent BIT
		,@strFileName NVARCHAR(50)
		,@intDocAttached INT
		,@intBillId INT
		,@strBillId NVARCHAR(50)
		,@intTransactionId INT
		,@newAttachmentId INT
		,@ErrMsg NVARCHAR(MAX)
		,@message NVARCHAR(1000)
		,@strFileName2 NVARCHAR(50)

	INSERT INTO @tblIPBillStage (intBillStageId)
	SELECT intBillStageId
	FROM tblIPBillStage
	WHERE intDocAttached IS NULL
		AND intBillId IS NOT NULL

	UPDATE S
	SET S.intDocAttached = - 1
	FROM tblIPBillStage S
	JOIN @tblIPBillStage TS ON TS.intBillStageId = S.intBillStageId

	SELECT @intBillStageId = MIN(intBillStageId)
	FROM @tblIPBillStage

	IF @intBillStageId IS NULL
	BEGIN
		RETURN
	END

	SELECT @strVendorInvoiceFilePath = strVendorInvoiceFilePath
	FROM tblIPCompanyPreference

	SELECT @strVendorInvoiceFilePath = ''

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'AccountsPayable.view.Voucher'

	WHILE @intBillStageId > 0
	BEGIN
		SELECT @strFileName = NULL

		SELECT @intDocAttached = NULL

		SELECT @strFileName = strFileName
			,@intBillId = intBillId
		FROM tblIPBillStage
		WHERE intBillStageId = @intBillStageId



		BEGIN TRY
			SELECT @isPresent = 0

			EXEC [uspSMCheckPendingAttachmentFileIfPresent] @fullFileName = @strFileName
				,@isPresent = @isPresent OUTPUT

			SELECT @isPresent

			IF @isPresent = 1
			BEGIN
				SELECT @intTransactionId = NULL

				SELECT @intTransactionId = intTransactionId
				FROM tblSMTransaction
				WHERE intRecordId = @intBillId
					AND intScreenId = @intScreenId


				IF @intTransactionId IS NOT NULL
				BEGIN
					SELECT @strFileName2 = @strFileName
					SELECT @strFileName = Replace(@strFileName, '.pdf', '')
					EXEC [uspSMCreateAttachmentFromFile] @transactionId = @intTransactionId -- the intTransactionId
						,@fileName = @strFileName -- file name
						,@fileExtension = 'pdf' -- extension
						,@filePath = @strVendorInvoiceFilePath -- path
						,@screenNamespace = 'AccountsPayable.view.Bill' -- screen type or namespace
						,@useDocumentWatcher = 1 -- flag if the file was uploaded using document wacther
						,@throwError = 1
						,@attachmentId = @newAttachmentId OUTPUT
						,@error = @message OUTPUT

					SELECT @newAttachmentId
						,@message
					IF Exists(Select *from tblSMAttachment Where strName=@strFileName2)
					BEGIN
						UPDATE tblIPBillStage
						SET intDocAttached = 1
						WHERE intBillStageId = @intBillStageId
						END
				END
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			UPDATE tblIPBillStage
			SET intDocAttached = 0
				,strMessage = @ErrMsg
			WHERE intBillStageId = @intBillStageId
				AND intStatusId = - 1
		END CATCH

		SELECT @intBillStageId = MIN(intBillStageId)
		FROM @tblIPBillStage
		WHERE intBillStageId > @intBillStageId
	END

	UPDATE S
	SET S.intDocAttached = NULL
	FROM tblIPBillStage S
	JOIN @tblIPBillStage TS ON TS.intBillStageId = S.intBillStageId
	WHERE S.intDocAttached = - 1
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	UPDATE tblIPBillStage
	SET intDocAttached = 0
		,strMessage = @ErrMsg
	WHERE intBillStageId = @intBillStageId
		AND intStatusId = - 1

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
