CREATE VIEW [dbo].[vyuGRGetVendors]
AS   
SELECT DISTINCT
  CS.intEntityId 
  , E.strName AS strEntityName
  , ET.strType AS strEntityType
  , ST.ysnCustomerStorage  
FROM tblGRCustomerStorage CS  
INNER JOIN tblEMEntity E 
  ON E.intEntityId = CS.intEntityId
INNER JOIN tblEMEntityType ET 
  ON ET.intEntityId = E.intEntityId
INNER JOIN tblGRStorageType ST 
  ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
WHERE CS.dblOpenBalance > 0 
  AND ET.strType = 'Vendor'
  AND ISNULL(CS.strStorageType,'') <> 'ITR'
  AND ST.ysnCustomerStorage = 0 