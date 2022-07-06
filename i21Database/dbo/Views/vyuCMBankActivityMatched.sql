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
dblTransAmount,  
Trans.strBankTransactionTypeName,  
Activity.strABRActivityId,  
Activity.dtmClear,  
Activity.strBankDescription,  
dblActivityAmount,  
Activity.strDebitCredit,  
Trans.dtmDateReconciled,  
Trans.intBankTransactionTypeId,  
A.intConcurrencyId  
FROM   
tblCMABRActivityMatched A  
OUTER APPLY(  
 	SELECT  
	strABRActivityId,  
	dtmClear,   
	strBankDescription,  
	ABS(dblAmount) * CASE WHEN B.strDebitCredit = 'D' THEN -1 ELSE 1 END  dblActivityAmount ,   
	strDebitCredit,  
	intImportStatus  
	FROM tblCMABRActivity B  
	WHERE intABRActivityId = A.intABRActivityId  
) Activity  
OUTER APPLY(  
	SELECT   
	intBankAccountId,  
	strTransactionId,   
	strReferenceNo,  
	dtmDate,  
	ABS(dblAmount) * CASE WHEN (BTY.strDebitCredit = 'D') OR (BTY.strDebitCredit = 'DC' AND dblAmount <0) THEN -1 ELSE 1 END dblTransAmount,
	strBankTransactionTypeName,  
	BT.intBankTransactionTypeId,
	BT.dtmDateReconciled
    FROM tblCMBankTransaction   BT join tblCMBankTransactionType BTY on BT.intBankTransactionTypeId = BTY.intBankTransactionTypeId
    WHERE intTransactionId = A.intTransactionId  
) Trans

