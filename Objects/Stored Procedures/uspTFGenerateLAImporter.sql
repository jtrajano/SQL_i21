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

	DECLARE @strAccountNumber NVARCHAR(50)
		, @strFEIN NVARCHAR(50)
		, @dbl1_A NUMERIC(18, 6) = 0
		, @dbl1_B NUMERIC(18, 6) = 0
		, @dbl1_C NUMERIC(18, 6) = 0
		, @dbl2_A NUMERIC(18, 6) = 0
		, @dbl2_B NUMERIC(18, 6) = 0
		, @dbl2_C NUMERIC(18, 6) = 0
		, @dblTaxRate_A NUMERIC(18, 6) = 0
		, @dblTaxRate_B NUMERIC(18, 6) = 0
		, @dblTaxRate_C NUMERIC(18, 6) = 0
		, @dbl3_A NUMERIC(18, 6) = 0
		, @dbl3_B NUMERIC(18, 6) = 0
		, @dbl3_C NUMERIC(18, 6) = 0
		, @dbl3_D NUMERIC(18, 6) = 0
		, @dbl3_E NUMERIC(18, 6) = 0
		, @dbl4_A NUMERIC(18, 6) = 0
		, @dbl4_B NUMERIC(18, 6) = 0
		, @dbl4_C NUMERIC(18, 6) = 0
		, @dbl4_D NUMERIC(18, 6) = 0
		, @dbl4_E NUMERIC(18, 6) = 0
		, @dblInspectionFeeRate_A NUMERIC(18, 6) = 0
		, @dblInspectionFeeRate_B NUMERIC(18, 6) = 0
		, @dblInspectionFeeRate_C NUMERIC(18, 6) = 0
		, @dblInspectionFeeRate_D NUMERIC(18, 6) = 0
		, @dblInspectionFeeRate_E NUMERIC(18, 6) = 0
		, @dblPenalty NUMERIC(18, 6) = 0
		, @dblInterest NUMERIC(18, 6) = 0

		, @dbl5_A NUMERIC(18, 6) = 0
		, @dbl5_B NUMERIC(18, 6) = 0
		, @dbl5_C NUMERIC(18, 6) = 0
		, @dbl5_D NUMERIC(18, 6) = 0
		, @dbl5_E NUMERIC(18, 6) = 0
		, @dbl6 NUMERIC(18, 6) = 0
		, @dbl9 NUMERIC(18, 6) = 0

		, @dbl10_A NUMERIC(18, 6) = 0
		, @dbl10_B NUMERIC(18, 6) = 0
		, @dbl10_C NUMERIC(18, 6) = 0
		, @dbl11_D NUMERIC(18, 6) = 0
		, @dbl11_E NUMERIC(18, 6) = 0
		, @dbl12_A NUMERIC(18, 6) = 0
		, @dbl12_B NUMERIC(18, 6) = 0
		, @dbl12_C NUMERIC(18, 6) = 0
		, @dbl12_D NUMERIC(18, 6) = 0
		, @dbl12_E NUMERIC(18, 6) = 0
		, @dbl13_A NUMERIC(18, 6) = 0
		, @dbl13_B NUMERIC(18, 6) = 0
		, @dbl13_C NUMERIC(18, 6) = 0
		, @dbl13_D NUMERIC(18, 6) = 0
		, @dbl13_E NUMERIC(18, 6) = 0
		, @dbl14_A NUMERIC(18, 6) = 0
		, @dbl14_B NUMERIC(18, 6) = 0
		, @dbl14_C NUMERIC(18, 6) = 0
		, @dbl14_D NUMERIC(18, 6) = 0
		, @dbl14_E NUMERIC(18, 6) = 0
		, @dbl15_A NUMERIC(18, 6) = 0
		, @dbl15_B NUMERIC(18, 6) = 0
		, @dbl15_C NUMERIC(18, 6) = 0
		, @dbl15_D NUMERIC(18, 6) = 0
		, @dbl15_E NUMERIC(18, 6) = 0
		, @dbl16_A NUMERIC(18, 6) = 0
		, @dbl16_B NUMERIC(18, 6) = 0
		, @dbl16_C NUMERIC(18, 6) = 0
		, @dbl16_D NUMERIC(18, 6) = 0
		, @dbl16_E NUMERIC(18, 6) = 0
		, @dbl17_A NUMERIC(18, 6) = 0
		, @dbl17_B NUMERIC(18, 6) = 0
		, @dbl17_C NUMERIC(18, 6) = 0
		, @dbl17_D NUMERIC(18, 6) = 0
		, @dbl17_E NUMERIC(18, 6) = 0
		, @dbl20_A NUMERIC(18, 6) = 0
		, @dbl20_B NUMERIC(18, 6) = 0
		, @dbl20_C NUMERIC(18, 6) = 0
		, @dbl23_A NUMERIC(18, 6) = 0
		, @dbl23_B NUMERIC(18, 6) = 0
		, @dbl23_C NUMERIC(18, 6) = 0
		, @dbl23_D NUMERIC(18, 6) = 0
		, @dbl23_E NUMERIC(18, 6) = 0
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

		DECLARE  @TaxAuthorityId INT, @Guid NVARCHAR(100)

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'
		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'LA'
		
		SELECT @dbl1_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl1_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl1_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl3_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl3_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl3_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl3_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl3_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			--, @dbl4_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			--, @dbl4_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			--, @dbl4_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			--, @dbl4_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			--, @dbl4_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl10_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl10_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl10_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-1' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl11_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-2' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl11_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-2' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl12_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl12_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl12_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl12_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl12_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl13_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl13_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl13_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl13_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl13_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'A-3' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl15_A = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl15_B = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl15_C = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl15_D = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
			, @dbl15_E = CASE WHEN strFormCode = 'R-5399' AND strScheduleCode = 'D-21' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0) ELSE 0 END
		FROM (
			SELECT strFormCode, 
				strScheduleCode, 
				strType, 
				dblReceived = SUM(ISNULL(dblReceived, 0)), 
				dblBillQty = SUM(ISNULL(dblBillQty, 0)), 
				dblQtyShipped = SUM(ISNULL(dblQtyShipped, 0)), 
				dblTax = SUM(ISNULL(dblTax, 0)), 
				dblTaxExempt = SUM(ISNULL(dblTaxExempt, 0))
			FROM vyuTFGetTransaction
			WHERE uniqTransactionGuid = @Guid
			GROUP BY strFormCode, strScheduleCode, strType
		) Trans

		SELECT TOP 1 @strFEIN = strTaxPayerFEIN, @dtmFromDate = dtmReportingPeriodBegin, @dtmToDate = dtmReportingPeriodEnd
		FROM vyuTFGetTransaction
		WHERE uniqTransactionGuid = @Guid


		SELECT @dblTaxRate_A = CASE WHEN strTemplateItemId = 'R-5399-TaxRateGasohol' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END 
			, @dblTaxRate_B = CASE WHEN strTemplateItemId = 'R-5399-TaxRateGasoline' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END 
			, @dblTaxRate_C = CASE WHEN strTemplateItemId = 'R-5399-TaxRateUndyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END 
			, @strAccountNumber = CASE WHEN strTemplateItemId = 'R-5399-AcctNumber' THEN strConfiguration ELSE '' END
			, @dblInspectionFeeRate_A = CASE WHEN strTemplateItemId = 'R-5399-InspRateGasohol' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dblInspectionFeeRate_B = CASE WHEN strTemplateItemId = 'R-5399-InspRateGasoline' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dblInspectionFeeRate_C = CASE WHEN strTemplateItemId = 'R-5399-InspRateUndyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dblInspectionFeeRate_D = CASE WHEN strTemplateItemId = 'R-5399-InspRateDyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dblInspectionFeeRate_E = CASE WHEN strTemplateItemId = 'R-5399-InspRateAviation' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dblPenalty = CASE WHEN strTemplateItemId = 'R-5399-Line7' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dblInterest = CASE WHEN strTemplateItemId = 'R-5399-Line8' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl14_A = CASE WHEN strTemplateItemId = 'R-5339-Line14Gasohol' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl14_B = CASE WHEN strTemplateItemId = 'R-5339-Line14Gasoline' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl14_C = CASE WHEN strTemplateItemId = 'R-5339-Line14UndyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl14_D = CASE WHEN strTemplateItemId = 'R-5339-Line14DyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl14_E = CASE WHEN strTemplateItemId = 'R-5339-Line14Aviation' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl16_A = CASE WHEN strTemplateItemId = 'R-5399-Line16Gasohol' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl16_B = CASE WHEN strTemplateItemId = 'R-5399-Line16Gasoline' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl16_C = CASE WHEN strTemplateItemId = 'R-5399-Line16UndyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl16_D = CASE WHEN strTemplateItemId = 'R-5399-Line16DyedDiesel' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
			, @dbl16_E = CASE WHEN strTemplateItemId = 'R-5399-Line16Aviation' THEN (CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END) ELSE 0 END
		FROM vyuTFGetReportingComponentConfiguration
		WHERE intTaxAuthorityId = @TaxAuthorityId


		SET @dbl2_A = @dbl1_A * @dblTaxRate_A
		SET @dbl2_B = @dbl1_B * @dblTaxRate_B
		SET @dbl2_C = @dbl1_C * @dblTaxRate_C

		SET @dbl4_A = @dbl2_A * @dblInspectionFeeRate_A
		SET @dbl4_B = @dbl2_B * @dblInspectionFeeRate_B
		SET @dbl4_C = @dbl2_C * @dblInspectionFeeRate_C
		SET @dbl4_D = 0 * @dblInspectionFeeRate_D
		SET @dbl4_E = 0 * @dblInspectionFeeRate_E

		SET @dbl5_A = @dbl2_A + @dbl4_A
		SET @dbl5_B = @dbl2_B + @dbl4_B
		SET @dbl5_C = @dbl2_C + @dbl4_C
		SET @dbl5_D = @dbl4_D
		SET @dbl5_E = @dbl4_E

		SET @dbl6 = @dbl5_A + @dbl5_B + @dbl5_C + @dbl5_D + @dbl5_E

		SET @dbl9 = @dbl6 + @dblPenalty + @dblInterest

		SET @dbl17_A = @dbl10_A + @dbl12_A + @dbl13_A + @dbl14_A + @dbl15_A + @dbl16_A
		SET @dbl17_B = @dbl10_B + @dbl12_B + @dbl13_B + @dbl14_B + @dbl15_B + @dbl16_B
		SET @dbl17_C = @dbl10_C + @dbl12_C + @dbl13_C + @dbl14_C + @dbl15_C + @dbl16_C
		SET @dbl17_D = @dbl11_D + @dbl12_D + @dbl13_D + @dbl14_D + @dbl15_D + @dbl16_D
		SET @dbl17_E = @dbl11_E + @dbl12_E + @dbl13_E + @dbl14_E + @dbl15_E + @dbl16_E		
		
		SET @dbl20_A = @dbl17_A - @dbl10_A
		SET @dbl20_B = @dbl17_B - @dbl10_B
		SET @dbl20_C = @dbl17_C - @dbl10_C

		SET @dbl23_A = @dbl17_A - @dbl10_A
		SET @dbl23_B = @dbl17_B - @dbl10_B
		SET @dbl23_C = @dbl17_C - @dbl10_C
		SET @dbl23_D = @dbl17_D - @dbl11_D
		SET @dbl23_E = @dbl17_E - @dbl11_E
	
	END

	SELECT  strAccountNumber = @strAccountNumber
		, strFEIN = @strFEIN
		, dbl1_A = @dbl1_A
		, dbl1_B = @dbl1_B
		, dbl1_C = @dbl1_C
		, dbl2_A = @dbl2_A
		, dbl2_B = @dbl2_B
		, dbl2_C = @dbl2_C
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
		, dbl5_A = @dbl5_A
		, dbl5_B = @dbl5_B
		, dbl5_C = @dbl5_C
		, dbl5_D = @dbl5_D
		, dbl5_E = @dbl5_E
		, dbl6 = @dbl6
		, dblPenalty = @dblPenalty
		, dblInterest = @dblInterest
		, dbl9 = @dbl9
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
		, dbl17_A = @dbl17_A
		, dbl17_B = @dbl17_B
		, dbl17_C = @dbl17_C
		, dbl17_D = @dbl17_D
		, dbl17_E = @dbl17_E
		, dbl20_A = @dbl20_A
		, dbl20_B = @dbl20_B
		, dbl20_C = @dbl20_C
		, dbl23_A = @dbl23_A
		, dbl23_B = @dbl23_B
		, dbl23_C = @dbl23_C
		, dbl23_D = @dbl23_D
		, dbl23_E = @dbl23_E
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