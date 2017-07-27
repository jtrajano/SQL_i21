CREATE PROCEDURE [dbo].[uspTFGenerateILMS]
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
		SELECT dtmDate = GETDATE()
			, dblPrimary_a = 0.000000
			, dblPrimary_b = 0.000000
			, dblPrimary_c = 0.000000
			, dblBlending_a = 0.000000
			, dblBlending_b = 0.000000
			, dblBlending_c = 0.000000
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