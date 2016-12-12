CREATE PROCEDURE [dbo].[uspTFUpgradeReportingComponentOutputDesigners]
	@ReportingComponentOutputDesigners TFReportingComponentOutputDesigners READONLY

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
	INTO	tblTFScheduleFields
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT RCOD.*, RC.intReportingComponentId FROM @ReportingComponentOutputDesigners RCOD
		LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = RCOD.strFormCode COLLATE Latin1_General_CI_AS
			AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = RCOD.strScheduleCode COLLATE Latin1_General_CI_AS
			AND RC.strType COLLATE Latin1_General_CI_AS = RCOD.strType COLLATE Latin1_General_CI_AS
	) AS SOURCE
		ON TARGET.intReportingComponentId = SOURCE.intReportingComponentId
			AND TARGET.strColumn = SOURCE.strColumn

	WHEN MATCHED THEN 
		UPDATE
		SET 
			intReportingComponentId	= SOURCE.intReportingComponentId
			, strColumn				= SOURCE.strColumn
			, strCaption			= SOURCE.strCaption
			, strFormat				= SOURCE.strFormat
			, strFooter				= SOURCE.strFooter
			, intWidth				= SOURCE.intWidth
	WHEN NOT MATCHED THEN 
		INSERT (
			intReportingComponentId
			, strColumn
			, strCaption
			, strFormat
			, strFooter
			, intWidth
		)
		VALUES (
			SOURCE.intReportingComponentId
			, SOURCE.strCaption
			, SOURCE.strColumn
			, SOURCE.strFormat
			, SOURCE.strFooter
			, SOURCE.intWidth
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