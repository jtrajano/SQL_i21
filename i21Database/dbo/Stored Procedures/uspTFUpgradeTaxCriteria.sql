CREATE PROCEDURE [dbo].[uspTFUpgradeTaxCriteria]
	@TaxAuthorityCode NVARCHAR(10),
	@TaxCriteria TFTaxCriteria READONLY

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
	INTO	tblTFReportingComponentCriteria
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT TaxCrit.*, TaxCat.intTaxCategoryId, RC.intReportingComponentId FROM @TaxCriteria TaxCrit
		LEFT JOIN tblTFTaxCategory TaxCat ON TaxCat.strTaxCategory COLLATE Latin1_General_CI_AS = TaxCrit.strTaxCategory COLLATE Latin1_General_CI_AS
			AND TaxCat.strState COLLATE Latin1_General_CI_AS = TaxCrit.strState COLLATE Latin1_General_CI_AS
		LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = TaxCrit.strFormCode COLLATE Latin1_General_CI_AS
			AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = TaxCrit.strScheduleCode COLLATE Latin1_General_CI_AS
			AND RC.strType COLLATE Latin1_General_CI_AS = TaxCrit.strType COLLATE Latin1_General_CI_AS

	) AS SOURCE
		ON TARGET.intTaxCategoryId = SOURCE.intTaxCategoryId
			AND TARGET.intReportingComponentId = SOURCE.intReportingComponentId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			intTaxCategoryId	= SOURCE.intTaxCategoryId
			, intReportingComponentId	= SOURCE.intReportingComponentId
			, strCriteria		= SOURCE.strCriteria
	WHEN NOT MATCHED THEN 
		INSERT (
			intTaxCategoryId
			, intReportingComponentId
			, strCriteria
		)
		VALUES (
			SOURCE.intTaxCategoryId
			, SOURCE.intReportingComponentId
			, SOURCE.strCriteria
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