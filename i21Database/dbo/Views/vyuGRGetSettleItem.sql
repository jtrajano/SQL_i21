CREATE VIEW [dbo].[vyuGRGetSettleItem]
AS 
SELECT DISTINCT
 CS.intEntityId    
,CS.intItemId  
,Item.strItemNo
,ST.ysnCustomerStorage  
FROM tblGRCustomerStorage CS
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR'