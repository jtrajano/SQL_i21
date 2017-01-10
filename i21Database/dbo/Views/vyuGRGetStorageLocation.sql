CREATE VIEW [dbo].[vyuGRGetStorageLocation]  
AS  
SELECT DISTINCT
 CS.intEntityId 
,CS.intCompanyLocationId  
,LOC.strLocationName  
FROM tblGRCustomerStorage CS
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId =CS.intCompanyLocationId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId  
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0

