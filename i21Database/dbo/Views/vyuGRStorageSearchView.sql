CREATE VIEW [dbo].[vyuGRStorageSearchView]
AS    
SELECT TOP 100 PERCENT  
 s.intCustomerStorageId
,s.intEntityId
,E.strName  
,strStorageTicketNumber
,s.intCompanyLocationId
,loc.strLocationName
,st.strStorageTypeDescription  
,s.dtmDeliveryDate
,s.intItemId  
,i.strItemNo  
,ISNULL(s.strCustomerReference,'')strCustomerReference  
,dbo.fnCTConvertQuantityToTargetItemUOM(s.intItemId,s.intUnitMeasureId,CU.intUnitMeasureId,s.dblOpenBalance) dblOpenBalance
,s.dtmLastStorageAccrueDate
,s.intStorageScheduleId
,SR.strScheduleId
FROM tblGRCustomerStorage s  
JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId=s.intCompanyLocationId  
LEFT JOIN tblGRStorageType st ON st.intStorageScheduleTypeId=s.intStorageTypeId  
JOIN tblICItem i on i.intItemId=s.intItemId
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=s.intCommodityId AND CU.ysnStockUnit=1  
JOIN tblEMEntity E ON E.intEntityId = s.intEntityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=s.intStorageScheduleId  
Where ISNULL(s.strStorageType,'') <> 'ITR' AND st.ysnCustomerStorage=0
ORDER BY s.intCustomerStorageId