CREATE PROCEDURE [dbo].[uspTFUpgradeTaxCategories]
	@TaxAuthorityCode NVARCHAR(10),
	@TaxCategories TFTaxCategories READONLY

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
	INTO	tblTFTaxCategory
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @TaxCategories
	) AS SOURCE
		ON TARGET.strTaxCategory COLLATE Latin1_General_CI_AS = SOURCE.strTaxCategory COLLATE Latin1_General_CI_AS
			AND TARGET.intTaxAuthorityId = @TaxAuthorityId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			strState = SOURCE.strState
	WHEN NOT MATCHED THEN 
		INSERT (
			intTaxAuthorityId
			, strState
			, strTaxCategory
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strState
			, SOURCE.strTaxCategory
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