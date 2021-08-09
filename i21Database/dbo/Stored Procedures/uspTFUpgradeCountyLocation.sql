CREATE PROCEDURE [dbo].[uspTFUpgradeCountyLocation]
	@TaxAuthorityCode NVARCHAR(10),
	@CountyLocation TFCountyLocation READONLY
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

	UPDATE tblTFCountyLocation
    SET intMasterId = B.intMasterId 
    FROM @CountyLocation B 
    WHERE tblTFCountyLocation.intTaxAuthorityId = @TaxAuthorityId
    AND tblTFCountyLocation.strCounty COLLATE Latin1_General_CI_AS = B.strCounty COLLATE Latin1_General_CI_AS
	AND tblTFCountyLocation.strLocation COLLATE Latin1_General_CI_AS = B.strLocation COLLATE Latin1_General_CI_AS
    AND (tblTFCountyLocation.intMasterId IS NULL OR tblTFCountyLocation.intMasterId = 0)

	MERGE	
	INTO tblTFCountyLocation 
	WITH (HOLDLOCK) 
	AS TARGET
	USING (
		SELECT * FROM @CountyLocation
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

	WHEN MATCHED THEN 
		UPDATE
		SET 
		    strCounty			= SOURCE.strCounty
			,strLocation		= SOURCE.strLocation
			,dblRate1			= SOURCE.dblRate1  
			,dblRate2			= SOURCE.dblRate2
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intTaxAuthorityId
			, strCounty
			, strLocation
			, dblRate1
			, dblRate2
			, intMasterId
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.strCounty
			, SOURCE.strLocation
			, SOURCE.dblRate1
			, SOURCE.dblRate2
			, SOURCE.intMasterId
		);

	-- Set insMasterId to 0 for records that are not exist in default data
	UPDATE tblTFCountyLocation
	SET intMasterId = NULL
	WHERE intTaxAuthorityId = @TaxAuthorityId 
	AND intMasterId NOT IN (SELECT intMasterId FROM @CountyLocation)

	DELETE tblTFCountyLocation WHERE intMasterId IS NULL
	AND intCountyLocationId NOT IN (SELECT intCountyLocationId FROM tblTFTaxAuthorityCountyLocation)

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