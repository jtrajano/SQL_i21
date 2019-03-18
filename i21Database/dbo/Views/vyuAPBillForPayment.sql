CREATE VIEW [dbo].[vyuAPBillForPayment]
AS 

SELECT
	CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS intForPaymentId,
	forPayment.*
FROM (
	SELECT 
		voucher.intBillId
		,voucher.intEntityVendorId
		,voucher.intTransactionType
		,voucher.ysnReadyForPayment
		,voucher.dtmDueDate
		,voucher.dtmDate
		,voucher.dtmBillDate
		,voucher.intAccountId
		,glAccount.strAccountId
		,voucher.strVendorOrderNumber
		,voucher.strBillId
		,CASE WHEN voucher.intTransactionType IN (3,8) AND voucher.dblTotal > 0 THEN voucher.dblTotal * -1
			WHEN voucher.intTransactionType IN (2, 13) AND voucher.ysnPrepayHasPayment = 1 THEN voucher.dblTotal * -1
			ELSE voucher.dblTotal END AS dblTotal
		,voucher.dblDiscount
		--use the tempdiscount(filled by multi payment screen) if not override, else use dblDiscount
		,CASE WHEN voucher.ysnDiscountOverride = 1 THEN voucher.dblDiscount ELSE voucher.dblTempDiscount END AS dblTempDiscount
		,voucher.dblInterest
		,voucher.dblTempInterest
		,CASE WHEN voucher.intTransactionType IN (3,8) AND voucher.dblAmountDue > 0 THEN voucher.dblAmountDue * -1
			WHEN voucher.intTransactionType IN (2, 13) AND voucher.ysnPrepayHasPayment = 1 THEN voucher.dblAmountDue * -1
			ELSE voucher.dblAmountDue END AS dblAmountDue
		,voucher.dblPayment
		,voucher.dblTempPayment
		,voucher.dblWithheld
		,voucher.dblTempWithheld
		,voucher.strTempPaymentInfo
		,voucher.strReference
		,voucher.intCurrencyId
		,voucher.ysnPosted
		,voucher.ysnDiscountOverride
		,voucher.intPayToAddressId
		,voucher.ysnPrepayHasPayment
		,vendor.intPaymentMethodId
		,vendor.ysnOneBillPerPayment
		,vendor.ysnPymtCtrlAlwaysDiscount
		,vendor.ysnWithholding
		,payMethod.strPaymentMethod
		,vendor.strVendorId
		,commodity.strCommodityCode
		,term.strTerm
		,entity.strName
		,payTo.strCheckPayeeName
		,NULL AS intPayScheduleId
		,CAST(CASE WHEN voucher.intTransactionType = 14 THEN 1 ELSE 0 END AS BIT) AS ysnDeferredPayment
		,ysnPastDue = dbo.fnIsDiscountPastDue(voucher.intTermsId, GETDATE(), voucher.dtmDate)
		-- ,ysnPaySchedule = CAST(0 AS BIT)
		,ysnOffset = CAST
					(
						CASE voucher.intTransactionType
						WHEN 1  THEN 0
						WHEN 14 THEN 0
						ELSE 1 END
					AS BIT)
	FROM tblAPBill voucher
	INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
		ON vendor.intEntityId = voucher.intEntityVendorId
	LEFT JOIN tblEMEntityLocation payTo ON voucher.intPayToAddressId = payTo.intEntityLocationId
	LEFT JOIN tblSMTerm term ON voucher.intTermsId = term.intTermID
	LEFT JOIN vyuAPVoucherCommodity commodity ON voucher.intBillId = commodity.intBillId
	LEFT JOIN tblSMPaymentMethod payMethod ON vendor.intPaymentMethodId = payMethod.intPaymentMethodID
	LEFT JOIN tblGLAccount glAccount ON glAccount.intAccountId = voucher.intAccountId
	WHERE voucher.ysnPosted = 1 
	AND voucher.ysnPaid = 0
	AND voucher.intTransactionType NOT IN (11, 12)
	AND voucher.intTransactionReversed IS NULL
	AND voucher.ysnIsPaymentScheduled = 0
	UNION ALL
	SELECT 
		voucher.intBillId
		,voucher.intEntityVendorId
		,voucher.intTransactionType
		,paySched.ysnReadyForPayment
		,voucher.dtmDueDate
		,voucher.dtmDate
		,voucher.dtmBillDate
		,voucher.intAccountId
		,glAccount.strAccountId
		,voucher.strVendorOrderNumber
		,voucher.strBillId
		,paySched.dblPayment AS dblTotal
		,voucher.dblDiscount
		,paySched.dblDiscount AS dblTempDiscount
		,voucher.dblInterest
		,voucher.dblTempInterest
		,paySched.dblPayment AS dblAmountDue
		,CASE WHEN paySched.ysnPaid = 1 THEN paySched.dblPayment ELSE 0 END
		,CASE WHEN paySched.ysnReadyForPayment = 1 THEN paySched.dblPayment - paySched.dblDiscount ELSE 0 END
		,voucher.dblWithheld
		,voucher.dblTempWithheld
		,voucher.strTempPaymentInfo
		,voucher.strReference
		,voucher.intCurrencyId
		,voucher.ysnPosted
		,voucher.ysnDiscountOverride
		,voucher.intPayToAddressId
		,voucher.ysnPrepayHasPayment
		,vendor.intPaymentMethodId
		,vendor.ysnOneBillPerPayment
		,vendor.ysnPymtCtrlAlwaysDiscount
		,vendor.ysnWithholding
		,payMethod.strPaymentMethod
		,vendor.strVendorId
		,commodity.strCommodityCode
		,term.strTerm
		,entity.strName
		,payTo.strCheckPayeeName
		,paySched.intId AS intPayScheduleId
		,CAST(0 AS BIT)
		,ysnPastDue = dbo.fnIsDiscountPastDue(paySched.intTermsId, GETDATE(), voucher.dtmDate)
		-- ,ysnPaySchedule = CAST(1 AS BIT)
		,ysnOffset = CAST
					(
						CASE voucher.intTransactionType
							WHEN 1  THEN 0
							WHEN 14 THEN 0
						ELSE 1 END
					AS BIT)
	FROM tblAPBill voucher
	INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
		ON vendor.intEntityId = voucher.intEntityVendorId
	INNER JOIN tblAPVoucherPaymentSchedule paySched
		ON paySched.intBillId = voucher.intBillId
	LEFT JOIN tblEMEntityLocation payTo ON voucher.intPayToAddressId = payTo.intEntityLocationId
	LEFT JOIN tblSMTerm term ON voucher.intTermsId = term.intTermID
	LEFT JOIN vyuAPVoucherCommodity commodity ON voucher.intBillId = commodity.intBillId
	LEFT JOIN tblSMPaymentMethod payMethod ON vendor.intPaymentMethodId = payMethod.intPaymentMethodID
	LEFT JOIN tblGLAccount glAccount ON glAccount.intAccountId = voucher.intAccountId
	WHERE voucher.ysnPosted = 1 
	AND voucher.ysnPaid = 0
	AND voucher.intTransactionType IN (1)
	AND voucher.intTransactionReversed IS NULL
	AND voucher.ysnIsPaymentScheduled = 1
) forPayment