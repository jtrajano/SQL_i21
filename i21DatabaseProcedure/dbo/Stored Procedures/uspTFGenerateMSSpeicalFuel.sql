CREATE PROCEDURE [dbo].[uspTFGenerateMSSpeicalFuel]
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

	DECLARE @DyedDiesel_1 NUMERIC(18, 0) = 0
			, @DyedDiesel_2 NUMERIC(18, 0) = 0
			, @DyedDiesel_3 NUMERIC(18, 0) = 0
			, @DyedDiesel_4 NUMERIC(18, 0) = 0
			, @DyedDiesel_5 NUMERIC(18, 0) = 0
			, @DyedDiesel_6 NUMERIC(18, 0) = 0
			, @DyedDiesel_7 NUMERIC(18, 0) = 0
			, @DyedDiesel_9 NUMERIC(18, 0) = 0
			, @DyedDiesel_11 NUMERIC(18, 0) = 0
			, @DyedDiesel_12 NUMERIC(18, 0) = 0
			, @DyedDiesel_13 NUMERIC(18, 0) = 0
			, @DyedDiesel_14 NUMERIC(18, 0) = 0
			, @DyedDiesel_15 NUMERIC(18, 0) = 0
			, @DyedDiesel_16 NUMERIC(18, 0) = 0
			, @DyedDiesel_17 NUMERIC(18, 0) = 0
			, @DyedDiesel_18 NUMERIC(18, 0) = 0
			, @DyedDiesel_19 NUMERIC(18, 0) = 0
			, @DyedDiesel_20 NUMERIC(18, 4) = 0
			, @DyedDiesel_21 NUMERIC(18, 2) = 0
			, @DyedDiesel_22 NUMERIC(18, 0) = 0
			, @DyedDiesel_23 NUMERIC(18, 0) = 0
			, @DyedDiesel_24 NUMERIC(18, 0) = 0
			, @DyedDiesel_25 NUMERIC(18, 4) = 0
			, @DyedDiesel_26 NUMERIC(18, 0) = 0
			, @DyedDiesel_27 NUMERIC(18, 0) = 0
			, @DyedDiesel_28 NUMERIC(18, 0) = 0	
			, @DyedDiesel_29 NUMERIC(18, 4) = 0
			, @DyedDiesel_30 NUMERIC(18, 0) = 0	
			, @DyedDiesel_31 NUMERIC(18, 0) = 0
			, @DyedDiesel_32 NUMERIC(18, 2) = 0	

			, @FuelOil_1 NUMERIC(18, 0) = 0
			, @FuelOil_2 NUMERIC(18, 0) = 0
			, @FuelOil_3 NUMERIC(18, 0) = 0
			, @FuelOil_4 NUMERIC(18, 0) = 0
			, @FuelOil_5 NUMERIC(18, 0) = 0
			, @FuelOil_6 NUMERIC(18, 0) = 0
			, @FuelOil_7 NUMERIC(18, 0) = 0
			, @FuelOil_9 NUMERIC(18, 0) = 0
			, @FuelOil_11 NUMERIC(18, 0) = 0
			, @FuelOil_12 NUMERIC(18, 0) = 0
			, @FuelOil_13 NUMERIC(18, 0) = 0
			, @FuelOil_14 NUMERIC(18, 0) = 0
			, @FuelOil_15 NUMERIC(18, 0) = 0
			, @FuelOil_16 NUMERIC(18, 0) = 0
			, @FuelOil_17 NUMERIC(18, 0) = 0
			, @FuelOil_18 NUMERIC(18, 0) = 0
			, @FuelOil_19 NUMERIC(18, 0) = 0
			, @FuelOil_20 NUMERIC(18, 4) = 0
			, @FuelOil_21 NUMERIC(18, 2) = 0
			--, @FuelOil_22 NUMERIC(18, 0) = 0
			--, @FuelOil_23 NUMERIC(18, 0) = 0
			, @FuelOil_24 NUMERIC(18, 0) = 0
			, @FuelOil_25 NUMERIC(18, 0) = 0
			, @FuelOil_26 NUMERIC(18, 0) = 0
			, @FuelOil_27 NUMERIC(18, 0) = 0
			, @FuelOil_28 NUMERIC(18, 0) = 0
			, @FuelOil_29 NUMERIC(18, 4) = 0		
			, @FuelOil_30 NUMERIC(18, 0) = 0
			, @FuelOil_31 NUMERIC(18, 0) = 0
			, @FuelOil_32 NUMERIC(18, 2) = 0
			  
			, @UndyedDiesel_1 NUMERIC(18, 0) = 0
			, @UndyedDiesel_2 NUMERIC(18, 0) = 0
			, @UndyedDiesel_3 NUMERIC(18, 0) = 0
			, @UndyedDiesel_4 NUMERIC(18, 0) = 0
			, @UndyedDiesel_5 NUMERIC(18, 0) = 0
			, @UndyedDiesel_6 NUMERIC(18, 0) = 0
			, @UndyedDiesel_7 NUMERIC(18, 0) = 0
			, @UndyedDiesel_9 NUMERIC(18, 0) = 0
			, @UndyedDiesel_11 NUMERIC(18, 0) = 0
			, @UndyedDiesel_12 NUMERIC(18, 0) = 0
			, @UndyedDiesel_13 NUMERIC(18, 0) = 0
			, @UndyedDiesel_14 NUMERIC(18, 0) = 0
			, @UndyedDiesel_15 NUMERIC(18, 0) = 0
			, @UndyedDiesel_16 NUMERIC(18, 0) = 0
			, @UndyedDiesel_17 NUMERIC(18, 0) = 0
			, @UndyedDiesel_18 NUMERIC(18, 0) = 0
			, @UndyedDiesel_19 NUMERIC(18, 0) = 0
			, @UndyedDiesel_20 NUMERIC(18, 4) = 0
			, @UndyedDiesel_21 NUMERIC(18, 2) = 0
			--, @UndyedDiesel_22 NUMERIC(18, 0) = 0
			--, @UndyedDiesel_23 NUMERIC(18, 0) = 0
			, @UndyedDiesel_24 NUMERIC(18, 0) = 0
			, @UndyedDiesel_25 NUMERIC(18, 0) = 0
			, @UndyedDiesel_26 NUMERIC(18, 0) = 0
			, @UndyedDiesel_27 NUMERIC(18, 0) = 0
			, @UndyedDiesel_28 NUMERIC(18, 0) = 0
			, @UndyedDiesel_29 NUMERIC(18, 4) = 0
			, @UndyedDiesel_30 NUMERIC(18, 0) = 0
			, @UndyedDiesel_31 NUMERIC(18, 0) = 0
			, @UndyedDiesel_32 NUMERIC(18, 0) = 0
		  
			, @JetFuel_1 NUMERIC(18, 0) = 0
			, @JetFuel_2 NUMERIC(18, 0) = 0
			, @JetFuel_3 NUMERIC(18, 0) = 0
			, @JetFuel_4 NUMERIC(18, 0) = 0
			, @JetFuel_5 NUMERIC(18, 0) = 0
			, @JetFuel_6 NUMERIC(18, 0) = 0
			, @JetFuel_7 NUMERIC(18, 0) = 0
			, @JetFuel_9 NUMERIC(18, 0) = 0
			, @JetFuel_11 NUMERIC(18, 0) = 0
			, @JetFuel_12 NUMERIC(18, 0) = 0
			, @JetFuel_13 NUMERIC(18, 0) = 0
			, @JetFuel_14 NUMERIC(18, 0) = 0
			, @JetFuel_15 NUMERIC(18, 0) = 0
			, @JetFuel_16 NUMERIC(18, 0) = 0
			, @JetFuel_17 NUMERIC(18, 0) = 0
			, @JetFuel_18 NUMERIC(18, 0) = 0
			, @JetFuel_19 NUMERIC(18, 0) = 0
			, @JetFuel_20 NUMERIC(18, 4) = 0
			, @JetFuel_21 NUMERIC(18, 2) = 0
			--, @JetFuel_22 NUMERIC(18, 0) = 0
			--, @JetFuel_23 NUMERIC(18, 0) = 0
			, @JetFuel_24 NUMERIC(18, 0) = 0
			, @JetFuel_25 NUMERIC(18, 0) = 0
			, @JetFuel_26 NUMERIC(18, 0) = 0
			, @JetFuel_27 NUMERIC(18, 0) = 0
			, @JetFuel_28 NUMERIC(18, 0) = 0		
			, @JetFuel_29 NUMERIC(18, 4) = 0
			, @JetFuel_30 NUMERIC(18, 0) = 0
			
			, @Line31 NUMERIC(18, 2) = 0
			, @Line32 NUMERIC(18, 2) = 0  
			, @Line33 NUMERIC(18, 2) = 0
			, @Line34 NUMERIC(18, 2) = 0
			, @Line35 NUMERIC(18, 2) = 0
			, @Line36 NUMERIC(18, 2) = 0
			

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

		DECLARE @transaction TABLE(
			 strFormCode NVARCHAR(100)
			,strScheduleCode NVARCHAR(100)
			,strType  NVARCHAR(100)
			,dblReceived NUMERIC
			,dblBillQty NUMERIC
			,dblQtyShipped NUMERIC
			,dblTax NUMERIC(18,2)
			,dblTaxExempt NUMERIC(18,2)
			)
		
		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'
		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'
				
		INSERT INTO @transaction
		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblReceived, 0.00)), dblBillQty = SUM(ISNULL(dblBillQty, 0.00)), dblQtyShipped = SUM(ISNULL(dblQtyShipped, 0.00)), dblTax = SUM(ISNULL(dblTax, 0.00)), dblTaxExempt = SUM(ISNULL(dblTaxExempt, 0.00))
		FROM vyuTFGetTransaction
		WHERE uniqTransactionGuid = @Guid
		GROUP BY strFormCode, strScheduleCode, strType

		-- Dyed Diesel
		SELECT @DyedDiesel_1 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '1' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_2 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2A' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_3 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2C' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_4 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2X' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_5 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5B' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_6 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5D' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_9 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '6D' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_11 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '7' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_13 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '8' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_14 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10A' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_15 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10B' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_16 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10R' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_17 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10Y' AND strType = 'Dyed Diesel and Kerosene'	
		SELECT @DyedDiesel_22 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5F' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_23 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5G' AND strType = 'Dyed Diesel and Kerosene'
		SELECT @DyedDiesel_28 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '13H' AND strType = 'Dyed Diesel and Kerosene'

		-- Fuel Oil
		SELECT @FuelOil_1 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '1' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_2 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2A' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_3 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2C' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_4 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2X' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_5 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5B' AND strType = 'Fuel Oil and Other Special Fuel'	
		SELECT @FuelOil_6 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5D' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_9 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '6D' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_11 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '7' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_13 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '8' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_14 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10A' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_15 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10B' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_16 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10R' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_17 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10Y' AND strType = 'Fuel Oil and Other Special Fuel'
		SELECT @FuelOil_28 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '13H' AND strType = 'Fuel Oil and Other Special Fuel'

		-- Undyed Diesel
		SELECT @UndyedDiesel_1 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '1' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_2 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2A' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_3 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2C' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_4 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2X' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_5 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5B' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_6 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5D' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_9 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '6D' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_11 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '7' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_13 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '8' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_14 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10A' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_15 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10B' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_16 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10R' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_17 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10Y' AND strType = 'Undyed Diesel'
		SELECT @UndyedDiesel_28 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '13H' AND strType = 'Undyed Diesel'

		-- Jet Fuel
		SELECT @JetFuel_1 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '1' AND strType = 'Jet Fuel'
		SELECT @JetFuel_2 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2A' AND strType = 'Jet Fuel'
		SELECT @JetFuel_3 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2C' AND strType = 'Jet Fuel'
		SELECT @JetFuel_4 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '2X' AND strType = 'Jet Fuel'
		SELECT @JetFuel_5 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5B' AND strType = 'Jet Fuel'
		SELECT @JetFuel_6 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '5D' AND strType = 'Jet Fuel'
		SELECT @JetFuel_9 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '6D' AND strType = 'Jet Fuel'
		SELECT @JetFuel_11 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '7' AND strType = 'Jet Fuel'
		SELECT @JetFuel_13 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '8' AND strType = 'Jet Fuel'
		SELECT @JetFuel_14 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10A' AND strType = 'Jet Fuel'
		SELECT @JetFuel_15 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10B' AND strType = 'Jet Fuel'
		SELECT @JetFuel_16 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10R' AND strType = 'Jet Fuel'
		SELECT @JetFuel_17 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '10Y' AND strType = 'Jet Fuel'
		SELECT @JetFuel_28 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'SpecialFuels' AND strScheduleCode = '13H' AND strType = 'Jet Fuel'

		-- Configuration
		SELECT @DyedDiesel_12 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line12Dyed'
		SELECT @DyedDiesel_20 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line20Dyed'
		SELECT @DyedDiesel_25 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line25Dyed'
		SELECT @DyedDiesel_29 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line29Dyed'

		SELECT @FuelOil_12 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line12FuelOil'
		SELECT @FuelOil_20 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line20FuelOil'
		SELECT @FuelOil_29 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line29FuelOil'

		SELECT @UndyedDiesel_12 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line12Undyed'
		SELECT @UndyedDiesel_20 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line20Undyed'
		SELECT @UndyedDiesel_29 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line29Undyed'

		SELECT @JetFuel_12 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line12Jet'
		SELECT @JetFuel_20 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line20Jet'
		SELECT @JetFuel_29 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line29Jet'

		SELECT @Line33 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line33'
		SELECT @Line34 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line34'
		SELECT @Line35 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'SpecialFuels' AND strTemplateItemId = 'SF-Line35'

		-- Line 7
		SET @DyedDiesel_7 = @DyedDiesel_1 + @DyedDiesel_2 + @DyedDiesel_3 + @DyedDiesel_4 + @DyedDiesel_5 + @DyedDiesel_6
		SET @FuelOil_7 =  @FuelOil_1 + @FuelOil_2 + @FuelOil_3 + @FuelOil_4 + @FuelOil_5 + @FuelOil_6
		SET @UndyedDiesel_7 = @UndyedDiesel_1 + @UndyedDiesel_2 + @UndyedDiesel_3 + @UndyedDiesel_4 + @UndyedDiesel_5 + @UndyedDiesel_6
		SET @JetFuel_7 = @JetFuel_1 + @JetFuel_2 + @JetFuel_3 + @JetFuel_4 + @JetFuel_5 + @JetFuel_6

		-- Line 18
		SET @DyedDiesel_18 = @DyedDiesel_1 + @DyedDiesel_9 + @DyedDiesel_4 + @DyedDiesel_11 + @DyedDiesel_12 + @DyedDiesel_13 + @DyedDiesel_14 + @DyedDiesel_15 + @DyedDiesel_16 + @DyedDiesel_17
		SET @FuelOil_18 = @FuelOil_1 + @FuelOil_9 + @FuelOil_4 + @FuelOil_11 + @FuelOil_12 + @FuelOil_13 + @FuelOil_14 + @FuelOil_15 + @FuelOil_16 + @FuelOil_17
		SET @UndyedDiesel_18 = @UndyedDiesel_1 + @UndyedDiesel_9 + @UndyedDiesel_4 + @UndyedDiesel_11 + @UndyedDiesel_12 + @UndyedDiesel_13 + @UndyedDiesel_14 + @UndyedDiesel_15 + @UndyedDiesel_16 + @UndyedDiesel_17
		SET @JetFuel_18 = @JetFuel_1 + @JetFuel_9 + @JetFuel_4 + @JetFuel_11 + @JetFuel_12 + @JetFuel_13 + @JetFuel_14 + @JetFuel_15 + @JetFuel_16 + @JetFuel_17
		
		-- Line 19
		SET @DyedDiesel_19 = @DyedDiesel_7 - @DyedDiesel_18
		SET @FuelOil_19 = @FuelOil_7 - @FuelOil_18
		SET @UndyedDiesel_19 = @UndyedDiesel_7 - @UndyedDiesel_18
		SET @JetFuel_19 = @JetFuel_7 - @JetFuel_18

		-- Line 21
		SET @DyedDiesel_21 = @DyedDiesel_19 * @DyedDiesel_20
		SET @FuelOil_21 = @FuelOil_19 * @FuelOil_20
		SET @UndyedDiesel_21 = @UndyedDiesel_19 * @UndyedDiesel_20
		SET @JetFuel_21 = @JetFuel_19 * @JetFuel_20

		-- Line 24
		SET @DyedDiesel_24 = @DyedDiesel_22 + @DyedDiesel_23

		-- Line 26
		SET @DyedDiesel_26 = @DyedDiesel_24 * @DyedDiesel_25


		-- Line 27
		SET @DyedDiesel_27 = @DyedDiesel_21 + @FuelOil_21 + @UndyedDiesel_21 + @JetFuel_21 + @DyedDiesel_26

		-- Line 30
		SET @DyedDiesel_30 =@DyedDiesel_28 * @DyedDiesel_29
		SET @FuelOil_30 = @FuelOil_28 * @FuelOil_29
		SET @UndyedDiesel_30 = @UndyedDiesel_28 * @UndyedDiesel_29
		SET @JetFuel_30 = @JetFuel_28 * @JetFuel_29

		-- Line 31
		SET @Line31 = @DyedDiesel_30 + @FuelOil_30 + @UndyedDiesel_30 + @JetFuel_30

		-- Line 32
		SET @Line32 = @DyedDiesel_27 - @Line31

		-- Line 36
		SET @Line36 = @Line32 + @Line33 + @Line34 + @Line35

	END

	SELECT DyedDiesel_1	= @DyedDiesel_1
		, DyedDiesel_2A = @DyedDiesel_2
		, DyedDiesel_2C = @DyedDiesel_3
		, DyedDiesel_2X = @DyedDiesel_4
		, DyedDiesel_5B = @DyedDiesel_5
		, DyedDiesel_5D = @DyedDiesel_6
		, DyedDiesel_SUM_7 = @DyedDiesel_7
		, DyedDiesel_6D = @DyedDiesel_9
		, DyedDiesel_7	= @DyedDiesel_11
		, DyedDiesel_7C = @DyedDiesel_12
		, DyedDiesel_8	= @DyedDiesel_13
		, DyedDiesel_10A = @DyedDiesel_14
		, DyedDiesel_10B = @DyedDiesel_15
		, DyedDiesel_10R = @DyedDiesel_16
		, DyedDiesel_10Y = @DyedDiesel_17
		, DyedDiesel_5F = @DyedDiesel_22
		, DyedDiesel_5G = @DyedDiesel_23
		, DyedDiesel_13H = @DyedDiesel_28
		, DyedDiesel_18 = @DyedDiesel_18
		, DyedDiesel_19 = @DyedDiesel_19
		, DyedDiesel_20 = @DyedDiesel_20
		, DyedDiesel_21 = @DyedDiesel_21	  
		, DyedDiesel_24 = @DyedDiesel_24
		, DyedDiesel_25 = @DyedDiesel_25
		, DyedDiesel_26 = @DyedDiesel_26
		, DyedDiesel_27 = @DyedDiesel_27
		, DyedDiesel_29 = @DyedDiesel_29
		, DyedDiesel_30 = @DyedDiesel_30
		--, DyedDiesel_31 = @DyedDiesel_31
		--, DyedDiesel_32 = @DyedDiesel_32

		, FuelOil_1	= @FuelOil_1
		, FuelOil_2A = @FuelOil_2
		, FuelOil_2C = @FuelOil_3
		, FuelOil_2X = @FuelOil_4
		, FuelOil_5B = @FuelOil_5
		, FuelOil_5D = @FuelOil_6
		, FuelOil_SUM_7 = @FuelOil_7
		, FuelOil_6D = @FuelOil_9
		, FuelOil_7	= @FuelOil_11
		, FuelOil_7C = @FuelOil_12
		, FuelOil_8	= @FuelOil_13
		, FuelOil_10A = @FuelOil_14
		, FuelOil_10B = @FuelOil_15
		, FuelOil_10R = @FuelOil_16
		, FuelOil_10Y = @FuelOil_17
		--, FuelOil_5F = @FuelOil_22
		--, FuelOil_5G = @FuelOil_23
		, FuelOil_13H = @FuelOil_28
		, FuelOil_18 = @FuelOil_18
		, FuelOil_19 = @FuelOil_19
		, FuelOil_20 = @FuelOil_20
		, FuelOil_21 = @FuelOil_21	  
		--, FuelOil_24 = @FuelOil_24
		--, FuelOil_25 = @FuelOil_25
		--, FuelOil_26 = @FuelOil_26
		--, FuelOil_27 = @FuelOil_27
		, FuelOil_29 = @FuelOil_29
		, FuelOil_30 = @FuelOil_30
		--, FuelOil_31 = @FuelOil_31
		--, FuelOil_32 = @FuelOil_32
			  
		, UndyedDiesel_1 = @UndyedDiesel_1
		, UndyedDiesel_2A = @UndyedDiesel_2
		, UndyedDiesel_2C = @UndyedDiesel_3
		, UndyedDiesel_2X = @UndyedDiesel_4
		, UndyedDiesel_5B = @UndyedDiesel_5
		, UndyedDiesel_5D = @UndyedDiesel_6
		, UndyedDiesel_SUM_7 = @UndyedDiesel_7
		, UndyedDiesel_6D = @UndyedDiesel_9
		, UndyedDiesel_7 = @UndyedDiesel_11
		, UndyedDiesel_7C = @UndyedDiesel_12
		, UndyedDiesel_8 = @UndyedDiesel_13
		, UndyedDiesel_10A = @UndyedDiesel_14
		, UndyedDiesel_10B = @UndyedDiesel_15
		, UndyedDiesel_10R = @UndyedDiesel_16
		, UndyedDiesel_10Y = @UndyedDiesel_17
		--, UndyedDiesel_5F = @UndyedDiesel_22
		--, UndyedDiesel_5G = @UndyedDiesel_23
		, UndyedDiesel_13H =@UndyedDiesel_28
		, UndyedDiesel_18 = @UndyedDiesel_18
		, UndyedDiesel_19 = @UndyedDiesel_19
		, UndyedDiesel_20 = @UndyedDiesel_20
		, UndyedDiesel_21 = @UndyedDiesel_21	  
		--, UndyedDiesel_24 = @UndyedDiesel_24
		--, UndyedDiesel_25 = @UndyedDiesel_25
		--, UndyedDiesel_26 = @UndyedDiesel_26
		--, UndyedDiesel_27 = @UndyedDiesel_27
		, UndyedDiesel_29 = @UndyedDiesel_29
		, UndyedDiesel_30 = @UndyedDiesel_30
		--, UndyedDiesel_31 = @UndyedDiesel_31
		--, UndyedDiesel_32 = @UndyedDiesel_32
			  
		, JetFuel_1	= @JetFuel_1
		, JetFuel_2A = @JetFuel_2
		, JetFuel_2C = @JetFuel_3
		, JetFuel_2X = @JetFuel_4
		, JetFuel_5B = @JetFuel_5
		, JetFuel_5D = @JetFuel_6
		, JetFuel_SUM_7 = @JetFuel_7
		, JetFuel_6D = @JetFuel_9
		, JetFuel_7 = @JetFuel_11
		, JetFuel_7C = @JetFuel_12
		, JetFuel_8 = @JetFuel_13
		, JetFuel_10A = @JetFuel_14
		, JetFuel_10B = @JetFuel_15
		, JetFuel_10R = @JetFuel_16
		, JetFuel_10Y = @JetFuel_17
		--, JetFuel_5F = @JetFuel_22
		--, JetFuel_5G = @JetFuel_23
		, JetFuel_13H = @JetFuel_28
		, JetFuel_18 = @JetFuel_18
		, JetFuel_19 = @JetFuel_19
		, JetFuel_20 = @JetFuel_20
		, JetFuel_21 = @JetFuel_21	  
		--, JetFuel_24 = @JetFuel_24
		--, JetFuel_25 = @JetFuel_25
		--, JetFuel_26 = @JetFuel_26
		--, JetFuel_27 = @JetFuel_27
		, JetFuel_29 = @JetFuel_29
		, JetFuel_30 = @JetFuel_30

	    , Line31 = @Line31
	    , Line32 = @Line32
		, Line33 = @Line33
		, Line34 = @Line34
		, Line35 = @Line35
		, Line36 = @Line36

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