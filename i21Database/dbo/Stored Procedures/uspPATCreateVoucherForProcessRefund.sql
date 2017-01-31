﻿CREATE PROCEDURE [dbo].[uspPATCreateVoucherForProcessRefund]
	@refundId INT = NULL,
	@intUserId INT = NULL,
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


CREATE TABLE #tempRefundCustomer(
	[intRefundId] INT,
	[strRefundNo] NVARCHAR(50),
	[dblServiceFee] NUMERIC(18,6),
	[intRefundCustomerId] INT,
	[intCustomerId] INT,
	[dblRefundAmount] NUMERIC(18,6),
	[dblCashRefund] NUMERIC(18,6),
	[ysnQualified] BIT,
	[intBillId] INT
)

	INSERT INTO #tempRefundCustomer
	SELECT	R.intRefundId,
			R.strRefundNo,
			R.dblServiceFee,
			RC.intRefundCustomerId,
			RC.intCustomerId,
			RC.dblRefundAmount,
			RC.dblCashRefund,
			RC.ysnQualified,
			RC.intBillId
	FROM tblPATRefund R
	INNER JOIN tblPATRefundCustomer RC
		ON R.intRefundId = RC.intRefundId
	WHERE R.intRefundId = 2 AND RC.intBillId IS NULL


	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
	DECLARE @dtmDate DATETIME = GETDATE();
	DECLARE @intRefundCustomerId INT;
	DECLARE @intCustomerId INT;
	DECLARE @strVendorOrderNumber NVARCHAR(MAX);
	DECLARE @intAPClearingGLAccount INT;
	DECLARE @intServiceFeeIncomeId INT;
	DECLARE @intCreatedBillId INT;
	DECLARE @dblServiceFee NUMERIC(18,6);
	DECLARE @dblCashRefund NUMERIC(18,6);
	DECLARE @dbl1099Amount NUMERIC(18,6);

	DECLARE @refundProcessed AS Id;
	DECLARE @totalRecords AS INT = 0;

	INSERT INTO @refundProcessed
	SELECT intRefundCustomerId FROM #tempRefundCustomer

	SELECT	@intAPClearingGLAccount = intAPClearingGLAccount,
			@intServiceFeeIncomeId = intServiceFeeIncomeId
	FROM tblPATCompanyPreference

	SELECT @dblServiceFee = dblServiceFee FROM #tempRefundCustomer GROUP BY dblServiceFee;

	BEGIN TRANSACTION
	
	BEGIN TRY
	WHILE EXISTS(SELECT 1 FROM @refundProcessed)
	BEGIN
		SELECT TOP 1
			@intRefundCustomerId = tempRC.intRefundCustomerId,
			@strVendorOrderNumber = tempRC.strRefundNo + '-' + CONVERT(NVARCHAR(MAX), tempRC.intRefundCustomerId),
			@intCustomerId = tempRC.intCustomerId,
			@dblCashRefund = ROUND(tempRC.dblCashRefund, 2),
			@dbl1099Amount = CASE WHEN tempRC.ysnQualified = 1 THEN tempRC.dblRefundAmount ELSE tempRC.dblCashRefund END
		FROM @refundProcessed rp INNER JOIN #tempRefundCustomer tempRC ON rp.intId = tempRC.intRefundCustomerId

		INSERT INTO @voucherDetailNonInventory
			([intAccountId], [intItemId], [strMiscDescription], [dblQtyReceived], [dblDiscount], [dblCost], [intTaxGroupId])
		VALUES
			(@intAPClearingGLAccount, 0, 'Patronage Refund', 1, 0, ROUND(@dblCashRefund, 2), NULL),
			(@intServiceFeeIncomeId, 0, 'Service Fee', 1, 0, (@dblServiceFee * -1), NULL)

		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intCustomerId
			,@type = 1	
			,@voucherNonInvDetails = @voucherDetailNonInventory
			,@shipTo = NULL
			,@vendorOrderNumber = @strVendorOrderNumber
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT;

		UPDATE tblAPBillDetail SET int1099Form = 4, int1099Category= 0, dbl1099 = ROUND(@dbl1099Amount, 2) WHERE intBillId = @intCreatedBillId;
		UPDATE tblPATRefundCustomer SET intBillId = @intCreatedBillId WHERE intRefundCustomerId = @intRefundCustomerId;

		EXEC [dbo].[uspAPPostBill]
			@batchId = @intCreatedBillId,
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
			
		DELETE FROM @refundProcessed WHERE intId = @intRefundCustomerId;
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
	
	UPDATE tblPATRefund SET ysnVoucherProcessed = 1 WHERE intRefundId = @refundId;

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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempRefundCustomer')) DROP TABLE #tempRefundCustomer
END