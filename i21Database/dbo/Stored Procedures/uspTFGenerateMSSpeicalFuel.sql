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

	DECLARE @DyedDiesel_1 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_2 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_3 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_4 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_5 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_6 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_9 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_11 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_12 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_13 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_14 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_15 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_16 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_17 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_22 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_23 NUMERIC(18, 6) = 0.00
			, @DyedDiesel_28 NUMERIC(18, 6) = 0.00
			  
			, @FuelOil_1 NUMERIC(18, 6) = 0.00
			, @FuelOil_2 NUMERIC(18, 6) = 0.00
			, @FuelOil_3 NUMERIC(18, 6) = 0.00
			, @FuelOil_4 NUMERIC(18, 6) = 0.00
			, @FuelOil_5 NUMERIC(18, 6) = 0.00
			, @FuelOil_6 NUMERIC(18, 6) = 0.00
			, @FuelOil_9 NUMERIC(18, 6) = 0.00
			, @FuelOil_11 NUMERIC(18, 6) = 0.00
			, @FuelOil_12 NUMERIC(18, 6) = 0.00
			, @FuelOil_13 NUMERIC(18, 6) = 0.00
			, @FuelOil_14 NUMERIC(18, 6) = 0.00
			, @FuelOil_15 NUMERIC(18, 6) = 0.00
			, @FuelOil_16 NUMERIC(18, 6) = 0.00
			, @FuelOil_17 NUMERIC(18, 6) = 0.00
			, @FuelOil_22 NUMERIC(18, 6) = 0.00
			, @FuelOil_23 NUMERIC(18, 6) = 0.00
			, @FuelOil_28 NUMERIC(18, 6) = 0.00
			  
			, @UndyedDiesel_1 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_2 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_3 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_4 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_5 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_6 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_9 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_11 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_12 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_13 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_14 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_15 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_16 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_17 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_22 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_23 NUMERIC(18, 6) = 0.00
			, @UndyedDiesel_28 NUMERIC(18, 6) = 0.00
			  
			, @JetFuel_1 NUMERIC(18, 6) = 0.00
			, @JetFuel_2 NUMERIC(18, 6) = 0.00
			, @JetFuel_3 NUMERIC(18, 6) = 0.00
			, @JetFuel_4 NUMERIC(18, 6) = 0.00
			, @JetFuel_5 NUMERIC(18, 6) = 0.00
			, @JetFuel_6 NUMERIC(18, 6) = 0.00
			, @JetFuel_9 NUMERIC(18, 6) = 0.00
			, @JetFuel_11 NUMERIC(18, 6) = 0.00
			, @JetFuel_12 NUMERIC(18, 6) = 0.00
			, @JetFuel_13 NUMERIC(18, 6) = 0.00
			, @JetFuel_14 NUMERIC(18, 6) = 0.00
			, @JetFuel_15 NUMERIC(18, 6) = 0.00
			, @JetFuel_16 NUMERIC(18, 6) = 0.00
			, @JetFuel_17 NUMERIC(18, 6) = 0.00
			, @JetFuel_22 NUMERIC(18, 6) = 0.00
			, @JetFuel_23 NUMERIC(18, 6) = 0.00
			, @JetFuel_28 NUMERIC(18, 6) = 0.00
			  
			, @TaxCredit NUMERIC(18, 6) = 0.00
			, @Penalty NUMERIC(18, 6)   = 0.00
			, @TotalDue NUMERIC(18, 6)  = 0.00

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
		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'
				
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


		SELECT @DyedDiesel_1 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_2 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_3 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_4 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_5 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_6 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_9 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_11 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_12 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_13 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_14 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_15 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_16 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10R' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_17 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10Y' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_22 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5F' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_23 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5G' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @DyedDiesel_28 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			  
			, @FuelOil_1 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_2 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_3 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_4 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_5 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_6 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_9 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_11 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_12 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_13 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_14 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_15 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_16 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10R' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_17 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10Y' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_22 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5F' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_23 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5G' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @FuelOil_28 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			  
			, @UndyedDiesel_1 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_2 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_3 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_4 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_5 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_6 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_9 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_11 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_12 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_13 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_14 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_15 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_16 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10R' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_17 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10Y' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_22 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5F' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_23 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5G' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @UndyedDiesel_28 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			  
			, @JetFuel_1 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_2 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_3 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_4 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_5 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_6 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_9 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_11 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_12 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7C' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_13 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_14 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10A' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_15 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10B' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_16 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10R' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_17 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '10Y' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_22 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5F' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_23 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5G' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @JetFuel_28 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
		FROM #tmpTotals		

		DROP TABLE #tmpTotals
		DROP TABLE #tmpTransactions
	END

	SELECT DyedDiesel_1	= @DyedDiesel_1
		, DyedDiesel_2A = @DyedDiesel_2
		, DyedDiesel_2C = @DyedDiesel_3
		, DyedDiesel_2X = @DyedDiesel_4
		, DyedDiesel_5B = @DyedDiesel_5
		, DyedDiesel_5D = @DyedDiesel_6
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
			  
		, FuelOil_1	= @FuelOil_1
		, FuelOil_2A = @FuelOil_2
		, FuelOil_2C = @FuelOil_3
		, FuelOil_2X = @FuelOil_4
		, FuelOil_5B = @FuelOil_5
		, FuelOil_5D = @FuelOil_6
		, FuelOil_6D = @FuelOil_9
		, FuelOil_7	= @FuelOil_11
		, FuelOil_7C = @FuelOil_12
		, FuelOil_8	= @FuelOil_13
		, FuelOil_10A = @FuelOil_14
		, FuelOil_10B = @FuelOil_15
		, FuelOil_10R = @FuelOil_16
		, FuelOil_10Y = @FuelOil_17
		, FuelOil_5F = @FuelOil_22
		, FuelOil_5G = @FuelOil_23
		, FuelOil_13H = @FuelOil_28
			  
		, UndyedDiesel_1 = @UndyedDiesel_1
		, UndyedDiesel_2A = @UndyedDiesel_2
		, UndyedDiesel_2C = @UndyedDiesel_3
		, UndyedDiesel_2X = @UndyedDiesel_4
		, UndyedDiesel_5B = @UndyedDiesel_5
		, UndyedDiesel_5D = @UndyedDiesel_6
		, UndyedDiesel_6D = @UndyedDiesel_9
		, UndyedDiesel_7 = @UndyedDiesel_11
		, UndyedDiesel_7C = @UndyedDiesel_12
		, UndyedDiesel_8 = @UndyedDiesel_13
		, UndyedDiesel_10A = @UndyedDiesel_14
		, UndyedDiesel_10B = @UndyedDiesel_15
		, UndyedDiesel_10R = @UndyedDiesel_16
		, UndyedDiesel_10Y = @UndyedDiesel_17
		, UndyedDiesel_5F = @UndyedDiesel_22
		, UndyedDiesel_5G = @UndyedDiesel_23
		, UndyedDiesel_13H =@UndyedDiesel_28
			  
		, JetFuel_1	= @JetFuel_1
		, JetFuel_2A = @JetFuel_2
		, JetFuel_2C = @JetFuel_3
		, JetFuel_2X = @JetFuel_4
		, JetFuel_5B = @JetFuel_5
		, JetFuel_5D = @JetFuel_6
		, JetFuel_6D = @JetFuel_9
		, JetFuel_7 = @JetFuel_11
		, JetFuel_7C = @JetFuel_12
		, JetFuel_8 = @JetFuel_13
		, JetFuel_10A = @JetFuel_14
		, JetFuel_10B = @JetFuel_15
		, JetFuel_10R = @JetFuel_16
		, JetFuel_10Y = @JetFuel_17
		, JetFuel_5F = @JetFuel_22
		, JetFuel_5G = @JetFuel_23
		, JetFuel_13H =@JetFuel_28
			  
		, TaxCredit = ISNULL(@TaxCredit, 0.00)
		, Penalty = ISNULL(@Penalty, 0.00)
		, TotalDue = ISNULL(@TotalDue, 0.00)

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