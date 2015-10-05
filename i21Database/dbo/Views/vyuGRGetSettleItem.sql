CREATE VIEW [dbo].[vyuGRGetSettleItem]
AS 
SELECT Distinct
   Cs.intEntityId    
  ,Cs.intItemId  
 ,Item.strItemNo
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
Where Cs.dblOpenBalance >0 