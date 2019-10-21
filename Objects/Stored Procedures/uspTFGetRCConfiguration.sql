CREATE PROCEDURE [dbo].[uspTFGetRCConfiguration]
	@ReportingComponentId INT
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

	SELECT *
	INTO #tmpRCConfig
	FROM tblTFReportingComponentConfiguration
	WHERE intReportingComponentId = @ReportingComponentId

	DECLARE @SQLString NVARCHAR(MAX)
		, @ColumnList NVARCHAR(MAX) = ''
	DECLARE @ConfigId INT
		, @column NVARCHAR(100)
		, @config NVARCHAR(100)

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRCConfig)
	BEGIN
		SELECT TOP 1 @ConfigId = intReportingComponentConfigurationId
			, @column = strTemplateItemId
			, @config = strConfiguration FROM #tmpRCConfig

		IF (ISNULL(@ColumnList, '') != '')
			SET @ColumnList += ', '

		SET @ColumnList += '[' + @column + '] = ' + CAST(ISNULL(@config, 'NULL') AS NVARCHAR(50))

		DELETE FROM #tmpRCConfig WHERE intReportingComponentConfigurationId = @ConfigId
	END

	SET @SQLString = 'SELECT ' + @ColumnList
	EXEC(@SQLString)

	DROP TABLE #tmpRCConfig

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