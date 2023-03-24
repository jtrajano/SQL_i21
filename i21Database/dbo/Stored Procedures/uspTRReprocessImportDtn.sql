CREATE PROCEDURE [dbo].[uspTRReprocessImportDtn]
	@strIds NVARCHAR(MAX),
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

	SELECT *
	INTO #tmpIds
	FROM dbo.fnSplitStringWithTrim(@strIds, ',')
		
	BEGIN TRY

		UPDATE tblTRImportDtnDetail
		SET intEntityVendorId = tblPatch.intVendorId
		FROM (
			SELECT CR.intVendorId
				, ID.intEntityVendorId
				, ID.intImportDtnDetailId
			FROM tblTRImportDtnDetail ID
			LEFT JOIN tblTRCrossReferenceDtn CR ON CR.strImportValue = ID.strSeller AND CR.strType = 'Vendor'
			WHERE CR.intVendorId <> ID.intEntityVendorId
				AND ID.intImportDtnDetailId IN (SELECT Item FROM #tmpIds)
		) tblPatch
		WHERE tblTRImportDtnDetail.intImportDtnDetailId = tblPatch.intImportDtnDetailId

		DECLARE @CursorTran AS CURSOR
		SET @CursorTran = CURSOR FOR
		SELECT  DD.intImportDtnDetailId,  
			DD.intInventoryReceiptId,
			DD.intTermId,
			DD.strInvoiceNo,
			DD.dtmDueDate,
			DD.dblInvoiceAmount,
			DD.intEntityVendorId,
			DD.intImportDtnId,
			ysnOverrideTolerance = CASE WHEN DD.strMessage LIKE '%Variance is greater than allowed%' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
			DD.strBillOfLading
		FROM tblTRImportDtnDetail DD
		WHERE DD.intImportDtnDetailId IN (SELECT Item FROM #tmpIds)

		DECLARE @intImportDtnDetailId INT = NULL,
			@intInventoryReceiptId INT = NULL,
			@intTermId INT = NULL,
			@strInvoiceNo NVARCHAR(50) = NULL,
			@dtmDueDate DATETIME = NULL,
			@dblInvoiceAmount DECIMAL(18,6) = NULL,
			@intEntityVendorId INT = NULL,
			@intImportLoadId INT = NULL,
			@strBillOfLading NVARCHAR(50) = NULL,
			@ysnOverrideTolerance BIT = NULL
	
		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate, @dblInvoiceAmount, @intEntityVendorId, @intImportLoadId, @ysnOverrideTolerance, @strBillOfLading
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF (ISNULL(@intInventoryReceiptId, 0) <> 0)
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId)
				BEGIN
					UPDATE tblTRImportDtnDetail SET intInventoryReceiptId = NULL WHERE intImportDtnDetailId = @intImportDtnDetailId
				END
			END
			
			IF (ISNULL(@intInventoryReceiptId, 0) = 0) OR (ISNULL(@intEntityVendorId, 0) = 0)
			BEGIN
				DECLARE @intSellerId INT = NULL
					, @strSeller NVARCHAR(100) = NULL
					, @strBOL NVARCHAR(50) = NULL

				SELECT TOP 1 @strSeller = strSeller
					, @strBOL = strBillOfLading
				FROM tblTRImportDtnDetail
				WHERE intImportDtnDetailId = @intImportDtnDetailId

				IF (ISNULL(@intEntityVendorId, 0) = 0)
				BEGIN
					SELECT @intSellerId = V.intVendorId
					FROM vyuTRCrossReferenceDtn V
					WHERE V.intCrossReferenceId = 2
					AND V.strImportValue = @strSeller

					IF (ISNULL(@intSellerId, 0) <> 0)
					BEGIN
						UPDATE tblTRImportDtnDetail SET intEntityVendorId = @intSellerId WHERE intImportDtnDetailId = @intImportDtnDetailId
						SET @intEntityVendorId = @intSellerId
					END
				END

				IF (ISNULL(@intInventoryReceiptId, 0) = 0) AND (ISNULL(@intEntityVendorId, 0) <> 0)
				BEGIN
					DECLARE @ysnInventoryPosted BIT = NULL

					SELECT TOP 1 @intInventoryReceiptId = IR.intInventoryReceiptId
					FROM tblICInventoryReceipt IR
					WHERE IR.intEntityVendorId = @intEntityVendorId
						AND IR.strBillOfLading = @strBOL
						AND IR.intSourceType = 3
						AND IR.strReceiptType = 'Direct'

					IF (ISNULL(@intInventoryReceiptId, 0) <> 0)
					BEGIN
						UPDATE tblTRImportDtnDetail SET intInventoryReceiptId = @intInventoryReceiptId WHERE intImportDtnDetailId = @intImportDtnDetailId
					END					
				END
			END

			-- Handle previous successful duplicates
			IF EXISTS (SELECT TOP 1 1 FROM vyuTRGetImportDTNForReprocess
						WHERE strBillOfLading = @strBillOfLading
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
					, @ysnOverrideTolerance = @ysnOverrideTolerance
			END			

			FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate, @dblInvoiceAmount, @intEntityVendorId, @intImportLoadId, @ysnOverrideTolerance, @strBillOfLading
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