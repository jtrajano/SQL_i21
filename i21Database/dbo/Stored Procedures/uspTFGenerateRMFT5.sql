CREATE PROCEDURE [dbo].[uspTFGenerateRMFT5]
	@Guid NVARCHAR(250)
	, @FormCodeParam NVARCHAR(MAX)
	, @ScheduleCodeParam NVARCHAR(MAX)
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