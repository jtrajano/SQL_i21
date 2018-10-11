CREATE VIEW [dbo].[vyuGRGetStorageEntity]
AS  
SELECT 
DISTINCT   
 CS.intEntityId  
,E.strName
FROM tblGRCustomerStorage	       CS
JOIN tblEMEntity			       E  ON E.intEntityId			     = CS.intEntityId
JOIN tblGRStorageType		       ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
LEFT JOIN tblGRStorageStatement    SS ON SS.intCustomerStorageId     = CS.intCustomerStorageId 
WHERE ISNULL(CS.strStorageType,'') <> 'ITR'  
AND   ST.ysnCustomerStorage = 0 
AND   CS.dblOpenBalance > 0
AND   SS.intCustomerStorageId IS NULL

