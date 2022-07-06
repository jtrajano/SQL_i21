CREATE PROCEDURE [dbo].[uspTFGenerateALIMR]
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
		--, @line1A NUMERIC(18, 6) = 0.00
		--, @line1B NUMERIC(18, 6) = 0.00
		--, @line1D NUMERIC(18, 6) = 0.00
		--, @line1E NUMERIC(18, 6) = 0.00
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
		, @line8 NUMERIC(18, 6) = 0.00
		, @line9A NUMERIC(18, 6) = 0.00
		, @line9B NUMERIC(18, 6) = 0.00
		, @line9C NUMERIC(18, 6) = 0.00
		, @line9D NUMERIC(18, 6) = 0.00
		, @line9E NUMERIC(18, 6) = 0.00
		, @line10A NUMERIC(18, 6) = 0.00
		, @line10B NUMERIC(18, 6) = 0.00
		, @line10C NUMERIC(18, 6) = 0.00
		, @line10D NUMERIC(18, 6) = 0.00
		, @line10E NUMERIC(18, 6) = 0.00				
		, @line11A NUMERIC(18, 6) = 0.00
		, @line11B NUMERIC(18, 6) = 0.00
		, @line11C NUMERIC(18, 6) = 0.00
		, @line11D NUMERIC(18, 6) = 0.00
		, @line11E NUMERIC(18, 6) = 0.00			
		, @line12A NUMERIC(18, 6) = 0.00
		, @line12B NUMERIC(18, 6) = 0.00
		, @line12C NUMERIC(18, 6) = 0.00
		, @line12D NUMERIC(18, 6) = 0.00
		, @line12E NUMERIC(18, 6) = 0.00
		, @line13A NUMERIC(18, 6) = 0.00
		, @line13B NUMERIC(18, 6) = 0.00
		, @line13C NUMERIC(18, 6) = 0.00
		, @line13D NUMERIC(18, 6) = 0.00
		, @line13E NUMERIC(18, 6) = 0.00
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
		SELECT @strFEIN	= NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-FEIN'
		SELECT @strLicenseNumber = NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-LicenseNumber'

		SELECT @line2A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line2A'
		SELECT @line2B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line2B'
		SELECT @line2D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line2D'
		SELECT @line2E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line2E'	

		SELECT @line4A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line4A'
		SELECT @line4B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line4B'
		SELECT @line4D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line4D'
		SELECT @line4E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line4E'

		SELECT @line5A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line5A'
		SELECT @line5B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line5B'
		SELECT @line5D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line5D'
		SELECT @line5E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line5E'

		SELECT @line6A = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line6A'
		SELECT @line6B = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line6B'
		SELECT @line6D = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line6D'
		SELECT @line6E = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_IMR-Line6E'
	

		SELECT @line9A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '3B' AND strType = 'Gasoline'
		SELECT @line9B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '3B' AND strType = 'Undyed Diesel'
		SELECT @line9C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '3B' AND strType = 'Dyed Diesel'
		SELECT @line9D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '3B' AND strType = 'Aviation Gas'
		SELECT @line9E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '3B' AND strType = 'Jet Fuel'

		SELECT @line10A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Gasoline'
		SELECT @line10B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
		SELECT @line10C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
		SELECT @line10D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Aviation Gas'
		SELECT @line10E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Jet Fuel'
	
		SELECT @line10A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Gasoline'
		SELECT @line10B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
		SELECT @line10C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
		SELECT @line10D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Aviation Gas'
		SELECT @line10E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '11B' AND strType = 'Jet Fuel'

		SET @line11A = @line9A + @line10A 
		SET @line11B = @line9B + @line10B
		SET @line11C = @line9C + @line10C		
		SET @line11D = @line9D + @line10D
		SET @line11E = @line9E + @line10E

		SELECT @line12A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1A' AND strType = 'Gasoline'
		SELECT @line12B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1A' AND strType = 'Undyed Diesel'
		SELECT @line12C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1A' AND strType = 'Dyed Diesel'
		SELECT @line12D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1A' AND strType = 'Aviation Gas'
		SELECT @line12E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1A' AND strType = 'Jet Fuel'

		SELECT @line13A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1C' AND strType = 'Gasoline'
		SELECT @line13B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1C' AND strType = 'Undyed Diesel'
		SELECT @line13C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1C' AND strType = 'Dyed Diesel'
		SELECT @line13D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1C' AND strType = 'Aviation Gas'
		SELECT @line13E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-IMR' AND strScheduleCode = '1C' AND strType = 'Jet Fuel'

		SET @line3A = @line11A * @line2A
		SET @line3B = @line11B * @line2B
		SET @line3D = @line11D * @line2D
		SET @line3E = @line11E * @line2E

		SET @line7A = @line3A + @line4A + @line5A + @line6A
		SET @line7B = @line3B + @line4B + @line5B + @line6B
		SET @line7D = @line3D + @line4D + @line5D + @line6D
		SET @line7E = @line3E + @line4E + @line5E + @line6E

		SET @line8 = @line7A + @line7B + @line7D + @line7E

	END

	SELECT dtmFrom  =  @dtmFrom 
		, dtmTo  =  @dtmTo 
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
		, line8 =  @line8
		, line9A =  @line9A
		, line9B =  @line9B
		, line9C =  @line9C
		, line9D =  @line9D
		, line9E =  @line9E
		, line10A =  @line10A
		, line10B =  @line10B
		, line10C =  @line10C
		, line10D =  @line10D
		, line10E =  @line10E
		, line11A =  @line11A
		, line11B =  @line11B
		, line11C =  @line11C
		, line11D =  @line11D
		, line11E =  @line11E
		, line12A =  @line12A
		, line12B =  @line12B
		, line12C =  @line12C
		, line12D =  @line12D
		, line12E =  @line12E
		, line13A =  @line13A
		, line13B =  @line13B
		, line13C =  @line13C
		, line13D =  @line13D
		, line13E =  @line13E
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