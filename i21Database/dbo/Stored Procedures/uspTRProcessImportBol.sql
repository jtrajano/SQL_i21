CREATE PROCEDURE [dbo].[uspTRProcessImportBol]
	@intImportLoadId INT
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

		
		DECLARE @CursorTran AS CURSOR

		--SET @CursorTran = CURSOR FOR
		--SELECT D.intImportLoadDetailId
		--	, D.strTruck
		--	, D.strTerminal
		--	, D.strCarrier
		--	, D.strDriver
		--	, D.strTrailer
		--	, D.strSupplier
		--	, D.strDestination
		--	, D.strPullProduct
		--	, D.strDropProduct 
		--	, D.ysnValid
		--	, D.strMessage
		--FROM tblTRImportLoad L 
		--INNER JOIN tblTRImportLoadDetail D ON D.intImportLoadId = L.intImportLoadId
		--WHERE L.intImportLoadId = @intImportLoadId AND D.ysnValid = 1 


	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
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