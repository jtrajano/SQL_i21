CREATE PROCEDURE [dbo].[uspTFUpgradeOriginDestinationState]
	@OriginDestinationStates TFOriginDestinationStates READONLY

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

	UPDATE tblTFOriginDestinationState
	SET intMasterId = B.intMasterId
	FROM @OriginDestinationStates B
    WHERE tblTFOriginDestinationState.intMasterId IS NULL
	AND tblTFOriginDestinationState.strOriginDestinationState COLLATE Latin1_General_CI_AS = B.strOriginDestinationState COLLATE Latin1_General_CI_AS

	MERGE	
	INTO	tblTFOriginDestinationState
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @OriginDestinationStates
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId
	WHEN MATCHED THEN 
		UPDATE
		SET 
			strOriginDestinationState = SOURCE.strOriginDestinationState
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			strOriginDestinationState
			, intMasterId
		)
		VALUES (
			SOURCE.strOriginDestinationState
			, SOURCE.intMasterId
		);

	-- Set insMasterId to 0 for records that are not exist in default data
	UPDATE tblTFOriginDestinationState
	SET intMasterId = 0
    WHERE intMasterId NOT IN (SELECT intMasterId FROM @OriginDestinationStates)
	
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