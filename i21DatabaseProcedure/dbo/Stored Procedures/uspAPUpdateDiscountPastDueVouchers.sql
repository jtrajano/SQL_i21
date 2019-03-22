CREATE PROCEDURE [dbo].[uspAPUpdateDiscountPastDueVouchers]
	@currencyId INT,
	@paymentMethodId INT = NULL,
	@datePaid DATETIME,
	@vendorId INT = NULL,
	@payToAddressId INT = NULL,
	@showDeferred BIT = 0,
	@rowsAffected INT = NULL OUTPUT
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

DECLARE @voucherAffected AS Id;

IF @vendorId IS NULL
BEGIN
	--MULTI VENDOR
	UPDATE voucher
		SET voucher.dblDiscount = 0
	FROM vyuAPBillForPayment forPay
	INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
	AND forPay.intCurrencyId = @currencyId
	AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
				ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
	AND voucher.intTransactionType = 1
	AND voucher.ysnPaid = 0
	AND voucher.ysnDiscountOverride = 1
	AND voucher.dblDiscount != 0
	AND dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate) = 1
	AND vendor.ysnPymtCtrlAlwaysDiscount = 0 --do not update the vendor with always discount enabled

	SET @rowsAffected = @@ROWCOUNT;
END
ELSE
BEGIN
	UPDATE voucher
		SET voucher.dblDiscount = 0
	OUTPUT inserted.intBillId INTO @voucherAffected
	FROM vyuAPBillForPayment forPay
	INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	WHERE 
		voucher.intEntityVendorId = @vendorId
	AND ISNULL(voucher.intPayToAddressId,0) = CASE WHEN NULLIF(@payToAddressId,0) IS NULL THEN ISNULL(voucher.intPayToAddressId,0) ELSE @payToAddressId END
	AND forPay.intCurrencyId = @currencyId
	AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
				ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
	AND voucher.intTransactionType = 1
	AND voucher.ysnPaid = 0
	AND voucher.ysnDiscountOverride = 1
	AND voucher.dblDiscount != 0
	AND dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate) = 1
	AND vendor.ysnPymtCtrlAlwaysDiscount = 0

	SET @rowsAffected = @@ROWCOUNT;

	--we removed the details of unposted records when recalculating
	-- --update unposted payment detail payment amount
	-- UPDATE A
	-- 	SET A.dblPayment = A.dblPayment - A.dblDiscount
	-- FROM tblAPPaymentDetail A
	-- INNER JOIN @voucherAffected A2 ON A.intBillId = A2.intId
	-- INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
	-- WHERE B.ysnPosted = 0

	-- --update unposted payment detail
	-- UPDATE A
	-- 	SET A.dblDiscount = 0
	-- FROM tblAPPaymentDetail A
	-- INNER JOIN @voucherAffected A2 ON A.intBillId = A2.intId
	-- INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
	-- INNER JOIN tblAPVendor vendor ON B.intEntityVendorId = vendor.intEntityId
	-- WHERE 
	-- 	B.ysnPosted = 0
	-- AND vendor.ysnPymtCtrlAlwaysDiscount = 0

	-- --update unposted payment total
	-- UPDATE B
	-- 	SET 
	-- 	B.dblAmountPaid = details.dblPayment
	-- FROM tblAPPayment B
	-- INNER JOIN 
	-- (
	-- 	SELECT TOP 1
	-- 		SUM(A.dblPayment) dblPayment,
	-- 		MIN(A.intPaymentId) intPaymentId
	-- 	FROM tblAPPaymentDetail A
	-- 	INNER JOIN @voucherAffected A2 ON A.intBillId = A2.intId
	-- 	INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
	-- 	WHERE B.ysnPosted = 0
	-- ) details
	-- ON B.intPaymentId = details.intPaymentId
	-- WHERE B.ysnPosted = 0
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