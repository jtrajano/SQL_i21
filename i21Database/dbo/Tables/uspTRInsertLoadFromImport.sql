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

AS

BEGIN
	
	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

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
					
			-- ADD ADJUSTMENT
			DECLARE @dblAdjustment DECIMAL(18,6) = NULL
				, @dblAdjustmentTolerance DECIMAL(18,6) = NULL
				, @intAdjAccountId INT = NULL
				, @intQtyToBill INT = 1

			SELECT TOP 1 @intAdjAccountId = intAdjustmentAccountId, @dblAdjustmentTolerance = dblAdjustmentTolerance FROM tblTRCompanyPreference

			SELECT @dblAdjustment = dblGrandTotal - @dblInvoiceAmount 
			FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF (@dblAdjustment < 0)
			BEGIN
				SET @intQtyToBill = -1
				SET @dblAdjustment = @dblAdjustment * -1
			END
			
			IF(@dblAdjustment > @dblAdjustmentTolerance AND @dblAdjustment > 0)
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

						IF( @dblAdjustment > 0)
						BEGIN
							DECLARE @VoucherPayable AS VoucherPayable
								, @VoucherDetailTax AS VoucherDetailTax
								, @errorAdjustment NVARCHAR(1000) = NULL

							IF (@intAdjAccountId IS NOT NULL) 
							BEGIN
								INSERT INTO @VoucherPayable (intTransactionType, intEntityVendorId, intAccountId, intBillId, dblCost,dblQuantityToBill)

								SELECT 	intTransactionType		= 1
									,intEntityVendorId			= @intEntityVendorId
									,intAccountId				= @intAdjAccountId
									,intBillId					= @intBillId
									,dblCost					= @dblAdjustment
									,dblQuantityToBill			= @intQtyToBill

								EXEC [dbo].[uspAPAddVoucherDetail] 
									@voucherDetails = @VoucherPayable
									,@voucherPayableTax = @VoucherDetailTax
									,@throwError = 0
									,@error = @errorAdjustment OUTPUT
								
								IF (@errorAdjustment IS NOT NULL)
								BEGIN	
									SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, @errorAdjustment)
								END
							END
						END

						-- ADD PAYMENT
						EXEC [dbo].[uspTRImportDtnVoucherPayment] 
							@intBillId = @intBillId
							, @intImportLoadId = @intImportLoadId
							, @intImportDtnDetailId = @intImportDtnDetailId

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
END