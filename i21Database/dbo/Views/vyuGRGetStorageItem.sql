CREATE VIEW [dbo].[vyuGRGetStorageItem]
AS  
SELECT Distinct
   Cs.intEntityId
  ,Cs.intCompanyLocationId     
  ,Cs.intItemId  
 ,Item.strItemNo
 ,Item.strDescription 
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId 
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0