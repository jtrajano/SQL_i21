CREATE PROCEDURE [dbo].[uspCCRemoveTransactionToCMBankTransaction]
	@intBankTransactionId	INT = NULL
	,@success				BIT = NULL OUTPUT
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


	-- Delete CM BankTransaction data
	IF(@intBankTransactionId IS NOT NULL)
	BEGIN
		DELETE tblCMBankTransaction WHERE intTransactionId = @intBankTransactionId
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
