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
	
	UPDATE tblTFReportingComponent 
    SET intMasterId = B.intMasterId 
    FROM @ReportingComponent B 
    WHERE tblTFReportingComponent.intTaxAuthorityId = @TaxAuthorityId
    AND tblTFReportingComponent.strFormCode COLLATE Latin1_General_CI_AS = B.strFormCode COLLATE Latin1_General_CI_AS
    AND tblTFReportingComponent.strScheduleCode COLLATE Latin1_General_CI_AS = B.strScheduleCode COLLATE Latin1_General_CI_AS
    AND tblTFReportingComponent.strType COLLATE Latin1_General_CI_AS = B.strType COLLATE Latin1_General_CI_AS
    AND tblTFReportingComponent.intMasterId IS NULL


	MERGE	
	INTO	tblTFReportingComponent
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @ReportingComponent
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			 strFormCode			= SOURCE.strFormCode
			, strFormName			= SOURCE.strFormName
			, strScheduleCode		= SOURCE.strScheduleCode
			, strScheduleName		= SOURCE.strScheduleName
			, strNote				= SOURCE.strNote
			, strType				= SOURCE.strType
			, strTransactionType	= SOURCE.strTransactionType
			, intSort				= SOURCE.intSort
			, strStoredProcedure	= SOURCE.strStoredProcedure
			, intComponentTypeId	= SOURCE.intComponentTypeId
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intTaxAuthorityId
			, strFormCode
			, strFormName
			, strScheduleCode
			, strScheduleName
			, strType
			, strNote
			, strTransactionType
			, intSort
			, strStoredProcedure
			, intMasterId
			, intComponentTypeId
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
			, SOURCE.intSort
			, SOURCE.strStoredProcedure
			, SOURCE.intMasterId
			, SOURCE.intComponentTypeId
		);

		-- Set insMasterId to 0 for records that are not exist in default data
		UPDATE tblTFReportingComponent 
		SET intMasterId = 0 
		WHERE intTaxAuthorityId = @TaxAuthorityId 
		AND intMasterId NOT IN (SELECT intMasterId FROM @ReportingComponent)
	
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