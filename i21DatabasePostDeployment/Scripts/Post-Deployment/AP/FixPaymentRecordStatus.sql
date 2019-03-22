--THIS WILL FIXED THE PAYMENT WITHOUT PAYMENT INFO/CHECK NO
IF(EXISTS(SELECT 1 FROM tblAPPayment A
					INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
					WHERE B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') = ''))
BEGIN
	UPDATE A
		SET A.strPaymentInfo = B.strReferenceNo
	FROM tblAPPayment A
					INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
					WHERE B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') = ''
END