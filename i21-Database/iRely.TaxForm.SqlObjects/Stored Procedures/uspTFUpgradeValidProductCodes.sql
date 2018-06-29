﻿CREATE PROCEDURE [dbo].[uspTFUpgradeValidProductCodes]
	@TaxAuthorityCode NVARCHAR(10),
	@ValidProductCodes TFValidProductCodes READONLY

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

	SELECT VPC.*, PC.intProductCodeId, RC.intReportingComponentId
	INTO #tmpVPC
	FROM @ValidProductCodes VPC
	LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = VPC.strFormCode COLLATE Latin1_General_CI_AS
		AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = VPC.strScheduleCode COLLATE Latin1_General_CI_AS
		AND RC.strType COLLATE Latin1_General_CI_AS = VPC.strType COLLATE Latin1_General_CI_AS
	LEFT JOIN tblTFProductCode PC ON PC.strProductCode COLLATE Latin1_General_CI_AS = VPC.strProductCode COLLATE Latin1_General_CI_AS
	WHERE PC.intTaxAuthorityId = @TaxAuthorityId 
	AND RC.intTaxAuthorityId = @TaxAuthorityId
	AND PC.intMasterId != 0

	MERGE	
	INTO	tblTFReportingComponentProductCode
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM #tmpVPC
	) AS SOURCE
		ON TARGET.intMasterId = SOURCE.intMasterId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			intReportingComponentId	= SOURCE.intReportingComponentId
			, intProductCodeId		= SOURCE.intProductCodeId
			, strType				= SOURCE.strType
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intReportingComponentId
			, intProductCodeId
			, strType
			, intMasterId
		)
		VALUES (
			SOURCE.intReportingComponentId
			, SOURCE.intProductCodeId
			, SOURCE.strType
			, SOURCE.intMasterId
		);

	-- Delete existing Valid Product Codes that is not within Source
	DELETE tblTFReportingComponentProductCode
	WHERE intMasterId NOT IN (SELECT intMasterId FROM #tmpVPC)
	AND intReportingComponentId IN (SELECT DISTINCT intReportingComponentId FROM #tmpVPC)

	DROP TABLE #tmpVPC

	-- Add Default (1) in NULL intConcurrencyId
	DECLARE @RCProductCode INT
	SELECT TOP 1 @RCProductCode =  intReportingComponentProductCodeId FROM tblTFReportingComponentProductCode
	IF(@RCProductCode IS NOT NULL)
		BEGIN
			UPDATE tblTFReportingComponentProductCode SET intConcurrencyId = 1 WHERE intConcurrencyId IS NULL
		END
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