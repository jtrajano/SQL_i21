CREATE VIEW [dbo].[vyuGRStorageSearchView]
AS    
SELECT TOP 100 PERCENT  
  s.intCustomerStorageId
 ,E.strName  
,strStorageTicketNumber
,loc.strLocationName
,st.strStorageTypeDescription  
,s.dtmDeliveryDate  
,i.strItemNo  
,ISNULL(s.strCustomerReference,'')strCustomerReference  
,s.dblOpenBalance
,s.dtmLastStorageAccrueDate
,s.intStorageScheduleId
,SR.strScheduleId 
FROM tblGRCustomerStorage s  
JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId=s.intCompanyLocationId  
LEFT JOIN tblGRStorageType st ON st.intStorageScheduleTypeId=s.intStorageTypeId  
JOIN tblICItem i on i.intItemId=s.intItemId  
JOIN tblEntity E ON E.intEntityId = s.intEntityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=s.intStorageScheduleId  
Where ISNULL(s.strStorageType,'') <> 'ITR' AND st.ysnCustomerStorage=0
ORDER BY s.intCustomerStorageId    