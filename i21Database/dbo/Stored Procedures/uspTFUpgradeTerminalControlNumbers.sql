CREATE PROCEDURE [dbo].[uspTFUpgradeTerminalControlNumbers]
	@TaxAuthorityCode NVARCHAR(10),
	@TerminalControlNumbers TFTerminalControlNumbers READONLY

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
	
	UPDATE tblTFTerminalControlNumber 
    SET intMasterId = B.intMasterId 
    FROM @TerminalControlNumbers B 
    WHERE tblTFTerminalControlNumber.intTaxAuthorityId = @TaxAuthorityId
    AND tblTFTerminalControlNumber.strTerminalControlNumber COLLATE Latin1_General_CI_AS = B.strTerminalControlNumber COLLATE Latin1_General_CI_AS
    AND (tblTFTerminalControlNumber.intMasterId IS NULL OR tblTFTerminalControlNumber.intMasterId = 0)

	MERGE	
	INTO	tblTFTerminalControlNumber 
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @TerminalControlNumbers
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

	WHEN MATCHED THEN 
		UPDATE
		SET 
		    strTerminalControlNumber = SOURCE.strTerminalControlNumber
			,strName				= SOURCE.strName
			, strAddress		= SOURCE.strAddress  
			, strCity			= SOURCE.strCity
			, dtmApprovedDate	= SOURCE.dtmApprovedDate
			, strZip			= SOURCE.strZip
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intTaxAuthorityId
			, strTerminalControlNumber
			, strName
			, strAddress
			, strCity
			, dtmApprovedDate
			, strZip
			, intMasterId
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strTerminalControlNumber
			, SOURCE.strName
			, SOURCE.strAddress
			, SOURCE.strCity
			, SOURCE.dtmApprovedDate
			, SOURCE.strZip
			, SOURCE.intMasterId
		);

	-- Set insMasterId to 0 for records that are not exist in default data
	UPDATE tblTFTerminalControlNumber
	SET intMasterId = NULL
	WHERE intTaxAuthorityId = @TaxAuthorityId 
	AND intMasterId NOT IN (SELECT intMasterId FROM @TerminalControlNumbers)
		
	
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