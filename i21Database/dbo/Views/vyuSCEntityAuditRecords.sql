CREATE VIEW [dbo].[vyuSCEntityAuditRecords]  
AS  
  
WITH cte   
AS (  
SELECT DISTINCT    A.intLogId, B.intRecordId, A.dtmDate from tblSMLog A  
INNER JOIN tblSMAudit E ON E.intLogId  = A.intLogId  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId 
INNER JOIN tblEMEntity F on F.intEntityId = B.intRecordId
INNER JOIN tblEMEntityType G on G.intEntityId = F.intEntityId
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
WHERE C.strNamespace = 'EntityManagement.view.Entity' 
AND F.ysnSent = 0 
AND E.intParentAuditId IS NULL  
AND E.strAction IN ('Created','Updated')   
AND G.strType in ('User', 'Customer', 'Vendor', 'Salesperson')
--order by A.dtmDate asc  
), secondLayer as 
(
SELECT intRecordId, intLogId, dtmDate  FROM cte 
UNION 
SELECT DISTINCT  F.intEntityId as 'intRecordId' ,A.intLogId, A.dtmDate from tblSMLog A  
INNER JOIN tblSMAudit E ON E.intLogId  = A.intLogId  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId
INNER JOIN tblEMEntitySplit X on X.intSplitId = B.intRecordId 
INNER JOIN tblEMEntity F on F.intEntityId = X.intEntityId
INNER JOIN tblEMEntityType G on G.intEntityId = F.intEntityId
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
WHERE C.strNamespace = 'EntityManagement.view.EntitySplit' 
AND F.ysnSent = 0
)
   
SELECT intRecordId, intLogId, dtmDate  FROM secondLayer 
WHERE   
intRecordId  
NOT IN  
  
(  
  
SELECT DISTINCT B.intRecordId FROM tblSMLog A  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId
inner join tblEMEntity F on F.intEntityId = B.intRecordId  
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
INNER JOIN tblSMAudit E ON E.intLogId = A.intLogId  
WHERE C.strNamespace = 'EntityManagement.view.Entity'    
AND E.strAction = 'Deleted' AND E.intParentAuditId IS NULL  
  
)  
-- AND intLogId   
-- NOT IN  
-- (  
--     SELECT intLogId FROM tblSCEntityGeneratedLog  
-- )  