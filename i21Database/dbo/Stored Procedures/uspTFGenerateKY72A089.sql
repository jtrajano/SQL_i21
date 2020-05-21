CREATE PROCEDURE [dbo].[uspTFGenerateKY72A089]
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
	DECLARE @dtmFrom DATE 
		, @dtmTo DATE 
		, @line1_B NUMERIC(18, 6) = 0.00
		, @line2a_A NUMERIC(18, 6) = 0.00
		, @line2b_A NUMERIC(18, 6) = 0.00
		, @line2c_B NUMERIC(18, 6) = 0.00
		, @line3_B NUMERIC(18, 6) = 0.00
		, @line4_B NUMERIC(18, 6) = 0.00
		, @line5_C NUMERIC(18, 6) = 0.00	
		, @line6_B NUMERIC(18, 6) = 0.00
		, @line7_B NUMERIC(18, 6) = 0.00
		, @line8_B NUMERIC(18, 6) = 0.00
		, @line9_B NUMERIC(18, 6) = 0.00
		, @line10_C NUMERIC(18, 6) = 0.00
		, @line11_C NUMERIC(18, 6) = 0.00
		, @line12 NUMERIC(18, 6) = 0.00
		, @line13 NUMERIC(18, 6) = 0.00
		, @line13_A NUMERIC(18, 6) = 0.00
		, @line13_B NUMERIC(18, 6) = 0.00
		, @line14 NUMERIC(18, 6) = 0.00
		, @line15_A NUMERIC(18, 6) = 0
		, @line16 NUMERIC(18, 6) = 0.00
		, @line17 NUMERIC(18, 6) = 0.00
		, @line18 NUMERIC(18, 6) = 0.00
		, @line19 NUMERIC(18, 6) = 0.00
		, @line20 NUMERIC(18, 6) = 0.00
		, @line21 NUMERIC(18, 6) = 0.00
		, @line22 NUMERIC(18, 6) = 0.00
		, @line23 NUMERIC(18, 6) = 0.00
		, @line12_TaxRate NUMERIC(18, 6) = 0.00
		, @line16_TaxRate NUMERIC(18, 6) = 0.00
		, @line18_AllowanceRate NUMERIC(18, 6) = 0.00
		, @strline12_TaxRate NVARCHAR(20) = ''
		, @strline16_TaxRate NVARCHAR(20) = ''
		, @strline18_AllowanceRate NVARCHAR(20) = ''
		, @strConfig_Line9 NVARCHAR(20) = NULL
		, @strConfig_Line12 NVARCHAR(20) = NULL
		, @strConfig_Line13a NVARCHAR(20) = NULL
		, @strConfig_Line13b NVARCHAR(20) = NULL
		, @strConfig_Line16 NVARCHAR(20) = NULL
		, @strConfig_Line18 NVARCHAR(20) = NULL
		, @strConfig_Line20 NVARCHAR(20) = NULL
		, @strConfig_StaGal NVARCHAR(20) = NULL
		, @dblConfig_Line12 NUMERIC(18,6) = 0
		, @dblConfig_Line16 NUMERIC(18,6) = 0
		, @dblConfig_Line18 NUMERIC(18,6) = 0

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

		DECLARE @TaxAuthorityId INT
		, @Guid NVARCHAR(100)

		DECLARE @transaction TFReportTransaction

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

			-- Configuration
		SELECT @strConfig_Line9		= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln9'
		SELECT @strConfig_Line12	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln12'
		SELECT @strConfig_Line13a	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln13a'
		SELECT @strConfig_Line13b	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln13b'
		SELECT @strConfig_Line16	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln16'
		SELECT @strConfig_Line18	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln18'	
		SELECT @strConfig_Line20	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-Ln20'	
		SELECT @strConfig_StaGal	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYGas-StaGal'

		SET @line9_B			= CONVERT(NUMERIC(18,0), @strConfig_Line9) 
		SET @dblConfig_Line12	= CONVERT(NUMERIC(18,8), @strConfig_Line12) 
		SET @line13_A			= CONVERT(NUMERIC(18,8), @strConfig_Line13a) 
		SET @line13_B			= CONVERT(NUMERIC(18,0), @strConfig_Line13b) 
		SET @dblConfig_Line16	= CONVERT(NUMERIC(18,8), @strConfig_Line16) 
		SET @dblConfig_Line18	= CONVERT(NUMERIC(18,8), @strConfig_Line18) 
		SET @line20				= CONVERT(NUMERIC(18,8), @strConfig_Line20) 
		SET @line23				= CONVERT(NUMERIC(18,0), @strConfig_StaGal)
		
		SELECT @line1_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '2'
		SELECT @line2a_A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode LIKE '5D%'
		SELECT @line2b_A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode LIKE '3%'

		SET @line2c_B = @line2a_A + @line2b_A

		SELECT @line3_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '2A'
		SELECT @line4_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '2B'

		SET @line5_C = @line1_B + @line2c_B + @line3_B + @line4_B

		SELECT @line6_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode LIKE '7%'
		SELECT @line7_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '6'
		SELECT @line8_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '8'

		SET @line10_C = @line6_B + @line7_B + @line8_B + @line9_B
		SET @line11_C = @line5_C - @line10_C
		SET @line12 = @line11_C * @dblConfig_Line12
		SET @line13 = @line13_A * @line13_B
		SET @line14 = @line12 - @line13

		SELECT @line15_A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '10I'

		SET @line16 = @line15_A * @dblConfig_Line16
		SET @line17 = @line14 - @line16
		SET @line18 = @line17 * @dblConfig_Line18
		SET @line19 = @line17 - @line18
		SET @line21 = @line19 - @line20

		SELECT @line22 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A089' AND strScheduleCode = '1'

	END

	SELECT dtmFrom	=	@dtmFrom
		, dtmTo		=	@dtmTo
		, line1_B	=	@line1_B 
		, line2a_A	=	@line2a_A 
		, line2b_A	=	@line2b_A 
		, line2c_B	=	@line2c_B 
		, line3_B	=	@line3_B
		, line4_B	=	@line4_B
		, line5_C	=	@line5_C
		, line6_B	=	@line6_B
		, line7_B	=	@line7_B
		, line8_B	=	@line8_B
		, line9_B	=	@line9_B
		, line10_C	=	@line10_C
		, line11_C	=	@line11_C
		, line12	=	@line12
		, line13	=	@line13
		, line13_A	=	@line13_A
		, line13_B	=	@line13_B
		, line14	=	@line14
		, line15_A	=	@line15_A
		, line16	=	@line16
		, line17	=	@line17
		, line18	=	@line18
		, line19	=	@line19
		, line20	=	@line20
		, line21	=	@line21
		, line22	=	@line22
		, line23	=	@line23
		, strline12_TaxRate =	@strConfig_Line12
		, strline16_TaxRate =	@strConfig_Line16
		, strline18_AllowanceRate =	@strConfig_Line18

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
