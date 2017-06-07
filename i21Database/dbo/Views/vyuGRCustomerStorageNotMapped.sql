CREATE VIEW [dbo].[vyuGRCustomerStorageNotMapped]
AS
SELECT    
 CS.intCustomerStorageId
,CS.intEntityId  
,E.strName  
,CS.intStorageTypeId  
,ST.strStorageTypeDescription
,CS.intItemId
,Item.strItemNo  
,CS.intCompanyLocationId  
,LOC.strLocationName
,ISNULL(CS.intCompanyLocationSubLocationId,0) intCompanyLocationSubLocationId
,ISNULL(SLOC.strSubLocationName,'') strSubLocationName
,CS.intDiscountScheduleId
,DS.strDiscountDescription
,CS.intStorageScheduleId
,SR.strScheduleId 
FROM tblGRCustomerStorage CS  
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity COM ON COM.intCommodityId = CS.intCommodityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=CS.intStorageScheduleId
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
JOIN tblGRDiscountSchedule DS ON DS.intDiscountScheduleId=CS.intDiscountScheduleId
LEFT JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=CS.intCompanyLocationSubLocationId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR'