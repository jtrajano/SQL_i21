CREATE VIEW [dbo].[vyuARCustomerAddressLabelReport]
	AS 
SELECT DISTINCT 	
	ACS.strAccountStatusCode, 
	ACS.strDescription,
	strName = UPPER(CS.strName),
	strAddress = UPPER(CS.strAddress),	
	strCityStateZipCode = UPPER(CS.strCity) + ' '+ UPPER(CS.strState) + ' ' + CS.strZipCode,
	strAccountNumber = CS.strAccountNumber,
	ysnActive = CS.ysnActive		
from tblARAccountStatus ACS
INNER JOIN 
	tblARCustomerAccountStatus CAS
ON ACS.intAccountStatusId = CAS.intAccountStatusId
RIGHT JOIN 
	vyuARCustomerSearch CS
ON CAS.intEntityCustomerId = CS.intEntityCustomerId
WHERE CS.ysnActive = 1
