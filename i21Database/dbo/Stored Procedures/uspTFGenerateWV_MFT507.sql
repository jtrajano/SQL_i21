CREATE PROCEDURE [dbo].[uspTFGenerateWV_MFT507]
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
		
		, @dblL1Gross NUMERIC(18, 6) = 0.00
		, @dblL1Net NUMERIC(18, 6) = 0.00
		, @dblL2Gross NUMERIC(18, 6) = 0.00
		, @dblL2Net NUMERIC(18, 6) = 0.00
		, @dblL3Gross NUMERIC(18, 6) = 0.00
		, @dblL3Net NUMERIC(18, 6) = 0.00
		, @dblL4Gross NUMERIC(18, 6) = 0.00
		, @dblL4Net NUMERIC(18, 6) = 0.00
		, @strL5 NVARCHAR(20) = NULL


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


		SELECT @dblL1Gross = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-507' AND strScheduleCode = '1'
		SELECT @dblL1Net = ISNULL(SUM(dblNet),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-507' AND strScheduleCode = '1'
		SELECT @dblL2Gross = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-507' AND strScheduleCode = '2'
		SELECT @dblL2Net = ISNULL(SUM(dblNet),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-507' AND strScheduleCode = '2'
		SELECT @dblL3Gross = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-507' AND strScheduleCode = '3'
		SELECT @dblL3Net = ISNULL(SUM(dblNet),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-507' AND strScheduleCode = '3'

		SET @dblL4Gross = @dblL1Gross + @dblL2Gross + @dblL3Gross
		SET @dblL4Net  = @dblL1Net + @dblL2Net + @dblL3Net

		SELECT @strL5 = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT507-L5'
		
	END

	SELECT dtmFrom = @dtmFrom 
		, dtmTo = @dtmTo 
		, dblL1Gross =  @dblL1Gross 
		, dblL1Net =  @dblL1Net 
		, dblL2Gross =  @dblL2Gross 
		, dblL2Net =  @dblL2Net 
		, dblL3Gross =  @dblL3Gross 
		, dblL3Net =  @dblL3Net 
		, dblL4Gross =  @dblL4Gross 
		, dblL4Net =  @dblL4Net 
		, strL5 = @strL5

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
