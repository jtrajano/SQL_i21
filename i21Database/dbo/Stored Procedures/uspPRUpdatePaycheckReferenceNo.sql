CREATE PROCEDURE uspPRUpdatePaycheckReferenceNo
	@intBankAccountId INT = NULL
AS

/* Update Reference (Check) No*/
UPDATE tblPRPaycheck 
SET strReferenceNo = ISNULL((SELECT TOP 1 strReferenceNo FROM tblCMBankTransaction 
						WHERE strTransactionId = tblPRPaycheck.strPaycheckId
						  AND intBankTransactionTypeId = 21
						  AND intBankAccountId = ISNULL(@intBankAccountId, intBankAccountId)
						  AND dtmCheckPrinted IS NOT NULL), ''),
	ysnPrinted = 1
WHERE ISNULL(strReferenceNo, '') = '' AND ysnPosted = 1 AND ysnVoid = 0 AND ysnDirectDeposit = 0

/* Update Printed (Committed) Status*/
UPDATE tblPRPaycheck 
SET ysnPrinted = 1
WHERE strPaycheckId IN (SELECT strTransactionId FROM tblCMBankTransaction
						WHERE intBankAccountId = ISNULL(@intBankAccountId, intBankAccountId)
							AND intBankTransactionTypeId = 23
							AND dtmCheckPrinted IS NOT NULL)
	  AND ysnPrinted = 0 AND ysnPosted = 1 AND ysnVoid = 0 AND ysnDirectDeposit = 1

GO