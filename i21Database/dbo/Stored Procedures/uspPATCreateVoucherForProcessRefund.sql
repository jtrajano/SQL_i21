﻿CREATE PROCEDURE [dbo].[uspPATCreateVoucherForProcessRefund]
	@refundId INT = NULL,
	@refundCustomerIds NVARCHAR(MAX) = NULL,
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
		[strName] NVARCHAR(50),
		[dblRefundAmount] NUMERIC(18,6),
		[dblCashRefund] NUMERIC(18,6),
		[ysnQualified] BIT,
		[ysnVendor] BIT,
		[intBillId] INT
	)

	IF(@refundCustomerIds = 'all')
	BEGIN
		INSERT INTO #tempRefundCustomer
		SELECT	R.intRefundId,
				R.strRefundNo,
				R.dblServiceFee,
				RC.intRefundCustomerId,
				RC.intCustomerId,
				EM.strName,
				RC.dblRefundAmount,
				RC.dblCashRefund,
				RC.ysnQualified,
				ysnVendor = APV.Vendor,
				RC.intBillId
		FROM tblPATRefund R
		INNER JOIN tblPATRefundCustomer RC
			ON R.intRefundId = RC.intRefundId
		INNER JOIN tblEMEntity EM
			ON EM.intEntityId = RC.intCustomerId
		LEFT OUTER JOIN vyuEMEntityType APV ON APV.intEntityId = RC.intCustomerId
		WHERE R.intRefundId = @refundId AND RC.intBillId IS NULL AND RC.ysnEligibleRefund = 1 AND RC.dblCashRefund > 0
	END 
	ELSE
	BEGIN
		INSERT INTO #tempRefundCustomer
		SELECT	R.intRefundId,
				R.strRefundNo,
				R.dblServiceFee,
				RC.intRefundCustomerId,
				RC.intCustomerId,
				EM.strName,
				RC.dblRefundAmount,
				RC.dblCashRefund,
				RC.ysnQualified,
				ysnVendor = APV.Vendor,
				RC.intBillId
		FROM tblPATRefund R
		INNER JOIN tblPATRefundCustomer RC
			ON R.intRefundId = RC.intRefundId
		INNER JOIN tblEMEntity EM
			ON EM.intEntityId = RC.intCustomerId
		LEFT OUTER JOIN vyuEMEntityType APV ON APV.intEntityId = RC.intCustomerId
		WHERE RC.intRefundCustomerId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@refundCustomerIds)) AND RC.ysnEligibleRefund = 1
	END
	

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
	DECLARE @batchId AS NVARCHAR(40);
	DECLARE @TransactionName AS VARCHAR(500) = 'CREATE VOUCHER' + CAST(NEWID() AS NVARCHAR(100));

	DECLARE @refundProcessed AS Id;
	DECLARE @totalRecords AS INT = 0;

	DECLARE @voucherId as Id;

	INSERT INTO @refundProcessed
	SELECT intRefundCustomerId FROM #tempRefundCustomer

	SELECT	@intAPClearingGLAccount = intAPClearingGLAccount,
			@intServiceFeeIncomeId = intServiceFeeIncomeId
	FROM tblPATCompanyPreference

	IF(ISNULL(@intAPClearingGLAccount,0) = 0)
	BEGIN
		SET @strErrorMessage = 'Unable to voucher. AP Clearing account is not set.';
		RAISERROR(@strErrorMessage, 16, 1);
		GOTO Post_Exit;
	END

	SELECT @dblServiceFee = dblServiceFee FROM #tempRefundCustomer GROUP BY dblServiceFee;

	IF EXISTS(SELECT 1 FROM #tempRefundCustomer WHERE dblCashRefund = 0)
	BEGIN
		SET @strErrorMessage = 'Zero Cash Refund cannot be vouchered.';
		RAISERROR(@strErrorMessage, 16, 1);
		GOTO Post_Exit;
	END

	SELECT @invalidCount = COUNT(*) FROM #tempRefundCustomer WHERE ysnVendor = 0;

	IF(@invalidCount > 0)
	BEGIN
		DECLARE @customerName NVARCHAR(50);
		SELECT TOP 1 @customerName = strName FROM #tempRefundCustomer WHERE ysnVendor = 0;
		SET @strErrorMessage = 'Cannot create voucher for <strong>'+ @customerName +'</strong> as the entity is not marked as vendor';
		RAISERROR(@strErrorMessage, 16, 1);
		GOTO Post_Exit;
	END
	
	BEGIN TRAN @TransactionName;
	SAVE TRAN @TransactionName;

	BEGIN TRY
	WHILE EXISTS(SELECT 1 FROM @refundProcessed)
	BEGIN
		SELECT TOP 1
			@intRefundCustomerId = tempRC.intRefundCustomerId,
			@strVendorOrderNumber = tempRC.strRefundNo + '-' + CONVERT(NVARCHAR(MAX), tempRC.intRefundCustomerId),
			@intCustomerId = tempRC.intCustomerId,
			@dblCashRefund = ROUND(tempRC.dblCashRefund, 2),
			@dbl1099Amount = CASE WHEN tempRC.ysnQualified = 1 THEN tempRC.dblRefundAmount ELSE tempRC.dblCashRefund END
		FROM @refundProcessed rp 
		INNER JOIN #tempRefundCustomer tempRC ON rp.intId = tempRC.intRefundCustomerId

		INSERT INTO @voucherDetailNonInventory
			([intAccountId], [intItemId], [strMiscDescription], [dblQtyReceived], [dblDiscount], [dblCost], [intTaxGroupId])
		VALUES
			(@intAPClearingGLAccount, 0, 'Patronage Refund', 1, 0, ROUND(@dblCashRefund, 2), NULL),
			(@intServiceFeeIncomeId, 0, 'Service Fee', 1, 0, (@dblServiceFee * -1), NULL)
		
		-- DELETE SERVICE FEE IF COST IS 0
		DELETE FROM @voucherDetailNonInventory
		WHERE [strMiscDescription] = N'Service Fee' AND @dblServiceFee = 0;

		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intCustomerId
			,@type = 1	
			,@voucherNonInvDetails = @voucherDetailNonInventory
			,@shipTo = NULL
			,@vendorOrderNumber = @strVendorOrderNumber
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT;

		UPDATE tblAPBillDetail SET int1099Form = 4, int1099Category = 1, dbl1099 = ROUND(@dbl1099Amount, 2), intCurrencyId = [dbo].[fnSMGetDefaultCurrency]('FUNCTIONAL') 
		WHERE intBillId = @intCreatedBillId AND strMiscDescription != N'Service Fee';

		UPDATE tblAPBillDetail SET int1099Form = 0, int1099Category = 0, intCurrencyId = [dbo].[fnSMGetDefaultCurrency]('FUNCTIONAL') 
		WHERE intBillId = @intCreatedBillId AND strMiscDescription = N'Service Fee';

		UPDATE tblPATRefundCustomer SET intBillId = @intCreatedBillId WHERE intRefundCustomerId = @intRefundCustomerId;

		IF EXISTS(SELECT 1 FROM tblAPBillDetailTax WHERE intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intCreatedBillId))
		BEGIN
			INSERT INTO @voucherId SELECT intBillId FROM tblAPBill where intBillId = @intCreatedBillId;

			EXEC [dbo].[uspAPDeletePatronageTaxes] @voucherId;

			UPDATE tblAPBill SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);
			UPDATE tblAPBillDetail SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);

			EXEC uspAPUpdateVoucherTotal @voucherId;
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

		IF(@bitSuccess = 0)
		BEGIN
			SELECT TOP 1 @strErrorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @intCreatedBillId;
			RAISERROR (@strErrorMessage, 16, 1);
			GOTO Post_Rollback;
		END

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

IF @@ERROR <> 0	GOTO Post_Rollback;

Post_Commit:
	COMMIT TRAN @TransactionName;
	SET @bitSuccess = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	IF(@@TRANCOUNT > 0)
		ROLLBACK TRAN @TransactionName;	

	SET @bitSuccess = 0
	GOTO Post_Exit
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempRefundCustomer')) DROP TABLE #tempRefundCustomer
END
