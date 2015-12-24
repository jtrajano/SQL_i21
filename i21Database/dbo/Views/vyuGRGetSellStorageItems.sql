CREATE VIEW [dbo].[vyuGRGetSellStorageItems]
AS   
SELECT Distinct
 Cs.intItemId
,Item.strItemNo
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId 
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1