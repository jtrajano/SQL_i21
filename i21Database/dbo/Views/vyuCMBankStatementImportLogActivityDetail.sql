CREATE  VIEW vyuCMBankStatementImportLogActivityDetail
AS
select 
C.intId,
A.intImportBankStatementLogId,  
C.intLineNo,  
B.strABRActivityId strTaskId,
ysnError = case when strError is null then cast(0 as bit) else cast(1 as bit) end ,  
C.strError,
B.strBankDescription,
strTransactionMatched = Match.strTransactionId
from 
tblCMBankStatementImportLog A 
join tblCMBankStatementImportLogDetail C on C.intImportBankStatementLogId = A.intImportBankStatementLogId
left join tblCMABRActivity B on B.strABRActivityId = C.strABRActivityId
OUTER APPLY(
    SELECT TOP 1 strTransactionId FROM tblCMABRActivityMatched M
    JOIN tblCMBankTransaction CM ON CM.intTransactionId = M.intTransactionId
    WHERE intABRActivityId = B.intABRActivityId
)Match