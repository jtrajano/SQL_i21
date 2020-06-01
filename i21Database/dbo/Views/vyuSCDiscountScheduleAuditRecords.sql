CREATE VIEW [dbo].[vyuSCDiscountScheduleAuditRecords]
AS

WITH cte   
AS (  
SELECT DISTINCT    A.intLogId, B.intRecordId, A.dtmDate from tblSMLog A  
INNER JOIN tblSMAudit E ON E.intLogId  = A.intLogId  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId 
INNER JOIN tblGRDiscountId F on F.intDiscountId = B.intRecordId
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
WHERE C.strNamespace = 'Grain.view.DiscountTable' 
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
inner join tblGRDiscountId F on F.intDiscountId = B.intRecordId  
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
INNER JOIN tblSMAudit E ON E.intLogId = A.intLogId  
WHERE C.strNamespace = 'Grain.view.DiscountTable'    
AND E.strAction = 'Deleted' AND E.intParentAuditId IS NULL  
  
) 