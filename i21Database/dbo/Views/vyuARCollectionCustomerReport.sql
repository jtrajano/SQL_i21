CREATE VIEW [dbo].[vyuARCollectionCustomerReport]
AS
SELECT intCompanyLocationId		=	(SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	, strCompanyName			=	(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	, strCompanyAddress			=	(SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
	, strCompanyPhone			=	(SELECT TOP 1 strPhone FROM tblSMCompanySetup)
	, intEntityCustomerId		=	Cus.intEntityCustomerId
	, strCustomerNumber			=	Cus.strCustomerNumber
 	, strCustomerName			=	Cus.strName
	, strCustomerAddress		=	[dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, Cus.strName, NULL)
	, strCustomerPhone			=	EnPhoneNo.strPhone 
	, strAccountNumber			=	(SELECT strAccountNumber FROM tblARCustomer WHERE intEntityCustomerId = Cus.intEntityCustomerId) 
	, strTerm					=	Term.strTerm			
FROM (
			SELECT 
				intEntityCustomerId
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
INNER JOIN (
			SELECT 
				intEntityId
					, [intEntityContactId]
					, ysnDefaultContact 
			FROM 
				[tblEMEntityToContact]) CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId AND CusToCon.ysnDefaultContact = 1
 LEFT JOIN (
			SELECT 
				intEntityId
				, strPhone 
			FROM 
				tblEMEntityPhoneNumber) EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
INNER JOIN (SELECT intTermID, 
				strTerm  
			FROM 
				tblSMTerm) Term ON Cus.intTermsId = Term.intTermID