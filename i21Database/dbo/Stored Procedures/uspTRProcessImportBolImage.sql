CREATE PROCEDURE [dbo].[uspTRProcessImportBolImage]
	@guidImportIdentifier UNIQUEIDENTIFIER,
    @intUserId INT,
	@strFilePath NVARCHAR(1000),
	@return INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY

		DECLARE @intImportAttachmentId INT,
			@intImportAttachmentDetailId INT = NULL,
			@strSupplier NVARCHAR(100) = NULL,
			@strBillOfLading NVARCHAR(100) = NULL,
			@dtmLoadDateTime DATETIME = NULL,
		    @ysnValid BIT = NULL,
			@strMessage NVARCHAR(MAX) = NULL,
			@strSource NVARCHAR(20) = NULL,
			@strFileName NVARCHAR(300) = NULL,
			@strFileExtension NVARCHAR(50) = NULL
	
		BEGIN TRANSACTION

		DECLARE @CursorTran AS CURSOR
		SET @CursorTran = CURSOR FAST_FORWARD FOR
		SELECT D.intImportAttachmentDetailId
			, D.strSupplier
			, D.strBillOfLading
			, D.dtmLoadDateTime
			, D.ysnValid
			, D.strMessage
			, L.strSource
			, D.strFileName
			, D.strFileExtension
		FROM tblTRImportAttachment L 
		INNER JOIN tblTRImportAttachmentDetail D ON D.intImportAttachmentId = L.intImportAttachmentId
		WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 1

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportAttachmentDetailId, @strSupplier, @strBillOfLading, @dtmLoadDateTime, @ysnValid, @strMessage, @strSource, @strFileName, @strFileExtension
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- SUPLLIER / VENDOR
            DECLARE @intVendorId INT = NULL,
				@intSupplyPointId INT = NULL,
				@intVendorCompanyLocationId INT = NULL
			
			SELECT @intVendorId = CRB.intSupplierId, @intSupplyPointId = CRB.intSupplyPointId, @intVendorCompanyLocationId = CRB.intCompanyLocationId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Supplier' AND CRB.strImportValue = @strSupplier
			
			IF (@intVendorId IS NULL)
			BEGIN
				IF (@intVendorCompanyLocationId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Supplier')
				END
				ELSE
				BEGIN
					UPDATE tblTRImportAttachmentDetail SET intVendorCompanyLocationId = @intVendorCompanyLocationId WHERE intImportAttachmentDetailId = @intImportAttachmentDetailId
				END
			END
			ELSE
			BEGIN
				IF(@intSupplyPointId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Supply Point')
				END
				ELSE
				BEGIN
					UPDATE tblTRImportAttachmentDetail SET intVendorId = @intVendorId, intSupplyPointId = @intSupplyPointId, intVendorCompanyLocationId = @intVendorCompanyLocationId WHERE intImportAttachmentDetailId = @intImportAttachmentDetailId
				END
			END

			IF(ISNULL(@strMessage, '') != '')
			BEGIN
				UPDATE tblTRImportAttachmentDetail SET strMessage = @strMessage, ysnValid = 0 WHERE intImportAttachmentDetailId = @intImportAttachmentDetailId 
			END	

			IF(@intVendorId IS NOT NULL AND @intSupplyPointId IS NOT NULL AND @intVendorCompanyLocationId IS NOT NULL AND ISNULL(@strMessage, '') = '')
			BEGIN

				DECLARE @intLoadHeaderId INT = NULL,
					@intAttachmentId INT = NULL,
					@attachmentErrorMessage NVARCHAR(MAX) = NULL,
					@strTransactionNumber NVARCHAR(100) = NULL,
					@intTransactionId INT = NULL,
					@ysnPosted BIT = NULL

				-- GET TRANSPORT LOAD THAT MATCHED THE IMAGE
				SELECT TOP 1 @intLoadHeaderId = L.intLoadHeaderId, @strTransactionNumber = L.strTransaction, @ysnPosted = L.ysnPosted
				FROM tblTRLoadHeader L INNER JOIN tblTRLoadReceipt R 
					ON R.intLoadHeaderId = L.intLoadHeaderId
				WHERE L.dtmLoadDateTime = @dtmLoadDateTime 
				AND R.intTerminalId = @intVendorId 
				AND R.intSupplyPointId = @intSupplyPointId 
				AND R.intCompanyLocationId = @intVendorCompanyLocationId
				AND R.strBillOfLading = @strBillOfLading

				IF(@intLoadHeaderId IS NOT NULL)
				BEGIN
					--CHECK IF HAS SAME FILE NAME ATTACH ON TR - IF EXISTS DONT ATTACH
					-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMAttachment WHERE strRecordNo = @intLoadHeaderId
					-- 	AND strScreen = 'Transports.view.TransportLoads'
					-- 	AND strName = @strFileName + @strFileExtension)
					-- BEGIN
					SELECT @intTransactionId = intTransactionId FROM tblSMTransaction a
					INNER JOIN tblSMScreen b ON a.intScreenId = b.intScreenId
					WHERE intRecordId = @intLoadHeaderId
						AND b.strNamespace = 'Transports.view.TransportLoads'

					EXEC [uspSMCreateAttachmentFromFile]   
						@transactionId = @intTransactionId												-- the intTransactionId
						,@fileName = @strFileName														-- file name
						,@fileExtension = @strFileExtension                                             -- extension
						,@filePath = @strFilePath														-- path
						,@screenNamespace = 'Transports.view.TransportLoads'                            -- screen type or namespace
						,@useDocumentWatcher = 0                                                        -- flag if the file was uploaded using document wacther
						,@throwError = 1
						,@attachmentId = @intAttachmentId OUTPUT
						,@error = @attachmentErrorMessage OUTPUT
					-- END

					--SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, @strTransactionNumber)	

					DECLARE @intInvoiceId INT = NULL,
						@intInvoiceTransactionId INT = NULL,
						@intInvoiceAttachmentId INT = NULL,
						@strInvoiceNumber NVARCHAR(100) = NULL,
						@strInvoiceId NVARCHAR(300) = NULL,
						@intInvoiceCount INT = NULL

					SELECT @intInvoiceCount = COUNT(DISTINCT ID.intInvoiceId)
						FROM tblTRLoadDistributionHeader DH INNER JOIN tblTRLoadHeader L ON L.intLoadHeaderId = DH.intLoadHeaderId
						INNER JOIN tblARInvoiceDetail ID ON ID.intInvoiceId = DH.intInvoiceId
						INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
						WHERE DH.intLoadHeaderId = @intLoadHeaderId
						AND ID.strBOLNumberDetail = @strBillOfLading

					IF(@intInvoiceCount = 1)
					BEGIN
						DECLARE @CursorInvoiceTran AS CURSOR
						SET @CursorInvoiceTran = CURSOR FAST_FORWARD FOR
							SELECT DISTINCT ID.intInvoiceId, strInvoiceNumber
							FROM tblTRLoadDistributionHeader DH INNER JOIN tblTRLoadHeader L ON L.intLoadHeaderId = DH.intLoadHeaderId
							INNER JOIN tblARInvoiceDetail ID ON ID.intInvoiceId = DH.intInvoiceId
							INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
							WHERE DH.intLoadHeaderId = @intLoadHeaderId
							AND ID.strBOLNumberDetail = @strBillOfLading

						OPEN @CursorInvoiceTran
						FETCH NEXT FROM @CursorInvoiceTran INTO @intInvoiceId, @strInvoiceNumber
						WHILE @@FETCH_STATUS = 0
						BEGIN
							--CHECK IF HAS SAME FILE NAME ATTACH ON SI - IF EXISTS DONT ATTACH
							IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMAttachment WHERE strRecordNo = @intInvoiceId
								AND strScreen = 'AccountsReceivable.view.Invoice'
								AND strName = @strFileName + @strFileExtension)
							BEGIN
								
								SELECT @intInvoiceTransactionId = intTransactionId FROM tblSMTransaction a
								INNER JOIN tblSMScreen b ON a.intScreenId = b.intScreenId
								WHERE intRecordId = @intInvoiceId
									AND b.strNamespace = 'AccountsReceivable.view.Invoice'

								EXEC [uspSMCreateAttachmentFromFile]   
									@transactionId = @intInvoiceTransactionId										-- the intTransactionId
									,@fileName = @strFileName														-- file name
									,@fileExtension = @strFileExtension                                             -- extension
									,@filePath = @strFilePath														-- path
									,@screenNamespace = 'AccountsReceivable.view.Invoice'                           -- screen type or namespace
									,@useDocumentWatcher = 0                                                        -- flag if the file was uploaded using document wacther
									,@throwError = 1
									,@attachmentId = @intInvoiceAttachmentId OUTPUT
									,@error = @attachmentErrorMessage OUTPUT
								
								--SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage,@strInvoiceNumber)		
							END
							
							SELECT @strInvoiceId = dbo.fnTRMessageConcat(@strInvoiceId,@intInvoiceId)

							FETCH NEXT FROM @CursorInvoiceTran INTO @intInvoiceId, @strInvoiceNumber
						END

						CLOSE @CursorInvoiceTran  
						DEALLOCATE @CursorInvoiceTran
					END
					ELSE IF(@intInvoiceCount > 1)
					BEGIN 
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage,'Multiple Distributions/Invoices')
					END
					ELSE
					BEGIN
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage,'SI not yet created or distributed to Bulk Plant')
					END

					UPDATE tblTRImportAttachmentDetail SET intLoadHeaderId = @intLoadHeaderId, strInvoiceId = @strInvoiceId, strMessage = @strMessage WHERE intImportAttachmentDetailId = @intImportAttachmentDetailId 
				END
				ELSE
				BEGIN
					UPDATE tblTRImportAttachmentDetail SET strMessage = 'Not matched to any existing Transport Load', ysnValid = 0 WHERE intImportAttachmentDetailId = @intImportAttachmentDetailId 
				END

			END

			FETCH NEXT FROM @CursorTran INTO @intImportAttachmentDetailId, @strSupplier, @strBillOfLading, @dtmLoadDateTime, @ysnValid, @strMessage, @strSource, @strFileName, @strFileExtension
		END

		CLOSE @CursorTran  
		DEALLOCATE @CursorTran

		COMMIT TRANSACTION

		SELECT @return = intImportAttachmentId FROM tblTRImportAttachment WHERE guidImportIdentifier = @guidImportIdentifier

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		)
	END CATCH

END