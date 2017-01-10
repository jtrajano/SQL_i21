CREATE PROCEDURE [dbo].[uspTFUpgradeValidOriginStates]
	@ValidOriginStates TFValidOriginStates READONLY

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
	INTO	tblTFReportingComponentOriginState
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT VOS.*, ODS.intOriginDestinationStateId, RC.intReportingComponentId FROM @ValidOriginStates VOS
		LEFT JOIN tblTFOriginDestinationState ODS ON ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS = VOS.strState COLLATE Latin1_General_CI_AS
		LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = VOS.strFormCode COLLATE Latin1_General_CI_AS
			AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = VOS.strScheduleCode COLLATE Latin1_General_CI_AS
			AND RC.strType COLLATE Latin1_General_CI_AS = VOS.strType COLLATE Latin1_General_CI_AS
	) AS SOURCE
		ON TARGET.intOriginDestinationStateId = SOURCE.intOriginDestinationStateId
			AND TARGET.intReportingComponentId = SOURCE.intReportingComponentId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			intReportingComponentId			= SOURCE.intReportingComponentId
			, intOriginDestinationStateId	= SOURCE.intOriginDestinationStateId
			, strType						= SOURCE.strStatus

	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intReportingComponentId
			, intOriginDestinationStateId
			, strType
		
		)
		VALUES (
			SOURCE.intReportingComponentId
			, SOURCE.intOriginDestinationStateId
			, SOURCE.strStatus
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