CREATE VIEW [dbo].[vyuGRGetStorageCustomer]  
AS  
SELECT Distinct   
  CS.intEntityId  
 ,E.strName
FROM tblGRCustomerStorage CS
JOIN tblEntity E ON E.intEntityId = CS.intEntityId
Where CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR'  
