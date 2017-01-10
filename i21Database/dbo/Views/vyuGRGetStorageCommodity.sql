CREATE VIEW [dbo].[vyuGRGetStorageCommodity]  
AS  
SELECT Distinct
   CS.intEntityId
  ,CS.intCompanyLocationId     
  ,CS.intCommodityId  
 ,COM.strCommodityCode
 ,COM.strDescription  
FROM tblGRCustomerStorage CS
JOIN tblICCommodity COM ON COM.intCommodityId=CS.intCommodityId
Where CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR'