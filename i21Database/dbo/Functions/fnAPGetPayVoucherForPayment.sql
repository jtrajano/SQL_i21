CREATE FUNCTION [dbo].[fnAPGetPayVoucherForPayment]
(
	@currencyId INT,
	@paymentMethodId INT = 0,
	@datePaid DATETIME,
	@showDeferred BIT,
	@vendorId INT = NULL,
	@payToAddress INT = 0,
	@paymentId INT = 0,
	@payFromBankAccountId INT = 0,
	@payToBankAccountId INT = 0
)
RETURNS TABLE AS RETURN
(
	SELECT
		forPay.intForPaymentId
		,forPay.intBillId
		,forPay.intInvoiceId
		,forPay.intEntityVendorId
		,forPay.intTransactionType
		,forPay.intPayToAddressId
		,forPay.ysnReadyForPayment
		,forPay.dtmDueDate
		,forPay.dtmDate
		,forPay.dtmCashFlowDate
		,forPay.dtmBillDate
		,forPay.intAccountId
		,forPay.strAccountId
		,forPay.strVendorOrderNumber
		,forPay.strBillId
		,forPay.dblTotal
		,forPay.dblDiscount
		,dblTempDiscount =  CASE WHEN forPay.intBillId > 0
							THEN
								CAST(CASE WHEN voucher.intTransactionType = 1 
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
							ELSE 0
							END
		,forPay.dblInterest 
		,dblTempInterest = CASE WHEN forPay.intBillId > 0
							THEN
								CAST(CASE WHEN voucher.intTransactionType = 1 AND
											(voucher.dtmInterestDate IS NULL OR @datePaid > voucher.dtmInterestDate)
								THEN
									dbo.fnGetInterestBasedOnTerm(forPay.dblAmountDue, voucher.dtmBillDate, @datePaid, voucher.dtmInterestDate, forPay.intTermsId)
								ELSE 0 END AS DECIMAL(18,2))
							ELSE 0
							END
		,forPay.dblAmountDue
		,forPay.dblPayment
		,forPay.dblTempPayment
		,forPay.dblWithheld
		,forPay.dblTempWithheld
		,forPay.strTempPaymentInfo
		,forPay.strReference
		,forPay.intCurrencyId
		,currency.strCurrency
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
		,forPay.strPaymentScheduleNumber
		,forPay.intPayFromBankAccountId
		,account.strBankAccountNo strPayFromBankAccount
		,forPay.intPayToBankAccountId
		,eft.strAccountNumber strPayToBankAccount
		,accountDetail.strAccountId strAPAccount
		,forPay.strHold
	FROM vyuAPBillForPayment forPay
	LEFT JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	LEFT JOIN tblARInvoice invoice ON invoice.intInvoiceId = forPay.intInvoiceId
	-- LEFT JOIN tblAPPaymentDetail payDetail
	-- 	ON voucher.intBillId = payDetail.intBillId AND payDetail.intPaymentId = @paymentId
	-- 	AND ISNULL(payDetail.intPayScheduleId,-1) = ISNULL(forPay.intPayScheduleId,-1)
	LEFT JOIN vyuCMBankAccount account ON account.intBankAccountId = voucher.intPayFromBankAccountId
	LEFT JOIN vyuAPEntityEFTInformation eft ON eft.intEntityEFTInfoId = voucher.intPayToBankAccountId
	LEFT JOIN vyuGLAccountDetail accountDetail ON accountDetail.intAccountId = voucher.intAccountId
	LEFT JOIN tblSMCurrency currency ON currency.intCurrencyID = voucher.intCurrencyId
	OUTER APPLY (
		SELECT TOP 1
			eg.strEntityGroupName,
			eg.intEntityGroupId
		FROM tblEMEntityGroup eg
		INNER JOIN tblEMEntityGroupDetail egd ON eg.intEntityGroupId = egd.intEntityGroupId
		WHERE egd.intEntityId = forPay.intEntityVendorId
	) entityGroup
	WHERE 
	(
		(forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
		AND forPay.intCurrencyId = @currencyId
		AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
				ELSE 
					(CASE WHEN forPay.intTransactionType = 14 THEN 0 ELSE 1 END) 
				END)
		AND 1 = (CASE WHEN @payToAddress > 0
						THEN (CASE WHEN forPay.intPayToAddressId = @payToAddress THEN 1 ELSE 0 END)
				ELSE 1 END)
		AND 
			(1 = (
				(CASE WHEN @vendorId > 0
							THEN 
								(CASE WHEN forPay.intEntityVendorId = @vendorId 
								--OR forPay.intEntityVendorId IN (SELECT childVend.intEntityId FROM tblAPVendor childVend WHERE strVendorPayToId = forPay.strVendorId)
							THEN 1 ELSE 0 END)
					ELSE 1 END)
				)
			)
		-- AND 1 = (CASE WHEN @paymentId > 0 
		-- 				THEN 
		-- 					(CASE WHEN payDetail.intPaymentDetailId > 0 AND payDetail.intPaymentId = @paymentId THEN 1 ELSE 0 END)
		-- 				ELSE 1 END)
		AND 1 = (CASE WHEN @paymentId = 0
						THEN (CASE WHEN ((forPay.ysnInPayment IS NULL OR forPay.ysnInPayment = 0) OR forPay.ysnPrepayHasPayment <> 0) THEN 1 WHEN forPay.ysnInPaymentSched = 1 THEN 1 ELSE 0 END)
						ELSE 1 END)
		-- AND 1 = (CASE WHEN @paymentId = 0
		-- 				THEN (CASE WHEN forPay.ysnInPaymentSched = 1 THEN 1 ELSE 0 END)
		-- 				ELSE 1 END)
		AND 1 = (CASE WHEN @payFromBankAccountId > 0 AND voucher.intPayFromBankAccountId > 0
						THEN (CASE WHEN @payFromBankAccountId = voucher.intPayFromBankAccountId THEN 1 ELSE 0 END)
						ELSE 1 END)
		AND 1 = (CASE WHEN @payToBankAccountId > 0 AND voucher.intPayToBankAccountId > 0
						THEN (CASE WHEN @payToBankAccountId = voucher.intPayToBankAccountId THEN 1 ELSE 0 END)
						ELSE 1 END)
	)
	OR (
		EXISTS(SELECT 1 FROM tblAPVendor childVend
		INNER JOIN tblAPVendor parentVend ON childVend.strVendorPayToId = parentVend.strVendorId
		WHERE parentVend.intEntityId = @vendorId AND childVend.intEntityId = forPay.intEntityVendorId)
	)
)

