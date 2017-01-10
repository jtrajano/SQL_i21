CREATE VIEW [dbo].[vyuGRGetStorageItem]
AS  
SELECT DISTINCT
 CS.intEntityId
,CS.intCompanyLocationId     
,CS.intItemId  
,Item.strItemNo
,Item.strDescription 
FROM tblGRCustomerStorage CS
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId 
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0