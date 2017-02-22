CREATE PROCEDURE [dbo].[uspTFUpgradeFilingPackets]
	@TaxAuthorityCode NVARCHAR(10),
	@FilingPackets TFFilingPackets READONLY

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
	INTO	tblTFFilingPacket
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT FP.*, RC.intReportingComponentId FROM @FilingPackets FP
		LEFT JOIN tblTFReportingComponent RC ON RC.strFormCode COLLATE Latin1_General_CI_AS = FP.strFormCode COLLATE Latin1_General_CI_AS
			AND RC.strScheduleCode COLLATE Latin1_General_CI_AS = FP.strScheduleCode COLLATE Latin1_General_CI_AS
			AND RC.strType COLLATE Latin1_General_CI_AS = FP.strType COLLATE Latin1_General_CI_AS
			AND RC.intTaxAuthorityId = @TaxAuthorityId
	) AS SOURCE
		ON TARGET.intReportingComponentId = SOURCE.intReportingComponentId
			AND TARGET.intTaxAuthorityId = @TaxAuthorityId

	WHEN MATCHED THEN 
		UPDATE
		SET 
			intFrequency				= SOURCE.intFrequency
	WHEN NOT MATCHED THEN 
		INSERT (
			intTaxAuthorityId
			, intReportingComponentId
			, ysnStatus
			, intFrequency
		)
		VALUES (
			@TaxAuthorityId
			, SOURCE.intReportingComponentId
			, SOURCE.ysnStatus
			, SOURCE.intFrequency
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