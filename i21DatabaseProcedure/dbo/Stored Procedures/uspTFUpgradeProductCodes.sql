CREATE PROCEDURE [dbo].[uspTFUpgradeProductCodes]
	@TaxAuthorityCode NVARCHAR(10),
	@ProductCodes TFProductCodes READONLY

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

	UPDATE tblTFProductCode
	SET intMasterId = B.intMasterId
	FROM @ProductCodes B
    WHERE tblTFProductCode.intMasterId IS NULL
	AND tblTFProductCode.intTaxAuthorityId = @TaxAuthorityId
	AND tblTFProductCode.strProductCode COLLATE Latin1_General_CI_AS = B.strProductCode COLLATE Latin1_General_CI_AS 
	AND tblTFProductCode.strProductCodeGroup  COLLATE Latin1_General_CI_AS = B.strProductCodeGroup COLLATE Latin1_General_CI_AS

	MERGE	
	INTO	tblTFProductCode 
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @ProductCodes
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			strProductCode			= SOURCE.strProductCode
			,strDescription			= SOURCE.strDescription
			, strProductCodeGroup	= SOURCE.strProductCodeGroup
			, strNote				= SOURCE.strNote
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intTaxAuthorityId
			, strProductCode
			, strDescription
			, strProductCodeGroup
			, strNote
			, intMasterId
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strProductCode
			, SOURCE.strDescription
			, SOURCE.strProductCodeGroup
			, SOURCE.strNote
			, SOURCE.intMasterId
		);

	-- Set insMasterId to 0 for records that are not exist in default data
	UPDATE tblTFProductCode
	SET strNote = 'This Product Code is now obsolete',
	intMasterId = 0
	WHERE intTaxAuthorityId = @TaxAuthorityId 
	AND intMasterId NOT IN (SELECT intMasterId FROM @ProductCodes)	

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