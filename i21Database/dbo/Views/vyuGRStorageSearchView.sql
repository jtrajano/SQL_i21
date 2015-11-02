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
FROM tblGRCustomerStorage s  
JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId=s.intCompanyLocationId  
LEFT JOIN tblGRStorageType st ON st.intStorageScheduleTypeId=s.intStorageTypeId  
JOIN tblICItem i on i.intItemId=s.intItemId  
JOIN tblEntity E ON E.intEntityId = s.intEntityId  
Where ISNULL(s.strStorageType,'') <> 'ITR'  
ORDER BY s.intCustomerStorageId  