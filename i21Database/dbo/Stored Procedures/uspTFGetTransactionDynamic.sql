CREATE PROCEDURE [dbo].[uspTFGetTransactionDynamic]
	@ReportingComponentId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @TaxAuthorityCode NVARCHAR(100)

	SELECT TOP 1 @TaxAuthorityCode = strTaxAuthorityCode
	FROM vyuTFGetReportingComponent
	WHERE intReportingComponentId = @ReportingComponentId
	
	IF (ISNULL(@TaxAuthorityCode, '')) <> ''
	BEGIN
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransactionDynamic' + @TaxAuthorityCode)
		BEGIN
			DECLARE @QueryScript NVARCHAR(MAX) = 'SELECT * FROM tblTFTransactionDynamic' + @TaxAuthorityCode
			EXECUTE sp_executesql @QueryScript
		END
	END

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