/**
This will update all existing voucher prepayment.
Before, we do not post prepayment.
Since we do  now post the vendor prepayment, we will update existing records
**/
IF OBJECT_ID(N'uspAPPostVoucherPrepay') IS NULL AND OBJECT_ID(N'tblAPBill') IS NOT NULL
BEGIN
	ALTER TABLE tblAPBill
		ADD [ysnOldPrepayment] BIT NOT NULL DEFAULT 0

	UPDATE voucherPrepay
		SET voucherPrepay.ysnPosted = 1, voucherPrepay.ysnOldPrepayment = 1
	FROM tblAPBill voucherPrepay
	WHERE voucherPrepay.intTransactionType IN (2)
	AND EXISTS ( --only update those already have payment transaction, even voided
		SELECT 1 FROM tblAPPayment payment
		INNER JOIN tblAPPaymentDetail paymentDetail ON payment.intPaymentId = paymentDetail.intPaymentId
		WHERE paymentDetail.intBillId = voucherPrepay.intBillId
		AND payment.ysnPrepay = 1
	)
END