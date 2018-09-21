CREATE VIEW dbo.vyuCFAccountSearchCustomer
AS

SELECT     
cfCustomerEntity.intEntityId, 
strName, 
strCustomerNumber, 
cfCustomerEntity.strType, 
cfCustomerEntity.strPhone, 
cfCustomerEntity.strAddress, 
cfCustomerEntity.strCity, 
cfCustomerEntity.strState, 
cfCustomerEntity.strZipCode, 
cfCustomerEntity.ysnActive, 
intSalespersonId,
arSalesPerson.strEntityName as strSalesPersonName,
intCurrencyId, 
intTermsId, 
smTerm.strTerm,
smTerm.strTermCode,
intShipViaId, 
strShipToLocationName, 
strShipToAddress, 
strShipToCity, 
strShipToState, 
strShipToZipCode, 
strShipToCountry,
strBillToLocationName, 
strBillToAddress, 
strBillToCity, 
strBillToState, 
strBillToZipCode, 
strBillToCountry, 
accountStatus.*
FROM  dbo.vyuCFCustomerEntity AS cfCustomerEntity
---------------------------------------------------------------------
LEFT JOIN tblSMTerm as smTerm
ON cfCustomerEntity.intTermsId = smTerm.intTermID
---------------------------------------------------------------------
LEFT JOIN vyuEMEntityBasicWithType as arSalesPerson
ON cfCustomerEntity.intSalespersonId = arSalesPerson.intEntityId
---------------------------------------------------------------------
OUTER APPLY 
	(SELECT TOP 1 strAccountStatusCode, iASC.intAccountStatusId 
	FROM tblARCustomerAccountStatus as iCASC
	LEFT JOIN tblARAccountStatus iASC
	ON iCASC.intAccountStatusId = iASC.intAccountStatusId
	WHERE intEntityCustomerId = cfCustomerEntity.intEntityId
	ORDER BY intCustomerAccountStatusId ASC 
)   AS accountStatus
---------------------------------------------------------------------
WHERE     (cfCustomerEntity.[intEntityId] NOT IN
                          (SELECT     intCustomerId
                            FROM          dbo.tblCFAccount))
