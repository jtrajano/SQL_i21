CREATE VIEW [dbo].[vyuGRGetTransferLocation]
AS  
SELECT Distinct   
  Cs.intCompanyLocationId  
 ,Loc.strLocationName  
FROM tblGRCustomerStorage Cs
JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId =Cs.intCompanyLocationId 