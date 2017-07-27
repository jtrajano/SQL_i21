CREATE PROCEDURE [dbo].[uspTFGenerateRMFT5US]
	@XMLParam NVARCHAR(MAX) = NULL

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

	DECLARE @Guid NVARCHAR(250)
	, @FormCodeParam NVARCHAR(MAX)
	, @ScheduleCodeParam NVARCHAR(MAX)
	, @ReportingComponentId NVARCHAR(MAX)
	, @Refresh BIT

	IF (ISNULL(@XMLParam,'') = '')
	BEGIN 
		SELECT dblColumn1_1 = 0.000000
			, dblColumn2_1 = 0.000000
			, dblColumn3_1 = 0.000000
			, dblColumn1_2a = 0.000000
			, dblColumn2_2a = 0.000000
			, dblColumn3_2a = 0.000000
			, dblColumn1_2b = 0.000000
			, dblColumn2_2b = 0.000000
			, dblColumn3_2b = 0.000000
			, dblColumn1_3 = 0.000000
			, dblColumn2_3 = 0.000000
			, dblColumn3_3 = 0.000000
			, dblColumn1_4 = 0.000000
			, dblColumn2_4 = 0.000000
			, dblColumn3_4 = 0.000000
			, dblColumn1_5 = 0.000000
			, dblColumn2_5 = 0.000000
			, dblColumn3_5 = 0.000000
			, dblColumn1_6a = 0.000000
			, dblColumn2_6a = 0.000000
			, dblColumn3_6a = 0.000000
			, dblColumn1_6b = 0.000000
			, dblColumn2_6b = 0.000000
			, dblColumn3_6b = 0.000000
			, dblColumn1_6c = 0.000000
			, dblColumn2_6c = 0.000000
			, dblColumn3_6c = 0.000000
			, dblColumn1_7 = 0.000000
			, dblColumn2_7 = 0.000000
			, dblColumn3_7 = 0.000000
			, dblColumn1_8 = 0.000000
			, dblColumn2_8 = 0.000000
			, dblColumn3_8 = 0.000000
			, dblColumn1_9a = 0.000000
			, dblColumn2_9a = 0.000000
			, dblColumn3_9a = 0.000000
			, dblColumn1_9b = 0.000000
			, dblColumn2_9b = 0.000000
			, dblColumn3_9b = 0.000000
			, dblColumn1_10 = 0.000000
			, dblColumn2_10 = 0.000000
			, dblColumn3_10 = 0.000000
			, dblColumn1_11 = 0.000000
			, dblColumn2_11 = 0.000000
			, dblColumn3_11 = 0.000000
			, dblColumn1_12 = 0.000000
			, dblColumn2_12 = 0.000000
			, dblColumn3_12 = 0.000000
			, dblColumn1_13 = 0.000000
			, dblColumn2_13 = 0.000000
			, dblColumn3_13 = 0.000000
			, dblColumn1_14 = 0.000000
			, dblColumn2_14 = 0.000000
			, dblColumn3_14 = 0.000000
			, [RMFT-5-US-Line1Col1] = NULL
			, [RMFT-5-US-Line1Col2] = NULL
			, [RMFT-5-US-Line4Col1] = NULL
			, [RMFT-5-US-Line4Col2] = NULL
			, [RMFT-5-US-Line9Col1] = NULL
			, [RMFT-5-US-Line9Col2] = NULL
			, [RMFT-5-US-USTRate] = NULL
			, [RMFT-5-US-EIFRate] = NULL
			, [RMFT-5-US-ColDisc] = NULL
			, [RMFT-5-US-RecLicense] = NULL
			, [RMFT-5-US-Line18] = NULL
		RETURN;
	END
	ELSE
	BEGIN

		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XMLParam
		
		DECLARE @Params TABLE ([fieldname] NVARCHAR(50)
				, condition NVARCHAR(20)      
				, [from] NVARCHAR(50)
				, [to] NVARCHAR(50)
				, [join] NVARCHAR(10)
				, [begingroup] NVARCHAR(50)
				, [endgroup] NVARCHAR(50) 
				, [datatype] NVARCHAR(50)) 
        
		INSERT INTO @Params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(50)
			, condition NVARCHAR(20)
			, [from] NVARCHAR(50)
			, [to] NVARCHAR(50)
			, [join] NVARCHAR(10)
			, [begingroup] NVARCHAR(50)
			, [endgroup] NVARCHAR(50)
			, [datatype] NVARCHAR(50))

		SELECT TOP 1 @FormCodeParam = [from] FROM @Params WHERE [fieldname] = 'FormCodeParam'
		SELECT TOP 1 @ScheduleCodeParam = [from] FROM @Params WHERE [fieldname] = 'ScheduleCodeParam'
		SELECT TOP 1 @ReportingComponentId = [from] FROM @Params WHERE [fieldname] = 'ReportingComponentId'
		SELECT TOP 1 @Refresh = [from] FROM @Params WHERE [fieldname] = 'Refresh'
		

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