CREATE PROCEDURE [dbo].[uspTFGenerateKY72A138]
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
		, @line10_B NUMERIC(18, 6) = 0.00
		, @line11_B NUMERIC(18, 6) = 0.00
		, @line12_C NUMERIC(18, 6) = 0.00
		, @line13_C NUMERIC(18, 6) = 0.00
		, @line14 NUMERIC(18, 6) = 0.00
		, @line15 NUMERIC(18, 6) = 0.00
		, @line15a NUMERIC(18, 6) = 0.00
		, @line15b NUMERIC(18, 6) = 0.00
		, @line16 NUMERIC(18, 6) = 0.00
		, @line17 NUMERIC(18, 6) = 0.00
		, @line17a NUMERIC(18, 6) = 0.00
		, @line17b NUMERIC(18, 6) = 0.00
		, @line17c NUMERIC(18, 6) = 0.00
		, @line17d NUMERIC(18, 6) = 0.00
		, @line17e NUMERIC(18, 6) = 0.00
		, @line18 NUMERIC(18, 6) = 0.00
		, @line19 NUMERIC(18, 6) = 0.00
		, @line20 NUMERIC(18, 6) = 0.00
		, @line21 NUMERIC(18, 6) = 0.00
		, @line22 NUMERIC(18, 6) = 0.00
		, @line23 NUMERIC(18, 6) = 0.00
		, @line24 NUMERIC(18, 6) = 0.00

		, @strConfig_Line8 NVARCHAR(20) = NULL
		, @strConfig_Line11 NVARCHAR(20) = NULL
		, @strConfig_Line14 NVARCHAR(20) = NULL
		, @strConfig_Line15a NVARCHAR(20) = NULL
		, @strConfig_Line15b NVARCHAR(20) = NULL
		, @strConfig_Line17 NVARCHAR(20) = NULL
		, @strConfig_Line20 NVARCHAR(20) = NULL
		, @strConfig_Line22 NVARCHAR(20) = NULL

		, @dblConfig_Line14 NUMERIC(18,6) = 0
		, @dblConfig_Line17 NUMERIC(18,6) = 0
		, @dblConfig_Line20 NUMERIC(18,6) = 0
		, @dblConfig_Line15a NUMERIC(18,6) = 0

		, @dblLine17a NUMERIC(18,6) = 0
		, @dblLine17b NUMERIC(18,6) = 0
		, @dblLine17c NUMERIC(18,6) = 0
		, @dblLine17d NUMERIC(18,6) = 0
		, @dblLine17e NUMERIC(18,6) = 0
		

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
		SELECT @strConfig_Line8	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln8'
		SELECT @strConfig_Line11 = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln11'
		SELECT @strConfig_Line14	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln14'
		SELECT @strConfig_Line15a	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln15a'
		SELECT @strConfig_Line15b	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln15b'
		SELECT @strConfig_Line17	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln17'	
		SELECT @strConfig_Line20	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln20'	
		SELECT @strConfig_Line22	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'KYSF-Ln22'

		SET @line8_B			= CONVERT(NUMERIC(18,0), @strConfig_Line8) 
		SET @line11_B			= CONVERT(NUMERIC(18,0), @strConfig_Line11) 
		SET @dblConfig_Line14	= CONVERT(NUMERIC(18,8), @strConfig_Line14) 
		SET @dblConfig_Line15a	= CONVERT(NUMERIC(18,8), @strConfig_Line15a) 
		SET @line15b			= CONVERT(NUMERIC(18,0), @strConfig_Line15b) 
		SET @dblConfig_Line17	= CONVERT(NUMERIC(18,8), @strConfig_Line17) 
		SET @dblConfig_Line20	= CONVERT(NUMERIC(18,8), @strConfig_Line20) 
		SET @line22				= CONVERT(NUMERIC(18,8), @strConfig_Line22)
		
		SELECT @line1_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '2'
		SELECT @line2a_A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode IN ('5DIL','5DIN','5DTN')
		SELECT @line2b_A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode IN ('3IL','3IN','3TN')

		SET @line2c_B = @line2a_A + @line2b_A

		SELECT @line3_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '2A'
		SELECT @line4_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '2B'

		SET @line5_C = @line1_B + @line2c_B + @line3_B + @line4_B

		SELECT @line6_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode IN ('7IL','7IN','7TN')
		SELECT @line7_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '6'	
		SELECT @line9_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '10Y'
		SELECT @line10_B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '8'

		SET @line12_C = @line6_B + @line7_B + @line8_B + @line9_B + @line10_B + @line11_B
		SET @line13_C = @line5_C - @line12_C
		SET @line14 = @line11_B * @dblConfig_Line14
		SET @line15 = @dblConfig_Line15a * @line15b
		SET @line16 = @line14 - @line15

		SELECT @dblLine17a = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '10I'
		SELECT @dblLine17b = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '10J'
		SELECT @dblLine17c = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '9'
		SELECT @dblLine17d = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '10G'
		SELECT @dblLine17e = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '10A'

		SET @Line17a = @dblLine17a * @dblConfig_Line17
		SET @Line17b = @dblLine17b * @dblConfig_Line17
		SET @Line17c = @dblLine17c * @dblConfig_Line17
		SET @Line17d = @dblLine17d * @dblConfig_Line17
		SET @Line17e = @dblLine17e * @dblConfig_Line17

		SET @line18 = @Line17a + @Line17b + @Line17c + @Line17d + @Line17e
		SET @line19 = @line16 - @line18
		SET @line20 = @line19 * @dblConfig_Line20
		SET @line21 = @line19 - @line20
		SET @line23 = @line21 - @line22

		SELECT @line24 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '72A138' AND strScheduleCode = '1'

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
		, line10_B	=	@line10_B 
		, line11_B	=	@line11_B
		, line12_C	=	@line12_C
		, line13_C	=	@line13_C
		, line14	=	@line14
		, line15	=	@line15
		--, line15a	=	@line15a 
		, line15b	=	@line15b
		, line16	=	@line16
		, line17a	=	@line17a
		, line17b	=	@line17b
		, line17c	=	@line17c 
		, line17d	=	@line17d
		, line17e	=	@line17e
		, line18	=	@line18
		, line19	=	@line19
		, line20	=	@line20
		, line21	=	@line21
		, line22	=	@line22
		, line23	=	@line23
		, line24	=	@line24
		, strConfig_Line14 =	@strConfig_Line14
		, strConfig_Line17 =	@strConfig_Line17
		, strConfig_Line20 =	@strConfig_Line20
		, strConfig_Line15a =	@strConfig_Line15a

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