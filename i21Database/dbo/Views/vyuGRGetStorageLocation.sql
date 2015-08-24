CREATE VIEW [dbo].[vyuGRGetStorageLocation]  
AS  
SELECT Distinct
   Cs.intEntityId 
  ,Cs.intCompanyLocationId  
  ,Loc.strLocationName  
FROM tblGRCustomerStorage Cs
JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId =Cs.intCompanyLocationId 
Where Cs.dblOpenBalance >0 

