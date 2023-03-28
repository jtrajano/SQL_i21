CREATE PROCEDURE [dbo].[uspAPClearVoucherTempData]
	@voucherIds NVARCHAR(MAX)
 ,@userId INT = NULL
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRY

	DECLARE @cntVoucher INT;
	DECLARE @cntPaySched INT;
	DECLARE @vouchersUpdated INT;
	DECLARE @paySchedUpdated INT;
	CREATE TABLE #tmpPaySchedVoucherId(intBillId INT);

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	DECLARE @ids AS Id;
	DECLARE @schedIds AS Id;

	INSERT INTO @ids
	SELECT DISTINCT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds) WHERE intID > 0

	SET @cntVoucher = (SELECT COUNT(*) FROM @ids);

	IF @cntVoucher > 0
	BEGIN
		UPDATE voucher
			SET voucher.ysnReadyForPayment = 0, voucher.dblTempPayment = 0, voucher.dblTempWithheld = 0, voucher.strTempPaymentInfo = null
				  ,voucher.intSelectedByUserId = NULL
		FROM tblAPBill voucher
		INNER JOIN @ids ids ON voucher.intBillId = ids.intId
		WHERE voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		AND voucher.ysnIsPaymentScheduled = 0
		AND 1 = (CASE WHEN forPay.intSelectedByUserId IS NULL OR forPay.intSelectedByUserId = @userId THEN 1 ELSE 0 END)

		SET @vouchersUpdated = @@ROWCOUNT;

		UPDATE paySched
			SET paySched.ysnReadyForPayment = 0
				 ,paySched.intSelectedByUserId = NULL
		OUTPUT inserted.intBillId INTO #tmpPaySchedVoucherId
		FROM tblAPVoucherPaymentSchedule paySched
		INNER JOIN @ids ids ON paySched.intBillId = ids.intId
		INNER JOIN tblAPBill voucher ON voucher.intBillId = paySched.intBillId
		WHERE 
			voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		AND voucher.dblAmountDue != 0
		AND paySched.ysnPaid = 0
		AND voucher.ysnIsPaymentScheduled = 1
		AND 1 = (CASE WHEN forPay.intSelectedByUserId IS NULL OR forPay.intSelectedByUserId = @userId THEN 1 ELSE 0 END)

		SET @paySchedUpdated = (SELECT COUNT(DISTINCT intBillId) FROM #tmpPaySchedVoucherId)

		SET @vouchersUpdated = @vouchersUpdated + @paySchedUpdated;

		IF @cntVoucher != @vouchersUpdated
		BEGIN
			RAISERROR('PAYVOUCHERINVALIDROWSAFFECTED', 16, 1);
			RETURN;
		END
	END

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

END