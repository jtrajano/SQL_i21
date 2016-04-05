CREATE VIEW [dbo].[vyuGRGetStorageCustomer]  
AS  
SELECT Distinct   
  CS.intEntityId  
 ,E.strName
FROM tblGRCustomerStorage CS
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
JOIN [tblEMEntityType] ET ON ET.intEntityId=E.intEntityId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId 
Where CS.dblOpenBalance >0 AND ET.strType='Vendor' AND ISNULL(CS.strStorageType,'') <> 'ITR'  AND ST.ysnCustomerStorage=0 
