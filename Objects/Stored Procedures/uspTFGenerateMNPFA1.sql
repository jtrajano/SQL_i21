CREATE PROCEDURE [dbo].[uspTFGenerateMNPFA1]
	@xmlParam NVARCHAR(MAX) = NULL
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

	DECLARE  @dtmFrom DATE
	, @dtmTo DATE
	, @dblSection1_1A NUMERIC(18, 0) = 0
	, @dblSection1_1C NUMERIC(18, 8) = 0
	, @dblSection1_2A NUMERIC(18, 0) = 0
	, @dblSection1_2C NUMERIC(18, 8) = 0
	, @dblSection1_3A NUMERIC(18, 0) = 0
	, @dblSection1_3C NUMERIC(18, 8) = 0
	, @dblSection1_4 NUMERIC(18, 8) = 0
	, @dblSection1_5 NUMERIC(18, 8) = 0
	, @dblSection1_6 NUMERIC(18, 8) = 0
	, @strSection1_1B NVARCHAR(25) = NULL
	, @strSection1_2B NVARCHAR(25) = NULL
	, @strSection1_3B NVARCHAR(25) = NULL
	, @strSection1_5_Allowance NVARCHAR(25) = NULL
	, @dblSection1_1B NUMERIC(18, 8) = 0
	, @dblSection1_2B NUMERIC(18, 8) = 0
	, @dblSection1_3B NUMERIC(18, 8) = 0
	, @dblSection1_5_Allowance NUMERIC(18, 8) = 0

	IF (ISNULL(@xmlParam,'') != '')
	BEGIN

		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		
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

		DECLARE @Guid NVARCHAR(100)

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		-- Configuration
		SELECT @strSection1_1B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PAF1-Ln1'
		SELECT @strSection1_2B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PAF1-Ln2'
		SELECT @strSection1_3B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PAF1-Ln3'
		SELECT @strSection1_5_Allowance = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PAF1-Ln5'

		SET @dblSection1_1B = CONVERT(NUMERIC(18,8), @strSection1_1B) 
		SET @dblSection1_2B = CONVERT(NUMERIC(18,8), @strSection1_2B) 
		SET @dblSection1_3B = CONVERT(NUMERIC(18,8), @strSection1_3B) 
		SET @dblSection1_5_Allowance = CONVERT(NUMERIC(18,8), @strSection1_5_Allowance) 

		-- SECTION 1
		SELECT @dblSection1_1A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PAF-1' AND strScheduleCode = '5Q' AND strType = 'LPG (Propane)'
		SET @dblSection1_1C = @dblSection1_1A * @dblSection1_1B

		SELECT @dblSection1_2A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PAF-1' AND strScheduleCode = '5Q' AND strType = 'CNG'
		SET @dblSection1_2C = @dblSection1_2A * @dblSection1_2B

		SELECT @dblSection1_2A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PAF-1' AND strScheduleCode = '5Q' AND strType = 'LNG'
		SET @dblSection1_3C = @dblSection1_3A * @dblSection1_3B

		SET @dblSection1_4 = @dblSection1_1C + @dblSection1_2C + @dblSection1_3C

		SET @dblSection1_5 = @dblSection1_4 * @dblSection1_5_Allowance

		SET @dblSection1_6 = @dblSection1_4 - @dblSection1_5

	END

	SELECT dtmFrom = @dtmFrom
	, dtmTo = @dtmTo
	, dblSection1_1A = @dblSection1_1A 
	, dblSection1_1C = @dblSection1_1C 
	, dblSection1_2A = @dblSection1_2A
	, dblSection1_2C = @dblSection1_2C
	, dblSection1_3A = @dblSection1_3A
	, dblSection1_3C = @dblSection1_3C
	, dblSection1_4 = @dblSection1_4
	, dblSection1_5 = @dblSection1_5
	, dblSection1_6 = @dblSection1_6
	, strSection1_1B = @strSection1_1B
	, strSection1_2B = @strSection1_2B
	, strSection1_3B = @strSection1_3B
	, strSection1_5_Allowance = @strSection1_5_Allowance

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
	)
END CATCH