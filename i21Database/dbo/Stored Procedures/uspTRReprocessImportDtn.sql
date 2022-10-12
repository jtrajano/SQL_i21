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

		DECLARE @CursorTran AS CURSOR
		SET @CursorTran = CURSOR FOR
		SELECT  DD.intImportDtnDetailId,  
			DD.intInventoryReceiptId,
			DD.intTermId,
			DD.strInvoiceNo,
			DD.dtmDueDate,
			DD.dblInvoiceAmount,
			DD.intEntityVendorId,
			DD.intImportDtnId
		FROM tblTRImportDtnDetail DD
		WHERE DD.intImportDtnDetailId IN (SELECT Item FROM #tmpIds)

		DECLARE @intImportDtnDetailId INT = NULL,
			@intInventoryReceiptId INT = NULL,
			@intTermId INT = NULL,
			@strInvoiceNo NVARCHAR(100) = NULL,
			@dtmDueDate DATETIME = NULL,
			@dblInvoiceAmount DECIMAL(18,6) = NULL,
			@intEntityVendorId INT = NULL,
			@intImportLoadId INT = NULL
	
		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate, @dblInvoiceAmount, @intEntityVendorId, @intImportLoadId
		WHILE @@FETCH_STATUS = 0
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
				, @ysnOverrideTolerance = 1

			FETCH NEXT FROM @CursorTran INTO @intImportDtnDetailId, @intInventoryReceiptId, @intTermId, @strInvoiceNo, @dtmDueDate, @dblInvoiceAmount, @intEntityVendorId, @intImportLoadId
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