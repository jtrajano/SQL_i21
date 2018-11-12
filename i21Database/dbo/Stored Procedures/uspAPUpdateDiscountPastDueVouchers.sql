CREATE PROCEDURE [dbo].[uspAPUpdateDiscountPastDueVouchers]
	@currencyId INT,
	@paymentMethodId INT,
	@datePaid DATETIME,
	@showDeferred BIT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

UPDATE voucher
	SET voucher.dblDiscount = 0
FROM vyuAPBillForPayment forPay
INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
AND forPay.intCurrencyId = @currencyId
AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
			ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
AND voucher.intTransactionType = 1
AND voucher.ysnPaid = 0
AND voucher.ysnDiscountOverride = 1
AND voucher.dblDiscount != 0
AND dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate) = 1

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