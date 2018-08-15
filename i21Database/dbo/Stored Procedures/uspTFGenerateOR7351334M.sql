CREATE PROCEDURE [dbo].[uspTFGenerateOR7351334M]
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

	DECLARE @Line_1 NUMERIC(18, 6) = 0
		, @Line_2 NUMERIC(18, 6) = 0
		, @Line_3 NUMERIC(18, 6) = 0
		, @Line_4 NUMERIC(18, 6) = 0
		, @Line_5 NUMERIC(18, 6) = 0
		, @Line_6 NUMERIC(18, 6) = 0
		, @Line_7 NUMERIC(18, 2) = 0
		, @Line_8 NUMERIC(18, 2) = 0
		, @Line_9 NUMERIC(18, 2) = 0
		, @Line_10 NUMERIC(18, 6) = 0
		, @Line_11 NUMERIC(18, 2) = 0
		, @Line_12 NUMERIC(18, 2) = 0
		, @Line_13 NUMERIC(18, 2) = 0
		, @Line_14 NUMERIC(18, 2) = 0
		, @Line_15 NUMERIC(18, 2) = 0
		, @Line_16 NUMERIC(18, 2) = 0
		, @Line_17 NUMERIC(18, 2) = 0

		, @TaxRate NUMERIC(18, 8) = 0
		, @CreditRate NUMERIC(18,8) = 0
		, @InterestRate NUMERIC(18,8) = 0

		, @dtmFrom DATE
		, @dtmTo DATE
		, @LicenseNumber NVARCHAR(50)
		
		, @strTaxRate NVARCHAR(20)
		, @strCreditRate NVARCHAR(20)
		, @strInterestRate NVARCHAR(20)

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

		DECLARE @TaxAuthorityId INT, @Guid NVARCHAR(100)

		DECLARE @transaction TFReportTransaction

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OR'

		-- Configuration
		SELECT TOP 1 @LicenseNumber = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-LicenseNumber'
		
		SELECT @Line_5 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-Line5'
		SELECT @strTaxRate = CASE WHEN ISNULL(strConfiguration, '') = '' THEN '0' ELSE strConfiguration END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-Line7'
		SELECT @strCreditRate = CASE WHEN ISNULL(strConfiguration, '') = '' THEN '0' ELSE strConfiguration END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-Line8'
		SELECT @strInterestRate = CASE WHEN ISNULL(strConfiguration, '') = '' THEN '0' ELSE strConfiguration END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-Line13'

	    SELECT @Line_5 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-Line5'


		SELECT @Line_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strTemplateItemId = '735-1344M-Line16'
		
		SET @TaxRate = CONVERT(NUMERIC(18,8), @strTaxRate)
		SET @CreditRate = CONVERT(NUMERIC(18,8), @strCreditRate)
		SET @InterestRate = CONVERT(NUMERIC(18,8), @strInterestRate)

		-- Transaction
		INSERT INTO @transaction (strFormCode, strScheduleCode, strType, dblReceived)
		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblQtyShipped, 0.00))
		FROM vyuTFGetTransaction Trans
		WHERE Trans.uniqTransactionGuid = @Guid
		GROUP BY strFormCode, strScheduleCode, strType

		-- Total of Transaction in SubReport
		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		DECLARE @Report TFReportOR7351334MSub
		DECLARE @TotalLine8 NVARCHAR(100) = NULL
		INSERT INTO @Report EXECUTE sp_executesql N'uspTFGenerateOR7351334MSub @xmlParam = @xmlParam', N'@xmlParam NVARCHAR(MAX) ', @xmlParam = @xmlParam

		SELECT @Line_1 = SUM(CONVERT(NUMERIC(18, 0), dblHandled)) FROM @Report
		SELECT @Line_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strScheduleCode = '5CRD'
		SELECT @Line_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strScheduleCode = '5FLT'

		SET @Line_6 = @Line_2 + @Line_3 + @Line_4 + @Line_5

		SET @Line_7 = @Line_6 * @TaxRate

		SET @Line_8 = @Line_7 * @CreditRate

		SET @Line_9 = @Line_8 - @Line_7

		SELECT @Line_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strScheduleCode = '5BLK'

		SET @Line_11 = @Line_10 * @TaxRate

		SET @Line_12 = @Line_9 + @Line_11

		SET @Line_13 = @Line_12 * @InterestRate

		SET @Line_14 = @Line_12 * 0.1

		SET @Line_15 = @Line_12 + @Line_13 + @Line_14

		SET @Line_17 = @Line_15 + @Line_16


	END

	SELECT Line_1 = @Line_1
		, Line_2 = @Line_2
		, Line_3 = @Line_3
		, Line_4 = @Line_4
		, Line_5 = @Line_5
		, Line_6 = @Line_6
		, Line_7 = @Line_7
		, Line_8 = @Line_8
		, Line_9 = @Line_9
		, Line_10 = @Line_10
		, Line_11 = @Line_11
		, Line_12 = @Line_12
		, Line_13 = @Line_13
		, Line_14 = @Line_14
		, Line_15 = @Line_15
		, Line_16 = @Line_16
		, Line_17 = @Line_17

		, strTaxRate = @strTaxRate
		, strCreditRate = @strCreditRate
		, strInterestRate = @strInterestRate

		, dtmFrom = @dtmFrom
		, dtmTo = @dtmTo
		, LicenseNumber = @LicenseNumber
		, strGuid = @Guid

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