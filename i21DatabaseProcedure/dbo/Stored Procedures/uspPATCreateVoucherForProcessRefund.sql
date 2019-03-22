CREATE PROCEDURE [dbo].[uspPATCreateVoucherForProcessRefund]
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

	CREATE TABLE #tempVoucherReference(
		[intBillId] INT NOT NULL,
		[intPatronageId] INT NOT NULL
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
	
	DECLARE @voucherPayable AS VoucherPayable;
	DECLARE @createdVouchersId AS NVARCHAR(MAX);
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
	DECLARE @shipToLocation INT = [dbo].[fnGetUserDefaultLocation](@intUserId);

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
	
	BEGIN TRAN;

	BEGIN TRY

		INSERT INTO @voucherPayable(
			[intPartitionId]
			,[intEntityVendorId]
			,[intTransactionType]
			,[strVendorOrderNumber]
			,[strSourceNumber]
			,[strMiscDescription]
			,[intAccountId]
			,[intLineNo]
			,[dblQuantityToBill]
			,[dblCost]
			,[int1099Form]
			,[int1099Category]
			,[dbl1099]
		)
		SELECT	intRefundCustomerId
				,intCustomerId
				,intTransactionType
				,strVendorOrderNumber
				,strRefundNo
				,strMiscDescription
				,intAccountId
				,intLineNo
				,dblQuantityToBill
				,dblCost
				,int1099Form
				,int1099Category
				,dbl1099
		FROM (
			SELECT	RefundCustomer.intRefundCustomerId
					,RefundCustomer.intCustomerId
					,[intTransactionType] = 1
					,[strVendorOrderNumber] = RefundCustomer.strRefundNo + '-' + CONVERT(NVARCHAR(MAX), RefundCustomer.intRefundCustomerId)
					,RefundCustomer.strRefundNo
					,[strMiscDescription] = 'Patronage Refund'
					,[intAccountId] = @intAPClearingGLAccount
					,[intLineNo] = 1
					,[dblQuantityToBill] = 1
					,[dblCost] = ROUND(RefundCustomer.dblCashRefund, 2)
					,[int1099Form] = 4
					,[int1099Category] = 1
					,[dbl1099] = CASE WHEN RefundCustomer.ysnQualified = 1 THEN RefundCustomer.dblRefundAmount ELSE RefundCustomer.dblCashRefund END
			FROM #tempRefundCustomer RefundCustomer
			UNION ALL
			SELECT	RefundCustomer.intRefundCustomerId
					,RefundCustomer.intCustomerId
					,[intTransactionType] = 1
					,[strVendorOrderNumber] = RefundCustomer.strRefundNo + '-' + CONVERT(NVARCHAR(MAX), RefundCustomer.intRefundCustomerId)
					,RefundCustomer.strRefundNo
					,[strMiscDescription] = 'Service Fee'
					,[intAccountId] = @intServiceFeeIncomeId
					,[intLineNo] = 2
					,[dblQuantityToBill] = 1
					,[dblCost] = - ROUND(RefundCustomer.dblServiceFee, 2)
					,[int1099Form] = 0
					,[int1099Category] = 0
					,[dbl1099] = 0
			FROM #tempRefundCustomer RefundCustomer
			WHERE RefundCustomer.dblServiceFee > 0
		) RefundVoucher
		ORDER BY intRefundCustomerId, intLineNo

		EXEC [dbo].[uspAPCreateVoucher]
			@voucherPayables = @voucherPayable
			,@userId = @intUserId
			,@throwError = 0
			,@error = @strErrorMessage OUT
			,@createdVouchersId = @createdVouchersId OUT

		IF (@strErrorMessage != '')
		BEGIN
			RAISERROR (@strErrorMessage, 16, 1);
			GOTO Post_Rollback;
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
			@param = @createdVouchersId,
			@userId = @intUserId,
			@success = @bitSuccess OUTPUT;

		IF(@bitSuccess = 0)
		BEGIN
			SELECT TOP 1 @strErrorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @intCreatedBillId;
			RAISERROR (@strErrorMessage, 16, 1);
			GOTO Post_Rollback;
		END

		INSERT INTO #tempVoucherReference(intBillId, intPatronageId)
		SELECT	intBillId
				,CAST(SUBSTRING([strVendorOrderNumber], CHARINDEX('-', [strVendorOrderNumber], CHARINDEX('-',[strVendorOrderNumber])+1) + 1, CHARINDEX('-',REVERSE([strVendorOrderNumber]))) AS INT)
		FROM tblAPBill Bill
		WHERE intBillId IN (SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVouchersId))
	

		UPDATE RefundCustomer
		SET RefundCustomer.intBillId = VoucherRef.intBillId
		FROM tblPATRefundCustomer RefundCustomer
		INNER JOIN #tempVoucherReference VoucherRef
			ON VoucherRef.intPatronageId = RefundCustomer.intRefundCustomerId

		SELECT @totalRecords = COUNT(*)
		FROM #tempRefundCustomer

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
	COMMIT TRAN;
	SET @bitSuccess = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	IF(@@TRANCOUNT > 0)
		ROLLBACK TRAN;	

	SET @bitSuccess = 0
	GOTO Post_Exit
Post_Exit:
END
