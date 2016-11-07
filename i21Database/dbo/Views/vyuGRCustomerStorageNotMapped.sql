CREATE VIEW [dbo].[vyuGRCustomerStorageNotMapped]
AS
SELECT    
 a.intCustomerStorageId
,a.intEntityId  
,E.strName  
,a.intStorageTypeId  
,b.strStorageTypeDescription
,a.intItemId
,Item.strItemNo  
,a.intCompanyLocationId  
,c.strLocationName
,ISNULL(a.intCompanyLocationSubLocationId,0) intCompanyLocationSubLocationId
,ISNULL(Sub.strSubLocationName,'') strSubLocationName 
FROM tblGRCustomerStorage a  
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = a.intEntityId  
JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=a.intStorageScheduleId
JOIN tblICItem Item ON Item.intItemId = a.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation Sub ON Sub.intCompanyLocationSubLocationId=a.intCompanyLocationSubLocationId
Where  ISNULL(a.strStorageType,'') <> 'ITR' 