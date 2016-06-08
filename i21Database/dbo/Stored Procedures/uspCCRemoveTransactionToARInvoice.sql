CREATE PROCEDURE [dbo].[uspCCRemoveTransactionToARInvoice]
	 @invoiceIds		NVARCHAR(MAX) = NULL
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

	-- Unposting


	-- Delete AP Bill data
	IF(@invoiceIds IS NOT NULL)
	BEGIN
		DELETE tblARInvoice WHERE intInvoiceId IN (@invoiceIds)
	END
	
END TRY
BEGIN CATCH
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH