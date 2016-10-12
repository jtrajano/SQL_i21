CREATE PROCEDURE [dbo].[uspMBOnDeleteMeterReading]
	@MeterReadingId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;


BEGIN TRY

	UPDATE tblARInvoice
	SET intMeterReadingId = NULL
		, intConcurrencyId	= intConcurrencyId + 1
	WHERE intMeterReadingId = @MeterReadingId
		AND ISNULL(ysnPosted, 0) <> 1

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
	);
END CATCH