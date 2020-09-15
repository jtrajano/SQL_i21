CREATE VIEW [dbo].[vyuSCDiscountScheduleAuditRecords]
AS

WITH cte   
AS (  
SELECT DISTINCT    A.intLogId, B.intRecordId, A.dtmDate from tblSMLog A  
INNER JOIN tblSMAudit E ON E.intLogId  = A.intLogId  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId 
INNER JOIN tblGRDiscountSchedule F on F.intDiscountScheduleId = B.intRecordId
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
WHERE C.strNamespace = 'Grain.view.DiscountSchedule' 

AND F.ysnSent = 0 
AND E.intParentAuditId IS NULL  
AND E.strAction IN ('Created','Updated')   

--order by A.dtmDate asc  
), secondLayer AS
(
SELECT intRecordId, intLogId, dtmDate  FROM cte 
UNION
SELECT DISTINCT  F.intDiscountScheduleId as 'intRecordId' ,A.intLogId, A.dtmDate from tblSMLog A  
INNER JOIN tblSMAudit E ON E.intLogId  = A.intLogId  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId
INNER JOIN tblGRDiscountScheduleCode F ON F.intDiscountScheduleCodeId = B.intRecordId
INNER JOIN tblGRDiscountSchedule G ON G.intDiscountScheduleId = F.intDiscountScheduleId
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
WHERE C.strNamespace = 'Grain.view.DiscountCode' 
AND G.ysnSent = 0
)

   
SELECT intRecordId, intLogId, dtmDate  FROM secondLayer 
WHERE   
intRecordId  
NOT IN  
  
(  
  
SELECT DISTINCT B.intRecordId FROM tblSMLog A  
INNER JOIN tblSMTransaction B ON B.intTransactionId = A.intTransactionId
inner join tblGRDiscountSchedule F on F.intDiscountScheduleId = B.intRecordId  
INNER JOIN tblSMScreen C ON C.intScreenId = B.intScreenId  
INNER JOIN tblSMAudit E ON E.intLogId = A.intLogId  
WHERE C.strNamespace = 'Grain.view.DiscountSchedule'    
AND E.strAction = 'Deleted' AND E.intParentAuditId IS NULL  
  
)


  
 