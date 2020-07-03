

CREATE VIEW vyuCFEntityCustomerSearch
AS

SELECT 
intId = CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT),
tblEMEntity.intEntityId,
tblEMEntity.strEntityNo,
intCustomerId = tblEMEntity.intEntityId,
strCustomerNo = tblEMEntity.strEntityNo,
tblEMEntity.strName,
tblSMTerm.strTerm,
intTermId = tblSMTerm.intTermID,
intSalesPersonId = tblEMSalesperson.intEntityId,
strSalesPersonId = tblEMSalesperson.strEntityNo,
strSalesPersonName = tblEMSalesperson.strName,
tblARAccountStatus.intAccountStatusId,
tblARAccountStatus.strAccountStatusCode
FROM tblARCustomer
INNER JOIN tblEMEntity
ON tblARCustomer.intEntityId = tblEMEntity.intEntityId
LEFT JOIN tblEMEntity AS tblEMSalesperson
ON tblEMSalesperson.intEntityId = tblARCustomer.intSalespersonId
LEFT JOIN tblSMTerm
ON tblARCustomer.intTermsId = tblSMTerm.intTermID
LEFT JOIN tblARCustomerAccountStatus
ON tblEMEntity.intEntityId = tblARCustomerAccountStatus.intEntityCustomerId
LEFT JOIN tblARAccountStatus
ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId

GO