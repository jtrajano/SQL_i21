CREATE VIEW [dbo].[vyuGRGetStorageEntity]
AS  
SELECT DISTINCT   
CS.intEntityId  
,E.strName
FROM tblGRCustomerStorage CS
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId 
WHERE ISNULL(CS.strStorageType,'') <> 'ITR'  AND ST.ysnCustomerStorage=0 

