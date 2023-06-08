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
			DD.dtmDueDate,
			DD.dblInvoiceAmount,
			DD.intEntityVendorId,
			DD.strBillOfLading
		FROM tblTRImportDtnDetail DD WHERE DD.ysnValid = 1 AND DD.intImportDtnId = @intImportLoadId

		DECLARE @intImportDtnDetailId INT = NULL,
			@intInventoryReceiptId INT = NULL,
			@intTermId INT = NULL,
			@strInvoiceNo NVARCHAR(50) = NULL,
			@dtmDueDate DATETIME = NULL,
			@dblInvoiceAmount DECIMAL(18,6) = NULL,
			@intEntityVendorId INT = NULL,
			@strBillOfLading NVARCHAR(50) = NULL
	
		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate, @dblInvoiceAmount, @intEntityVendorId, @strBillOfLading
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Handle previous successful duplicates
			IF EXISTS (SELECT TOP 1 1 FROM vyuTRGetImportDTNForReprocess
						WHERE dbo.fnRemoveLeadingZero(strBillOfLading) = dbo.fnRemoveLeadingZero(@strBillOfLading)
							AND intImportDtnDetailId <> @intImportDtnDetailId
							AND ysnSuccess = 1)
			BEGIN
				UPDATE tblTRImportDtnDetail
				SET ysnReImport = 1
					, ysnValid = 0
					, strMessage = 'Bill of Lading has been previously processed.'
				WHERE intImportDtnDetailId = @intImportDtnDetailId
			END
			ELSE
			BEGIN
				EXEC uspTRInsertLoadFromImport 
					@intImportLoadId = @intImportLoadId
					, @intImportDtnDetailId = @intImportDtnDetailId
					, @intInventoryReceiptId = @intInventoryReceiptId
					, @intTermId = @intTermId
					, @strInvoiceNo = @strInvoiceNo
					, @dtmDueDate = @dtmDueDate
					, @dblInvoiceAmount = @dblInvoiceAmount
					, @intEntityVendorId = @intEntityVendorId
					, @intUserId = @intUserId
					, @strBillOfLading = @strBillOfLading
					, @ysnOverrideTolerance = 0
			END

			FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate, @dblInvoiceAmount, @intEntityVendorId, @strBillOfLading
		END
		CLOSE @CursorTran  
		DEALLOCATE @CursorTran

		--IF EXISTS (SELECT TOP 1 1 FROM vyuTRGetImportDTNForReprocess id
		--			WHERE intImportDtnId <> @intImportLoadId
		--				AND ISNULL(ysnSuccess, 0) = 0
		--				AND ISNULL(ysnVarianceIssue, 0) = 0
		--				AND ISNULL(ysnException, 0) = 0)
		--BEGIN
		--	DECLARE	@strIds AS NVARCHAR(MAX)
		--	SELECT @strIds = STUFF((SELECT DISTINCT ', ' + LTRIM(id.intImportDtnDetailId)
		--							FROM vyuTRGetImportDTNForReprocess id
		--							WHERE intImportDtnId <> @intImportLoadId
		--								AND ISNULL(id.ysnSuccess, 0) = 0
		--								AND ISNULL(id.ysnVarianceIssue, 0) = 0
		--								AND ISNULL(id.ysnException, 0) = 0
		--							FOR XML PATH('')
		--						),1,2, '')

		--	EXEC uspTRReprocessImportDtn @strIds, @intUserId
		--END
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