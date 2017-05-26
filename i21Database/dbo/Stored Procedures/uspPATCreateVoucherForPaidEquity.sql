CREATE PROCEDURE [dbo].[uspPATCreateVoucherForPaidEquity]
	@equityPay INT = NULL,
	@equityPaymentIds NVARCHAR(MAX) = NULL,
	@intUserId INT = NULL,
	@intAPClearing INT = NULL,
	@successfulCount INT = 0 OUTPUT,
	@strErrorMessage NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@bitSuccess BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

CREATE TABLE #tempEquityPayments(
	[intEquityPayId] INT,
	[strPaymentNumber] NVARCHAR(50),
	[dtmPaymentDate] DATETIME,
	[intEquityPaySummaryId] INT,
	[intCustomerPatronId] INT,
	[dblEquityPaid] NUMERIC(18,6)
)


BEGIN TRANSACTION 
IF(@equityPaymentIds = 'all')
BEGIN
	INSERT INTO #tempEquityPayments
	SELECT	EP.intEquityPayId,
			EP.strPaymentNumber,
			EP.dtmPaymentDate,
			EPS.intEquityPaySummaryId,
			EPS.intCustomerPatronId,
			EPS.dblEquityPaid
	FROM tblPATEquityPay EP
	INNER JOIN tblPATEquityPaySummary EPS
		ON EPS.intEquityPayId = EP.intEquityPayId
	WHERE EP.intEquityPayId = @equityPay AND EPS.intBillId IS NULL
END
ELSE
BEGIN
	INSERT INTO #tempEquityPayments
	SELECT	EP.intEquityPayId,
			EP.strPaymentNumber,
			EP.dtmPaymentDate,
			EPS.intEquityPaySummaryId,
			EPS.intCustomerPatronId,
			EPS.dblEquityPaid
	FROM tblPATEquityPay EP
	INNER JOIN tblPATEquityPaySummary EPS
		ON EPS.intEquityPayId = EP.intEquityPayId
	WHERE EPS.intEquityPaySummaryId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@equityPaymentIds))
END

	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
	DECLARE @dtmDate DATETIME = GETDATE();
	DECLARE @intEquityPaySummaryId INT;
	DECLARE @intCustomerPatronId INT;
	DECLARE @dblEquityPay NUMERIC(18,6);
	DECLARE @strVenderOrderNumber NVARCHAR(MAX);
	DECLARE @intCreatedBillId INT;
	DECLARE @batchId AS NVARCHAR(40);

	DECLARE @equityPayments AS Id;
	DECLARE @totalRecords AS INT = 0;

	INSERT INTO @equityPayments
	SELECT intEquityPaySummaryId FROM #tempEquityPayments
	
	DECLARE @voucherId AS Id;

	BEGIN TRY 
	WHILE EXISTS(SELECT 1 FROM @equityPayments)
	BEGIN 
		SELECT TOP 1
			@intEquityPaySummaryId = tEP.intEquityPaySummaryId,
			@intCustomerPatronId = tEP.intCustomerPatronId,
			@dblEquityPay = ROUND(tEP.dblEquityPaid,2),
			@strVenderOrderNumber = tEP.strPaymentNumber + '-' + CONVERT(NVARCHAR(MAX), tEP.intEquityPaySummaryId)
		FROM @equityPayments dEP INNER JOIN #tempEquityPayments tEP ON tEP.intEquityPaySummaryId = dEP.intId

		INSERT INTO @voucherDetailNonInventory([intAccountId],[intItemId],[strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost],[intTaxGroupId])
				VALUES(@intAPClearing,NULL,'Patronage Equity Payment', 1, 0, @dblEquityPay, NULL);

		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intCustomerPatronId
			,@type = 1	
			,@voucherNonInvDetails = @voucherDetailNonInventory
			,@shipTo = NULL
			,@vendorOrderNumber = @strVenderOrderNumber
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT;

		UPDATE tblPATEquityPaySummary SET intBillId = @intCreatedBillId WHERE intEquityPaySummaryId = @intEquityPaySummaryId;

		IF EXISTS(SELECT 1 FROM tblAPBillDetailTax WHERE intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intCreatedBillId))
		BEGIN
			INSERT INTO @voucherId SELECT intBillId FROM tblAPBill where intBillId = @intCreatedBillId;

			EXEC [dbo].[uspAPDeletePatronageTaxes] @voucherId;

			UPDATE tblAPBill SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);
			UPDATE tblAPBillDetail SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);

			EXEC [dbo].[uspAPUpdateVoucherTotal] @voucherId;

			DELETE FROM @voucherId;
		END

		IF(@batchId IS NULL)
			EXEC uspSMGetStartingNumber 3, @batchId OUT

		EXEC [dbo].[uspAPPostBill]
			@batchId = @batchId,
			@billBatchId = NULL,
			@transactionType = NULL,
			@post = 1,
			@recap = 0,
			@isBatch = 0,
			@param = NULL,
			@userId = @intUserId,
			@beginTransaction = @intCreatedBillId,
			@endTransaction = @intCreatedBillId,
			@success = @bitSuccess OUTPUT;


		DELETE FROM @equityPayments WHERE intId = @intEquityPaySummaryId;
		DELETE FROM @voucherDetailNonInventory;
		SET @intCreatedBillId = NULL;
		SET @totalRecords = @totalRecords + 1;
	END

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
	GOTO Post_Rollback
END CATCH

IF @@ERROR <> 0	GOTO Post_Rollback;

Post_Commit:
	COMMIT TRANSACTION
	SET @bitSuccess = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @bitSuccess = 0
	GOTO Post_Exit
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempEquityPayments')) DROP TABLE #tempEquityPayments
END