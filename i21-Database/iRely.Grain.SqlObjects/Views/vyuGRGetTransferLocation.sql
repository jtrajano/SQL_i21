CREATE VIEW [dbo].[vyuGRGetTransferLocation]
AS  
SELECT DISTINCT   
 CS.intCompanyLocationId  
,LOC.strLocationName  
FROM tblGRCustomerStorage CS
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId =CS.intCompanyLocationId 