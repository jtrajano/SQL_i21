CREATE VIEW vyuCMBankActivityMatched
AS
SELECT 
A.strMatchingId,
A.intBankAccountId, --  FOR FILTERING
A.intABRActivityMatchedId intMatchedId,
A.intABRActivityId,
A.intTransactionId,
Trans.strTransactionId,
Trans.strReferenceNo,
Trans.dtmDate,
ABS(Trans.dblAmount) * CASE WHEN strDebitCredit = 'D' THEN -1 ELSE 1 END  dblTransAmount,
Trans.strBankTransactionTypeName,
Activity.strABRActivityId,
Activity.dtmClear,
Activity.strBankDescription,
Activity.dblAmount * CASE WHEN strDebitCredit = 'D' THEN -1 ELSE 1 END dblActivityAmount,
Activity.strDebitCredit,
A.dtmDateReconciled,
Trans.intBankTransactionTypeId,
A.intConcurrencyId
FROM 
tblCMABRActivityMatched A
OUTER APPLY(
	SELECT
	strABRActivityId,
	dtmClear, 
    strBankDescription,
    dblAmount , 
    strDebitCredit,
	intImportStatus
    FROM tblCMABRActivity 
    WHERE intABRActivityId = A.intABRActivityId
) Activity
OUTER APPLY(
	SELECT 
	intBankAccountId,
	strTransactionId, 
	strReferenceNo,
	dtmDate,
	dblAmount,
	strBankTransactionTypeName,
	intBankTransactionTypeId
    FROM vyuCMBankTransaction 
    WHERE intTransactionId = A.intTransactionId
) Trans
