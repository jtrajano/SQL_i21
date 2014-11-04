--Update Payment Info of Payment
UPDATE A
	SET A.strPaymentInfo = B.strReferenceNo
FROM tblAPPayment A
	INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
