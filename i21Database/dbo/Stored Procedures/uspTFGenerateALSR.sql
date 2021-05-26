CREATE PROCEDURE [dbo].[uspTFGenerateALSR]
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
		-- , @line1A NUMERIC(18, 6) = 0.00
		-- , @line1B NUMERIC(18, 6) = 0.00
		-- , @line1D NUMERIC(18, 6) = 0.00
		-- , @line1E NUMERIC(18, 6) = 0.00
		, @line2A NUMERIC(18, 6) = 0.00
		, @line2B NUMERIC(18, 6) = 0.00
		, @line2D NUMERIC(18, 6) = 0.00
		, @line2E NUMERIC(18, 6) = 0.00
		, @line3A NUMERIC(18, 6) = 0.00
		, @line3B NUMERIC(18, 6) = 0.00
		, @line3D NUMERIC(18, 6) = 0.00
		, @line3E NUMERIC(18, 6) = 0.00
		, @line4A NUMERIC(18, 6) = 0.00
		, @line4B NUMERIC(18, 6) = 0.00
		, @line4D NUMERIC(18, 6) = 0.00
		, @line4E NUMERIC(18, 6) = 0.00
		, @line5A NUMERIC(18, 6) = 0.00
		, @line5B NUMERIC(18, 6) = 0.00
		, @line5D NUMERIC(18, 6) = 0.00
		, @line5E NUMERIC(18, 6) = 0.00
		, @line6A NUMERIC(18, 6) = 0.00
		, @line6B NUMERIC(18, 6) = 0.00
		, @line6D NUMERIC(18, 6) = 0.00
		, @line6E NUMERIC(18, 6) = 0.00
		, @line7A NUMERIC(18, 6) = 0.00
		, @line7B NUMERIC(18, 6) = 0.00
		, @line7D NUMERIC(18, 6) = 0.00
		, @line7E NUMERIC(18, 6) = 0.00
		, @line8A NUMERIC(18, 6) = 0.00
		, @line8B NUMERIC(18, 6) = 0.00
		, @line8D NUMERIC(18, 6) = 0.00
		, @line8E NUMERIC(18, 6) = 0.00
		, @line9A NUMERIC(18, 6) = 0.00
		, @line9B NUMERIC(18, 6) = 0.00
		, @line9D NUMERIC(18, 6) = 0.00
		, @line9E NUMERIC(18, 6) = 0.00
		, @line10A NUMERIC(18, 6) = 0.00
		, @line10B NUMERIC(18, 6) = 0.00
		, @line10D NUMERIC(18, 6) = 0.00
		, @line10E NUMERIC(18, 6) = 0.00		
		, @line11A NUMERIC(18, 6) = 0.00
		, @line11B NUMERIC(18, 6) = 0.00
		, @line11D NUMERIC(18, 6) = 0.00
		, @line11E NUMERIC(18, 6) = 0.00		
		, @line12A NUMERIC(18, 6) = 0.00
		, @line12B NUMERIC(18, 6) = 0.00
		, @line12D NUMERIC(18, 6) = 0.00
		, @line12E NUMERIC(18, 6) = 0.00
		, @line13A NUMERIC(18, 6) = 0.00
		, @line13B NUMERIC(18, 6) = 0.00
		, @line13D NUMERIC(18, 6) = 0.00
		, @line13E NUMERIC(18, 6) = 0.00
		, @line14A NUMERIC(18, 6) = 0.00
		, @line14B NUMERIC(18, 6) = 0.00
		, @line14D NUMERIC(18, 6) = 0.00
		, @line14E NUMERIC(18, 6) = 0.00
		, @line15 NUMERIC(18, 6) = 0.00
		, @line16A NUMERIC(18, 6) = 0.00
		, @line16B NUMERIC(18, 6) = 0.00
		, @line16C NUMERIC(18, 6) = 0.00
		, @line17A NUMERIC(18, 6) = 0.00
		, @line17B NUMERIC(18, 6) = 0.00
		, @line17C NUMERIC(18, 6) = 0.00
		, @line18A NUMERIC(18, 6) = 0.00
		, @line18B NUMERIC(18, 6) = 0.00
		, @line18C NUMERIC(18, 6) = 0.00
		, @line18D NUMERIC(18, 6) = 0.00
		, @line18E NUMERIC(18, 6) = 0.00
		, @line19A NUMERIC(18, 6) = 0.00
		, @line19B NUMERIC(18, 6) = 0.00
		, @line19C NUMERIC(18, 6) = 0.00
		, @line19D NUMERIC(18, 6) = 0.00
		, @line19E NUMERIC(18, 6) = 0.00
		, @line20A NUMERIC(18, 6) = 0.00
		, @line20B NUMERIC(18, 6) = 0.00
		, @line20C NUMERIC(18, 6) = 0.00
		, @line20D NUMERIC(18, 6) = 0.00
		, @line20E NUMERIC(18, 6) = 0.00
		, @line21D NUMERIC(18, 6) = 0.00
		, @line21E NUMERIC(18, 6) = 0.00
		, @line22 NUMERIC(18, 6) = 0.00
		--, @line22A NUMERIC(18, 6) = 0.00
		--, @line22B NUMERIC(18, 6) = 0.00
		--, @line22C NUMERIC(18, 6) = 0.00
		--, @line22D NUMERIC(18, 6) = 0.00
		--, @line22E NUMERIC(18, 6) = 0.00
		, @line23A NUMERIC(18, 6) = 0.00
		, @line23B NUMERIC(18, 6) = 0.00
		, @line23C NUMERIC(18, 6) = 0.00
		, @line23D NUMERIC(18, 6) = 0.00
		, @line23E NUMERIC(18, 6) = 0.00
		, @line24A NUMERIC(18, 6) = 0.00
		, @line24B NUMERIC(18, 6) = 0.00
		, @line24C NUMERIC(18, 6) = 0.00
		, @line24D NUMERIC(18, 6) = 0.00
		, @line24E NUMERIC(18, 6) = 0.00
		, @line25A NUMERIC(18, 6) = 0.00
		, @line25B NUMERIC(18, 6) = 0.00
		, @line25C NUMERIC(18, 6) = 0.00
		, @line25D NUMERIC(18, 6) = 0.00
		, @line25E NUMERIC(18, 6) = 0.00
		, @line27A NUMERIC(18, 6) = 0.00
		, @line28A NUMERIC(18, 6) = 0.00
		, @line28B NUMERIC(18, 6) = 0.00
		, @line28C NUMERIC(18, 6) = 0.00
		, @line28D NUMERIC(18, 6) = 0.00
		, @line28E NUMERIC(18, 6) = 0.00
		, @line29A NUMERIC(18, 6) = 0.00
		, @line29B NUMERIC(18, 6) = 0.00
		, @line29C NUMERIC(18, 6) = 0.00
		, @line29D NUMERIC(18, 6) = 0.00
		, @line29E NUMERIC(18, 6) = 0.00
		-- , @line30A NUMERIC(18, 6) = 0.00
		-- , @line30B NUMERIC(18, 6) = 0.00
		-- , @line30C NUMERIC(18, 6) = 0.00
		-- , @line30D NUMERIC(18, 6) = 0.00
		-- , @line30E NUMERIC(18, 6) = 0.00
		-- , @line31A NUMERIC(18, 6) = 0.00
		-- , @line31B NUMERIC(18, 6) = 0.00
		-- , @line31C NUMERIC(18, 6) = 0.00
		-- , @line31D NUMERIC(18, 6) = 0.00
		-- , @line31E NUMERIC(18, 6) = 0.00
		, @line32A NUMERIC(18, 6) = 0.00
		, @line32B NUMERIC(18, 6) = 0.00
		, @line32C NUMERIC(18, 6) = 0.00
		, @line32D NUMERIC(18, 6) = 0.00
		, @line32E NUMERIC(18, 6) = 0.00
		, @line33A NUMERIC(18, 6) = 0.00
		, @line33B NUMERIC(18, 6) = 0.00
		, @line33D NUMERIC(18, 6) = 0.00
		, @line33E NUMERIC(18, 6) = 0.00	
		, @line34A NUMERIC(18, 6) = 0.00
		, @line34B NUMERIC(18, 6) = 0.00
		, @line34D NUMERIC(18, 6) = 0.00
		, @line34E NUMERIC(18, 6) = 0.00
		, @strConfig_Line2A NVARCHAR(20) = NULL
		, @strConfig_Line2B NVARCHAR(20) = NULL
		, @strConfig_Line2D NVARCHAR(20) = NULL
		, @strConfig_Line2E NVARCHAR(20) = NULL
		, @strConfig_Line4 NVARCHAR(20) = NULL
		, @strConfig_Line5 NVARCHAR(20) = NULL
		, @strConfig_Line11A NVARCHAR(20) = NULL
		, @strConfig_Line11B NVARCHAR(20) = NULL
		, @strConfig_Line11D NVARCHAR(20) = NULL
		, @strConfig_Line11E NVARCHAR(20) = NULL
		, @strConfig_Line12A NVARCHAR(20) = NULL
		, @strConfig_Line12B NVARCHAR(20) = NULL
		, @strConfig_Line12D NVARCHAR(20) = NULL
		, @strConfig_Line12E NVARCHAR(20) = NULL
		, @strConfig_Line13A NVARCHAR(20) = NULL
		, @strConfig_Line13B NVARCHAR(20) = NULL
		, @strConfig_Line13D NVARCHAR(20) = NULL
		, @strConfig_Line13E NVARCHAR(20) = NULL
		, @dblConfig_Line4 NUMERIC(18, 6) = 0.00
		, @dblConfig_Line5 NUMERIC(18, 6) = 0.00
		, @strFEIN NVARCHAR(50) = NULL
		, @strLicenseNumber NVARCHAR(50) = NULL

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
		SELECT @strFEIN	= NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-FEIN'
		SELECT @strLicenseNumber = NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-LicenseNumber'

		SELECT @strConfig_Line2A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line2A'
		SELECT @strConfig_Line2B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line2B'
		SELECT @strConfig_Line2D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line2D'
		SELECT @strConfig_Line2E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line2E'	
		SELECT @strConfig_Line4 = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line4'
		SELECT @strConfig_Line5 = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line5'

		SELECT @line7A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line7A'
		SELECT @line7B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line7B'
		SELECT @line7D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line7D'
		SELECT @line7E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line7E'

		SELECT @line8A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line8A'
		SELECT @line8B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line8B'
		SELECT @line8D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line8D'
		SELECT @line8E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line8E'

		SELECT @line9A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line9A'
		SELECT @line9B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line9B'
		SELECT @line9D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line9D'
		SELECT @line9E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line9E'

		SELECT @line11A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line11A'
		SELECT @line11B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line11B'
		SELECT @line11D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line11D'
		SELECT @line11E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line11E'

		SELECT @line12A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line12A'
		SELECT @line12B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line12B'
		SELECT @line12D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line12D'
		SELECT @line12E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line12E'

		SELECT @line13A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line13A'
		SELECT @line13B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line13B'
		SELECT @line13D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line13D'
		SELECT @line13E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_SR-Line13E'

		SET @line2A = CONVERT(NUMERIC(18,6), @strConfig_Line2A) 
		SET @line2B = CONVERT(NUMERIC(18,6), @strConfig_Line2B) 
		SET @line2D = CONVERT(NUMERIC(18,6), @strConfig_Line2D) 
		SET @line2E = CONVERT(NUMERIC(18,6), @strConfig_Line2E)
		SET @dblConfig_Line4 = CONVERT(NUMERIC(18,6), @strConfig_Line4) 
		SET @dblConfig_Line5 = CONVERT(NUMERIC(18,6), @strConfig_Line5) 

		SELECT @line16A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5A' AND strType = 'Gasoline'
		SELECT @line16B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5A' AND strType = 'Undyed Diesel'
		SELECT @line16C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5A' AND strType = 'Dyed Diesel'

		SELECT @line17A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5C' AND strType = 'Gasoline'
		SELECT @line17B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5C' AND strType = 'Undyed Diesel'
		SELECT @line17C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5C' AND strType = 'Dyed Diesel'

		SELECT @line18A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '2' AND strType = 'Gasoline'
		SELECT @line18B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '2' AND strType = 'Undyed Diesel'
		SELECT @line18C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '2' AND strType = 'Dyed Diesel'
		SELECT @line18D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '2' AND strType = 'Aviation Gas'
		SELECT @line18E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '2' AND strType = 'Jet Fuel'
	
		SELECT @line19A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5Q' AND strType = 'Gasoline'
		SELECT @line19B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5Q' AND strType = 'Undyed Diesel'
		SELECT @line19C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5Q' AND strType = 'Dyed Diesel'
		SELECT @line19D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5Q' AND strType = 'Aviation Gas'
		SELECT @line19E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '5Q' AND strType = 'Jet Fuel'
	
		SELECT @line20A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11B' AND strType = 'Gasoline'
		SELECT @line20B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
		SELECT @line20C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
		SELECT @line20D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11B' AND strType = 'Aviation Gas'
		SELECT @line20E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11B' AND strType = 'Jet Fuel'
	
		SELECT @line21D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '10B' AND strType = 'Aviation Gas'
		SELECT @line21E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '10B' AND strType = 'Jet Fuel'
	
		SELECT @line22 = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '2B' AND strType = 'Other'
		
		SET @line23A = @line16A + @line17A + @line18A + @line19A + @line20A + @line22
		SET @line23B = @line16B + @line17B + @line18B + @line19B + @line20B + @line22
		SET @line23C = @line16C + @line17C + @line18C + @line19C + @line20C + @line22
		SET @line23D = @line18D + @line19D + @line20D + @line22
		SET @line23E = @line18E + @line19E + @line20E + @line22

		SELECT @line24A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode IN ('7A_TN', '7A_MS', '7A_GA', '7A_FL') AND strType = 'Gasoline'
		SELECT @line24B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode IN ('7A_TN', '7A_MS', '7A_GA', '7A_FL') AND strType = 'Undyed Diesel'
		SELECT @line24C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode IN ('7A_TN', '7A_MS', '7A_GA', '7A_FL') AND strType = 'Dyed Diesel'
		SELECT @line24D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode IN ('7A_TN', '7A_MS', '7A_GA', '7A_FL') AND strType = 'Aviation Gas'
		SELECT @line24E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode IN ('7A_TN', '7A_MS', '7A_GA', '7A_FL') AND strType = 'Jet Fuel'
	
		SELECT @line25A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '8' AND strType = 'Gasoline'
		SELECT @line25B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '8' AND strType = 'Undyed Diesel'
		SELECT @line25C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '8' AND strType = 'Dyed Diesel'
		SELECT @line25D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '8' AND strType = 'Aviation Gas'
		SELECT @line25E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '8' AND strType = 'Jet Fuel'
	
		SELECT @line27A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '10Z' AND strType = 'Gasoline'
			
		SELECT @line28A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11A' AND strType = 'Gasoline'
		SELECT @line28B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11A' AND strType = 'Undyed Diesel'
		SELECT @line28C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11A' AND strType = 'Dyed Diesel'
		SELECT @line28D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11A' AND strType = 'Aviation Gas'
		SELECT @line28E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '11A' AND strType = 'Jet Fuel'

		SET @line29A = @line24A + @line25A + @line27A + @line28A
		SET @line29B = @line24B + @line25B + @line28B
		SET @line29C = @line24C + @line25C + @line28C
		SET @line29D = @line24D + @line25D + @line28D
		SET @line29E = @line24E + @line25E + @line28E

		SET @line32A = @line29A - @line23A
		SET @line32B = @line29B - @line23B
		SET @line32C = @line29C - @line23C
		SET @line32D = @line29D - @line23D
		SET @line32E = @line29E - @line23E

		SELECT @line33A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '1' AND strType = 'Gasoline'
		SELECT @line33B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '1' AND strType = 'Undyed Diesel'
		SELECT @line33D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '1' AND strType = 'Aviation Gas'
		SELECT @line33E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-SR' AND strScheduleCode = '1' AND strType = 'Jet Fuel'

		SET @line34A = @line33A - @line32A
		SET @line34B = @line33B - @line32B
		SET @line34D = @line33D - @line32D
		SET @line34E = @line33E - @line32E

		SET @line3A = @line34A * @line2A
		SET @line3B = @line34B * @line2B
		SET @line3D = @line34D * @line2D
		SET @line3E = @line34E * @line2E

		SET @line4A = @line3A * @dblConfig_Line4
		SET @line4B = @line3B * @dblConfig_Line4
		SET @line4D = @line3D * @dblConfig_Line4
		SET @line4E = @line3E * @dblConfig_Line4

		SET @line5A = @line3A * @dblConfig_Line5
		SET @line5B = @line3B * @dblConfig_Line5
		SET @line5D = @line3D * @dblConfig_Line5
		SET @line5E = @line3E * @dblConfig_Line5

		SET @line6A = (@line4A + @line5A) - @dblConfig_Line5
		SET @line6B = (@line4B + @line5B) - @dblConfig_Line5
		SET @line6D = (@line4D + @line5D) - @dblConfig_Line5
		SET @line6E = (@line4E + @line5E) - @dblConfig_Line5

		SET @line10A = ((@line7A + @line9A) - @line6A) + @line8A
		SET @line10B = ((@line7B + @line9B) - @line6B) + @line8B
		SET @line10D = ((@line7D + @line9D) - @line6D) + @line8D
		SET @line10E = ((@line7E + @line9E) - @line6E) + @line8E

		SET @line14A = @line10A + @line11A + @line12A + @line13A
		SET @line14B = @line10B + @line11B + @line12B + @line13B
		SET @line14D = @line10D + @line11D + @line12D + @line13D
		SET @line14E = @line10E + @line11E + @line12E + @line13E

		SET @line15 = @line14A + @line14B + @line14D + @line14E

	END

	SELECT dtmFrom =  @dtmFrom
		, dtmTo =  @dtmTo
		, line1A =  @line34A
		, line1B =  @line34B
		, line1D =  @line34D
		, line1E =  @line34E
		, line2A =  @line2A
		, line2B =  @line2B
		, line2D =  @line2D
		, line2E =  @line2E
		, line3A =  @line3A
		, line3B =  @line3B
		, line3D =  @line3D
		, line3E =  @line3E
		, line4A =  @line4A
		, line4B =  @line4B
		, line4D =  @line4D
		, line4E =  @line4E
		, line5A =  @line5A
		, line5B =  @line5B
		, line5D =  @line5D
		, line5E =  @line5E
		, line6A =  @line6A
		, line6B =  @line6B
		, line6D =  @line6D
		, line6E =  @line6E
		, line7A =  @line7A
		, line7B =  @line7B
		, line7D =  @line7D
		, line7E =  @line7E
		, line8A =  @line8A
		, line8B =  @line8B
		, line8D =  @line8D
		, line8E =  @line8E
		, line9A =  @line9A
		, line9B =  @line9B
		, line9D =  @line9D
		, line9E =  @line9E
		, line10A =  @line10A
		, line10B =  @line10B
		, line10D =  @line10D
		, line10E =  @line10E
		, line11A =  @line11A
		, line11B =  @line11B
		, line11D =  @line11D
		, line11E =  @line11E
		, line12A =  @line12A
		, line12B =  @line12B
		, line12D =  @line12D
		, line12E =  @line12E
		, line13A =  @line13A
		, line13B =  @line13B
		, line13D =  @line13D
		, line13E =  @line13E
		, line14A =  @line14A
		, line14B =  @line14B
		, line14D =  @line14D
		, line14E =  @line14E
		, line15 =  @line15
		, line16A =  @line16A
		, line16B =  @line16B
		, line16C =  @line16C
		, line17A =  @line17A
		, line17B =  @line17B
		, line17C =  @line17C
		, line18A =  @line18A
		, line18B =  @line18B
		, line18C =  @line18C
		, line18D =  @line18D
		, line18E =  @line18E
		, line19A =  @line19A
		, line19B =  @line19B
		, line19C =  @line19C
		, line19D =  @line19D
		, line19E =  @line19E
		, line20A =  @line20A
		, line20B =  @line20B
		, line20C =  @line20C
		, line20D =  @line20D
		, line20E =  @line20E
		, line21D =  @line21D
		, line21E =  @line21E
		, line22A =  @line22
		, line22B =  @line22
		, line22C =  @line22
		, line22D =  @line22
		, line22E =  @line22
		, line23A =  @line23A
		, line23B =  @line23B
		, line23C =  @line23C
		, line23D =  @line23D
		, line23E =  @line23E
		, line24A =  @line24A
		, line24B =  @line24B
		, line24C =  @line24C
		, line24D =  @line24D
		, line24E =  @line24E
		, line25A =  @line25A
		, line25B =  @line25B
		, line25C =  @line25C
		, line25D =  @line25D
		, line25E =  @line25E
		, line27A =  @line27A
		, line28A =  @line28A
		, line28B =  @line28B
		, line28C =  @line28C
		, line28D =  @line28D
		, line28E =  @line28E
		, line29A =  @line29A
		, line29B =  @line29B
		, line29C =  @line29C
		, line29D =  @line29D
		, line29E =  @line29E
		, line30A =  @line23A
		, line30B =  @line23B
		, line30C =  @line23C
		, line30D =  @line23D
		, line30E =  @line23E
		, line31A =  @line29A
		, line31B =  @line29B
		, line31C =  @line29C
		, line31D =  @line29D
		, line31E =  @line29E
		, line32A =  @line32A
		, line32B =  @line32B
		, line32C =  @line32C
		, line32D =  @line32D
		, line32E =  @line32E
		, line33A =  @line33A
		, line33B =  @line33B
		, line33D =  @line33D
		, line33E =  @line33E
		, line34A =  @line34A
		, line34B =  @line34B
		, line34D =  @line34D
		, line34E =  @line34E
		, strConfig_Line2A =  @strConfig_Line2A
		, strConfig_Line2B =  @strConfig_Line2B
		, strConfig_Line2D =  @strConfig_Line2D
		, strConfig_Line2E =  @strConfig_Line2E
		, strConfig_Line4 =  @strConfig_Line4
		, strConfig_Line5 =  @strConfig_Line5
		-- , strConfig_Line11A =  @strConfig_Line11A
		-- , strConfig_Line11B =  @strConfig_Line11B
		-- , strConfig_Line11D =  @strConfig_Line11D
		-- , strConfig_Line11E =  @strConfig_Line11E
		-- , strConfig_Line12A =  @strConfig_Line12A
		-- , strConfig_Line12B =  @strConfig_Line12B
		-- , strConfig_Line12D =  @strConfig_Line12D
		-- , strConfig_Line12E =  @strConfig_Line12E
		-- , strConfig_Line13A =  @strConfig_Line13A
		-- , strConfig_Line13B =  @strConfig_Line13B
		-- , strConfig_Line13D =  @strConfig_Line13D
		-- , strConfig_Line13E =  @strConfig_Line13E
		, strFEIN =  @strFEIN
		, strLicenseNumber =  @strLicenseNumber

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