CREATE VIEW [dbo].[vyuAPBillForPayment]
AS 
SELECT 
	voucher.intBillId
	,voucher.intTransactionType
	,voucher.ysnReadyForPayment
	,voucher.dtmDueDate
	,voucher.strVendorOrderNumber
	,voucher.strBillId
	,CASE WHEN voucher.intTransactionType IN (3,8) AND voucher.dblTotal > 0 THEN voucher.dblTotal * -1
		WHEN voucher.intTransactionType IN (2, 13) AND voucher.ysnPrepayHasPayment = 1 THEN voucher.dblTotal * -1
		ELSE voucher.dblTotal END AS dblTotal
	,voucher.dblDiscount
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
	,vendor.intPaymentMethodId
	,vendor.ysnOneBillPerPayment
	,vendor.ysnWithholding
	,payMethod.strPaymentMethod
	,vendor.strVendorId
	,commodity.strCommodityCode
	,term.strTerm
	,entity.strName
	,payTo.strCheckPayeeName
	,CAST(CASE WHEN voucher.intTransactionType = 14 THEN 1 ELSE 0 END AS BIT) AS ysnDeferredPayment
FROM tblAPBill voucher
INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
	ON vendor.intEntityId = voucher.intEntityVendorId
LEFT JOIN tblEMEntityLocation payTo ON voucher.intPayToAddressId = payTo.intEntityLocationId
LEFT JOIN tblSMTerm term ON voucher.intTermsId = term.intTermID
LEFT JOIN vyuAPVoucherCommodity commodity ON voucher.intBillId = commodity.intBillId
LEFT JOIN tblSMPaymentMethod payMethod ON vendor.intPaymentMethodId = payMethod.intPaymentMethodID
WHERE voucher.ysnPosted = 1 
AND voucher.ysnPaid = 0
AND voucher.intTransactionType NOT IN (11, 12)
AND voucher.intTransactionReversed IS NULL