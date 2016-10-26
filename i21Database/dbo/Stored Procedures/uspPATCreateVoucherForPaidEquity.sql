CREATE PROCEDURE [dbo].[uspPATCreateVoucherForPaidEquity]
	@equityCustomer AS NVARCHAR(MAX),
	@intUserId AS INT,
	@successfulCount INT = 0 OUTPUT,
	@strErrorMessage NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION

	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
	DECLARE @dtmDate DATETIME = GETDATE();
	DECLARE @intCustomerId INT;
	DECLARE @strVenderOrderNumber NVARCHAR(MAX);
	DECLARE @intCreatedBillId INT;
	DECLARE @equityCustomerIds AS Id;
	DECLARE @tempEquityDetails TABLE (dblEquity NUMERIC(18,6),strFiscalYear NVARCHAR(50));
	DECLARE @totalRecords AS INT = 0;

	SELECT CE.intCustomerId, CE.intFiscalYearId, dblEquity = SUM(CE.dblEquity)
	INTO #tempCustomerEquity 
	FROM tblPATCustomerEquity CE 
	WHERE CE.intCustomerEquityId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@equityCustomer))
	GROUP BY CE.intCustomerId,CE.intFiscalYearId

	INSERT INTO @equityCustomerIds
	SELECT DISTINCT intCustomerId FROM #tempCustomerEquity

BEGIN TRY

	WHILE EXISTS(SELECT 1 FROM @equityCustomerIds)
	BEGIN

		SELECT TOP 1			
			@intCustomerId = TCE.intCustomerId,
			@strVenderOrderNumber = 'PCE-' + CONVERT(NVARCHAR(50), TCE.intFiscalYearId) + CONVERT(NVARCHAR(MAX), TCE.intCustomerId) 
		FROM @equityCustomerIds EC INNER JOIN #tempCustomerEquity TCE ON EC.intId = TCE.intCustomerId
		
		INSERT INTO @tempEquityDetails
		SELECT 
			TCE.dblEquity,
			FY.strFiscalYear
		FROM #tempCustomerEquity TCE 
		INNER JOIN tblGLFiscalYear FY 
			ON FY.intFiscalYearId = TCE.intFiscalYearId
		WHERE TCE.intCustomerId = @intCustomerId 

		INSERT INTO @voucherDetailNonInventory([strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost])
		SELECT 'Patronage Equity Voucher (' + TCE.strFiscalYear + ')' , 
				dblQtyReceived = 1,
				dblDiscount = 0,
				dblCost = TCE.dblEquity
		FROM @tempEquityDetails TCE
		
		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intCustomerId
			,@type = 1	
			,@voucherNonInvDetails = @voucherDetailNonInventory
			,@shipTo = NULL
			,@vendorOrderNumber = @strVenderOrderNumber
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT
		
		DELETE FROM @equityCustomerIds WHERE intId = @intCustomerId;
		DELETE FROM @voucherDetailNonInventory;
		DELETE FROM @tempEquityDetails;

		SET @totalRecords = @totalRecords + 1;

	END

	UPDATE tblPATCustomerEquity SET ysnEquityPaid = 1,dtmLastActivityDate = GETDATE() WHERE intCustomerEquityId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@equityCustomer))

	IF @@ERROR <> 0	GOTO Post_Rollback;

END TRY

BEGIN CATCH
	DECLARE @intErrorSeverity INT,
			@intErrorNumber   INT,
			@intErrorState INT;
		
	SET @intErrorSeverity = ERROR_SEVERITY()
	SET @intErrorNumber   = ERROR_NUMBER()
	SET @strErrorMessage  = ERROR_MESSAGE()
	SET @intErrorState    = ERROR_STATE()
	RAISERROR (@strErrorMessage , @intErrorSeverity, @intErrorState, @intErrorNumber)
	GOTO Post_RollBack
END CATCH

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempCustomerEquity')) DROP TABLE #tempCustomerEquity
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempEquityDetails')) DROP TABLE #tempEquityDetails

GO