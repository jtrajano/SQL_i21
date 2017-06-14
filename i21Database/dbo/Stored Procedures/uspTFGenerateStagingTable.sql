CREATE PROCEDURE [dbo].[uspTFGenerateStagingTable]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(MAX)
	, @DateFrom DATETIME
	, @DateTo DATETIME
	, @IsEdi BIT
	, @Refresh BIT

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

	DECLARE @RCId INT
		, @FormCode NVARCHAR(20)
		, @FormName NVARCHAR(100)
		, @ScheduleCode NVARCHAR(20)
		, @ScheduleName NVARCHAR(100)
		, @Type NVARCHAR(100)
		, @TransactionType NVARCHAR(20)
		, @SPInventory NVARCHAR(50)
		, @SPInvoice NVARCHAR(50)
		, @SPRunReport NVARCHAR(50)

	DECLARE @ParamDefinition NVARCHAR(MAX)
		, @SPRunString NVARCHAR(MAX)
		, @ErrMsg NVARCHAR(MAX) = ''
	
	DELETE FROM tblTFTransaction
		
	SELECT *
	INTO #tmpRC
	FROM vyuTFGetReportingComponent
	WHERE intReportingComponentId IN (SELECT Item COLLATE Latin1_General_CI_AS FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ','))
		AND strScheduleName != 'Main Form'
		AND strType != 'EDI'
	ORDER BY strFormCode, strScheduleCode, strType, strTransactionType

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		
		SELECT TOP 1 @RCId = intReportingComponentId
			, @FormCode = strFormCode
			, @FormName = strFormName
			, @ScheduleCode = strScheduleCode
			, @ScheduleName = strScheduleName
			, @Type = strType
			, @TransactionType = strTransactionType
			, @SPInventory = strSPInventory
			, @SPInvoice = strSPInvoice
			, @SPRunReport = CASE WHEN (strTransactionType = 'Inventory') THEN strSPInventory
								WHEN (strTransactionType = 'Invoice') THEN strSPInvoice
								ELSE NULL END
		FROM #tmpRC

		IF (ISNULL(@TransactionType, '') = '')
		BEGIN
			SET @ErrMsg = 'Form: ' + @FormCode + ' Schedule: ' + @ScheduleCode + ' Type: ' + @Type + ' does not have a valid Transaction Type.'
			RAISERROR(@ErrMsg, 16, 1)
		END
		IF (ISNULL(@SPRunReport, '') = '')
		BEGIN
			SET @ErrMsg = 'Form: ' + @FormCode + ' Schedule: ' + @ScheduleCode + ' Type: ' + @Type + ' does not have a valid ' + @TransactionType + ' SP.'
			RAISERROR(@ErrMsg, 16, 1)
		END

		SET @ParamDefinition =  N'@Guid NVARCHAR(50), @ReportingComponentId NVARCHAR(MAX), @DateFrom DATETIME, @DateTo DATETIME, @IsEdi BIT, @Refresh BIT'
		SET @SPRunString = @SPRunReport + ' @Guid = @Guid, @ReportingComponentId = @ReportingComponentId, @DateFrom = @DateFrom, @DateTo = @DateTo, @IsEdi = @IsEdi, @Refresh = @Refresh'
		
		EXECUTE sp_executesql @SPRunString, @ParamDefinition, @Guid = @Guid, @ReportingComponentId = @RCId, @DateFrom = @DateFrom, @DateTo = @DateTo, @IsEdi = @IsEdi, @Refresh = 0;  

		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId

	END

	DROP TABLE #tmpRC

	SELECT *
	INTO #tmpMain
	FROM vyuTFGetReportingComponent
	WHERE intReportingComponentId IN (SELECT Item COLLATE Latin1_General_CI_AS FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ','))
		AND strScheduleName = 'Main Form'
	ORDER BY strFormCode, strScheduleCode, strType, strTransactionType

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpMain)
	BEGIN
		
		SELECT TOP 1 @RCId = intReportingComponentId
			, @FormCode = strFormCode
			, @FormName = strFormName
			, @ScheduleCode = strScheduleCode
			, @ScheduleName = strScheduleName
			, @Type = strType
			, @TransactionType = strTransactionType
			, @SPRunReport = strSPRunReport
		FROM #tmpMain

		SET @ParamDefinition =  N'@Guid NVARCHAR(250), @FormCodeParam NVARCHAR(MAX), @ScheduleCodeParam NVARCHAR(MAX), @Refresh NVARCHAR(5)'
		SET @SPRunString = @SPRunReport + ' @Guid = @Guid, @FormCodeParam = @FormCodeParam, @ScheduleCodeParam = @ScheduleCodeParam, @Refresh = @Refresh'
		
		EXECUTE sp_executesql @SPRunString, @ParamDefinition, @Guid = @Guid, @FormCodeParam = @FormCode, @ScheduleCodeParam = @ScheduleCode, @Refresh = 0;  

		DELETE FROM #tmpMain WHERE intReportingComponentId = @RCId

	END

	DROP TABLE #tmpMain

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