CREATE PROCEDURE [dbo].[uspTFUpgradeReportingComponents]
	@TaxAuthorityCode NVARCHAR(10),
	@ReportingComponent TFReportingComponent READONLY

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

	DECLARE @TaxAuthorityId INT
	SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode
	IF (ISNULL(@TaxAuthorityId, 0) = 0)
	BEGIN
		RAISERROR('Tax Authority code does not exist.', 16, 1)
	END
	
	MERGE	
	INTO	tblTFReportingComponent
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @ReportingComponent
	) AS SOURCE
		ON TARGET.strFormCode COLLATE Latin1_General_CI_AS = SOURCE.strFormCode COLLATE Latin1_General_CI_AS
			AND TARGET.strScheduleCode COLLATE Latin1_General_CI_AS = SOURCE.strScheduleCode COLLATE Latin1_General_CI_AS
			AND TARGET.strType COLLATE Latin1_General_CI_AS = SOURCE.strType COLLATE Latin1_General_CI_AS
			AND TARGET.intTaxAuthorityId = @TaxAuthorityId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			strFormName				= SOURCE.strFormName
			, strScheduleName		= SOURCE.strScheduleName
			, strNote				= SOURCE.strNote
			, strTransactionType	= SOURCE.strTransactionType
			, intPositionId			= SOURCE.intPositionId
			, strSPInventory		= SOURCE.strSPInventory
			, strSPInvoice			= SOURCE.strSPInvoice
			, strSPRunReport		= SOURCE.strSPRunReport
	WHEN NOT MATCHED THEN 
		INSERT (
			intTaxAuthorityId
			, strFormCode
			, strFormName
			, strScheduleCode
			, strScheduleName
			, strType
			, strNote
			, strTransactionType
			, intPositionId
			, strSPInventory
			, strSPInvoice
			, strSPRunReport
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strFormCode
			, SOURCE.strFormName
			, SOURCE.strScheduleCode
			, SOURCE.strScheduleName
			, SOURCE.strType
			, SOURCE.strNote
			, SOURCE.strTransactionType
			, SOURCE.intPositionId
			, SOURCE.strSPInventory
			, SOURCE.strSPInvoice
			, SOURCE.strSPRunReport
		);
	
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