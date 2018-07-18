CREATE FUNCTION [dbo].[fnAPGetPayVoucherForPayment]
(
	@currencyId INT,
	@paymentMethodId INT,
	@datePaid DATETIME,
	@showDeferred BIT
)
RETURNS TABLE AS RETURN
(
	SELECT
		forPay.intBillId
		,forPay.intTransactionType
		,forPay.ysnReadyForPayment
		,forPay.dtmDueDate
		,forPay.strVendorOrderNumber
		,forPay.strBillId
		,forPay.dblTotal
		,forPay.dblDiscount
		,dblTempDiscount =  dbo.fnGetDiscountBasedOnTerm(@datePaid, voucher.dtmDate, voucher.intTermsId, voucher.dblTotal)
		,forPay.dblInterest 
		,dblTempInterest = dbo.fnGetInterestBasedOnTerm(voucher.dblTotal, voucher.dtmDate, @datePaid, voucher.intTermsId)
		,forPay.dblAmountDue
		,forPay.dblPayment
		,forPay.dblTempPayment
		,forPay.dblWithheld
		,forPay.dblTempWithheld
		,forPay.strTempPaymentInfo
		,forPay.strReference
		,forPay.intCurrencyId
		,forPay.ysnPosted
		,forPay.ysnDiscountOverride
		,forPay.intPaymentMethodId
		,forPay.ysnOneBillPerPayment
		,forPay.ysnWithholding
		,forPay.strPaymentMethod
		,forPay.strVendorId
		,forPay.strCommodityCode
		,forPay.strTerm
		,forPay.strName
		,forPay.strCheckPayeeName
		,forPay.ysnDeferredPayment
	FROM vyuAPBillForPayment forPay
	INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
	AND forPay.intCurrencyId = @currencyId
	AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
				ELSE (CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) END)
)
