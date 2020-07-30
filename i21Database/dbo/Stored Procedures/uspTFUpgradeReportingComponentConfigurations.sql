CREATE PROCEDURE [dbo].[uspTFUpgradeReportingComponentConfigurations]
	@TaxAuthorityCode NVARCHAR(10),
	@ReportingComponentConfigurations TFReportingComponentConfigurations READONLY

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

	SELECT RCC.*, RC.intReportingComponentId
	INTO #tmpRCC
	FROM @ReportingComponentConfigurations RCC
	LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = RCC.strFormCode COLLATE Latin1_General_CI_AS
		AND ISNULL(RC.strScheduleCode, '') COLLATE Latin1_General_CI_AS = ISNULL(RCC.strScheduleCode, '') COLLATE Latin1_General_CI_AS
		AND ISNULL(RC.strType, '') COLLATE Latin1_General_CI_AS = ISNULL(RCC.strType, '') COLLATE Latin1_General_CI_AS
	WHERE RC.intTaxAuthorityId = @TaxAuthorityId

	MERGE	
	INTO	tblTFReportingComponentConfiguration
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM #tmpRCC
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId
	WHEN MATCHED THEN 
		UPDATE
		SET 
			intReportingComponentId		= SOURCE.intReportingComponentId
			, strTemplateItemId			= SOURCE.strTemplateItemId
			, strReportSection			= SOURCE.strReportSection
			, intReportItemSequence		= SOURCE.intReportItemSequence
			, intTemplateItemNumber		= SOURCE.intTemplateItemNumber
			, strDescription			= SOURCE.strDescription
			, strScheduleCode			= SOURCE.strScheduleList
			, ysnConfiguration			= SOURCE.ysnConfiguration
			, ysnUserDefinedValue		= SOURCE.ysnUserDefinedValue
			, strConfiguration			= CASE WHEN SOURCE.ysnUserDefinedValue = 0 THEN SOURCE.strConfiguration ELSE TARGET.strConfiguration END
			, strLastIndexOf			= SOURCE.strLastIndexOf
			, strSegment				= SOURCE.strSegment
			, intConfigurationSequence	= SOURCE.intSort
			, ysnOutputDesigner			= SOURCE.ysnOutputDesigner
			, strInputType				= SOURCE.strInputType
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intReportingComponentId
			, strTemplateItemId
			, strReportSection
			, intReportItemSequence
			, intTemplateItemNumber
			, strDescription
			, strScheduleCode
			, strConfiguration
			, ysnConfiguration
			, ysnUserDefinedValue
			, strLastIndexOf
			, strSegment
			, intConfigurationSequence
			, ysnOutputDesigner	
			, strInputType
			, intMasterId
		)
		VALUES (
			SOURCE.intReportingComponentId
			, SOURCE.strTemplateItemId
			, SOURCE.strReportSection
			, SOURCE.intReportItemSequence
			, SOURCE.intTemplateItemNumber
			, SOURCE.strDescription
			, SOURCE.strScheduleList
			, SOURCE.strConfiguration
			, SOURCE.ysnConfiguration
			, SOURCE.ysnUserDefinedValue
			, SOURCE.strLastIndexOf
			, SOURCE.strSegment
			, SOURCE.intSort
			, SOURCE.ysnOutputDesigner
			, SOURCE.strInputType
			, SOURCE.intMasterId
		);
	
	-- Set insMasterId to 0 for records that are not exist in default data
	DELETE tblTFReportingComponentConfiguration
	WHERE intMasterId NOT IN (SELECT intMasterId FROM #tmpRCC)
	AND intReportingComponentId IN (SELECT intReportingComponentId FROM tblTFReportingComponent WHERE intTaxAuthorityId = @TaxAuthorityId)

	DROP TABLE #tmpRCC

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