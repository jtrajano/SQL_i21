/*
If Discount Days have passed and there are overridden discount, 
use this view to identify those vouchers
*/
CREATE FUNCTION [dbo].[fnAPGetDiscountPastDueVouchers]
(
	@currencyId INT,
	@paymentMethodId INT = NULL,
	@datePaid DATETIME,
	@vendorId INT = NULL,
	@payToAddressId INT = NULL,
	@showDeferred BIT = 0,
	@paymentId INT = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vouchers NVARCHAR(MAX) = ''

	IF @vendorId IS NULL
	BEGIN
		--MULTI VENDOR
		SELECT
			@vouchers = COALESCE(@vouchers + CHAR(10) + CHAR(13), '') +  voucher.strBillId
		FROM vyuAPBillForPayment forPay
		INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
		WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
		AND forPay.intCurrencyId = @currencyId
		AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
					ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
		AND voucher.ysnDiscountOverride = 1
		AND voucher.dblDiscount != 0
		AND dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate) = 1
		AND forPay.ysnPymtCtrlAlwaysDiscount = 0
	END
	ELSE
	BEGIN
		IF NULLIF(@paymentId,0) IS NULL
		BEGIN
			SELECT
				@vouchers = COALESCE(@vouchers + CHAR(10) + CHAR(13), '') +  voucher.strBillId
			FROM vyuAPBillForPayment forPay
			INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
			WHERE 
				voucher.intEntityVendorId = @vendorId
			AND ISNULL(voucher.intPayToAddressId,0) = CASE WHEN @payToAddressId IS NULL THEN ISNULL(voucher.intPayToAddressId,0) ELSE @payToAddressId END
			AND forPay.intCurrencyId = @currencyId
			AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
						ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
			AND voucher.ysnDiscountOverride = 1
			AND voucher.dblDiscount != 0
			AND dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate) = 1
			AND forPay.ysnPymtCtrlAlwaysDiscount = 0
		END
		ELSE
		BEGIN
			SELECT
				@vouchers = COALESCE(@vouchers + CHAR(10) + CHAR(13), '') +  voucher.strBillId
			FROM vyuAPBillForPayment forPay
			INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
			WHERE 
				voucher.intEntityVendorId = @vendorId
			AND ISNULL(voucher.intPayToAddressId,0) = CASE WHEN @payToAddressId IS NULL THEN ISNULL(voucher.intPayToAddressId,0) ELSE @payToAddressId END
			AND forPay.intCurrencyId = @currencyId
			AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
						ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
			AND voucher.ysnDiscountOverride = 1
			AND voucher.dblDiscount != 0
			AND dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate) = 1
			AND voucher.intBillId
			IN
			(
				SELECT 
					payDetail.intBillId
				FROM tblAPPaymentDetail payDetail
				WHERE payDetail.intPaymentId = @paymentId
			)
			AND forPay.ysnPymtCtrlAlwaysDiscount = 0
		END
	END
	RETURN @vouchers;
END
