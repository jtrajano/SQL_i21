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
			DECLARE @strMessage NVARCHAR(MAX) = NULL
				

			IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId AND ysnPosted = 1)
			BEGIN
				--uspICProcessToBill 
				DECLARE @intBillId INT = NULL
				DECLARE @strBillId NVARCHAR(MAX) = NULL
				DECLARE @voucherItem AS VoucherPayable

				BEGIN TRY 
					
					-- CREATE VOUCHER
					EXEC [dbo].[uspICConvertReceiptToVoucher] 
					   @intReceiptId = @intInventoryReceiptId
					  ,@intEntityUserSecurityId = @intUserId
					  ,@intBillId = @intBillId OUTPUT
					  ,@strBillIds = @strBillId OUTPUT
					  ,@intScreenId = NULL
					-- Need to wait for additional parameter to override the other fields
					

					IF (@intBillId IS NOT NULL)
					BEGIN
						UPDATE tblTRImportDtnDetail SET intBillId = @intBillId WHERE intImportDtnDetailId = @intImportDtnDetailId
						DECLARE @strVoucherNo NVARCHAR(100)
						SELECT @strVoucherNo = strBillId FROM tblAPBill WHERE intBillId = intBillId
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, @strVoucherNo + ' - Voucher successfully created')
					END
					ELSE
					BEGIN
						SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Voucher cannot created')
					END

				END TRY
				BEGIN CATCH
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, ERROR_MESSAGE())
				END CATCH

			END
			ELSE
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Has no valid Inventory Receipt')
			END

			IF(ISNULL(@strMessage, '') != '')
			BEGIN
				UPDATE tblTRImportDtnDetail SET strMessage = @strMessage WHERE intImportDtnDetailId = @intImportDtnDetailId 
			END	

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