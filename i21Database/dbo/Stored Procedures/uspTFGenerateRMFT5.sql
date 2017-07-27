CREATE PROCEDURE [dbo].[uspTFGenerateRMFT5]
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
			, dblColumn1_2c = 0.000000
			, dblColumn2_2c = 0.000000
			, dblColumn3_2c = 0.000000
			, dblColumn1_3 = 0.000000
			, dblColumn2_3 = 0.000000
			, dblColumn3_3 = 0.000000
			, dblColumn1_4 = 0.000000
			, dblColumn2_4 = 0.000000
			, dblColumn3_4 = 0.000000
			, dblColumn1_5 = 0.000000
			, dblColumn2_5 = 0.000000
			, dblColumn3_5 = 0.000000
			, dblColumn1_6 = 0.000000
			, dblColumn2_6 = 0.000000
			, dblColumn3_6 = 0.000000
			, dblColumn1_7 = 0.000000
			, dblColumn2_7 = 0.000000
			, dblColumn3_7 = 0.000000
			, dblColumn1_8a = 0.000000
			, dblColumn2_8a = 0.000000
			, dblColumn3_8a = 0.000000
			, dblColumn1_8b = 0.000000
			, dblColumn2_8b = 0.000000
			, dblColumn3_8b = 0.000000
			, dblColumn1_8c = 0.000000
			, dblColumn2_8c = 0.000000
			, dblColumn3_8c = 0.000000
			, dblColumn1_9 = 0.000000
			, dblColumn2_9 = 0.000000
			, dblColumn3_9 = 0.000000
			, dblColumn1_10a = 0.000000
			, dblColumn2_10a = 0.000000
			, dblColumn3_10a = 0.000000
			, dblColumn1_10b = 0.000000
			, dblColumn2_10b = 0.000000
			, dblColumn3_10b = 0.000000
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
			, dblColumn1_15 = 0.000000
			, dblColumn2_15 = 0.000000
			, dblColumn3_15 = 0.000000
			, dblColumn1_16 = 0.000000
			, dblColumn2_16 = 0.000000
			, dblColumn3_16 = 0.000000
			, dblColumn1_17 = 0.000000
			, dblColumn2_17 = 0.000000
			, dblColumn3_17 = 0.000000
			, dblColumn1_18 = 0.000000
			, dblColumn2_18 = 0.000000
			, dblColumn3_18 = 0.000000
			, [RMFT-5-DistLicense] = NULL
			, [RMFT-5-SupplierLicense] = NULL
			, [RMFT-5-Line1Col1] = NULL
			, [RMFT-5-Line1Col2] = NULL
			, [RMFT-5-Line1Col3] = NULL
			, [RMFT-5-Line4Col1] = NULL
			, [RMFT-5-Line4Col2] = NULL
			, [RMFT-5-Line4Col3] = NULL
			, [RMFT-5-Line8C] = NULL
			, [RMFT-5-Line9Col1] = NULL
			, [RMFT-5-Line9Col2] = NULL
			, [RMFT-5-Line9Col3] = NULL
			, [RMFT-5-Line10Col1] = NULL
			, [RMFT-5-Line10Col2] = NULL
			, [RMFT-5-Line10Col3] = NULL
			, [RMFT-5-Line13Col1] = NULL
			, [RMFT-5-Line13Col2] = NULL
			, [RMFT-5-Line14Col1] = NULL
			, [RMFT-5-Line14Col2] = NULL
			, [RMFT-5-Line15Col1] = NULL
			, [RMFT-5-Line15Col2] = NULL
			, [RMFT-5-TaxRateGas] = NULL
			, [RMFT-5-TaxRateSpecialFuel] = NULL
			, [RMFT-5-ColDiscGas] = NULL
			, [RMFT-5-ColDiscSpecialFuel] = NULL
			, [RMFT-5-Line23] = NULL
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