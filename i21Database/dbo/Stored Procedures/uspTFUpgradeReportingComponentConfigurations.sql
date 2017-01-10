CREATE PROCEDURE [dbo].[uspTFUpgradeReportingComponentConfigurations]
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

	MERGE	
	INTO	tblTFReportingComponentConfiguration
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT RCC.*, RC.intReportingComponentId FROM @ReportingComponentConfigurations RCC
		LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = RCC.strFormCode COLLATE Latin1_General_CI_AS
			AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = RCC.strScheduleCode COLLATE Latin1_General_CI_AS
			AND RC.strType COLLATE Latin1_General_CI_AS = RCC.strType COLLATE Latin1_General_CI_AS
	) AS SOURCE
		ON TARGET.strTemplateItemId = SOURCE.strTemplateItemId

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
			, strConfiguration			= SOURCE.strConfiguration
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