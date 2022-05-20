CREATE  VIEW vyuCMBankStatementImportLogActivityDetail  
AS  
select   
C.intId,  
A.intImportBankStatementLogId,    
C.intLineNo,    
ISNULL(C.strTaskId, B.strABRActivityId) strTaskId,  
ysnError = case when C.ysnSuccess = 0 then cast(1 as bit) else cast( 0 as bit) end ,   
C.strError,  
ISNULL(B.strBankDescription, Task.strNotes) strBankDescription,
strTransactionMatched = Match.strTransactionId  
FROM   
tblCMBankStatementImportLog A   
join tblCMBankStatementImportLogDetail C on C.intImportBankStatementLogId = A.intImportBankStatementLogId  
left join tblCMABRActivity B on B.strABRActivityId = C.strABRActivityId  
OUTER APPLY(  
    SELECT TOP 1 strTransactionId FROM tblCMABRActivityMatched M  
    JOIN tblCMBankTransaction CM ON CM.intTransactionId = M.intTransactionId  
    WHERE intABRActivityId = B.intABRActivityId  
)Match
OUTER APPLY(  
    SELECT strNotes FROM tblCMResponsiblePartyTask
	WHERE strTaskId = C.strTaskId

)Task