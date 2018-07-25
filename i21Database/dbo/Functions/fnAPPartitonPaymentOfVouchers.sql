CREATE FUNCTION [dbo].[fnAPPartitonPaymentOfVouchers]
(
	@voucherIds AS Id READONLY
)
RETURNS TABLE AS RETURN
(
	SELECT
		voucher.intBillId
		,voucher.intPayToAddressId
		,voucher.intEntityVendorId
		,DENSE_RANK() OVER(ORDER BY voucher.intEntityVendorId, voucher.intPayToAddressId DESC) AS intPaymentId
		,SUM(ISNULL((CASE WHEN voucher.intTransactionType NOT IN (1, 14) THEN -voucher.dblTempPayment ELSE voucher.dblTempPayment END), 0))
				OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId) AS dblTempPayment
		,SUM(ISNULL((CASE WHEN voucher.intTransactionType NOT IN (1, 14) THEN -voucher.dblTempWithheld ELSE voucher.dblTempWithheld END), 0))
				OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId) AS dblTempWithheld
		,voucher.strTempPaymentInfo
	FROM tblAPBill voucher
	INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	WHERE vendor.ysnOneBillPerPayment = 0
	AND voucher.ysnPosted = 1
	AND voucher.ysnPaid = 0
	AND 1 = (CASE WHEN voucher.intTransactionType IN (2,13) AND voucher.ysnPrepayHasPayment = 0 THEN 0 ELSE 1 END) --do not include basis/prepaid w/o actual payment
	UNION ALL
	--BASIS AND PREPAID WITH NO ACTUAL PAYMENT YET
	SELECT
		voucher.intBillId
		,voucher.intPayToAddressId
		,voucher.intEntityVendorId
		,DENSE_RANK() OVER(ORDER BY voucher.intEntityVendorId, voucher.intPayToAddressId DESC) AS intPaymentId
		,SUM(ISNULL(voucher.dblTempPayment, 0)) OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId)
		,SUM(ISNULL(voucher.dblTempWithheld, 0)) OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId)
		,voucher.strTempPaymentInfo
	FROM tblAPBill voucher
	INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	WHERE voucher.intTransactionType IN (2, 13)
	AND vendor.ysnOneBillPerPayment = 0
	AND voucher.ysnPosted = 1
	AND voucher.ysnPaid = 0
	AND voucher.ysnPrepayHasPayment = 0
	UNION ALL
	--ALL TRANSACTIONS WHICH VENDOR IS ONE BILL PER PAYMENT
	SELECT
		voucher.intBillId
		,voucher.intPayToAddressId
		,voucher.intEntityVendorId
		,DENSE_RANK() OVER(ORDER BY voucher.intEntityVendorId, voucher.intPayToAddressId DESC) AS intPaymentId
		,SUM(ISNULL(voucher.dblTempPayment, 0)) OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId)
		,SUM(ISNULL(voucher.dblTempWithheld, 0)) OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId)
		,voucher.strTempPaymentInfo
	FROM tblAPBill voucher
	INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	WHERE vendor.ysnOneBillPerPayment = 1
	AND voucher.ysnPosted = 1
	AND voucher.ysnPaid = 0
	--we will exlcude basis and prepaid that do not have actual payment because we already did that on second union
	AND 1 = CASE WHEN voucher.intTransactionType IN (2, 13) AND voucher.ysnPrepayHasPayment = 1 THEN 0 ELSE 1 END 
)
