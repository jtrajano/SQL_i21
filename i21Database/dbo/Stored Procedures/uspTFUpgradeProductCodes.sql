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

	MERGE	
	INTO	tblTFProductCode 
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @ProductCodes
	) AS SOURCE
		ON TARGET.strProductCode COLLATE Latin1_General_CI_AS = SOURCE.strProductCode COLLATE Latin1_General_CI_AS
			AND TARGET.intTaxAuthorityId = @TaxAuthorityId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			strDescription			= SOURCE.strDescription
			, strProductCodeGroup	= SOURCE.strProductCodeGroup
			, strNote				= SOURCE.strNote
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intTaxAuthorityId
			, strProductCode
			, strDescription
			, strProductCodeGroup
			, strNote
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strProductCode
			, SOURCE.strDescription
			, SOURCE.strProductCodeGroup
			, SOURCE.strNote
		);

	-- Update existing Product Code associated with Tax Authority Id that is not within Source
	UPDATE tblTFProductCode
	SET strNote = 'This Product Code is now obsolete'
	WHERE intTaxAuthorityId = @TaxAuthorityId
		AND strProductCode NOT IN (SELECT strProductCode FROM @ProductCodes WHERE intTaxAuthorityId = @TaxAuthorityId)

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