CREATE PROCEDURE [dbo].[uspTRInsertLoadFromImport]
	@intImportLoadId INT
	, @intImportDtnDetailId INT
	, @intInventoryReceiptId INT
	, @intTermId INT
	, @strInvoiceNo NVARCHAR(50)
	, @dtmDueDate DATETIME
	, @dblInvoiceAmount NUMERIC(18, 6)
	, @intEntityVendorId INT
	, @intUserId INT
	, @strBillOfLading NVARCHAR(50)
	, @ysnOverrideTolerance BIT = 0

AS

BEGIN
	
	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	--BEGIN TRANSACTION
	
	BEGIN TRY
		DECLARE @strMessage NVARCHAR(MAX) = NULL

		IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId AND ysnPosted = 1)
		BEGIN

			DECLARE @intBillId INT = NULL
			DECLARE @strBillId NVARCHAR(MAX) = NULL
			DECLARE @voucherItem AS VoucherPayable
			DECLARE @intExistBillId INT = NULL

			SELECT TOP 1 @intExistBillId = BD.intBillId
			FROM tblAPBillDetail BD
			JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
			JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = RI.intInventoryReceiptId
			WHERE RI.intInventoryReceiptId = @intInventoryReceiptId
				AND IR.intEntityVendorId = Bill.intEntityVendorId				
					
			-- ADD ADJUSTMENT
			DECLARE @dblAdjustment DECIMAL(18,6) = NULL
				, @dblAdjustmentTolerance DECIMAL(18,6) = NULL
				, @intAdjAccountId INT = NULL
				, @intQtyToBill INT = 1

			SELECT TOP 1 @intAdjAccountId = intAdjustmentAccountId, @dblAdjustmentTolerance = ISNULL(dblAdjustmentTolerance, 0) FROM tblTRCompanyPreference

			SELECT @dblAdjustment = @dblInvoiceAmount - dblGrandTotal
			FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF (@dblAdjustment < 0)
			BEGIN
				SET @intQtyToBill = -1
				SET @dblAdjustment = @dblAdjustment * -1
			END
			
			IF (ISNULL(@intExistBillId, 0) <> 0)
			BEGIN
				SET @intBillId = @intExistBillId
				UPDATE tblTRImportDtnDetail SET intBillId = @intExistBillId WHERE intImportDtnDetailId = @intImportDtnDetailId
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher already exists')
			END
			ELSE IF (@dblAdjustment > @dblAdjustmentTolerance AND @dblAdjustment > 0) AND (@ysnOverrideTolerance = 0)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Variance is greater than allowed')
			END
			ELSE
			BEGIN
				-- CREATE VOUCHER		
				IF (@intExistBillId IS NULL)
				BEGIN			
					DECLARE @ysnVoucherSuccess BIT = 0
					BEGIN TRY

						EXEC [dbo].[uspICProcessToBill] 
							@intReceiptId = @intInventoryReceiptId
							,@intUserId = @intUserId
							,@intBillId = @intBillId OUTPUT
							,@strBillIds = @strBillId OUTPUT
							,@intScreenId = NULL

						SET @ysnVoucherSuccess = 1	

					END TRY
					BEGIN CATCH
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher is not created')
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
					END CATCH

					IF(@ysnVoucherSuccess = 1)
					BEGIN
						IF (@intBillId IS NULL)
						BEGIN
							IF (@dblAdjustment > @dblAdjustmentTolerance AND @dblAdjustment > 0)
							BEGIN
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Variance is greater than allowed')
							END
							SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher is not created')
						END
					END
				END

				DECLARE @ysnSuccessPayables BIT = 1
				IF(@intBillId IS NOT NULL)
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblAPBill WHERE intBillId = @intBillId AND ysnPosted = 0)
					BEGIN						
						IF( @dblAdjustment > 0)
						BEGIN
							DECLARE @VoucherPayable AS VoucherPayable
								, @VoucherDetailTax AS VoucherDetailTax
								, @errorAdjustment NVARCHAR(1000) = NULL

							INSERT INTO @VoucherPayable (intTransactionType, intEntityVendorId, intAccountId, intBillId, dblCost,dblQuantityToBill, dblOrderQty, ysnStage)
							SELECT 	intTransactionType		= 1
								,intEntityVendorId			= @intEntityVendorId
								,intAccountId				= @intAdjAccountId
								,intBillId					= @intBillId
								,dblCost					= @dblAdjustment
								,dblQuantityToBill			= @intQtyToBill
								,dblQtyOrdered				= @intQtyToBill
								,ysnStage					= 0

							BEGIN TRY
								EXEC [dbo].[uspAPAddVoucherDetail] 
									@voucherDetails = @VoucherPayable
									,@voucherPayableTax = @VoucherDetailTax
									,@throwError = 0
									,@error = @errorAdjustment OUTPUT
							END TRY
							BEGIN CATCH
								SET @ysnSuccessPayables = 0
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher Payable is not created')
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
							END CATCH
								
							IF (@errorAdjustment IS NOT NULL) AND (@ysnSuccessPayables = 1)
							BEGIN	
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, @errorAdjustment)
							END

						END

						IF (@ysnSuccessPayables = 1)
						BEGIN
							BEGIN TRY
								DECLARE @strErrMsg NVARCHAR(MAX)
								-- ADD PAYMENT
								EXEC [dbo].[uspTRImportDtnVoucherPayment] 
									@intBillId = @intBillId
									, @intImportLoadId = @intImportLoadId
									, @intImportDtnDetailId = @intImportDtnDetailId
									, @strErrMsg = @strErrMsg OUT

								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher Payable is not created')
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
							END TRY
							BEGIN CATCH
								SET @ysnSuccessPayables = 0
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher Payable is not created')
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
							END CATCH
						END						

						--TR-1730
						UPDATE tblAPBill SET strVendorOrderNumber = @strInvoiceNo where intBillId = @intBillId
					END
				END

				-- POST VOUCHER
				DECLARE @success BIT = NULL

				IF (@intBillId IS NOT NULL) AND (@ysnSuccessPayables = 1)
				BEGIN
					BEGIN TRY
						EXEC [dbo].[uspAPPostBill]
							@post = 1
							,@recap = 0
							,@isBatch = 0
							,@transactionType = 'Transport Load'
							,@param = @intBillId
							,@userId = @intUserId
							,@success = @success OUTPUT
					END TRY
					BEGIN CATCH
						SELECT @strMessage = dbo.fnTRStringConcat(@strMessage, 'Voucher create but not posted', ' / ')
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
					END CATCH

					IF (@success = 0)
					BEGIN
						SELECT @strMessage = dbo.fnTRStringConcat(@strMessage, 'Voucher create but not posted', ' / ')
						SELECT TOP 1 dbo.fnTRMessageConcat(@strMessage,strMessage) FROM tblAPPostResult WHERE intTransactionId = @intBillId ORDER BY intId DESC
					END
					ELSE
					BEGIN
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher successfully posted')
					END
				END
			END

			IF (@dblAdjustment <> 0) AND (ISNULL(@intBillId, 0) <> 0) AND (ISNULL(@intExistBillId, 0) = 0)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ' (With Variance)')
			END
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Inventory Receipt is not posted')
			END
			ELSE
			BEGIN
				DECLARE @BOL NVARCHAR(50)
				SELECT @BOL = strBillOfLading FROM tblTRImportDtnDetail WHERE intImportDtnDetailId = @intImportDtnDetailId

				IF EXISTS (
					SELECT TOP 1 1 FROM tblTRLoadReceipt lr
					JOIN tblTRLoadHeader lh ON lh.intLoadHeaderId = lr.intLoadHeaderId
					WHERE lr.intTerminalId = @intEntityVendorId
						AND dbo.fnRemoveLeadingZero(lr.strBillOfLading) = dbo.fnRemoveLeadingZero(@BOL)
						AND ISNULL(lh.ysnPosted, 0) = 0)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Transport Load is not posted')
				END
				ELSE
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Does not match to any Inventory Receipt')
				END
			END			
		END

		IF(@intBillId IS NOT NULL)
		BEGIN
			UPDATE tblTRImportDtnDetail
			SET intBillId = @intBillId
			WHERE intImportDtnDetailId = @intImportDtnDetailId
		END

		DECLARE @ysnValid BIT = 0
		SELECT @ysnValid = CASE WHEN @strMessage LIKE '%Voucher successfully posted%' OR @strMessage LIKE '%Voucher create but not posted%' THEN 1
								WHEN ISNULL(@strMessage, '') = '' THEN 1
								ELSE 0 END

		UPDATE tblTRImportDtnDetail
		SET strMessage = @strMessage + CASE WHEN @ysnOverrideTolerance = 1 THEN ' (Reprocess)' ELSE '' END
			, ysnValid = @ysnValid
		WHERE intImportDtnDetailId = @intImportDtnDetailId

		IF NOT EXISTS(SELECT TOP 1 1 FROM vyuTRGetImportDTNForReprocess WHERE dbo.fnRemoveLeadingZero(strBillOfLading) = dbo.fnRemoveLeadingZero(@strBillOfLading) AND ISNULL(ysnSuccess, 0) = 1)
		BEGIN
			DECLARE @maxValue NUMERIC(18, 6)
				, @intPreviousId INT

			SELECT TOP 1 @maxValue = dblInvoiceAmount, @intPreviousId = intImportDtnDetailId FROM tblTRImportDtnDetail WHERE ISNULL(ysnReImport, 0) = 0 AND dbo.fnRemoveLeadingZero(strBillOfLading) = dbo.fnRemoveLeadingZero(@strBillOfLading) AND intImportDtnDetailId <> @intImportDtnDetailId

			IF (ISNULL(@intPreviousId, 0) = 0)
			BEGIN
				UPDATE tblTRImportDtnDetail
				SET ysnReImport = 0
				WHERE intImportDtnDetailId = @intImportDtnDetailId
			END
			ELSE IF (ISNULL(@dblInvoiceAmount, 0) >= ISNULL(@maxValue, 0))
			BEGIN
				UPDATE tblTRImportDtnDetail
				SET ysnReImport = CASE WHEN intImportDtnDetailId = @intImportDtnDetailId THEN 0 ELSE 1 END
				WHERE intImportDtnDetailId IN (@intImportDtnDetailId, @intPreviousId)

				UPDATE tblTRImportDtnDetail
				SET ysnReImport = 1
				WHERE intImportDtnDetailId NOT IN (@intImportDtnDetailId, @intPreviousId)
					AND strBillOfLading = @strBillOfLading
			END
			ELSE
			BEGIN
				UPDATE tblTRImportDtnDetail
				SET ysnReImport = 1
				WHERE intImportDtnDetailId = @intImportDtnDetailId
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTRImportDtnDetail WHERE dbo.fnRemoveLeadingZero(strBillOfLading) = dbo.fnRemoveLeadingZero(@strBillOfLading) AND ISNULL(ysnReImport, 0) = 0)
		BEGIN
			UPDATE tblTRImportDtnDetail
			SET ysnReImport = 0
			WHERE intImportDtnDetailId = @intImportDtnDetailId
		END

		--UPDATE tblTRImportDtnDetail
		--SET ysnReImport = 1
		--WHERE intImportDtnDetailId IN (
		--	SELECT intImportDtnDetailId FROM vyuTRGetImportDTNForReprocess
		--	WHERE strBillOfLading = @strBillOfLading
		--		AND intImportDtnDetailId <> @intImportDtnDetailId
		--		AND ISNULL(ysnSuccess, 0) = 0)		

		--IF @@TRANCOUNT > 0 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE()

		UPDATE tblTRImportDtnDetail
		SET ysnValid = 0
			, strMessage = ERROR_MESSAGE()
		WHERE intImportDtnDetailId = @intImportDtnDetailId

		--RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END