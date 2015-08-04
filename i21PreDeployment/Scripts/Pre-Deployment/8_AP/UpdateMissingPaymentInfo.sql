--THIS WILL FIXED THE PAYMENT WITHOUT PAYMENT INFO/CHECK NO
BEGIN TRY
BEGIN TRANSACTION #updatePaymentInfo
SAVE TRANSACTION #updatePaymentInfo
IF(EXISTS(SELECT 1 FROM tblAPPayment A
					INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
					WHERE B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') = ''
					AND B.intBankTransactionTypeId = 16))
BEGIN
	UPDATE A
		SET A.strPaymentInfo = B.strReferenceNo
	FROM tblAPPayment A
					INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
					WHERE B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') = ''
					AND B.intBankTransactionTypeId = 16
END

IF @@TRANCOUNT > 0
BEGIN
COMMIT TRANSACTION #updatePaymentInfo
END
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION #updatePaymentInfo
END CATCH