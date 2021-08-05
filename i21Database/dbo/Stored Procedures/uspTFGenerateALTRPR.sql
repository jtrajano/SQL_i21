CREATE PROCEDURE [dbo].[uspTFGenerateALTRPR]
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
		, @line1C NUMERIC(18, 6) = 0.00
		, @line1D NUMERIC(18, 6) = 0.00
		, @line1E NUMERIC(18, 6) = 0.00
		, @line2A NUMERIC(18, 6) = 0.00
		, @line2B NUMERIC(18, 6) = 0.00
		, @line2C NUMERIC(18, 6) = 0.00
		, @line2D NUMERIC(18, 6) = 0.00
		, @line2E NUMERIC(18, 6) = 0.00
		, @line3A NUMERIC(18, 6) = 0.00
		, @line3B NUMERIC(18, 6) = 0.00
		, @line3C NUMERIC(18, 6) = 0.00
		, @line3D NUMERIC(18, 6) = 0.00
		, @line3E NUMERIC(18, 6) = 0.00
		, @line4A NUMERIC(18, 6) = 0.00
		, @line4B NUMERIC(18, 6) = 0.00
		, @line4C NUMERIC(18, 6) = 0.00
		, @line4D NUMERIC(18, 6) = 0.00
		, @line4E NUMERIC(18, 6) = 0.00
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
		SELECT @strFEIN	= NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_TRPR-FEIN'
		SELECT @strLicenseNumber = NULLIF(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MFT_TRPR-LicenseNumber'

		SELECT @line1A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14A' AND strType = 'Gasoline'
		SELECT @line1B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14A' AND strType = 'Undyed Diesel'
		SELECT @line1C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14A' AND strType = 'Dyed Diesel'
		SELECT @line1D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14A' AND strType = 'Aviation Gas'
		SELECT @line1E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14A' AND strType = 'Jet Fuel'

		SELECT @line2A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14B' AND strType = 'Gasoline'
		SELECT @line2B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14B' AND strType = 'Undyed Diesel'
		SELECT @line2C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14B' AND strType = 'Dyed Diesel'
		SELECT @line2D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14B' AND strType = 'Aviation Gas'
		SELECT @line2E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14B' AND strType = 'Jet Fuel'
	
		SELECT @line3A = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14C' AND strType = 'Gasoline'
		SELECT @line3B = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14C' AND strType = 'Undyed Diesel'
		SELECT @line3C = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14C' AND strType = 'Dyed Diesel'
		SELECT @line3D = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14C' AND strType = 'Aviation Gas'
		SELECT @line3E = ISNULL(SUM(ISNULL(dblGross,0)), 0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-TRPR' AND strScheduleCode = '14C' AND strType = 'Jet Fuel'

		SET @line4A = @line1A + @line2A + @line3A
		SET @line4B = @line1B + @line2B + @line3B
		SET @line4C = @line1C + @line2C	+ @line3C
		SET @line4D = @line1D + @line2D + @line3D
		SET @line4E = @line1E + @line2E + @line3E

	END

	SELECT dtmFrom  =  @dtmFrom 
		, dtmTo  =  @dtmTo 
		, line1A =  @line1A
		, line1B =  @line1B
		, line1C =  @line1C
		, line1D =  @line1D
		, line1E =  @line1E
		, line2A =  @line2A
		, line2B =  @line2B
		, line2C =  @line2C
		, line2D =  @line2D
		, line2E =  @line2E
		, line3A =  @line3A
		, line3B =  @line3B
		, line3C =  @line3C
		, line3D =  @line3D
		, line3E =  @line3E
		, line4A =  @line4A
		, line4B =  @line4B
		, line4C =  @line4C
		, line4D =  @line4D
		, line4E =  @line4E
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
