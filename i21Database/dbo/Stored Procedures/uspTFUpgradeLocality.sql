CREATE PROCEDURE [dbo].[uspTFUpgradeLocality]
	@TaxAuthorityCode NVARCHAR(5),
	@Locality TFLocality READONLY
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

	UPDATE tblTFLocality
    SET intMasterId = B.intMasterId 
    FROM @Locality B 
    WHERE tblTFLocality.intTaxAuthorityId = @TaxAuthorityId
    AND tblTFLocality.strLocalityCode COLLATE Latin1_General_CI_AS = B.strLocalityCode COLLATE Latin1_General_CI_AS
    AND (tblTFLocality.intMasterId IS NULL OR tblTFLocality.intMasterId = 0)

	MERGE	
	INTO	tblTFLocality 
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM @Locality
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

	WHEN MATCHED THEN 
		UPDATE
		SET strLocalityCode		= SOURCE.strLocalityCode
			, strLocalityZipCode	= SOURCE.strLocalityZipCode
			, strLocalityName		= SOURCE.strLocalityName
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intTaxAuthorityId
			, strLocalityCode
			, strLocalityZipCode
			, strLocalityName
			, intMasterId
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strLocalityCode
			, SOURCE.strLocalityZipCode
			, SOURCE.strLocalityName
			, SOURCE.intMasterId
		);

	-- Set insMasterId to 0 for records that are not exist in default data
	UPDATE tblTFLocality
	SET intMasterId = NULL
	WHERE intTaxAuthorityId = @TaxAuthorityId 
	AND intMasterId NOT IN (SELECT intMasterId FROM @Locality)


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
	)
END CATCH

