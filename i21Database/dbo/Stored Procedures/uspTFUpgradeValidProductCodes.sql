CREATE PROCEDURE [dbo].[uspTFUpgradeValidProductCodes]
	@ValidProductCodes TFValidProductCodes READONLY

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
	INTO	tblTFReportingComponentProductCode
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT VPC.*, PC.intProductCodeId, RC.intReportingComponentId FROM @ValidProductCodes VPC
		LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = VPC.strFormCode COLLATE Latin1_General_CI_AS
			AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = VPC.strScheduleCode COLLATE Latin1_General_CI_AS
			AND RC.strType COLLATE Latin1_General_CI_AS = VPC.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN tblTFProductCode PC ON PC.strProductCode COLLATE Latin1_General_CI_AS = VPC.strProductCode COLLATE Latin1_General_CI_AS
			AND PC.intTaxAuthorityId = RC.intTaxAuthorityId

	) AS SOURCE
		ON TARGET.intReportingComponentProductCodeId = SOURCE.intProductCodeId
			AND TARGET.intReportingComponentId = SOURCE.intReportingComponentId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			intReportingComponentId	= SOURCE.intReportingComponentId
			, intProductCodeId		= SOURCE.intProductCodeId
			, strType			= SOURCE.strFilter
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intReportingComponentId
			, intProductCodeId
			, strType
		)
		VALUES (
			SOURCE.intReportingComponentId
			, SOURCE.intProductCodeId
			, SOURCE.strType
		)
	WHEN NOT MATCHED BY SOURCE THEN 
		DELETE;

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