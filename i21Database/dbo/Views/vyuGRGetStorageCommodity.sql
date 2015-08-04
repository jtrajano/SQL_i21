CREATE VIEW [dbo].[vyuGRGetStorageCommodity]  
AS  
SELECT Distinct   
  Cs.intCommodityId  
 ,Cm.strCommodityCode
 ,Cm.strDescription  
FROM tblGRCustomerStorage Cs
JOIN tblICCommodity Cm ON Cm.intCommodityId=Cs.intCommodityId