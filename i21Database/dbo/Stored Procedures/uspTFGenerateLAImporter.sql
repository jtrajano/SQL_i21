CREATE PROCEDURE [dbo].[uspTFGenerateLAImporter]
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

	DECLARE @dtmFillingPeriod DATE
		, @strAccountNumber NVARCHAR(50)
		, @strFEIN NVARCHAR(50)
		, @dbl1_A NUMERIC(18, 6)
		, @dbl1_B NUMERIC(18, 6)
		, @dbl1_C NUMERIC(18, 6)
		, @dblTaxRate_A NUMERIC(18, 6)
		, @dblTaxRate_B NUMERIC(18, 6)
		, @dblTaxRate_C NUMERIC(18, 6)
		, @dbl3_A NUMERIC(18, 6)
		, @dbl3_B NUMERIC(18, 6)
		, @dbl3_C NUMERIC(18, 6)
		, @dbl3_D NUMERIC(18, 6)
		, @dbl3_E NUMERIC(18, 6)
		, @dbl4_A NUMERIC(18, 6)
		, @dbl4_B NUMERIC(18, 6)
		, @dbl4_C NUMERIC(18, 6)
		, @dbl4_D NUMERIC(18, 6)
		, @dbl4_E NUMERIC(18, 6)
		, @dblInspectionFeeRate_A NUMERIC(18, 6)
		, @dblInspectionFeeRate_B NUMERIC(18, 6)
		, @dblInspectionFeeRate_C NUMERIC(18, 6)
		, @dblInspectionFeeRate_D NUMERIC(18, 6)
		, @dblInspectionFeeRate_E NUMERIC(18, 6)
		, @dblPenalty NUMERIC(18, 6)
		, @dblInterest NUMERIC(18, 6)
		, @dbl10_A NUMERIC(18, 6)
		, @dbl10_B NUMERIC(18, 6)
		, @dbl10_C NUMERIC(18, 6)
		, @dbl11_D NUMERIC(18, 6)
		, @dbl11_E NUMERIC(18, 6)
		, @dbl12_A NUMERIC(18, 6)
		, @dbl12_B NUMERIC(18, 6)
		, @dbl12_C NUMERIC(18, 6)
		, @dbl12_D NUMERIC(18, 6)
		, @dbl12_E NUMERIC(18, 6)
		, @dbl13_A NUMERIC(18, 6)
		, @dbl13_B NUMERIC(18, 6)
		, @dbl13_C NUMERIC(18, 6)
		, @dbl13_D NUMERIC(18, 6)
		, @dbl13_E NUMERIC(18, 6)
		, @dbl14_A NUMERIC(18, 6)
		, @dbl14_B NUMERIC(18, 6)
		, @dbl14_C NUMERIC(18, 6)
		, @dbl14_D NUMERIC(18, 6)
		, @dbl14_E NUMERIC(18, 6)
		, @dbl15_A NUMERIC(18, 6)
		, @dbl15_B NUMERIC(18, 6)
		, @dbl15_C NUMERIC(18, 6)
		, @dbl15_D NUMERIC(18, 6)
		, @dbl15_E NUMERIC(18, 6)
		, @dbl16_A NUMERIC(18, 6)
		, @dbl16_B NUMERIC(18, 6)
		, @dbl16_C NUMERIC(18, 6)
		, @dbl16_D NUMERIC(18, 6)
		, @dbl16_E NUMERIC(18, 6)
		, @dtmFromDate DATE
		, @dtmToDate DATE

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

		DECLARE @DateFrom DATETIME
		, @DateTo DATETIME
		, @TaxAuthorityId INT
		, @Guid NVARCHAR(100)

		SELECT TOP 1 @DateFrom = [from],  @DateTo = [to] FROM @Params WHERE [fieldname] = 'dtmDate'
		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'
		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'LA'
		
		SELECT * 
		INTO #tmpTransactions
		FROM vyuTFGetTransaction Trans
		WHERE Trans.uniqTransactionGuid = @Guid
			AND CAST(FLOOR(CAST(Trans.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(Trans.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND Trans.intTaxAuthorityId = @TaxAuthorityId

		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblReceived, 0.00)), dblBillQty = SUM(ISNULL(dblBillQty, 0.00)), dblQtyShipped = SUM(ISNULL(dblQtyShipped, 0.00)), dblTax = SUM(ISNULL(dblTax, 0.00)), dblTaxExempt = SUM(ISNULL(dblTaxExempt, 0.00))
		INTO #tmpTotals
		FROM #tmpTransactions
		GROUP BY strFormCode, strScheduleCode, strType

		SELECT TOP 1 @strFEIN = strTaxPayerFEIN
			, @dtmFillingPeriod = dtmReportingPeriodBegin
		FROM #tmpTransactions

		SELECT @dblTaxRate_A = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-TaxRateGasohol' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblTaxRate_B = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-TaxRateGasoline' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblTaxRate_C = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-TaxRateUndyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @strAccountNumber = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-AcctNumber' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblInspectionFeeRate_A = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-InspRateGasohol' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblInspectionFeeRate_B = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-InspRateGasoline' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblInspectionFeeRate_C = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-InspRateUndyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblInspectionFeeRate_D = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-InspRateDyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblInspectionFeeRate_E = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-InspRateAviation' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblPenalty = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line7' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dblInterest = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line8' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl14_A = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5339-Line14Gasohol' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl14_B = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5339-Line14Gasoline' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl14_C = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5339-Line14UndyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl14_D = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5339-Line14DyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl14_E = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5339-Line14Aviation' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl16_A = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line16Gasohol' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl16_B = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line16Gasoline' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl16_C = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line16UndyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl16_D = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line16DyedDiesel' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @dbl16_E = CASE WHEN strFormCode = 'R-5399' AND strTemplateItemId = 'R-5399-Line16Aviation' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
		FROM vyuTFGetReportingComponentConfiguration
		WHERE intTaxAuthorityId = @TaxAuthorityId

		SELECT @dbl1_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl1_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl1_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl4_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl4_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl4_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl4_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl4_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END

			, @dbl10_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl10_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl10_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl11_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-2' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl11_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-2' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl12_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl12_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl12_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl12_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl12_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl13_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl13_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl13_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl13_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl13_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl15_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl15_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl15_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl15_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl15_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
		FROM #tmpTotals

		DROP TABLE #tmpTotals
		DROP TABLE #tmpTransactions
	END

	SELECT dtmFillingPeriod = @dtmFillingPeriod
		, strAccountNumber = @strAccountNumber
		, strFEIN = @strFEIN
		, dbl1_A = @dbl1_A
		, dbl1_B = @dbl1_B
		, dbl1_C = @dbl1_C
		, dblTaxRate_A = @dblTaxRate_A
		, dblTaxRate_B = @dblTaxRate_B
		, dblTaxRate_C = @dblTaxRate_C
		, dbl3_A = @dbl3_A
		, dbl3_B = @dbl3_B
		, dbl3_C = @dbl3_C
		, dbl3_D = @dbl3_D
		, dbl3_E = @dbl3_E
		, dbl4_A = @dbl4_A
		, dbl4_B = @dbl4_B
		, dbl4_C = @dbl4_C
		, dbl4_D = @dbl4_D
		, dbl4_E = @dbl4_E
		, dblInspectionFeeRate_A = @dblInspectionFeeRate_A
		, dblInspectionFeeRate_B = @dblInspectionFeeRate_B
		, dblInspectionFeeRate_C = @dblInspectionFeeRate_C
		, dblInspectionFeeRate_D = @dblInspectionFeeRate_D
		, dblInspectionFeeRate_E = @dblInspectionFeeRate_E
		, dblPenalty = @dblPenalty
		, dblInterest = @dblInterest
		, dbl10_A = @dbl10_A
		, dbl10_B = @dbl10_B
		, dbl10_C = @dbl10_C
		, dbl11_D = @dbl11_D
		, dbl11_E = @dbl11_E
		, dbl12_A = @dbl12_A
		, dbl12_B = @dbl12_B
		, dbl12_C = @dbl12_C
		, dbl12_D = @dbl12_D
		, dbl12_E = @dbl12_E
		, dbl13_A = @dbl13_A
		, dbl13_B = @dbl13_B
		, dbl13_C = @dbl13_C
		, dbl13_D = @dbl13_D
		, dbl13_E = @dbl13_E
		, dbl14_A = @dbl14_A
		, dbl14_B = @dbl14_B
		, dbl14_C = @dbl14_C
		, dbl14_D = @dbl14_D
		, dbl14_E = @dbl14_E
		, dbl15_A = @dbl15_A
		, dbl15_B = @dbl15_B
		, dbl15_C = @dbl15_C
		, dbl15_D = @dbl15_D
		, dbl15_E = @dbl15_E
		, dbl16_A = @dbl16_A
		, dbl16_B = @dbl16_B
		, dbl16_C = @dbl16_C
		, dbl16_D = @dbl16_D
		, dbl16_E = @dbl16_E
		, dtmFromDate = @dtmFromDate
		, dtmToDate = @dtmToDate

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