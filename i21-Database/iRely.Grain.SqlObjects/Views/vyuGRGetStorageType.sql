CREATE VIEW [dbo].[vyuGRGetStorageType]
AS  
SELECT DISTINCT
 CS.intEntityId
,CS.intCompanyLocationId     
,CS.intItemId  
,ST.intStorageScheduleTypeId
,ST.strStorageTypeCode
,ST.strStorageTypeDescription
FROM tblGRCustomerStorage CS
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId 
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0