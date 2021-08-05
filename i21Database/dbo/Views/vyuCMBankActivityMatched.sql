CREATE VIEW vyuCMBankActivityMatched
AS
SELECT 
Trans.intBankAccountId, --  FOR FILTERING
A.intABRActivityMatchedId intMatchedId,
A.intABRActivityId,
A.intTransactionId,
Trans.strTransactionId,
Trans.strReferenceNo,
Trans.dtmDate,
Trans.dblAmount dblTransAmount,
Trans.strBankTransactionTypeName,
Activity.strABRActivityId,
Activity.dtmClear,
Activity.strBankDescription,
Activity.dblAmount * CASE WHEN strDebitCredit = 'D' THEN -1 ELSE 1 END dblActivityAmount,
Activity.strDebitCredit,
A.dtmDateReconciled,
A.intConcurrencyId
FROM 
tblCMABRActivityMatched A
CROSS APPLY(
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
CROSS APPLY(
	SELECT 
	intBankAccountId,
	strTransactionId, 
	strReferenceNo,
	dtmDate,
	dblAmount,
	strBankTransactionTypeName 
    FROM vyuCMBankTransaction 
    WHERE intTransactionId = A.intTransactionId
) Trans
