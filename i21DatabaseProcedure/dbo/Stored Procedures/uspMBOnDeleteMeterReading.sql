CREATE PROCEDURE [dbo].[uspMBOnDeleteMeterReading]
	@MeterReadingId INT,
	@UserId INT
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

	DECLARE @InvoiceId INT
	SELECT TOP 1 @InvoiceId =  intInvoiceId FROM tblARInvoice
	WHERE intMeterReadingId = @MeterReadingId

	UPDATE tblARInvoice
	SET intMeterReadingId = NULL
		, intConcurrencyId	= intConcurrencyId + 1
	WHERE intInvoiceId = @InvoiceId
		AND ISNULL(ysnPosted, 0) <> 1

	/*Update the tblMBMeterReading > intInvoiceId=null to delete the Invoice (coz this will cause constraint error)*/
	update tblMBMeterReading
	set intInvoiceId = null
	where intMeterReadingId = @MeterReadingId

	EXEC uspARDeleteInvoice @InvoiceId, @UserId

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