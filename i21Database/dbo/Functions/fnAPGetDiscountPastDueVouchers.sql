CREATE FUNCTION [dbo].[fnAPGetDiscountPastDueVouchers]
(
	@currencyId INT,
	@paymentMethodId INT,
	@datePaid DATETIME,
	@showDeferred BIT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vouchers NVARCHAR(MAX)

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

	RETURN @vouchers;
END
