/**
This will update all existing voucher prepayment.
Before, we do not post prepayment.
Since we do  now post the vendor prepayment, we will update existing records
**/
IF OBJECT_ID(N'uspAPPostVoucherPrepay') IS NULL AND OBJECT_ID(N'tblAPBill') IS NOT NULL AND COL_LENGTH('tblAPBill','ysnOldPrepayment') IS NULL
BEGIN

	EXEC ('
		ALTER TABLE tblAPBill
			ADD ysnOldPrepayment BIT NOT NULL DEFAULT(0)
		')
	EXEC('
		--SET THE ysnPosted AND ysnOldPrepayment to 1
		UPDATE voucherPrepay
			SET voucherPrepay.ysnPosted = 1, voucherPrepay.ysnOldPrepayment = 1
		FROM tblAPBill voucherPrepay
		WHERE voucherPrepay.intTransactionType IN (2)
		AND (
			EXISTS ( --update those already have payment transaction, even voided
				SELECT 1 FROM tblAPPayment payment
				INNER JOIN tblAPPaymentDetail paymentDetail ON payment.intPaymentId = paymentDetail.intPaymentId
				WHERE paymentDetail.intBillId = voucherPrepay.intBillId
				AND payment.ysnPrepay = 1
			)
			OR (voucherPrepay.ysnOrigin = 1 AND voucherPrepay.ysnPaid = 1) --HANDLE ORIGIN PREPAYMENT, THIS MAYBE HAS NO PAYMENT TRANSACTION
		)

		--UPDATE THE DETAIL ACCOUNT OF EXISTING VENDOR PREPAYMENT WITHOUTH PAYMENT CREATED YET AND NOT ORIGIN
		DECLARE @apAccount INT;
		select 
			@apAccount = A.intAccountId
		from tblGLAccount A
		join tblGLAccountSegmentMapping S on A.intAccountId = S.intAccountId
		join tblGLAccountSegment Se on Se.intAccountSegmentId = S.intAccountSegmentId
		join tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
		join tblGLAccountCategory Ca on Ca.intAccountCategoryId = Se.intAccountCategoryId
		where St.strType = ''Primary'' AND Ca.intAccountCategoryId = 1 --AP Account

		UPDATE voucherDetail
			SET voucherDetail.intAccountId = @apAccount
		FROM tblAPBill voucherPrepay
		INNER JOIN tblAPBillDetail voucherDetail ON voucherPrepay.intBillId = voucherDetail.intBillId
		WHERE voucherPrepay.intTransactionType IN (2)
		AND NOT EXISTS ( 
			SELECT 1 FROM tblAPPayment payment
			INNER JOIN tblAPPaymentDetail paymentDetail ON payment.intPaymentId = paymentDetail.intPaymentId
			WHERE paymentDetail.intBillId = voucherPrepay.intBillId
			AND payment.ysnPrepay = 1
		)
	')
END