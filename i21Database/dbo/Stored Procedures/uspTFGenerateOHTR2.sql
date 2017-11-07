CREATE PROCEDURE [dbo].[uspTFGenerateOHTR2]
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
	
		, @Gasoline_1B NUMERIC(18, 6) = 0.00
		, @Gasoline_2E NUMERIC(18, 6) = 0.00
		, @Gasoline_7A NUMERIC(18, 6) = 0.00
		, @Gasoline_7D NUMERIC(18, 6) = 0.00
		
		, @ClearDiesel_1B NUMERIC(18, 6) = 0.00
		, @ClearDiesel_2E NUMERIC(18, 6) = 0.00
		, @ClearDiesel_7A NUMERIC(18, 6) = 0.00
		, @ClearDiesel_7D NUMERIC(18, 6) = 0.00

		, @LowSulfur_1B NUMERIC(18, 6) = 0.00
		, @LowSulfur_2E NUMERIC(18, 6) = 0.00
		, @LowSulfur_7A NUMERIC(18, 6) = 0.00
		, @LowSulfur_7D NUMERIC(18, 6) = 0.00

		, @HighSulfur_1B NUMERIC(18, 6) = 0.00
		, @HighSulfur_2E NUMERIC(18, 6) = 0.00
		, @HighSulfur_7A NUMERIC(18, 6) = 0.00
		, @HighSulfur_7D NUMERIC(18, 6) = 0.00

		, @Kerosene_1B NUMERIC(18, 6) = 0.00
		, @Kerosene_2E NUMERIC(18, 6) = 0.00
		, @Kerosene_7A NUMERIC(18, 6) = 0.00
		, @Kerosene_7D NUMERIC(18, 6) = 0.00

		, @CNG_1B NUMERIC(18, 6) = 0.00
		, @CNG_2E NUMERIC(18, 6) = 0.00
		, @CNG_7A NUMERIC(18, 6) = 0.00
		, @CNG_7D NUMERIC(18, 6) = 0.00

		, @LNG_1B NUMERIC(18, 6) = 0.00
		, @LNG_2E NUMERIC(18, 6) = 0.00
		, @LNG_7A NUMERIC(18, 6) = 0.00
		, @LNG_7D NUMERIC(18, 6) = 0.00

		, @Propane_1B NUMERIC(18, 6) = 0.00
		, @Propane_2E NUMERIC(18, 6) = 0.00
		, @Propane_7A NUMERIC(18, 6) = 0.00
		, @Propane_7D NUMERIC(18, 6) = 0.00

		, @Other_1B NUMERIC(18, 6) = 0.00
		, @Other_2E NUMERIC(18, 6) = 0.00
		, @Other_7A NUMERIC(18, 6) = 0.00
		, @Other_7D NUMERIC(18, 6) = 0.00

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


		--@Name NVARCHAR(100)
		--, @Address NVARCHAR(250)
		--, @City NVARCHAR(50)
		--, @State NVARCHAR(50)
		--, @ZipCode NVARCHAR(50)
		--, @Email NVARCHAR(50)
		--, @TIN NVARCHAR(50)
		--, @OhioAccountNo NVARCHAR(50)
		--, @Period DATETIME
		--, @AmmendedReturn BIT


		SELECT @Gasoline_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Gasoline_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'Gasoline' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @ClearDiesel_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @ClearDiesel_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'Clear Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @LowSulfur_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LowSulfur_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'Low Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @HighSulfur_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @HighSulfur_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'High Sulfur Dyed Diesel' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @Kerosene_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Kerosene_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'Kerosene' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @CNG_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @CNG_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'CNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @LNG_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @LNG_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'LNG' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @Propane_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Propane_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'Propane' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @Other_1B = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '1B' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_2E = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '2E' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_7A = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7A' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @Other_7D = CASE WHEN strFormCode = 'TR2' AND strScheduleCode = '7D' AND strType = 'Other' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
		FROM #tmpTotals

		SELECT @OhioAccountNo = strConfiguration
		FROM vyuTFGetReportingComponentConfiguration
		WHERE intTaxAuthorityId = @TaxAuthorityId
			AND strFormCode = 'TR2' AND strTemplateItemId = ''

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
	
		, Gasoline_1B = @Gasoline_1B
		, Gasoline_2E = @Gasoline_2E
		, Gasoline_7A = @Gasoline_7A
		, Gasoline_7D = @Gasoline_7D
		
		, ClearDiesel_1B = @ClearDiesel_1B
		, ClearDiesel_2E = @ClearDiesel_2E
		, ClearDiesel_7A = @ClearDiesel_7A
		, ClearDiesel_7D = @ClearDiesel_7D

		, LowSulfur_1B = @LowSulfur_1B
		, LowSulfur_2E = @LowSulfur_2E
		, LowSulfur_7A = @LowSulfur_7A
		, LowSulfur_7D = @LowSulfur_7D

		, HighSulfur_1B = @HighSulfur_1B
		, HighSulfur_2E = @HighSulfur_2E
		, HighSulfur_7A = @HighSulfur_7A
		, HighSulfur_7D = @HighSulfur_7D

		, Kerosene_1B = @Kerosene_1B
		, Kerosene_2E = @Kerosene_2E
		, Kerosene_7A = @Kerosene_7A
		, Kerosene_7D = @Kerosene_7D

		, CNG_1B = @CNG_1B
		, CNG_2E = @CNG_2E
		, CNG_7A = @CNG_7A
		, CNG_7D = @CNG_7D

		, LNG_1B = @LNG_1B
		, LNG_2E = @LNG_2E
		, LNG_7A = @LNG_7A
		, LNG_7D = @LNG_7D

		, Propane_1B = @Propane_1B
		, Propane_2E = @Propane_2E
		, Propane_7A = @Propane_7A
		, Propane_7D = @Propane_7D

		, Other_1B = @Other_1B
		, Other_2E = @Other_2E
		, Other_7A = @Other_7A
		, Other_7D = @Other_7D

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