--THIS WILL FIXED THE PAYMENT WITHOUT PAYMENT INFO/CHECK NO
BEGIN TRY
BEGIN TRANSACTION #updatePaymentInfo
SAVE TRANSACTION #updatePaymentInfo
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

COMMIT TRANSACTION #updatePaymentInfo
END TRY
BEGIN CATCH
PRINT 'FAILED TO UPDATE PAYMENTS PAYMENT INFO';
ROLLBACK TRANSACTION #updatePaymentInfo
END CATCH