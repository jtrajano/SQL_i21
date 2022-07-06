﻿CREATE FUNCTION [dbo].[fnAPGetPayVoucherForPaymentPayVoucher]
(
	@currencyId INT,
	@paymentMethodId INT = 0,
	@datePaid DATETIME,
	@showDeferred BIT,
	@vendorId INT = NULL,
	@payToAddress INT = 0,
	@paymentId INT = 0,
	@bankAccountId INT = 0
)
RETURNS TABLE AS RETURN
(
	SELECT
		-- forPay.intForPaymentId
		CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS intForPaymentId
		,forPay.intBillId
		,forPay.intEntityVendorId
		,forPay.intTransactionType
		,forPay.intPayToAddressId
		,forPay.ysnReadyForPayment
		,forPay.dtmDueDate
		,forPay.dtmCashFlowDate
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
		,CASE WHEN forPay.intPayScheduleId IS NOT NULL OR forPay.ysnOffset = 1
			THEN 
				forPay.dblAmountDue
			ELSE
				CASE WHEN forPay.dblPaymentTemp <> 0 
					THEN 
						((forPay.dblTotal - ISNULL(appliedPrepays.dblPayment, 0)) - forPay.dblPaymentTemp) 
					ELSE forPay.dblAmountDue 
				END
			END AS dblAmountDue
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
		,voucher.intPayFromBankAccountId
		,account.strBankAccountNo strPayFromBankAccount
		,voucher.intPayToBankAccountId
		,eft.strAccountNumber strPayToBankAccount
		,accountDetail.strAccountId strAPAccount
	FROM vyuAPBillForPayment forPay
	INNER JOIN tblAPBill voucher ON voucher.intBillId = forPay.intBillId
	LEFT JOIN tblAPPaymentDetail payDetail
		ON voucher.intBillId = payDetail.intBillId AND payDetail.intPaymentId = @paymentId
		AND ISNULL(payDetail.intPayScheduleId,-1) = ISNULL(forPay.intPayScheduleId,-1)
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
	OUTER APPLY (
		SELECT SUM(APD.dblAmountApplied) AS dblPayment
		FROM tblAPAppliedPrepaidAndDebit APD
		WHERE APD.intBillId = voucher.intBillId AND APD.ysnApplied = 1
	) appliedPrepays
	WHERE (forPay.intPaymentMethodId = @paymentMethodId OR forPay.intPaymentMethodId IS NULL)
	AND forPay.ysnDeferredPay = @showDeferred
	AND 1 = (CASE WHEN @currencyId > 0
					THEN (CASE WHEN forPay.intCurrencyId = @currencyId THEN 1 ELSE 0 END)
					ELSE 1 END)
	AND 1 = (CASE WHEN @showDeferred = 1 THEN 1
			ELSE 
				(CASE WHEN forPay.intTransactionType = 14 THEN 1 ELSE 1 END) 
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
	AND 1 = (CASE WHEN @paymentId = 0
					THEN (CASE WHEN ((forPay.ysnInPayment IS NULL OR forPay.ysnInPayment = 0) OR forPay.ysnPrepayHasPayment <> 0) THEN 1 ELSE 0 END)
					ELSE 1 END)
	AND 1 = (CASE WHEN @paymentId = 0
					THEN (CASE WHEN forPay.ysnInPaymentSched = 0 THEN 1 ELSE 0 END)
					ELSE 1 END)
	AND 1 = (CASE WHEN @bankAccountId > 0 AND voucher.intPayFromBankAccountId > 0
					THEN (CASE WHEN @bankAccountId = voucher.intPayFromBankAccountId THEN 1 ELSE 0 END)
					ELSE 1 END)
)