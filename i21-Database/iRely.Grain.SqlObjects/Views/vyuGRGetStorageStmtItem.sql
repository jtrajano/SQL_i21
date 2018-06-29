CREATE VIEW [dbo].[vyuGRGetStorageStmtItem]
AS 
SELECT DISTINCT
Cs.intEntityId    
,Cs.intItemId  
,Item.strItemNo
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId
WHERE  ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0 
