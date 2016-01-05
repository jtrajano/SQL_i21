CREATE PROCEDURE uspPRUpdatePaycheckReferenceNo
	@intBankAccountId INT = NULL
AS

UPDATE tblPRPaycheck 
SET strReferenceNo = ISNULL((SELECT TOP 1 strReferenceNo FROM tblCMBankTransaction 
						WHERE strTransactionId = tblPRPaycheck.strPaycheckId
						  AND intBankTransactionTypeId = 21
						  AND strSourceSystem = 'PR'
						  AND intBankAccountId = ISNULL(@intBankAccountId, intBankAccountId)
						  AND dtmCheckPrinted IS NOT NULL), '')
WHERE ISNULL(strReferenceNo, '') = ''

GO