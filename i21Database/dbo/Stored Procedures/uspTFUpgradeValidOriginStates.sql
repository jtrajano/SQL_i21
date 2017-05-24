CREATE PROCEDURE [dbo].[uspTFUpgradeValidOriginStates]
	@TaxAuthorityCode NVARCHAR(10),
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

	DECLARE @TaxAuthorityId INT
	SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode
	IF (ISNULL(@TaxAuthorityId, 0) = 0)
	BEGIN
		RAISERROR('Tax Authority code does not exist.', 16, 1)
	END

	SELECT VOS.*, ODS.intOriginDestinationStateId, RC.intReportingComponentId
	INTO #tmpVOS
	FROM @ValidOriginStates VOS
	LEFT JOIN tblTFOriginDestinationState ODS ON ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS = VOS.strState COLLATE Latin1_General_CI_AS
	LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = VOS.strFormCode COLLATE Latin1_General_CI_AS
		AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = VOS.strScheduleCode COLLATE Latin1_General_CI_AS
		AND RC.strType COLLATE Latin1_General_CI_AS = VOS.strType COLLATE Latin1_General_CI_AS

	UPDATE tblTFReportingComponentOriginState
	SET tblTFReportingComponentOriginState.intMasterId = Source.intMasterId
	FROM #tmpVOS Source
	WHERE tblTFReportingComponentOriginState.intOriginDestinationStateId = Source.intOriginDestinationStateId
		AND tblTFReportingComponentOriginState.intReportingComponentId = Source.intReportingComponentId
		AND ISNULL(tblTFReportingComponentOriginState.intMasterId, '') = ''

	MERGE	
	INTO	tblTFReportingComponentOriginState
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM #tmpVOS
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

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
			, intMasterId
		)
		VALUES (
			SOURCE.intReportingComponentId
			, SOURCE.intOriginDestinationStateId
			, SOURCE.strStatus
			, SOURCE.intMasterId
		);

	-- Delete existing Valid Origin States that is not within Source
	DELETE FROM tblTFReportingComponentOriginState
	WHERE intReportingComponentOriginStateId IN (
		SELECT DISTINCT RCOrigin.intReportingComponentOriginStateId FROM tblTFReportingComponentOriginState RCOrigin
		LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCOrigin.intReportingComponentId
		LEFT JOIN #tmpVOS tmp ON tmp.intReportingComponentId = RCOrigin.intReportingComponentId
			AND tmp.intOriginDestinationStateId = RCOrigin.intOriginDestinationStateId
		WHERE RC.intTaxAuthorityId = @TaxAuthorityId
			AND ISNULL(tmp.intOriginDestinationStateId, '') = ''
	)

	DROP TABLE #tmpVOS

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