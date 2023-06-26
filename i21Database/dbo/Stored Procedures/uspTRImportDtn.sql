CREATE PROCEDURE [dbo].[uspTRImportDtn]
	@guidImportIdentifier UNIQUEIDENTIFIER,
    @intUserId INT,
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

		DECLARE @intImportDtnId INT,
			@intImportDtnDetailId INT = NULL,
			@strSeller NVARCHAR(200) = NULL,
			@strTerm NVARCHAR(100) = NULL,	
		    @ysnValid BIT = NULL,
			@strMessage NVARCHAR(MAX) = NULL
			
		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT D.intImportDtnId
			, D.intImportDtnDetailId
			, D.strSeller
			, D.strTerm
			, D.ysnValid
			, D.strMessage
		FROM tblTRImportDtn L 
		INNER JOIN tblTRImportDtnDetail D ON D.intImportDtnId = L.intImportDtnId
		WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 1 

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportDtnId, @intImportDtnDetailId, @strSeller, @strTerm, @ysnValid, @strMessage
		WHILE @@FETCH_STATUS = 0
		BEGIN		
			-- Vendor
			DECLARE @intSellerId INT = NULL
			SELECT @intSellerId = V.intVendorId
			FROM vyuTRCrossReferenceDtn V
			WHERE V.intCrossReferenceId = 2
			AND V.strImportValue = @strSeller

            IF (@intSellerId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Seller Name')	
			END
			ELSE
			BEGIN
				UPDATE tblTRImportDtnDetail SET intEntityVendorId = @intSellerId WHERE intImportDtnDetailId = @intImportDtnDetailId
			END

			IF(ISNULL(@strMessage, '') = '' AND @ysnValid = 1)
			BEGIN
				-- Related IR
				DECLARE @intInventoryReceiptId INT = NULL,
					@ysnInventoryPosted BIT = NULL
				SELECT @intInventoryReceiptId = IR.intInventoryReceiptId, @ysnInventoryPosted = IR.ysnPosted
				FROM tblTRImportDtnDetail DD
				INNER JOIN tblICInventoryReceipt IR ON IR.intEntityVendorId = DD.intEntityVendorId
					AND dbo.fnRemoveLeadingZero(IR.strBillOfLading) = dbo.fnRemoveLeadingZero(DD.strBillOfLading)
				WHERE DD.intImportDtnDetailId = @intImportDtnDetailId
					AND IR.intSourceType = 3
					AND IR.strReceiptType = 'Direct'

				IF (@intInventoryReceiptId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Does not match to any Inventory Receipt')	
				END
				ELSE IF (@intInventoryReceiptId IS NOT NULL AND @ysnInventoryPosted = 0)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Inventory Receipt is not posted')
					UPDATE tblTRImportDtnDetail SET intInventoryReceiptId = @intInventoryReceiptId WHERE intImportDtnDetailId = @intImportDtnDetailId
				END
				ELSE
				BEGIN
					UPDATE tblTRImportDtnDetail SET intInventoryReceiptId = @intInventoryReceiptId WHERE intImportDtnDetailId = @intImportDtnDetailId
				END
			END

            IF(@ysnValid = 1)
			BEGIN			
				IF(ISNULL(@strMessage, '') != '')
				BEGIN
					UPDATE tblTRImportDtnDetail SET strMessage = @strMessage, ysnValid = CASE WHEN @strMessage = 'Does not match to any Inventory Receipt' THEN 1 ELSE 0 END WHERE intImportDtnDetailId = @intImportDtnDetailId 
				END	
			END
			ELSE
			BEGIN
				UPDATE tblTRImportDtnDetail SET strMessage = @strMessage, ysnValid = CASE WHEN @strMessage = 'Does not match to any Inventory Receipt' THEN 1 ELSE 0 END WHERE intImportDtnDetailId = @intImportDtnDetailId 
			END

			FETCH NEXT FROM @CursorTran INTO @intImportDtnId, @intImportDtnDetailId, @strSeller, @strTerm, @ysnValid, @strMessage
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

		-- Call Import Processing right after loading
		EXEC uspTRProcessImportDtn @intImportLoadId = @intImportDtnId
			, @intUserId = @intUserId

		SELECT @return = intImportDtnId FROM tblTRImportDtn WHERE guidImportIdentifier = @guidImportIdentifier
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE()
			, @ErrorSeverity = ERROR_SEVERITY()
			, @ErrorState = ERROR_STATE();

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