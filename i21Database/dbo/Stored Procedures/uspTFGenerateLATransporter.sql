CREATE PROCEDURE [dbo].[uspTFGenerateLATransporter]
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

	DECLARE @dtmFillingPeriod DATETIME
		, @strAccountNumber NVARCHAR(50)
		, @strFEIN NVARCHAR(50)
		, @dbl1_A NUMERIC(18, 6)
		, @dbl1_B NUMERIC(18, 6)
		, @dbl1_C NUMERIC(18, 6)
		, @dbl1_D NUMERIC(18, 6)
		, @dbl1_E NUMERIC(18, 6)
		, @dbl2_A NUMERIC(18, 6)
		, @dbl2_B NUMERIC(18, 6)
		, @dbl2_C NUMERIC(18, 6)
		, @dbl2_D NUMERIC(18, 6)
		, @dbl2_E NUMERIC(18, 6)
		, @dbl3_A NUMERIC(18, 6)
		, @dbl3_B NUMERIC(18, 6)
		, @dbl3_C NUMERIC(18, 6)
		, @dbl3_D NUMERIC(18, 6)
		, @dbl3_E NUMERIC(18, 6)
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

		SELECT @strAccountNumber = CASE WHEN strFormCode = 'R-5346' AND strTemplateItemId = 'R-5346-AcctNum' THEN ISNULL(strConfiguration, 0.00) ELSE 0.00 END
		FROM vyuTFGetReportingComponentConfiguration
		WHERE intTaxAuthorityId = @TaxAuthorityId

		SELECT @dbl1_A = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-23' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl1_B = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-23' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl1_C = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-23' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl1_D = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-23' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl1_E = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-23' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl2_A = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-24' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl2_B = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-24' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl2_C = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-24' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl2_D = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-24' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl2_E = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-24' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_A = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-25' AND strType = 'Gasohol' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_B = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-25' AND strType = 'Gasoline' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_C = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-25' AND strType = 'Undyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_D = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-25' AND strType = 'Dyed Diesel' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
			, @dbl3_E = CASE WHEN strFormCode = 'R-5346' AND strScheduleCode = 'G-25' AND strType = 'Aviation Fuels' THEN ISNULL(dblQtyShipped, 0.00) ELSE 0.00 END
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
		, dbl1_D = @dbl1_D
		, dbl1_E = @dbl1_E
		, dbl2_A = @dbl2_A
		, dbl2_B = @dbl2_B
		, dbl2_C = @dbl2_C
		, dbl2_D = @dbl2_D
		, dbl2_E = @dbl2_E
		, dbl3_A = @dbl3_A
		, dbl3_B = @dbl3_B
		, dbl3_C = @dbl3_C
		, dbl3_D = @dbl3_D
		, dbl3_E = @dbl3_E
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