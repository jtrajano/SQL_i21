CREATE VIEW [dbo].[vyuARCustomerAddressLabelReport]
	AS 
SELECT DISTINCT 	
	ACS.strAccountStatusCode, 
	ACS.strDescription,
	strName = UPPER(CS.strName),
	strAddress = UPPER(CS.strAddress),	
	strCityStateZipCode = UPPER(CS.strCity) + ' '+ UPPER(CS.strState) + ' ' + CS.strZipCode,
	strAccountNumber = CS.strAccountNumber		
from tblARAccountStatus ACS
INNER JOIN 
	tblARCustomerAccountStatus CAS
ON ACS.intAccountStatusId = CAS.intAccountStatusId
INNER JOIN 
	vyuARCustomerSearch CS
ON CAS.intEntityCustomerId = CS.intEntityCustomerId
