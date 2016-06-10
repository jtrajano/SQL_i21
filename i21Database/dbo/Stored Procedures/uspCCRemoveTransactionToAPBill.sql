CREATE PROCEDURE [dbo].[uspCCRemoveTransactionToAPBill]
	 @billId			INT = NULL
	,@userId			INT = NULL
	,@success			BIT = NULL OUTPUT
	,@errorMessage NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorSeverity INT,
		@ErrorNumber   INT,
		@ErrorState INT

BEGIN TRY
	IF (@billId IS NOT NULL)
	BEGIN
		-- Unposting
		EXEC [dbo].[uspAPPostBill]
				@post = 0,
				@recap = 0,
				@isBatch = 0,
				@param = @billId,
				@userId = @userId,
				@success = @success OUTPUT

		-- Delete AP Bill data
		DELETE tblAPBill WHERE intBillId = @billId
	END
	SET @success = 1
END TRY
BEGIN CATCH
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
