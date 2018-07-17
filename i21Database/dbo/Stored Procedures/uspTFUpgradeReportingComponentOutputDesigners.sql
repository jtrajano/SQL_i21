CREATE PROCEDURE [dbo].[uspTFUpgradeReportingComponentOutputDesigners]
	@TaxAuthorityCode NVARCHAR(10),
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
	
	DECLARE @TaxAuthorityId INT
	SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode
	IF (ISNULL(@TaxAuthorityId, 0) = 0)
	BEGIN
		RAISERROR('Tax Authority code does not exist.', 16, 1)
	END

	SELECT RCOD.*, RC.intReportingComponentId
	INTO #tmpRCOD
	FROM @ReportingComponentOutputDesigners RCOD
	LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = RCOD.strFormCode COLLATE Latin1_General_CI_AS
		AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = RCOD.strScheduleCode COLLATE Latin1_General_CI_AS
		AND RC.strType COLLATE Latin1_General_CI_AS = RCOD.strType COLLATE Latin1_General_CI_AS
	WHERE RC.intTaxAuthorityId = @TaxAuthorityId
	ORDER BY RCOD.intScheduleColumnId

	UPDATE tblTFReportingComponentField
	SET intReportingComponentId	= SOURCE.intReportingComponentId
		, strColumn				= SOURCE.strColumn
		, strCaption			= SOURCE.strCaption
		, strFormat				= SOURCE.strFormat
		, strFooter				= SOURCE.strFooter
		, intWidth				= SOURCE.intWidth
		, ysnFromConfiguration  = SOURCE.ysnFromConfiguration
	FROM #tmpRCOD SOURCE
	WHERE tblTFReportingComponentField.intMasterId = SOURCE.intMasterId
		
	INSERT INTO tblTFReportingComponentField(
		intReportingComponentId
		, strColumn
		, strCaption
		, strFormat
		, strFooter
		, intWidth
		, intMasterId
		, ysnFromConfiguration
	)
	SELECT SOURCE.intReportingComponentId
		, SOURCE.strColumn
		, SOURCE.strCaption
		, SOURCE.strFormat
		, SOURCE.strFooter
		, SOURCE.intWidth
		, SOURCE.intMasterId
		, SOURCE.ysnFromConfiguration
	FROM #tmpRCOD SOURCE
	LEFT JOIN tblTFReportingComponentField TARGET ON TARGET.intMasterId = SOURCE.intMasterId
	WHERE TARGET.intReportingComponentFieldId IS NULL
	ORDER BY SOURCE.intScheduleColumnId

	-- Set insMasterId to 0 for records that are not exist in default data
	DELETE tblTFReportingComponentField
	WHERE intMasterId NOT IN (SELECT intMasterId FROM #tmpRCOD)
	AND intReportingComponentId IN (SELECT intReportingComponentId FROM tblTFReportingComponent WHERE intTaxAuthorityId = @TaxAuthorityId)

	DROP TABLE #tmpRCOD

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