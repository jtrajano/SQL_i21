CREATE VIEW [dbo].[vyuGRGetVendors]
AS   
SELECT Distinct     
  CS.intEntityId    
 ,E.strName
,ET.strType  
FROM tblGRCustomerStorage CS  
JOIN tblEntity E ON E.intEntityId = CS.intEntityId
JOIN tblEntityType ET ON ET.intEntityId=E.intEntityId  
Where CS.dblOpenBalance >0 AND ET.strType='Vendor' AND ISNULL(CS.strStorageType,'') <> 'ITR'