﻿CREATE FUNCTION [dbo].[fnAPGetDiscountPastDueVouchers]
(
	@currencyId INT,
	@paymentMethodId INT = NULL,
	@datePaid DATETIME,
	@vendorId INT = NULL,
	@payToAddressId INT = NULL,
	@showDeferred BIT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vouchers NVARCHAR(MAX)

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
	END
	RETURN @vouchers;
END
