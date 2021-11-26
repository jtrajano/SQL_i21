CREATE PROCEDURE [dbo].[uspTRProcessImportDtn]
	@intImportLoadId INT,
	@intUserId INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

		
	BEGIN TRY

		DECLARE @CursorTran AS CURSOR
		SET @CursorTran = CURSOR FOR
		SELECT  DD.intImportDtnDetailId,  
			DD.intInventoryReceiptId,
			DD.intTermId,
			DD.strInvoiceNo,
			DD.dtmDueDate
		FROM tblTRImportDtnDetail DD WHERE DD.ysnValid = 1 AND DD.intImportDtnId = @intImportLoadId

		DECLARE @intImportDtnDetailId INT = NULL,
			@intInventoryReceiptId INT = NULL,
			@intTermId INT = NULL,
			@strInvoiceNo NVARCHAR(100) = NULL,
			@dtmDueDate DATETIME = NULL
	
		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate
		WHILE @@FETCH_STATUS = 0
		BEGIN

			BEGIN TRANSACTION

			BEGIN TRY

				DECLARE @strMessage NVARCHAR(MAX) = NULL

				IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId AND ysnPosted = 1)
				BEGIN

					DECLARE @intBillId INT = NULL
					DECLARE @strBillId NVARCHAR(MAX) = NULL
					DECLARE @voucherItem AS VoucherPayable
					DECLARE @intExistBillId INT = NULL

					SELECT @intExistBillId = intBillId FROM tblAPBillDetail BD 
						INNER JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
						WHERE RI.intInventoryReceiptId = @intInventoryReceiptId

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
								SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher is not created')
							END
						END

					END
					ELSE
					BEGIN
						SET @intBillId = @intExistBillId
						UPDATE tblTRImportDtnDetail SET intBillId = @intExistBillId WHERE intImportDtnDetailId = @intImportDtnDetailId
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher already exists')
					END

					IF(@intBillId IS NOT NULL)
					BEGIN
						IF EXISTS(SELECT TOP 1 1 FROM tblAPBill WHERE intBillId = @intBillId AND ysnPosted = 0)
						BEGIN
						-- ADD PAYMENT
							EXEC [dbo].[uspTRImportDtnVoucherPayment] 
								@intBillId = @intBillId,
								@intImportLoadId = @intImportLoadId,
								@intImportDtnDetailId = @intImportDtnDetailId

						--TR-1730
							UPDATE tblAPBill SET strVendorOrderNumber = @strInvoiceNo where intBillId = @intBillId
						END
					END

					-- POST VOUCHER
					DECLARE @success BIT = NULL

					IF (@intBillId IS NOT NULL)
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
							SELECT @strMessage = dbo.fnTRStringConcat(@strMessage, 'Voucher cannot be posted', ' / ')
							SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
						END CATCH

						IF (@success = 0)
						BEGIN
							SELECT @strMessage = dbo.fnTRStringConcat(@strMessage, 'Voucher cannot be posted', ' / ')
							SELECT TOP 1 dbo.fnTRMessageConcat(@strMessage,strMessage) FROM tblAPPostResult WHERE intTransactionId = @intBillId ORDER BY intId DESC
						END
						ELSE
						BEGIN
							SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher successfully posted')
						END
					END
					
				END
				ELSE
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Does not match to any Inventory Receipt')
				END

				IF(@intBillId IS NOT NULL)
				BEGIN
					UPDATE tblTRImportDtnDetail SET intBillId = @intBillId WHERE intImportDtnDetailId = @intImportDtnDetailId
				END

				IF(ISNULL(@strMessage, '') != '')
				BEGIN
					UPDATE tblTRImportDtnDetail SET strMessage = @strMessage WHERE intImportDtnDetailId = @intImportDtnDetailId 
				END	

				IF @@TRANCOUNT > 0 COMMIT TRANSACTION

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
				SELECT @ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE()
				RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
			END CATCH

			FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate
		END
		CLOSE @CursorTran  
		DEALLOCATE @CursorTran

	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		)
	END CATCH

END