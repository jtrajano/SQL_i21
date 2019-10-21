CREATE PROCEDURE [dbo].[uspTFGenerateNM41164]
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

		, @LPG_1 NUMERIC(18, 6) = 0.00
		, @LPG_2 NUMERIC(18, 6) = 0.00
		, @LPG_3 NUMERIC(18, 6) = 0.00
		, @LPG_4 NUMERIC(18, 6) = 0.00
		, @LPG_5 NUMERIC(18, 6) = 0.00
		, @LPG_6 NUMERIC(18, 6) = 0.00

		, @CNG_1 NUMERIC(18, 6) = 0.00
		, @CNG_2 NUMERIC(18, 6) = 0.00
		, @CNG_3 NUMERIC(18, 6) = 0.00
		, @CNG_4 NUMERIC(18, 6) = 0.00
		, @CNG_5 NUMERIC(18, 6) = 0.00
		, @CNG_6 NUMERIC(18, 6) = 0.00

		, @LNG_1 NUMERIC(18, 6) = 0.00
		, @LNG_2 NUMERIC(18, 6) = 0.00
		, @LNG_3 NUMERIC(18, 6) = 0.00
		, @LNG_4 NUMERIC(18, 6) = 0.00
		, @LNG_5 NUMERIC(18, 6) = 0.00
		, @LNG_6 NUMERIC(18, 6) = 0.00

		, @A55_1 NUMERIC(18, 6) = 0.00
		, @A55_2 NUMERIC(18, 6) = 0.00
		, @A55_3 NUMERIC(18, 6) = 0.00
		, @A55_4 NUMERIC(18, 6) = 0.00
		, @A55_5 NUMERIC(18, 6) = 0.00
		, @A55_6 NUMERIC(18, 6) = 0.00

		, @TaxDue NUMERIC(18, 6) = 0.00
		, @Penalty NUMERIC(18, 6) = 0.00
		, @Interest NUMERIC(18, 6) = 0.00
		, @TotalDue NUMERIC(18, 6) = 0.00

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

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NM'

		-- Configuration
		SELECT @LPG_5 = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'Form 41164' AND strTemplateItemId = 'NMAlt-TaxRateLPG'	
		SELECT @CNG_5= strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'Form 41164' AND strTemplateItemId = 'NMAlt-TaxRateCNG'	
		SELECT @LNG_5 = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'Form 41164' AND strTemplateItemId = 'NMAlt-TaxRateLNG'	
		SELECT @A55_5 = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'Form 41164' AND strTemplateItemId = 'NMAlt-TaxRateA55'	

		-- Transaction
		INSERT INTO @transaction (strFormCode, strScheduleCode, strType, dblReceived)
		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblQtyShipped, 0.00))
		FROM vyuTFGetTransaction Trans
		WHERE Trans.uniqTransactionGuid = @Guid
		GROUP BY strFormCode, strScheduleCode, strType

		-- Transaction Info
		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		SELECT @LPG_1= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Disbursed' AND strType = 'LPG'
		SELECT @LPG_2= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Exemptions' AND strType = 'LPG'
		SELECT @LPG_3= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Deductions' AND strType = 'LPG'
		SET @LPG_4 = @LPG_1 + @LPG_2 + @LPG_3
		SET @LPG_6 = CONVERT(NUMERIC(18,2), @LPG_4 * @LPG_5)
	
		SELECT @CNG_1= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Disbursed' AND strType = 'CNG'
		SELECT @CNG_2= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Exemptions' AND strType = 'CNG'
		SELECT @CNG_3= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Deductions' AND strType = 'CNG'
		SET @CNG_4 = @CNG_1 + @CNG_2 + @CNG_3
		SET @CNG_6 = CONVERT(NUMERIC(18,2), @CNG_4 * @CNG_5)

		SELECT @LNG_1= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Disbursed' AND strType = 'LNG'
		SELECT @LNG_2= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Exemptions' AND strType = 'LNG'
		SELECT @LNG_3= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Deductions' AND strType = 'LNG'
		SET @LNG_4 = @LNG_1 + @LNG_2 + @LNG_3
		SET @LNG_6 = CONVERT(NUMERIC(18,2), @LNG_4 * @LNG_5)

		SELECT @A55_1= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Disbursed' AND strType = 'A-55'
		SELECT @A55_2= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Exemptions' AND strType = 'A-55'
		SELECT @A55_3= ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'Form 41164' AND strScheduleCode = 'Deductions' AND strType = 'A-55'
		SET @A55_4 = @A55_1 + @A55_2 + @A55_3
		SET @A55_6 = CONVERT(NUMERIC(18,2), @A55_4 * @A55_5)

		SET @TaxDue = @LPG_6 + @CNG_6 + @LNG_6 + @A55_6

	END

	SELECT dtmFrom = @dtmFrom
		, dtmTo= @dtmTo

		, LPG_1 = @LPG_1 
		, LPG_2 = @LPG_2 
		, LPG_3 = @LPG_3 
		, LPG_4 = @LPG_4 
		, LPG_5 = @LPG_5 
		, LPG_6 = @LPG_6 

		, CNG_1 = @CNG_1 
		, CNG_2 = @CNG_2 
		, CNG_3 = @CNG_3 
		, CNG_4 = @CNG_4 
		, CNG_5 = @CNG_5 
		, CNG_6 = @CNG_6 

		, LNG_1 = @LNG_1 
		, LNG_2 = @LNG_2 
		, LNG_3 = @LNG_3 
		, LNG_4 = @LNG_4 
		, LNG_5 = @LNG_5 
		, LNG_6 = @LNG_6 

		, A55_1 = @A55_1 
		, A55_2 = @A55_2 
		, A55_3 = @A55_3 
		, A55_4 = @A55_4 
		, A55_5 = @A55_5 
		, A55_6 = @A55_6 

		, TaxDue = @TaxDue 


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