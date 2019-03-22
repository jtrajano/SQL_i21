CREATE VIEW [dbo].[vyuARCollectionCustomerReport]
AS
SELECT intCompanyLocationId		= COMPANY.intCompanySetupID
	, strCompanyName			= COMPANY.strCompanyName
	, strCompanyAddress			= COMPANY.strCompanyAddress
	, strCompanyPhone			= COMPANY.strPhone
	, intEntityCustomerId		= Cus.[intEntityId]
	, strCustomerNumber			= Cus.strCustomerNumber
 	, strCustomerName			= Cus.strName
	, strCustomerAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, Cus.strName, NULL) COLLATE Latin1_General_CI_AS
	, strCustomerPhone			= EnPhoneNo.strPhone 
	, strAccountNumber			= (SELECT strAccountNumber FROM tblARCustomer WHERE [intEntityId] = Cus.[intEntityId]) 
	, strTerm					= Term.strTerm		
	, dtmLetterDate				= GETDATE()	
	, strCurrentUser			= CURRENTUSER.strName
	, strContactName			= EC.strName		
FROM (
	SELECT [intEntityId]
		, strCustomerNumber
		, strName
		, strBillToAddress
		, strBillToCity
		, strBillToCountry
		, strBillToLocationName
		, strBillToState
		, strBillToZipCode
		, intTermsId 
	FROM vyuARCustomer
) Cus 
LEFT JOIN (
	SELECT intEntityId
	     , [intEntityContactId]
	FROM [tblEMEntityToContact]
	WHERE ysnDefaultContact = 1
) CusToCon ON Cus.[intEntityId] = CusToCon.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strPhone 
	FROM tblEMEntityPhoneNumber
) EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
LEFT JOIN (
	SELECT intTermID 
		 , strTerm  
	FROM tblSMTerm
) Term ON Cus.intTermsId = Term.intTermID
OUTER APPLY (
	SELECT TOP 1 strName
			   , intEntityContactId 
	FROM dbo.vyuEMEntityContact WITH (NOLOCK) 
	WHERE CusToCon.intEntityContactId = intEntityContactId
) EC
OUTER APPLY (
	SELECT CU.intEntityId, EE.strName
	FROM tblSMConnectedUser CU
	LEFT JOIN (
		SELECT intEntityId, strName FROM tblEMEntity
	) EE ON EE.intEntityId = CU.intConcurrencyId
) CURRENTUSER
OUTER APPLY (
	SELECT TOP 1 intCompanySetupID
			   , strCompanyName
			   , strPhone
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY