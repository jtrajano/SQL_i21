CREATE FUNCTION [dbo].[fnAPGetPayVoucherForPayment]
(
	@currencyId INT,
	@paymentMethodId INT = 0,
	@datePaid DATETIME,
	@showDeferred BIT,
	@vendorId INT = NULL,
	@payToAddress INT = 0,
	@paymentId INT = 0
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
										CASE WHEN voucher.ysnDiscountOverride = 1 AND NULLIF(forPay.intPayScheduleId,0) IS NULL
												THEN voucher.dblDiscount
											WHEN forPay.intPayScheduleId > 0
												THEN forPay.dblTempDiscount
												--calculate discount base on voucher date to make sure there is a discount
												--always discount bypasses due date
											WHEN forPay.ysnPymtCtrlAlwaysDiscount = 1 
												THEN dbo.fnGetDiscountBasedOnTerm(voucher.dtmBillDate, voucher.dtmBillDate, forPay.intTermsId, forPay.dblTotal)
											ELSE dbo.fnGetDiscountBasedOnTerm(@datePaid, voucher.dtmBillDate, forPay.intTermsId, forPay.dblTotal)
										END
									) 
							ELSE 0 END AS DECIMAL(18,2))
		,forPay.dblInterest 
		,dblTempInterest = CAST(CASE WHEN voucher.intTransactionType = 1 AND
											(voucher.dtmInterestDate IS NULL OR @datePaid > voucher.dtmInterestDate)
								THEN
									dbo.fnGetInterestBasedOnTerm(forPay.dblAmountDue, voucher.dtmBillDate, @datePaid, voucher.dtmInterestDate, forPay.intTermsId)
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
		,forPay.intTermsId
		,forPay.strName
		,forPay.strCheckPayeeName
		,forPay.ysnDeferredPayment
		,forPay.intPayScheduleId
		,ysnPastDue = dbo.fnIsDiscountPastDue(voucher.intTermsId, @datePaid, voucher.dtmDate)
		,forPay.ysnPymtCtrlAlwaysDiscount
		-- ,forPay.ysnPaySchedule
		,forPay.ysnOffset
		,entityGroup.strEntityGroupName
	FROM vyuAPBillForPayment forPay
	INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	LEFT JOIN tblAPPaymentDetail payDetail
		ON voucher.intBillId = payDetail.intBillId AND payDetail.intPaymentId = @paymentId
		AND ISNULL(payDetail.intPayScheduleId,-1) = ISNULL(forPay.intPayScheduleId,-1)
	OUTER APPLY (
		SELECT TOP 1
			eg.strEntityGroupName,
			eg.intEntityGroupId
		FROM tblEMEntityGroup eg
		INNER JOIN tblEMEntityGroupDetail egd ON eg.intEntityGroupId = egd.intEntityGroupId
		WHERE egd.intEntityId = forPay.intEntityVendorId
	) entityGroup
	WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
	AND forPay.intCurrencyId = @currencyId
	AND forPay.ysnDeferredPay = @showDeferred
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
	AND 1 = (CASE WHEN @paymentId > 0 
					THEN 
						(CASE WHEN payDetail.intPaymentDetailId > 0 AND payDetail.intPaymentId = @paymentId THEN 1 ELSE 0 END)
					ELSE 1 END)
	-- UNION ALL
	-- SELECT
	-- 	CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS intForPaymentId
	-- 	,NULL
	-- 	,A.intInvoiceId
	-- 	,A.intEntityCustomerId
	-- 	,NULL
	-- 	,strTransactionType
	-- 	,NULL
	-- 	,NULL
	-- FROM vyuARInvoicesForPayment A
	-- LEFT JOIN tblAPPaymentDetail payDetail
	-- 	ON A.intInvoiceId = payDetail.intInvoiceId
	-- WHERE 
	-- 	A.strTransactionType IN ('Invoice','Debit Memo','Cash','Cash Refund')
	-- AND A.dblAmountDue != 0
	-- AND A.intCurrencyId = @currencyId
	-- AND 1 = (CASE WHEN @vendorId > 0
	-- 				THEN (CASE WHEN A.intEntityCustomerId = @vendorId THEN 1 ELSE 0 END)
	-- 		ELSE 1 END)
	-- AND 1 = (CASE WHEN @paymentId > 0 
	-- 				THEN 
	-- 					(CASE WHEN payDetail.intPaymentDetailId > 0 THEN 1 ELSE 0 END)
	-- 				ELSE 0 END)

)
