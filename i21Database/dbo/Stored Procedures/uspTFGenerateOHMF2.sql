CREATE PROCEDURE [dbo].[uspTFGenerateOHMF2]
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

	DECLARE @Name NVARCHAR(100)
		, @Address NVARCHAR(250)
		, @City NVARCHAR(50)
		, @State NVARCHAR(50)
		, @ZipCode NVARCHAR(50)
		, @Email NVARCHAR(50)
		, @TIN NVARCHAR(50)
		, @OhioAccountNo NVARCHAR(50)
		, @Period DATETIME
		, @AmmendedReturn BIT
	
		, @Gasoline_BeginInv NUMERIC(18, 6) = 0.00
		, @Gasoline_EndInv NUMERIC(18, 6) = 0.00
		, @Gasoline_1 NUMERIC(18, 6) = 0.00
		, @Gasoline_2 NUMERIC(18, 6) = 0.00
		, @Gasoline_3 NUMERIC(18, 6) = 0.00
		, @Gasoline_4 NUMERIC(18, 6) = 0.00
		, @Gasoline_5AD NUMERIC(18, 6) = 0.00
		, @Gasoline_5 NUMERIC(18, 6) = 0.00
		, @Gasoline_6 NUMERIC(18, 6) = 0.00
		, @Gasoline_7 NUMERIC(18, 6) = 0.00
		, @Gasoline_8 NUMERIC(18, 6) = 0.00
		, @Gasoline_10 NUMERIC(18, 6) = 0.00
		, @Gasoline_10B NUMERIC(18, 6) = 0.00
		, @Gasoline_14A NUMERIC(18, 6) = 0.00
		, @Gasoline_14B NUMERIC(18, 6) = 0.00
		, @Gasoline_14C NUMERIC(18, 6) = 0.00
		, @Gasoline_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @Gasoline_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @Gasoline_TaxRate NUMERIC(18, 6) = 0.00		
		
		, @ClearDiesel_BeginInv NUMERIC(18, 6) = 0.00
		, @ClearDiesel_EndInv NUMERIC(18, 6) = 0.00
		, @ClearDiesel_1 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_2 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_3 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_4 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_5AD NUMERIC(18, 6) = 0.00
		, @ClearDiesel_5 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_6 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_7 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_8 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_10 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_10B NUMERIC(18, 6) = 0.00
		, @ClearDiesel_14A NUMERIC(18, 6) = 0.00
		, @ClearDiesel_14B NUMERIC(18, 6) = 0.00
		, @ClearDiesel_14C NUMERIC(18, 6) = 0.00
		, @ClearDiesel_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @ClearDiesel_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @ClearDiesel_TaxRate NUMERIC(18, 6) = 0.00

		, @LowSulfur_BeginInv NUMERIC(18, 6) = 0.00
		, @LowSulfur_EndInv NUMERIC(18, 6) = 0.00
		, @LowSulfur_1 NUMERIC(18, 6) = 0.00
		, @LowSulfur_2 NUMERIC(18, 6) = 0.00
		, @LowSulfur_3 NUMERIC(18, 6) = 0.00
		, @LowSulfur_4 NUMERIC(18, 6) = 0.00
		, @LowSulfur_5AD NUMERIC(18, 6) = 0.00
		, @LowSulfur_5 NUMERIC(18, 6) = 0.00
		, @LowSulfur_6 NUMERIC(18, 6) = 0.00
		, @LowSulfur_7 NUMERIC(18, 6) = 0.00
		, @LowSulfur_8 NUMERIC(18, 6) = 0.00
		, @LowSulfur_10 NUMERIC(18, 6) = 0.00
		, @LowSulfur_10B NUMERIC(18, 6) = 0.00
		, @LowSulfur_14A NUMERIC(18, 6) = 0.00
		, @LowSulfur_14B NUMERIC(18, 6) = 0.00
		, @LowSulfur_14C NUMERIC(18, 6) = 0.00
		, @LowSulfur_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @LowSulfur_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @LowSulfur_TaxRate NUMERIC(18, 6) = 0.00

		, @HighSulfur_BeginInv NUMERIC(18, 6) = 0.00
		, @HighSulfur_EndInv NUMERIC(18, 6) = 0.00
		, @HighSulfur_1 NUMERIC(18, 6) = 0.00
		, @HighSulfur_2 NUMERIC(18, 6) = 0.00
		, @HighSulfur_3 NUMERIC(18, 6) = 0.00
		, @HighSulfur_4 NUMERIC(18, 6) = 0.00
		, @HighSulfur_5AD NUMERIC(18, 6) = 0.00
		, @HighSulfur_5 NUMERIC(18, 6) = 0.00
		, @HighSulfur_6 NUMERIC(18, 6) = 0.00
		, @HighSulfur_7 NUMERIC(18, 6) = 0.00
		, @HighSulfur_8 NUMERIC(18, 6) = 0.00
		, @HighSulfur_10 NUMERIC(18, 6) = 0.00
		, @HighSulfur_10B NUMERIC(18, 6) = 0.00
		, @HighSulfur_14A NUMERIC(18, 6) = 0.00
		, @HighSulfur_14B NUMERIC(18, 6) = 0.00
		, @HighSulfur_14C NUMERIC(18, 6) = 0.00
		, @HighSulfur_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @HighSulfur_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @HighSulfur_TaxRate NUMERIC(18, 6) = 0.00

		, @Kerosene_BeginInv NUMERIC(18, 6) = 0.00
		, @Kerosene_EndInv NUMERIC(18, 6) = 0.00
		, @Kerosene_1 NUMERIC(18, 6) = 0.00
		, @Kerosene_2 NUMERIC(18, 6) = 0.00
		, @Kerosene_3 NUMERIC(18, 6) = 0.00
		, @Kerosene_4 NUMERIC(18, 6) = 0.00
		, @Kerosene_5AD NUMERIC(18, 6) = 0.00
		, @Kerosene_5 NUMERIC(18, 6) = 0.00
		, @Kerosene_6 NUMERIC(18, 6) = 0.00
		, @Kerosene_7 NUMERIC(18, 6) = 0.00
		, @Kerosene_8 NUMERIC(18, 6) = 0.00
		, @Kerosene_10 NUMERIC(18, 6) = 0.00
		, @Kerosene_10B NUMERIC(18, 6) = 0.00
		, @Kerosene_14A NUMERIC(18, 6) = 0.00
		, @Kerosene_14B NUMERIC(18, 6) = 0.00
		, @Kerosene_14C NUMERIC(18, 6) = 0.00
		, @Kerosene_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @Kerosene_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @Kerosene_TaxRate NUMERIC(18, 6) = 0.00

		, @CNG_BeginInv NUMERIC(18, 6) = 0.00
		, @CNG_EndInv NUMERIC(18, 6) = 0.00
		, @CNG_1 NUMERIC(18, 6) = 0.00
		, @CNG_2 NUMERIC(18, 6) = 0.00
		, @CNG_3 NUMERIC(18, 6) = 0.00
		, @CNG_4 NUMERIC(18, 6) = 0.00
		, @CNG_5AD NUMERIC(18, 6) = 0.00
		, @CNG_5 NUMERIC(18, 6) = 0.00
		, @CNG_6 NUMERIC(18, 6) = 0.00
		, @CNG_7 NUMERIC(18, 6) = 0.00
		, @CNG_8 NUMERIC(18, 6) = 0.00
		, @CNG_10 NUMERIC(18, 6) = 0.00
		, @CNG_10B NUMERIC(18, 6) = 0.00
		, @CNG_14A NUMERIC(18, 6) = 0.00
		, @CNG_14B NUMERIC(18, 6) = 0.00
		, @CNG_14C NUMERIC(18, 6) = 0.00
		, @CNG_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @CNG_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @CNG_TaxRate NUMERIC(18, 6) = 0.00

		, @LNG_BeginInv NUMERIC(18, 6) = 0.00
		, @LNG_EndInv NUMERIC(18, 6) = 0.00
		, @LNG_1 NUMERIC(18, 6) = 0.00
		, @LNG_2 NUMERIC(18, 6) = 0.00
		, @LNG_3 NUMERIC(18, 6) = 0.00
		, @LNG_4 NUMERIC(18, 6) = 0.00
		, @LNG_5AD NUMERIC(18, 6) = 0.00
		, @LNG_5 NUMERIC(18, 6) = 0.00
		, @LNG_6 NUMERIC(18, 6) = 0.00
		, @LNG_7 NUMERIC(18, 6) = 0.00
		, @LNG_8 NUMERIC(18, 6) = 0.00
		, @LNG_10 NUMERIC(18, 6) = 0.00
		, @LNG_10B NUMERIC(18, 6) = 0.00
		, @LNG_14A NUMERIC(18, 6) = 0.00
		, @LNG_14B NUMERIC(18, 6) = 0.00
		, @LNG_14C NUMERIC(18, 6) = 0.00
		, @LNG_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @LNG_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @LNG_TaxRate NUMERIC(18, 6) = 0.00

		, @Propane_BeginInv NUMERIC(18, 6) = 0.00
		, @Propane_EndInv NUMERIC(18, 6) = 0.00
		, @Propane_1 NUMERIC(18, 6) = 0.00
		, @Propane_2 NUMERIC(18, 6) = 0.00
		, @Propane_3 NUMERIC(18, 6) = 0.00
		, @Propane_4 NUMERIC(18, 6) = 0.00
		, @Propane_5AD NUMERIC(18, 6) = 0.00
		, @Propane_5 NUMERIC(18, 6) = 0.00
		, @Propane_6 NUMERIC(18, 6) = 0.00
		, @Propane_7 NUMERIC(18, 6) = 0.00
		, @Propane_8 NUMERIC(18, 6) = 0.00
		, @Propane_10 NUMERIC(18, 6) = 0.00
		, @Propane_10B NUMERIC(18, 6) = 0.00
		, @Propane_14A NUMERIC(18, 6) = 0.00
		, @Propane_14B NUMERIC(18, 6) = 0.00
		, @Propane_14C NUMERIC(18, 6) = 0.00
		, @Propane_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @Propane_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @Propane_TaxRate NUMERIC(18, 6) = 0.00

		, @Other_BeginInv NUMERIC(18, 6) = 0.00
		, @Other_EndInv NUMERIC(18, 6) = 0.00
		, @Other_1 NUMERIC(18, 6) = 0.00
		, @Other_2 NUMERIC(18, 6) = 0.00
		, @Other_3 NUMERIC(18, 6) = 0.00
		, @Other_4 NUMERIC(18, 6) = 0.00
		, @Other_5AD NUMERIC(18, 6) = 0.00
		, @Other_5 NUMERIC(18, 6) = 0.00
		, @Other_6 NUMERIC(18, 6) = 0.00
		, @Other_7 NUMERIC(18, 6) = 0.00
		, @Other_8 NUMERIC(18, 6) = 0.00
		, @Other_10 NUMERIC(18, 6) = 0.00
		, @Other_10B NUMERIC(18, 6) = 0.00
		, @Other_14A NUMERIC(18, 6) = 0.00
		, @Other_14B NUMERIC(18, 6) = 0.00
		, @Other_14C NUMERIC(18, 6) = 0.00
		, @Other_ShrinkageAllowanceRate NUMERIC(18, 6) = 0.00
		, @Other_RetailShrinkageRate NUMERIC(18, 6) = 0.00
		, @Other_TaxRate NUMERIC(18, 6) = 0.00

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
		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH'
				
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

		SELECT TOP 1 @Name = strTaxPayerName
			, @TIN = strTaxPayerFEIN
			, @Period = dtmReportingPeriodBegin
		FROM #tmpTransactions

		SELECT @Gasoline_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @ClearDiesel_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @LowSulfur_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @HighSulfur_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @Kerosene_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @CNG_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @LNG_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @Propane_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @Other_1 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_2 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_3 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_4 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_5AD = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_5 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_6 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_7 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_8 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_10 = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_10B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_14A = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_14B = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_14C = CASE WHEN strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
		FROM #tmpTotals

		SELECT @Gasoline_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColA' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Gasoline_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColA' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Gasoline_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColA' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Gasoline_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColA' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Gasoline_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColA' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @ClearDiesel_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColB' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @ClearDiesel_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColB' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @ClearDiesel_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColB' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @ClearDiesel_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColB' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @ClearDiesel_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColB' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @LowSulfur_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColC' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LowSulfur_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColC' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LowSulfur_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColC' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LowSulfur_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColC' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LowSulfur_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColC' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @HighSulfur_ShrinkageAllowanceRate= CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColD' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @HighSulfur_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColD' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @HighSulfur_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColD' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @HighSulfur_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColD' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @HighSulfur_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColD' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @Kerosene_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColE' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Kerosene_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColE' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Kerosene_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColE' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Kerosene_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColE' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Kerosene_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColE' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @CNG_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColF' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @CNG_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColF' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @CNG_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColF' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @CNG_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColF' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @CNG_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColF' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @LNG_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColG' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LNG_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColG' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LNG_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColG' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LNG_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColG' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @LNG_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColG' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @Propane_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColH' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Propane_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColH' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Propane_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColH' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Propane_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColH' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Propane_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColH' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @Other_ShrinkageAllowanceRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColI' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Other_RetailShrinkageRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColI' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Other_TaxRate = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColI' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Other_BeginInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line1ColI' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
			, @Other_EndInv = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line16ColI' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END

			, @OhioAccountNo = CASE WHEN strFormCode = 'MF2' AND strTemplateItemId = 'MF2-OHAcctNumber' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
		FROM vyuTFGetReportingComponentConfiguration
		WHERE intTaxAuthorityId = @TaxAuthorityId

		DROP TABLE #tmpTotals
		DROP TABLE #tmpTransactions
	END

	SELECT Name = @Name
		, [Address] = @Address
		, City = @City
		, [State] = @State
		, ZipCode = @ZipCode
		, Email = @Email
		, TIN = @TIN
		, OhioAccountNo = @OhioAccountNo
		, Period = @Period
		, AmmendedReturn = @AmmendedReturn
	
		, Gasoline_BeginInv = @Gasoline_BeginInv
		, Gasoline_EndInv = @Gasoline_EndInv
		, Gasoline_1 = @Gasoline_1
		, Gasoline_2 = @Gasoline_2
		, Gasoline_3 = @Gasoline_3
		, Gasoline_4 = @Gasoline_4
		, Gasoline_5AD = @Gasoline_5AD
		, Gasoline_5 = @Gasoline_5
		, Gasoline_6 = @Gasoline_6
		, Gasoline_7 = @Gasoline_7
		, Gasoline_8 = @Gasoline_8
		, Gasoline_10 = @Gasoline_10
		, Gasoline_10B = @Gasoline_10B
		, Gasoline_14A = @Gasoline_14A
		, Gasoline_14B = @Gasoline_14B
		, Gasoline_14C = @Gasoline_14C
		, Gasoline_ShrinkageAllowanceRate = @Gasoline_ShrinkageAllowanceRate
		, Gasoline_RetailShrinkageRate = @Gasoline_RetailShrinkageRate
		, Gasoline_TaxRate = @Gasoline_TaxRate
		
		
		, ClearDiesel_BeginInv = @ClearDiesel_BeginInv
		, ClearDiesel_EndInv = @ClearDiesel_EndInv
		, ClearDiesel_1 = @ClearDiesel_1
		, ClearDiesel_2 = @ClearDiesel_2
		, ClearDiesel_3 = @ClearDiesel_3
		, ClearDiesel_4 = @ClearDiesel_4
		, ClearDiesel_5AD = @ClearDiesel_5AD
		, ClearDiesel_5 = @ClearDiesel_5
		, ClearDiesel_6 = @ClearDiesel_6
		, ClearDiesel_7 = @ClearDiesel_7
		, ClearDiesel_8 = @ClearDiesel_8
		, ClearDiesel_10 = @ClearDiesel_10
		, ClearDiesel_10B = @ClearDiesel_10B
		, ClearDiesel_14A = @ClearDiesel_14A
		, ClearDiesel_14B = @ClearDiesel_14B
		, ClearDiesel_14C = @ClearDiesel_14C
		, ClearDiesel_ShrinkageAllowanceRate = @ClearDiesel_ShrinkageAllowanceRate
		, ClearDiesel_RetailShrinkageRate = @ClearDiesel_RetailShrinkageRate
		, ClearDiesel_TaxRate = @ClearDiesel_TaxRate

		, LowSulfur_BeginInv = @LowSulfur_BeginInv
		, LowSulfur_EndInv = @LowSulfur_EndInv
		, LowSulfur_1 = @LowSulfur_1
		, LowSulfur_2 = @LowSulfur_2
		, LowSulfur_3 = @LowSulfur_3
		, LowSulfur_4 = @LowSulfur_4
		, LowSulfur_5AD = @LowSulfur_5AD
		, LowSulfur_5 = @LowSulfur_5
		, LowSulfur_6 = @LowSulfur_6
		, LowSulfur_7 = @LowSulfur_7
		, LowSulfur_8 = @LowSulfur_8
		, LowSulfur_10 = @LowSulfur_10
		, LowSulfur_10B = @LowSulfur_10B
		, LowSulfur_14A = @LowSulfur_14A
		, LowSulfur_14B = @LowSulfur_14B
		, LowSulfur_14C = @LowSulfur_14C
		, LowSulfur_ShrinkageAllowanceRate = @LowSulfur_ShrinkageAllowanceRate
		, LowSulfur_RetailShrinkageRate = @LowSulfur_RetailShrinkageRate
		, LowSulfur_TaxRate = @LowSulfur_TaxRate

		, HighSulfur_BeginInv = @HighSulfur_BeginInv
		, HighSulfur_EndInv = @HighSulfur_EndInv
		, HighSulfur_1 = @HighSulfur_1
		, HighSulfur_2 = @HighSulfur_2
		, HighSulfur_3 = @HighSulfur_3
		, HighSulfur_4 = @HighSulfur_4
		, HighSulfur_5AD = @HighSulfur_5AD
		, HighSulfur_5 = @HighSulfur_5
		, HighSulfur_6 = @HighSulfur_6
		, HighSulfur_7 = @HighSulfur_7
		, HighSulfur_8 = @HighSulfur_8
		, HighSulfur_10 = @HighSulfur_10
		, HighSulfur_10B = @HighSulfur_10B
		, HighSulfur_14A = @HighSulfur_14A
		, HighSulfur_14B = @HighSulfur_14B
		, HighSulfur_14C = @HighSulfur_14C
		, HighSulfur_ShrinkageAllowanceRate = @HighSulfur_ShrinkageAllowanceRate
		, HighSulfur_RetailShrinkageRate = @HighSulfur_RetailShrinkageRate
		, HighSulfur_TaxRate = @HighSulfur_TaxRate

		, Kerosene_BeginInv = @Kerosene_BeginInv
		, Kerosene_EndInv = @Kerosene_EndInv
		, Kerosene_1 = @Kerosene_1
		, Kerosene_2 = @Kerosene_2
		, Kerosene_3 = @Kerosene_3
		, Kerosene_4 = @Kerosene_4
		, Kerosene_5AD = @Kerosene_5AD
		, Kerosene_5 = @Kerosene_5
		, Kerosene_6 = @Kerosene_6
		, Kerosene_7 = @Kerosene_7
		, Kerosene_8 = @Kerosene_8
		, Kerosene_10 = @Kerosene_10
		, Kerosene_10B = @Kerosene_10B
		, Kerosene_14A = @Kerosene_14A
		, Kerosene_14B = @Kerosene_14B
		, Kerosene_14C = @Kerosene_14C
		, Kerosene_ShrinkageAllowanceRate = @Kerosene_ShrinkageAllowanceRate
		, Kerosene_RetailShrinkageRate = @Kerosene_RetailShrinkageRate
		, Kerosene_TaxRate = @Kerosene_TaxRate

		, CNG_BeginInv = @CNG_BeginInv
		, CNG_EndInv = @CNG_EndInv
		, CNG_1 = @CNG_1
		, CNG_2 = @CNG_2
		, CNG_3 = @CNG_3
		, CNG_4 = @CNG_4
		, CNG_5AD = @CNG_5AD
		, CNG_5 = @CNG_5
		, CNG_6 = @CNG_6
		, CNG_7 = @CNG_7
		, CNG_8 = @CNG_8
		, CNG_10 = @CNG_10
		, CNG_10B = @CNG_10B
		, CNG_14A = @CNG_14A
		, CNG_14B = @CNG_14B
		, CNG_14C = @CNG_14C
		, CNG_ShrinkageAllowanceRate = @CNG_ShrinkageAllowanceRate
		, CNG_RetailShrinkageRate = @CNG_RetailShrinkageRate
		, CNG_TaxRate = @CNG_TaxRate

		, LNG_BeginInv = @LNG_BeginInv
		, LNG_EndInv  = @LNG_EndInv
		, LNG_1 = @LNG_1
		, L6NG_2 = @LNG_2
		, LNG_3 = @LNG_3
		, LNG_4 = @LNG_4
		, LNG_5AD = @LNG_5AD
		, LNG_5 = @LNG_5
		, LNG_6 = @LNG_6
		, LNG_7 = @LNG_7
		, LNG_8 = @LNG_8
		, LNG_10 = @LNG_10
		, LNG_10B = @LNG_10B
		, LNG_14A = @LNG_14A
		, LNG_14B = @LNG_14B
		, LNG_14C = @LNG_14C
		, LNG_ShrinkageAllowanceRate = @LNG_ShrinkageAllowanceRate
		, LNG_RetailShrinkageRate = @LNG_RetailShrinkageRate
		, LNG_TaxRate = @LNG_TaxRate

		, Propane_BeginInv = @Propane_BeginInv
		, Propane_EndInvInv = @Propane_EndInv
		, Propane_1 = @Propane_1
		, Propane_2 = @Propane_2
		, Propane_3 = @Propane_3
		, Propane_4 = @Propane_4
		, Propane_5AD = @Propane_5AD
		, Propane_5 = @Propane_5
		, Propane_6 = @Propane_6
		, Propane_7 = @Propane_7
		, Propane_8 = @Propane_8
		, Propane_10 = @Propane_10
		, Propane_10B = @Propane_10B
		, Propane_14A = @Propane_14A
		, Propane_14B = @Propane_14B
		, Propane_14C = @Propane_14C
		, Propane_ShrinkageAllowanceRate = @Propane_ShrinkageAllowanceRate
		, Propane_RetailShrinkageRate = @Propane_RetailShrinkageRate
		, Propane_TaxRate = @Propane_TaxRate

		, Other_15C = @Other_BeginInv
		, Other_15C = @Other_BeginInv
		, Other_1 = @Other_1
		, Other_2 = @Other_2
		, Other_3 = @Other_3
		, Other_4 = @Other_4
		, Other_5AD = @Other_5AD
		, Other_5 = @Other_5
		, Other_6 = @Other_6
		, Other_7 = @Other_7
		, Other_8 = @Other_8
		, Other_10 = @Other_10
		, Other_10B = @Other_10B
		, Other_14A = @Other_14A
		, Other_14B = @Other_14B
		, Other_14C = @Other_14C
		, Other_ShrinkageAllowanceRate = @Other_ShrinkageAllowanceRate
		, Other_RetailShrinkageRate = @Other_RetailShrinkageRate
		, Other_TaxRate = @Other_TaxRate

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