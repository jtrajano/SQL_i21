CREATE PROCEDURE uspPRUpdatePaycheckReferenceNo
	@intBankAccountId INT = NULL
AS

UPDATE tblPRPaycheck 
SET strReferenceNo = ISNULL((SELECT TOP 1 strReferenceNo FROM tblCMBankTransaction 
						WHERE strTransactionId = tblPRPaycheck.strPaycheckId
						  AND intBankTransactionTypeId IN (21, 23)
						  AND intBankAccountId = ISNULL(@intBankAccountId, intBankAccountId)
						  AND dtmCheckPrinted IS NOT NULL), ''),
	ysnPrinted = 1
WHERE ISNULL(strReferenceNo, '') = ''

GO