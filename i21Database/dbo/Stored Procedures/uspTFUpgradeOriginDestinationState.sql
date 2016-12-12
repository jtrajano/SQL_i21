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

	MERGE	
	INTO	tblTFOriginDestinationState
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @OriginDestinationStates
	) AS SOURCE
		ON TARGET.strOriginDestinationState COLLATE Latin1_General_CI_AS = SOURCE.strOriginDestinationState COLLATE Latin1_General_CI_AS

	WHEN MATCHED THEN 
		UPDATE
		SET 
			strOriginDestinationState = SOURCE.strOriginDestinationState
	WHEN NOT MATCHED THEN 
		INSERT (
			strOriginDestinationState
		)
		VALUES (
			SOURCE.strOriginDestinationState
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