CREATE PROCEDURE [dbo].[uspTFProcessBeforePreview]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(50)
	, @DateFrom DATETIME
	, @DateTo DATETIME

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

	DECLARE @FormCode NVARCHAR(50)
		, @ScheduleCode NVARCHAR(50)
		, @TransactionType NVARCHAR(50)
		, @RCId INT

	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')
		
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC

		SELECT * 
		INTO #tmpTransaction
		FROM tblTFTransaction	
		WHERE uniqTransactionGuid = @Guid
			AND intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)

		SELECT TOP 1 @FormCode = strFormCode
			, @ScheduleCode = strScheduleCode
			, @TransactionType = strTransactionType
		FROM tblTFReportingComponent
		WHERE intReportingComponentId = @RCId

		IF (@FormCode = 'MF-360' OR @FormCode = 'SF-900')
		BEGIN
			IF (@TransactionType = 'Invoice')
			BEGIN
				-- MFT-517 -- Hard Code Terminal Control Number to 'BULK'
				UPDATE tblTFTransaction
				SET strTerminalControlNumber = 'BULK'
				WHERE intTransactionId IN (SELECT DISTINCT intTransactionId FROM #tmpTransaction)
			END			
		END

		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId

		DROP TABLE #tmpTransaction
	END

	DROP TABLE #tmpRC

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