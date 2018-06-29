CREATE PROCEDURE [dbo].[uspTFGetUncommonField]
	@ReportingComponentId INT,
	@GenerateTable BIT = 0
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

	SELECT DISTINCT strColumn, strConfigurationValue
	INTO #tmpCustomField
	FROM vyuTFGetReportingComponentField
	WHERE intReportingComponentId = @ReportingComponentId
		AND ysnFromConfiguration = 1
		AND ISNULL(strConfigurationValue, '') <> ''
		AND ISNULL(strConfigurationValue, '') <> 'BLANK'

	DECLARE @column NVARCHAR(100)
		, @value NVARCHAR(100)
		, @InsertScript NVARCHAR(MAX) = 'INSERT INTO tblTFCustomField' + CAST(@ReportingComponentId AS NVARCHAR(50)) + '(intReportingComponentId,'
		, @QueryScript NVARCHAR(MAX) = 'SELECT ' + CAST(@ReportingComponentId AS NVARCHAR(50)) + ' AS [intReportingComponentId]'
		, @CreateTableScript NVARCHAR(MAX) = 'CREATE TABLE tblTFCustomField' + CAST(@ReportingComponentId AS NVARCHAR(50)) + '(intReportingComponentId INT,'
		, @DropScript NVARCHAR(MAX) = 'IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = ''tblTFCustomField' + CAST(@ReportingComponentId AS NVARCHAR(50)) + ''')	DROP TABLE tblTFCustomField' + CAST(@ReportingComponentId AS NVARCHAR(50)) + ''

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomField)
	BEGIN
		SELECT TOP 1 @column = strColumn, @value = strConfigurationValue FROM #tmpCustomField

		IF (LEN(@QueryScript) > 0)
		BEGIN
			SET @QueryScript += ', '
		END
		ELSE
		BEGIN
			SET @QueryScript += 'SELECT '
		END

		SET @QueryScript += '''' + @value + ''' AS [' + @column + ']'
		SET @InsertScript +=  '[' + @column + '],'
		SET @CreateTableScript +=  '[' + @column + '] NVARCHAR(100),'

		DELETE FROM #tmpCustomField WHERE strColumn = @column
	END

	IF (@InsertScript LIKE '%,')
	BEGIN
		SET @InsertScript = SUBSTRING(@InsertScript, 0, LEN(@InsertScript))
	END
	SET @InsertScript += ') '
	IF (@CreateTableScript LIKE '%,')
	BEGIN
		SET @CreateTableScript = SUBSTRING(@CreateTableScript, 0, LEN(@CreateTableScript))
	END
	SET @CreateTableScript += ')'

	IF (@GenerateTable = 1)
	BEGIN
		SET @QueryScript = @InsertScript + @QueryScript

		EXECUTE sp_executesql @DropScript
		EXECUTE sp_executesql @CreateTableScript
	END
	EXECUTE sp_executesql @QueryScript

	DROP TABLE #tmpCustomField

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