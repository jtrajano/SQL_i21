CREATE FUNCTION [dbo].[fnAPGetPayVoucherForPayment]
(
	@currencyId INT,
	@paymentMethodId INT = 0,
	@datePaid DATETIME,
	@showDeferred BIT,
	@vendorId INT = NULL,
	@payToAddress INT = 0
)
RETURNS TABLE AS RETURN
(
	SELECT
		forPay.intForPaymentId
		,forPay.intBillId
		,forPay.intEntityVendorId
		,forPay.intTransactionType
		,forPay.intPayToAddressId
		,forPay.ysnReadyForPayment
		,forPay.dtmDueDate
		,forPay.dtmDate
		,forPay.dtmBillDate
		,forPay.intAccountId
		,forPay.strAccountId
		,forPay.strVendorOrderNumber
		,forPay.strBillId
		,forPay.dblTotal
		,forPay.dblDiscount
		,dblTempDiscount =  CAST(CASE WHEN voucher.intTransactionType = 1 
									THEN 
									(
										CASE WHEN voucher.ysnDiscountOverride = 1 THEN voucher.dblDiscount
											ELSE dbo.fnGetDiscountBasedOnTerm(@datePaid, voucher.dtmDate, voucher.intTermsId, voucher.dblTotal)
										END
									) 
							ELSE 0 END AS DECIMAL(18,2))
		,forPay.dblInterest 
		,dblTempInterest = CAST(CASE WHEN voucher.intTransactionType = 1 
								THEN dbo.fnGetInterestBasedOnTerm(voucher.dblTotal, voucher.dtmDate, @datePaid, voucher.intTermsId)
								ELSE 0 END AS DECIMAL(18,2))
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
		,forPay.ysnPrepayHasPayment
		,forPay.ysnWithholding
		,forPay.strPaymentMethod
		,forPay.strVendorId
		,forPay.strCommodityCode
		,forPay.strTerm
		,forPay.strName
		,forPay.strCheckPayeeName
		,forPay.ysnDeferredPayment
		,forPay.intPayScheduleId
		,ysnPastDue = dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate)
		,forPay.ysnPymtCtrlAlwaysDiscount
		-- ,forPay.ysnPaySchedule
		,forPay.ysnOffset
	FROM vyuAPBillForPayment forPay
	INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
	AND forPay.intCurrencyId = @currencyId
	AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
			ELSE 
				(CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) 
			END)
	AND 1 = (CASE WHEN @payToAddress > 0
					THEN (CASE WHEN forPay.intPayToAddressId = @payToAddress THEN 1 ELSE 0 END)
			ELSE 1 END)
	AND 1 = (CASE WHEN @vendorId > 0
					THEN (CASE WHEN forPay.intEntityVendorId = @vendorId THEN 1 ELSE 0 END)
			ELSE 1 END)
)
