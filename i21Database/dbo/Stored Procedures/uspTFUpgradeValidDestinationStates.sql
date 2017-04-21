CREATE PROCEDURE [dbo].[uspTFUpgradeValidDestinationStates]
	@TaxAuthorityCode NVARCHAR(10),
	@ValidDestinationStates TFValidDestinationStates READONLY

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

	SELECT VDS.*, ODS.intOriginDestinationStateId, RC.intReportingComponentId
	INTO #tmpVDS
	FROM @ValidDestinationStates VDS
	LEFT JOIN tblTFOriginDestinationState ODS ON ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS = VDS.strState COLLATE Latin1_General_CI_AS
	LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = VDS.strFormCode COLLATE Latin1_General_CI_AS
		AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = VDS.strScheduleCode COLLATE Latin1_General_CI_AS
		AND RC.strType COLLATE Latin1_General_CI_AS = VDS.strType COLLATE Latin1_General_CI_AS

	MERGE	
	INTO	tblTFReportingComponentDestinationState
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM #tmpVDS
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
		);

	-- Delete existing Valid Destination States that is not within Source
	DELETE FROM tblTFReportingComponentDestinationState
	WHERE intReportingComponentDestinationStateId IN (
		SELECT DISTINCT RCDestination.intReportingComponentDestinationStateId FROM tblTFReportingComponentDestinationState RCDestination
		LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCDestination.intReportingComponentId
		LEFT JOIN #tmpVDS tmp ON tmp.intReportingComponentId = RCDestination.intReportingComponentId
			AND tmp.intOriginDestinationStateId = RCDestination.intOriginDestinationStateId
		WHERE RC.intTaxAuthorityId = @TaxAuthorityId
			AND ISNULL(tmp.intOriginDestinationStateId, '') = ''
	)

	DROP TABLE #tmpVDS

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