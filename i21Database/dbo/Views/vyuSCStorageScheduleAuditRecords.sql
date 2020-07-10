CREATE VIEW vyuSCStorageScheduleAuditRecords
AS 
WITH cte   
AS (  
SELECT DISTINCT    A.intLogId, B.intRecordId, A.dtmDate from tblSMLog A  
INNER JOIN tblSMAudit E ON E.intLogId  = A.intLogId  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId 
INNER JOIN tblGRStorageScheduleRule F on F.intStorageScheduleRuleId = B.intRecordId
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
WHERE C.strNamespace = 'Grain.view.StorageSchedule' 

AND F.ysnSent = 0 
AND E.intParentAuditId IS NULL  
AND E.strAction IN ('Created','Updated')   

--order by A.dtmDate asc  
)

   
SELECT intRecordId, intLogId, dtmDate  FROM cte 
WHERE   
intRecordId  
NOT IN  
  
(  
  
SELECT DISTINCT B.intRecordId FROM tblSMLog A  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId
inner join tblGRStorageScheduleRule F on F.intStorageScheduleRuleId = B.intRecordId  
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
INNER JOIN tblSMAudit E ON E.intLogId = A.intLogId  
WHERE C.strNamespace = 'Grain.view.StorageSchedule'    
AND E.strAction = 'Deleted' AND E.intParentAuditId IS NULL  
  
)

