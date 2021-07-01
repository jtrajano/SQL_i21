CREATE VIEW vyuCMBankActivityMatched
AS
SELECT 
Trans.intBankAccountId, --  FOR FILTERING
A.intABRActivityMatchedDetailId intMatchedId,
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
Activity.dblAmount dblActivityAmount,
Activity.strDebitCredit
FROM 
tblCMABRActivityMatchedDetail A
CROSS APPLY(
	SELECT
	strABRActivityId,
	dtmClear, 
    strBankDescription,
    dblAmount , 
    strDebitCredit 
    FROM tblCMABRActivity 
    WHERE intABRActivityId = A.intABRActivityId
    AND intImportStatus = 1 -- ONLY MATCHED ACTIVITY
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
    AND dtmDateReconciled IS NULL -- NON-RECONCILED ONLY
) Trans