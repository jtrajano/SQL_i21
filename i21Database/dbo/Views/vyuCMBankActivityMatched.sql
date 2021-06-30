CREATE VIEW vyuCMBankActivityMatched
AS
SELECT 
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
OUTER APPLY(
	SELECT
	strABRActivityId,
	 dtmClear, strBankDescription,dblAmount , strDebitCredit 
    FROM tblCMABRActivity 
    WHERE intABRActivityId = A.intABRActivityId
) Activity
OUTER APPLY(
	SELECT strTransactionId, strReferenceNo,dtmDate,dblAmount,strBankTransactionTypeName 
    FROM vyuCMBankTransaction 
    WHERE intTransactionId = A.intTransactionId
) Trans