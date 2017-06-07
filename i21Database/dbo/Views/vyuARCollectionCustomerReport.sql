CREATE VIEW [dbo].[vyuARCollectionCustomerReport]
AS
SELECT intCompanyLocationId		=	(SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	, strCompanyName			=	(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	, strCompanyAddress			=	(SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
	, strCompanyPhone			=	(SELECT TOP 1 strPhone FROM tblSMCompanySetup)
	, intEntityCustomerId		=	Cus.[intEntityId]
	, strCustomerNumber			=	Cus.strCustomerNumber
 	, strCustomerName			=	Cus.strName
	, strCustomerAddress		=	[dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, Cus.strName, NULL)
	, strCustomerPhone			=	EnPhoneNo.strPhone 
	, strAccountNumber			=	(SELECT strAccountNumber FROM tblARCustomer WHERE [intEntityId] = Cus.[intEntityId]) 
	, strTerm					=	Term.strTerm			
FROM (
			SELECT 
				[intEntityId]
				, strCustomerNumber
				, strName
				, strBillToAddress
				, strBillToCity
				, strBillToCountry
				, strBillToLocationName
				, strBillToState
				, strBillToZipCode
				, intTermsId 
			FROM 
				vyuARCustomer) Cus 
LEFT JOIN (
			SELECT 
				intEntityId
					, [intEntityContactId]
					, ysnDefaultContact 
			FROM 
				[tblEMEntityToContact]) CusToCon ON Cus.[intEntityId] = CusToCon.intEntityId AND CusToCon.ysnDefaultContact = 1
LEFT JOIN (
			SELECT 
				intEntityId
				, strPhone 
			FROM 
				tblEMEntityPhoneNumber) EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
LEFT JOIN (SELECT intTermID, 
				strTerm  
			FROM 
				tblSMTerm) Term ON Cus.intTermsId = Term.intTermID