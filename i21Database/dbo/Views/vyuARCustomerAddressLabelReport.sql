CREATE VIEW [dbo].[vyuARCustomerAddressLabelReport]
	AS
SELECT 	
	ACS.strAccountStatusCode, 
	ACS.strDescription,
	strName = UPPER(CS.strName),
	strAddress = UPPER(CS.strAddress),	
	strCityStateZipCode = UPPER(CS.strCity) + ' '+ UPPER(CS.strState) + ' ' + CS.strZipCode		
from tblARAccountStatus ACS
INNER JOIN 
	tblARCustomerAccountStatus CAS
ON ACS.intAccountStatusId = CAS.intAccountStatusId
INNER JOIN 
	vyuARCustomerSearch CS
ON CAS.intEntityCustomerId = CS.intEntityCustomerId
