CREATE PROCEDURE [dbo].[uspTFGenerateALEXPR]
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
		, @line1A NUMERIC(18, 6) = 0.00
		, @line1B NUMERIC(18, 6) = 0.00
		, @line1D NUMERIC(18, 6) = 0.00
		, @line1E NUMERIC(18, 6) = 0.00
		, @line2A NUMERIC(18, 6) = 0.00
		, @line2B NUMERIC(18, 6) = 0.00
		, @line2C NUMERIC(18, 6) = 0.00
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
		, @line6C NUMERIC(18, 6) = 0.00
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
		, @line13 NUMERIC(18, 6) = 0.00
		--, @strConfig_Line4A NVARCHAR(20) = NULL
		--, @strConfig_Line4B NVARCHAR(20) = NULL
		--, @strConfig_Line4D NVARCHAR(20) = NULL
		--, @strConfig_Line4E NVARCHAR(20) = NULL
		--, @strConfig_Line7A NVARCHAR(20) = NULL
		--, @strConfig_Line7B NVARCHAR(20) = NULL
		--, @strConfig_Line7D NVARCHAR(20) = NULL
		--, @strConfig_Line7E NVARCHAR(20) = NULL
		--, @strConfig_Line9A NVARCHAR(20) = NULL
		--, @strConfig_Line9B NVARCHAR(20) = NULL
		--, @strConfig_Line9D NVARCHAR(20) = NULL
		--, @strConfig_Line9E NVARCHAR(20) = NULL
		--, @strConfig_Line10A NVARCHAR(20) = NULL
		--, @strConfig_Line10B NVARCHAR(20) = NULL
		--, @strConfig_Line10D NVARCHAR(20) = NULL
		--, @strConfig_Line10E NVARCHAR(20) = NULL
		--, @strConfig_Line11A NVARCHAR(20) = NULL
		--, @strConfig_Line11B NVARCHAR(20) = NULL
		--, @strConfig_Line11D NVARCHAR(20) = NULL
		--, @strConfig_Line11E NVARCHAR(20) = NULL
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
		SELECT @strFEIN	= NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-FEIN'
		SELECT @strLicenseNumber = NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-LicenseNumber'

		SELECT @line4A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line4A'
		SELECT @line4B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line4B'
		SELECT @line4D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line4D'
		SELECT @line4E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line4E'	

		SELECT @line7A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line7A'
		SELECT @line7B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line7B'
		SELECT @line7D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line7D'
		SELECT @line7E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line7E'

		SELECT @line9A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line9A'
		SELECT @line9B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line9B'
		SELECT @line9D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line9D'
		SELECT @line9E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line9E'

		SELECT @line10A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line10A'
		SELECT @line10B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line10B'
		SELECT @line10D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line10D'
		SELECT @line10E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line10E'

		SELECT @line11A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line11A'
		SELECT @line11B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line11B'
		SELECT @line11D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line11D'
		SELECT @line11E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_EXPR-Line11E'

		SELECT @line1A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '7B' AND strType = 'Gasoline'
		SELECT @line1B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '7B' AND strType = 'Undyed Diesel'
		SELECT @line1D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '7B' AND strType = 'Aviation Gas'
		SELECT @line1E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '7B' AND strType = 'Jet Fuel'

		SELECT @line2A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode IN ('11A_TN','11A_MS','11A_GA','11A_FL') AND strType = 'Gasoline'
		SELECT @line2B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode IN ('11A_TN','11A_MS','11A_GA','11A_FL') AND strType = 'Undyed Diesel'
		SELECT @line2C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode IN ('11A_TN','11A_MS','11A_GA','11A_FL') AND strType = 'Dyed Diesel'
		SELECT @line2D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode IN ('11A_TN','11A_MS','11A_GA','11A_FL') AND strType = 'Aviation Gas'
		SELECT @line2E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode IN ('11A_TN','11A_MS','11A_GA','11A_FL') AND strType = 'Jet Fuel'
	
		SET @line3A = @line1A + @line2A 
		SET @line3B = @line1B + @line2B	
		SET @line3D = @line1D + @line2D
		SET @line3E = @line1E + @line2E

		SET @line5A = @line3A * @line4A 
		SET @line5B = @line3B * @line4B	
		SET @line5D = @line3D * @line4D
		SET @line5E = @line3E * @line4E

		SELECT @line6A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '11B' AND strType = 'Gasoline'
		SELECT @line6B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
		SELECT @line6C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
		SELECT @line6D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '11B' AND strType = 'Aviation Gas'
		SELECT @line6E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-EXPR' AND strScheduleCode = '11B' AND strType = 'Jet Fuel'

		SET @line8A = @line6A * @line7A
		SET @line8B = @line6B * @line7B
		SET @line8D = @line6D * @line7D
		SET @line8E = @line6E * @line7E

		SET @line12A = @line8A + @line9A + @line10A + @line11A
		SET @line12B = @line8B + @line9B + @line10B + @line11B
		SET @line12D = @line8D + @line9D + @line10D + @line11D
		SET @line12E = @line8E + @line9E + @line10E + @line11E

		SET @line13 = @line12A + @line12B + @line12D + @line12E

	END

	SELECT dtmFrom  =  @dtmFrom 
		, dtmTo  =  @dtmTo 
		, line1A  =  @line1A 
		, line1B  =  @line1B 
		, line1D  =  @line1D 
		, line1E  =  @line1E 
		, line2A  =  @line2A 
		, line2B  =  @line2B 
		, line2C  =  @line2C 
		, line2D  =  @line2D 
		, line2E  =  @line2E 
		, line3A  =  @line3A 
		, line3B  =  @line3B 
		, line3D  =  @line3D 
		, line3E  =  @line3E 
		, line4A  =  @line4A 
		, line4B  =  @line4B 
		, line4D  =  @line4D 
		, line4E  =  @line4E 
		, line5A  =  @line5A 
		, line5B  =  @line5B 
		, line5D  =  @line5D 
		, line5E  =  @line5E 
		, line6A  =  @line6A 
		, line6B  =  @line6B 
		, line6C  =  @line6C 
		, line6D  =  @line6D 
		, line6E  =  @line6E 
		, line7A  =  @line7A 
		, line7B  =  @line7B 
		, line7D  =  @line7D 
		, line7E  =  @line7E 
		, line8A  =  @line8A 
		, line8B  =  @line8B 
		, line8D  =  @line8D 
		, line8E  =  @line8E 
		, line9A  =  @line9A 
		, line9B  =  @line9B 
		, line9D  =  @line9D 
		, line9E  =  @line9E 
		, line10A  =  @line10A 
		, line10B  =  @line10B 
		, line10D  =  @line10D 
		, line10E  =  @line10E 
		, line11A  =  @line11A 
		, line11B  =  @line11B 
		, line11D  =  @line11D 
		, line11E  =  @line11E 
		, line12A  =  @line12A 
		, line12B  =  @line12B 
		, line12D  =  @line12D 
		, line12E  =  @line12E 
		, line13  =  @line13 
		, strFEIN  =  @strFEIN 
		, strLicenseNumber  =  @strLicenseNumber 


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