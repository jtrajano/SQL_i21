CREATE VIEW [dbo].[vyuARCollectionCustomerReport]
AS
SELECT intCompanyLocationId		= COMPANY.intCompanySetupID
	, strCompanyName			= COMPANY.strCompanyName
	, strCompanyAddress			= COMPANY.strCompanyAddress
	, strCompanyPhone			= COMPANY.strPhone
	, intEntityCustomerId		= C.intEntityId
	, strCustomerNumber			= C.strCustomerNumber
 	, strCustomerName			= E.strName
	, strCustomerAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, E.strName, NULL) COLLATE Latin1_General_CI_AS
	, strCustomerPhone			= PHONE.strPhone 
	, strAccountNumber			= C.strAccountNumber
	, strTerm					= TERM.strTerm		
	, dtmLetterDate				= CAST(GETDATE() AS DATE)
	, strCurrentUser			= CURRENTUSER.strName
	, strContactName			= CON.strName
	, dblARBalance				= C.dblARBalance
FROM tblARCustomer C
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
INNER JOIN tblEMEntityLocation EL ON C.intBillToId = EL.intEntityLocationId
LEFT JOIN (
	SELECT EC.intEntityId
	     , EC.intEntityContactId
		 , EEC.strName
	FROM tblEMEntityToContact EC
	INNER JOIN tblEMEntity EEC ON EC.intEntityId = EEC.intEntityId
	WHERE ysnDefaultContact = 1
) CON ON C.intEntityId = CON.intEntityId
LEFT JOIN tblEMEntityPhoneNumber PHONE ON CON.intEntityContactId = PHONE.[intEntityId]
LEFT JOIN tblSMTerm TERM ON C.intTermsId = TERM.intTermID
OUTER APPLY (
	SELECT TOP 1 E.strName
	FROM tblSMConnectedUser CU
	INNER JOIN tblEMEntity E ON CU.intEntityId = E.intEntityId
) CURRENTUSER
OUTER APPLY (
	SELECT TOP 1 intCompanySetupID
			   , strCompanyName
			   , strPhone
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY