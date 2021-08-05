CREATE PROCEDURE [dbo].[uspTFGenerateMDS7762]
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
		, @line1 NUMERIC(18, 6) = 0.00
		, @line2 NUMERIC(18, 6) = 0.00
		, @line3 NUMERIC(18, 6) = 0.00
		, @line4 NUMERIC(18, 6) = 0.00
		, @line5 NUMERIC(18, 6) = 0.00
		, @line6 NUMERIC(18, 6) = 0.00
		, @line7 NUMERIC(18, 6) = 0.00
		, @line8 NUMERIC(18, 6) = 0.00
		, @line9 NUMERIC(18, 6) = 0.00
		, @line10 NUMERIC(18, 6) = 0.00
		, @line11 NUMERIC(18, 6) = 0.00
		, @line12 NUMERIC(18, 6) = 0.00
		, @line13 NUMERIC(18, 6) = 0.00
		, @line14 NUMERIC(18, 6) = 0.00
		, @line15 NUMERIC(18, 6) = 0.00
		, @line16 NUMERIC(18, 6) = 0.00
		, @line17 NUMERIC(18, 6) = 0.00
		, @line18 NUMERIC(18, 6) = 0.00
		, @line19 NUMERIC(18, 6) = 0.00
		, @line20 NUMERIC(18, 6) = 0.00
		, @line21 NUMERIC(18, 6) = 0.00
		, @line22 NUMERIC(18, 6) = 0.00
		, @line23 NUMERIC(18, 6) = 0.00
		, @line24A NUMERIC(18, 6) = 0.00
		, @line24B NUMERIC(18, 6) = 0.00
		, @line24C NUMERIC(18, 6) = 0.00
		, @line25A NUMERIC(18, 6) = 0.00
		, @line25B NUMERIC(18, 6) = 0.00
		, @line26 NUMERIC(18, 6) = 0.00
		, @line27 NUMERIC(18, 6) = 0.00
		, @line28 NUMERIC(18, 6) = 0.00
		, @line29 NUMERIC(18, 6) = 0.00
		, @line30 NUMERIC(18, 6) = 0.00
		, @line31 NUMERIC(18, 6) = 0.00
		, @line32 NUMERIC(18, 6) = 0.00
		, @line33 NUMERIC(18, 6) = 0.00
		, @line34 NUMERIC(18, 6) = 0.00
		, @line35 NUMERIC(18, 6) = 0.00
		, @line36 NUMERIC(18, 6) = 0.00
		, @line37 NUMERIC(18, 6) = 0.00
		, @strConfig_Line1 NVARCHAR(20) = NULL
		, @strConfig_Line7 NVARCHAR(20) = NULL
		, @strConfig_Line15 NVARCHAR(20) = NULL
		, @strConfig_Line16 NVARCHAR(20) = NULL
		, @strConfig_Line25A NVARCHAR(20) = NULL
		, @strConfig_Line25B NVARCHAR(20) = NULL
		, @strConfig_Line27 NVARCHAR(20) = NULL
		, @strConfig_Line28 NVARCHAR(20) = NULL	
		, @strConfig_Line32 NVARCHAR(20) = NULL
		, @strConfig_Line33 NVARCHAR(20) = NULL
		, @strConfig_Line34 NVARCHAR(20) = NULL
		, @strConfig_Line35 NVARCHAR(20) = NULL
		, @strConfig_Line36 NVARCHAR(20) = NULL
		, @dblConfig_Line25A NUMERIC(18, 6) = 0.00
		, @dblConfig_Line25B NUMERIC(18, 6) = 0.00
		, @dblConfig_Line27 NUMERIC(18, 6) = 0.00
		, @dblConfig_Line28 NUMERIC(18, 6) = 0.00
		, @strFEIN NVARCHAR(100) = NULL

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
		SELECT @strFEIN	= NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strHeaderLicenseNo'
		SELECT @strConfig_Line1		= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine1'
		SELECT @strConfig_Line7		= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine7'
		SELECT @strConfig_Line15	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine15'
		SELECT @strConfig_Line16	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine16'	
		SELECT @strConfig_Line25A	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine25A'
		SELECT @strConfig_Line25B	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine25B'
		SELECT @strConfig_Line27	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine27'
		SELECT @strConfig_Line28	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine28'
		SELECT @strConfig_Line32	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine32'
		SELECT @strConfig_Line33	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine33'
		SELECT @strConfig_Line34	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine34'
		SELECT @strConfig_Line35	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine35'
		SELECT @strConfig_Line36	= ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'S-strLine36'

		SET @line1 = CONVERT(NUMERIC(18,0), @strConfig_Line1) 
		SET @line7 = CONVERT(NUMERIC(18,0), @strConfig_Line7) 
		SET @line15 = CONVERT(NUMERIC(18,0), @strConfig_Line15) 
		SET @line16 = CONVERT(NUMERIC(18,0), @strConfig_Line16) 
		SET @dblConfig_Line25A = CONVERT(NUMERIC(18,6), @strConfig_Line25A) 
		SET @dblConfig_Line25B = CONVERT(NUMERIC(18,6), @strConfig_Line25B) 
		SET @dblConfig_Line27 = CONVERT(NUMERIC(18,6), @strConfig_Line27) 
		SET @dblConfig_Line28 = CONVERT(NUMERIC(18,6), @strConfig_Line28) 
		SET @line32 = CONVERT(NUMERIC(18,6), @strConfig_Line32) 
		SET @line33 = CONVERT(NUMERIC(18,6), @strConfig_Line33) 
		SET @line34 = CONVERT(NUMERIC(18,6), @strConfig_Line34) 
		SET @line35 = CONVERT(NUMERIC(18,6), @strConfig_Line35) 
		SET @line36 = CONVERT(NUMERIC(18,6), @strConfig_Line36) 

		SELECT @line2 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '1'
		SELECT @line3 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '2'
		SELECT @line4 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '3'
		SELECT @line5 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '4'

		SET @line6 = @line1 + @line2 + @line3 + @line4 + @line5
	
		SELECT @line9 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '5'
		SELECT @line10 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '6'
		SELECT @line11 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode IN ('7DE','7PA','7VA','7WV')
		SELECT @line12 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '8'
		SELECT @line13 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '9'
		SELECT @line14 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '10'

		SET @line17 = @line9 + @line10 + @line11 + @line12 + @line13 + @line14 + @line15 + @line16
		SET @line8 = @line17
		SET @line18 = @line9
		SET @line19 = @line2

		SELECT @line20 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '11'
		SELECT @line21 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'S' AND strScheduleCode = '12'

		SET @line23 = (@line18 - (@line19 + @line20)) + @line21
		SET @line24A = @line23
		SET @line24B = @line16

		SET @line24C = @line24A + @line24B

		SET @line25A = @line24A * @dblConfig_Line25A
		SET @line25B = @line25A * @dblConfig_Line25B
		SET @line26 = @line24C
		SET @line27 = @line26 * @dblConfig_Line27
		SET @line28 = @line26 * @dblConfig_Line28
		SET @line29 = @line27 + @line28

		SET @line30 = @line25B

		SET @line31 = @line29 - @line30
		SET @line37 = @line31 + @line32 + @line33 + @line34 + @line35 + @line36

	END

	SELECT dtmFrom = @dtmFrom
		, dtmTo	=	@dtmTo
		, line1 =  @line1
		, line2 =  @line2
		, line3 =  @line3
		, line4 =  @line4
		, line5 =  @line5
		, line6 =  @line6
		, line7 =  @line7
		, line8 =  @line8
		, line9 =  @line9
		, line10 =  @line10
		, line11 =  @line11
		, line12 =  @line12
		, line13 =  @line13
		, line14 =  @line14
		, line15 =  @line15
		, line16 =  @line16
		, line17 =  @line17
		, line18 =  @line18
		, line19 =  @line19
		, line20 = @line20
		, line21 =  @line21
		, line22 =  @line22
		, line23 =  @line23
		, line24A =  @line24A
		, line24B =  @line24B
		, line24C =  @line24C
		, line25A =  @line25A
		, line25B =  @line25B
		, line26 =  @line26
		, line27 =  @line27
		, line28 =  @line28
		, line29 =  @line29
		, line30 =  @line30
		, line31 =  @line31
		, line32 =  @line32
		, line33 =  @line33
		, line34 =  @line34
		, line35 =  @line35
		, line36 =  @line36
		, line37 =  @line37
		, strConfig_Line25A = @strConfig_Line25A
		, strConfig_Line25B = @strConfig_Line25B
		, strConfig_Line27 = @strConfig_Line27
		, strConfig_Line28 = @strConfig_Line28
		, strFEIN = @strFEIN


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