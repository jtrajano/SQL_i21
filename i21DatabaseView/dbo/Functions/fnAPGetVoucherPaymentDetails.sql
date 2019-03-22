/*
	This will get all vouchers that would be in a single payment
*/
CREATE FUNCTION [dbo].[fnAPGetVoucherPaymentDetails]
(
	@voucherId INT
)
RETURNS @vouchersForPaymentDetails TABLE(intBillId INT)
AS
BEGIN
	INSERT INTO @vouchersForPaymentDetails
	SELECT intBillId 
	FROM (
		SELECT 
			intBillId
		FROM tblAPBill curVoucher
		WHERE curVoucher.intBillId = @voucherId
		UNION ALL
		SELECT
			voucher.intBillId
		FROM tblAPBill voucher
		INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
		-- INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
		CROSS APPLY (
			SELECT
				curVoucher2.intBillId
				,curVoucher2.intEntityVendorId
				,curVoucher2.intPayToAddressId
			FROM tblAPBill curVoucher2
			WHERE curVoucher2.intBillId = @voucherId
		) currentVoucher
		WHERE voucher.intBillId != @voucherId
		AND voucher.dblAmountDue != 0
		AND voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		AND voucher.intEntityVendorId = currentVoucher.intEntityVendorId
		AND voucher.intPayToAddressId = currentVoucher.intPayToAddressId
		AND vendor.ysnOneBillPerPayment = 0
		AND voucher.intTransactionType IN (1, 3, 14) --Voucher, DM, Deferred
		AND voucher.ysnReadyForPayment = 1
		UNION ALL
		SELECT
			voucher.intBillId
		FROM tblAPBill voucher
		INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
		-- INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
		CROSS APPLY (
			SELECT
				curVoucher2.intBillId
				,curVoucher2.intEntityVendorId
				,curVoucher2.intPayToAddressId
			FROM tblAPBill curVoucher2
			WHERE curVoucher2.intBillId = @voucherId
		) currentVoucher
		WHERE voucher.intBillId != @voucherId
		AND voucher.dblAmountDue != 0
		AND voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		AND voucher.intEntityVendorId = currentVoucher.intEntityVendorId
		AND voucher.intPayToAddressId = currentVoucher.intPayToAddressId
		AND vendor.ysnOneBillPerPayment = 0
		AND voucher.intTransactionType IN (2, 13) --Basis, Prepay
		AND voucher.ysnPrepayHasPayment = 1
		AND voucher.ysnReadyForPayment = 1
	) AS voucherIds
	RETURN;
END