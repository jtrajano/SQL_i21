GO
--This will fix the payment bank transaction on CM for filtering on printing checks
IF EXISTS(SELECT 1 FROM tblCMBankTransaction A
						INNER JOIN tblAPPayment B
							ON A.strTransactionId = B.strPaymentRecordNum
						INNER JOIN tblSMPaymentMethod C
							ON B.intPaymentMethodId = C.intPaymentMethodID
						WHERE C.strPaymentMethod = 'Cash' AND A.strReferenceNo <> 'Cash')
BEGIN

UPDATE tblCMBankTransaction
SET strReferenceNo = 'Cash'
FROM tblCMBankTransaction A
	INNER JOIN tblAPPayment B
		ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblSMPaymentMethod C
		ON B.intPaymentMethodId = C.intPaymentMethodID
	WHERE C.strPaymentMethod = 'Cash' AND A.strReferenceNo <> 'Cash'

END

GO