CREATE VIEW [dbo].[vyuGRGetVendors]
AS   
SELECT Distinct     
  CS.intEntityId    
 ,E.strName
,ET.strType
,ST.ysnCustomerStorage  
FROM tblGRCustomerStorage CS  
JOIN tblEntity E ON E.intEntityId = CS.intEntityId
JOIN tblEntityType ET ON ET.intEntityId=E.intEntityId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId   
Where CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' 