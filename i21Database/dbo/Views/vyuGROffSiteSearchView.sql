CREATE VIEW [dbo].[vyuGROffSiteSearchView]
AS    
SELECT TOP 100 PERCENT  
  CS.intCustomerStorageId
 ,E.strName  
,strStorageTicketNumber
,LOC.strLocationName
,ST.strStorageTypeDescription  
,CS.dtmDeliveryDate  
,Item.strItemNo  
,ISNULL(CS.strCustomerReference,'')strCustomerReference  
,CS.dblOpenBalance  
FROM tblGRCustomerStorage CS  
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId=CS.intCompanyLocationId  
LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId  
JOIN tblICItem Item on Item.intItemId=CS.intItemId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
Where ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1 
ORDER BY CS.intCustomerStorageId 