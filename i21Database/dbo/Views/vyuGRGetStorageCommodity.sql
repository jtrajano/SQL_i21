CREATE VIEW [dbo].[vyuGRGetStorageCommodity]  
AS  
SELECT Distinct
   Cs.intEntityId
  ,Cs.intCompanyLocationId     
  ,Cs.intCommodityId  
 ,Cm.strCommodityCode
 ,Cm.strDescription  
FROM tblGRCustomerStorage Cs
JOIN tblICCommodity Cm ON Cm.intCommodityId=Cs.intCommodityId
Where Cs.dblOpenBalance >0 