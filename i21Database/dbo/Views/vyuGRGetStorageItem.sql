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
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR'