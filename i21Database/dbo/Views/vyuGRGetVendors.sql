CREATE VIEW [dbo].[vyuGRGetVendors]
AS   
SELECT Distinct     
  CS.intEntityId    
 ,E.strName AS strEntityName
,ET.strType AS strEntityType
,ST.ysnCustomerStorage  
FROM tblGRCustomerStorage CS  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
JOIN [tblEMEntityType] ET ON ET.intEntityId=E.intEntityId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId   
Where CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' 