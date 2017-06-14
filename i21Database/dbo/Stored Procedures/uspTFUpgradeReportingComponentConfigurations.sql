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
		AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = RCC.strScheduleCode COLLATE Latin1_General_CI_AS
		AND RC.strType COLLATE Latin1_General_CI_AS = RCC.strType COLLATE Latin1_General_CI_AS
		AND RC.intTaxAuthorityId = @TaxAuthorityId

	UPDATE tblTFReportingComponentConfiguration
	SET tblTFReportingComponentConfiguration.intMasterId = Source.intMasterId
	FROM #tmpRCC Source
	WHERE tblTFReportingComponentConfiguration.intReportingComponentId = Source.intReportingComponentId
		AND tblTFReportingComponentConfiguration.strTemplateItemId COLLATE Latin1_General_CI_AS = Source.strTemplateItemId COLLATE Latin1_General_CI_AS
		AND ISNULL(tblTFReportingComponentConfiguration.intMasterId, '') = ''

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
			, ysnDynamicConfiguration	= SOURCE.ysnDynamicConfiguration
			, strLastIndexOf			= SOURCE.strLastIndexOf
			, strSegment				= SOURCE.strSegment
			, intConfigurationSequence	= SOURCE.intSort
	WHEN NOT MATCHED THEN 
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
			, ysnDynamicConfiguration
			, strLastIndexOf
			, strSegment
			, intConfigurationSequence
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
			, SOURCE.ysnDynamicConfiguration
			, SOURCE.strLastIndexOf
			, SOURCE.strSegment
			, SOURCE.intSort
			, SOURCE.intMasterId
		);

	
	-- Delete existing Reporting Component Configuration that is not within Source
	DELETE FROM tblTFReportingComponentConfiguration
	WHERE intReportingComponentConfigurationId IN (
		SELECT DISTINCT RCC.intReportingComponentConfigurationId FROM tblTFReportingComponentConfiguration RCC
		LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId
		LEFT JOIN #tmpRCC tmp ON tmp.intReportingComponentId = RCC.intReportingComponentId
			AND tmp.strTemplateItemId = RCC.strTemplateItemId
		WHERE RC.intTaxAuthorityId = @TaxAuthorityId
			AND ISNULL(tmp.strTemplateItemId, '') = ''
	)

	DELETE FROM tblTFReportingComponentConfiguration
	WHERE intMasterId IN (SELECT intMasterId 
						FROM tblTFReportingComponentConfiguration
						GROUP BY intMasterId
						HAVING COUNT(*) > 1)
		AND intReportingComponentConfigurationId NOT IN (SELECT MAX(intReportingComponentConfigurationId) intReportingComponentConfigurationId 
														FROM tblTFReportingComponentConfiguration
														GROUP BY intMasterId
														HAVING COUNT(*) > 1)

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