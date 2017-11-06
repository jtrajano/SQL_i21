CREATE PROCEDURE [dbo].[uspTFGenerateMSGas]
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

	DECLARE @AutomotiveGas_6D NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_1 NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_2 NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_2A NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_2B NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_2C NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_2X NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_5B NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_5D NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_7 NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_8 NUMERIC(18, 6) = 0.00
		, @AutomotiveGas_13H NUMERIC(18, 6) = 0.00

		, @AviationGas_6D NUMERIC(18, 6) = 0.00
		, @AviationGas_1 NUMERIC(18, 6) = 0.00
		, @AviationGas_2 NUMERIC(18, 6) = 0.00
		, @AviationGas_2A NUMERIC(18, 6) = 0.00
		, @AviationGas_2B NUMERIC(18, 6) = 0.00
		, @AviationGas_2C NUMERIC(18, 6) = 0.00
		, @AviationGas_2X NUMERIC(18, 6) = 0.00
		, @AviationGas_5B NUMERIC(18, 6) = 0.00
		, @AviationGas_5D NUMERIC(18, 6) = 0.00
		, @AviationGas_7 NUMERIC(18, 6) = 0.00
		, @AviationGas_8 NUMERIC(18, 6) = 0.00
		, @AviationGas_13H NUMERIC(18, 6) = 0.00

		, @TaxCredit NUMERIC(18, 6) = 0.00
		, @Penalty NUMERIC(18, 6) = 0.00
		, @Interest NUMERIC(18, 6) = 0.00

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
				
		SELECT @AutomotiveGas_6D = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_1 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_2 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_2A = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_2B = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_2C = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_2X = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_5B = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_5D = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_7 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_8 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AutomotiveGas_13H = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Automotive Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END

			, @AviationGas_6D = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_1 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_2 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_2A = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_2B = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2B' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_2C = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_2X = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_5B = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_5D = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_7 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_8 = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
			, @AviationGas_13H = CASE WHEN strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Aviation Gas' THEN ISNULL(dblReceived, 0.00) ELSE 0.00 END
		FROM #tmpTotals		

		DROP TABLE #tmpTotals
		DROP TABLE #tmpTransactions
	END

	SELECT AutomotiveGas_6D = @AutomotiveGas_6D
		, AutomotiveGas_1 = @AutomotiveGas_1
		, AutomotiveGas_2 = @AutomotiveGas_2
		, AutomotiveGas_2A = @AutomotiveGas_2A
		, AutomotiveGas_2B = @AutomotiveGas_2B
		, AutomotiveGas_2C = @AutomotiveGas_2C
		, AutomotiveGas_2X = @AutomotiveGas_2X
		, AutomotiveGas_5B = @AutomotiveGas_5B
		, AutomotiveGas_5D = @AutomotiveGas_5D
		, AutomotiveGas_7 = @AutomotiveGas_7
		, AutomotiveGas_8 = @AutomotiveGas_8
		, AutomotiveGas_13H = @AutomotiveGas_13H

		, AviationGas_6D = @AviationGas_6D
		, AviationGas_1 = @AviationGas_1
		, AviationGas_2 = @AviationGas_2
		, AviationGas_2A = @AviationGas_2A
		, AviationGas_2B = @AviationGas_2B
		, AviationGas_2C = @AviationGas_2C
		, AviationGas_2X = @AviationGas_2X
		, AviationGas_5B = @AviationGas_5B
		, AviationGas_5D = @AviationGas_5D
		, AviationGas_7 = @AviationGas_7
		, AviationGas_8 = @AviationGas_8
		, AviationGas_13H = @AviationGas_13H
			  
		, TaxCredit = ISNULL(@TaxCredit, 0.00)
		, Penalty = ISNULL(@Penalty, 0.00)
		, Interest = ISNULL(@Interest, 0.00)

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