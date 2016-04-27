CREATE VIEW [dbo].[vyuGRGetSettleItem]
AS 
SELECT Distinct
   Cs.intEntityId    
  ,Cs.intItemId  
 ,Item.strItemNo
 ,ST.ysnCustomerStorage  
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR'