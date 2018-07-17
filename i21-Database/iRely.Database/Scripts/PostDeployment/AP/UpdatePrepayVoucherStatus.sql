--THIS WILL UPDATE THE VALUE OF NEW FIELD tblAPBill.ysnPrepayHasPayment
--MAKE SURE COLUMN EXISTS
--MAKE SURE THERE IS NO RECORD OF PREPAYMENT TRANSACTION THAT HAS ALREADY BEEN UPDATED
IF COL_LENGTH('tblAPBill','ysnPrepayHasPayment') IS NOT NULL 
	AND NOT EXISTS(SELECT 1 FROM tblAPBill WHERE intTransactionType = 2 AND ysnPrepayHasPayment = 1)
BEGIN
	UPDATE prepayment
		SET prepayment.ysnPrepayHasPayment = 1
	FROM tblAPBill prepayment
	WHERE prepayment.intTransactionType = 2 AND prepayment.ysnPrepayHasPayment = 0 AND prepayment.ysnPosted = 1
	AND EXISTS(
		SELECT 1 FROM tblAPPayment payment 
			INNER JOIN tblAPPaymentDetail paymentDetail ON payment.intPaymentId = paymentDetail.intPaymentId
		WHERE paymentDetail.intBillId = prepayment.intBillId AND payment.ysnPrepay = 1
		AND EXISTS (
			SELECT 1 FROM tblCMBankTransaction bankTran WHERE bankTran.strTransactionId = payment.strPaymentRecordNum AND bankTran.ysnCheckVoid = 0
		)
	)
END