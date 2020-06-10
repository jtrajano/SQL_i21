CREATE PROCEDURE [dbo].[uspAPCreatePaymentBatch]
	@userId INT,
	@intPaymentBatchId INT,
	@dtmDatePaid DATETIME,
	@ysnShowDeferred BIT,
	@intBankAccountId INT,
	@dblUnpaidDeferredPayments DECIMAL(18, 6),
	@intCountDeferredPayments INT,
	@intPaymentMethodId INT,
	@dblTotalAmount DECIMAL(18, 6),
	@intBillIds NVARCHAR(MAX),
	@intPaymentBatchIdUsed AS INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	DECLARE @ids AS Id;
	DECLARE @batchId AS Id;
	DECLARE @strPaymentBatchId NVARCHAR(50);

	INSERT INTO @ids
	--USE DISTINCT TO REMOVE DUPLICATE BILL ID FOR SCHEDULE PAYMENT
	SELECT DISTINCT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@intBillIds)

	--Generate BPAY-XXXX if new entry
	IF @intPaymentBatchId = 0
	BEGIN
		EXEC uspSMGetStartingNumber 154, @strPaymentBatchId OUT
	END

	--Temporary tblAPPaymentBatch
	DECLARE @tmpPaymentBatch AS TABLE
	(
		[intPaymentBatchId] INT NULL,
		[strPaymentBatchId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[dtmDatePaid] DATETIME NULL,
		[ysnShowDeferred] NVARCHAR(10) NULL,
		[intBankAccountId] INT NULL,
		[dblUnpaidDeferredPayments] DECIMAL(18, 6) NULL,
		[intCountDeferredPayments] INT NULL,
		[intPaymentMethodId] INT NULL,
		[dblTotalAmount] DECIMAL(18, 6) NULL,
		[intUserId] INT NULL
	);

	INSERT INTO @tmpPaymentBatch
	VALUES
	(
		@intPaymentBatchId,
		@strPaymentBatchId,
		@dtmDatePaid,
		@ysnShowDeferred,
		@intBankAccountId,
		@dblUnpaidDeferredPayments,
		@intCountDeferredPayments,
		@intPaymentMethodId,
		@dblTotalAmount,
		@userId
	)

	--Temporary tblAPPaymentBatchDetail
	DECLARE @tmpPaymentBatchDetail AS TABLE
	(
		[intPaymentBatchDetailId] INT NULL, 
    	[intPaymentBatchId] INT NULL,
    	[intBillId] INT NULL
	);

	INSERT INTO @tmpPaymentBatchDetail
	SELECT
		[intPaymentBatchDetailId]	= 0,
		[intPaymentBatchId]			= 0,
		[intBillId]					= ids.intId
	FROM @ids ids WHERE ids.intId <> 0 AND ids.intId IS NOT NULL

	--Merge to tblAPPaymentBatch
	MERGE INTO tblAPPaymentBatch AS TARGET
	USING @tmpPaymentBatch AS SOURCE
	ON (TARGET.intPaymentBatchId = SOURCE.intPaymentBatchId)
	WHEN MATCHED THEN
	UPDATE SET 
		[dtmDatePaid]				= SOURCE.dtmDatePaid,
		[ysnShowDeferred]			= SOURCE.ysnShowDeferred,
		[intBankAccountId]			= SOURCE.intBankAccountId,
		[dblUnpaidDeferredPayments]	= SOURCE.dblUnpaidDeferredPayments,
		[intCountDeferredPayments]	= SOURCE.intCountDeferredPayments,
		[intPaymentMethodId]		= SOURCE.intPaymentMethodId,
		[dblTotalAmount]			= SOURCE.dblTotalAmount,
		[intConcurrencyId]			= TARGET.intConcurrencyId + 1
	WHEN NOT MATCHED THEN
	INSERT
	(
		[strPaymentBatchId],
		[dtmDatePaid],
		[ysnShowDeferred],
		[intBankAccountId],
		[dblUnpaidDeferredPayments],
		[intCountDeferredPayments],
		[intPaymentMethodId],
		[dblTotalAmount],
		[intUserId]
	)
	VALUES
	(
		SOURCE.strPaymentBatchId,
		SOURCE.dtmDatePaid,
		SOURCE.ysnShowDeferred,
		SOURCE.intBankAccountId,
		SOURCE.dblUnpaidDeferredPayments,
		SOURCE.intCountDeferredPayments,
		SOURCE.intPaymentMethodId,
		SOURCE.dblTotalAmount,
		SOURCE.intUserId
	)
	OUTPUT INSERTED.intPaymentBatchId INTO @batchId;

	UPDATE @tmpPaymentBatchDetail SET intPaymentBatchId = (SELECT TOP 1 intId FROM @batchId) WHERE intBillId IS NOT NULL

	--Merge to tblAPPaymentBatchDetail
	MERGE INTO tblAPPaymentBatchDetail AS TARGET
	USING @tmpPaymentBatchDetail AS SOURCE
	ON (TARGET.intPaymentBatchId = SOURCE.intPaymentBatchId AND TARGET.intBillId = SOURCE.intBillId)
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
	(
		[intPaymentBatchId],
    	[intBillId]
	)
	VALUES
	(
		SOURCE.intPaymentBatchId,
		SOURCE.intBillId
	)
	WHEN NOT MATCHED BY SOURCE AND TARGET.intPaymentBatchId = (SELECT TOP 1 intId FROM @batchId) 
	AND TARGET.intBillId NOT IN (SELECT intBillId FROM @tmpPaymentBatchDetail) THEN
	DELETE;

	--Generate Payment Transactions
	DECLARE @tmpPartitionedVouchers AS TABLE
	(
		[intPartionId] INT NULL,
    	[strBillIds] NVARCHAR(MAX) NULL
	);

	INSERT INTO @tmpPartitionedVouchers
	SELECT intPartitionId, STRING_AGG(intBillId, ', ') AS strBillIds
	FROM fnAPPartitonPaymentOfVouchers(@ids)
	GROUP BY intPartitionId

	DECLARE @strBillIds NVARCHAR(MAX);
	DECLARE @csrPartitionedVouchers CURSOR;
	
	SET @csrPartitionedVouchers = CURSOR FORWARD_ONLY FOR
	SELECT strBillIds FROM @tmpPartitionedVouchers
	
	OPEN @csrPartitionedVouchers;
	FETCH NEXT FROM @csrPartitionedVouchers INTO @strBillIds
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC uspAPCreatePayment @userId = @userId, @bankAccount = @intBankAccountId, @billId = @strBillIds
		FETCH NEXT FROM @csrPartitionedVouchers INTO @strBillIds
	END;
	CLOSE @csrPartitionedVouchers;
	DEALLOCATE @csrPartitionedVouchers;

	--Return intPaymentBatchId used
	SET @intPaymentBatchIdUsed = (SELECT TOP 1 intId FROM @batchId)

	IF @transCount = 0 COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH