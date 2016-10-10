CREATE VIEW [dbo].[vyuARCollectionOverdueReport]
AS
SELECT
	intCompanyLocationId		=	(SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	, strCompanyName			=	(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	, strCompanyAddress			=	(SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
	, strCompanyPhone			=	(SELECT TOP 1 strPhone FROM tblSMCompanySetup)
	, IAR.intEntityCustomerId
	, Cus.strCustomerNumber
	, strCustomerName			=	Cus.strName
	, strCustomerAddress		=	[dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, Cus.strName, NULL)
	, strCustomerPhone			=	EnPhoneNo.strPhone 
	, strAccountNumber			=	(SELECT strAccountNumber FROM tblARCustomer WHERE intEntityCustomerId = Cus.intEntityCustomerId) 
	, IAR.intInvoiceId
	, IAR.strInvoiceNumber
	, IAR.strBOLNumber
	, IAR.dblCreditLimit
	, ARI.intTermId
	, IAR.dblTotalAR
	, CAR.[dblTotalARSum]		
	, IAR.dblFuture
	, CAR.[dblFutureSum]	
	, IAR.dbl0Days
	, CAR.[dbl0DaysSum]	
	, IAR.dbl10Days
	, CAR.[dbl10DaysSum]	
	, IAR.dbl30Days
	, CAR.[dbl30DaysSum]
	, IAR.dbl60Days
	, CAR.[dbl60DaysSum]	
	, IAR.dbl90Days
	, CAR.[dbl90DaysSum]
	, IAR.dbl91Days
	, CAR.[dbl91DaysSum]	
	, IAR.dblTotalDue
	, CAR.[dblTotalDueSum]	
	, IAR.dblAmountPaid
	, CAR.[dblAmountPaidSum]	
	, IAR.dblInvoiceTotal
	, CAR.[dblInvoiceTotalSum]	 
	, IAR.dblCredits
	, CAR.[dblCreditsSum]	
	, IAR.dblPrepaids
	, CAR.[dblPrepaidsSum]
	, IAR.dtmDate
	, IAR.dtmDueDate	
FROM 
	vyuARInvoiceAgingReport IAR
INNER JOIN (
			SELECT 
				intInvoiceId
				, intTermId  
			FROM tblARInvoice 
			) ARI ON IAR.intInvoiceId = ARI.intInvoiceId
INNER JOIN (
			SELECT 
				intEntityCustomerId
				, [dblTotalARSum]		=	dblTotalAR  
				, [dblFutureSum]		=	dblFuture 
				, [dbl0DaysSum]			=	dbl0Days 
				, [dbl10DaysSum]		=	dbl10Days
				, [dbl30DaysSum]		=	dbl30Days
				, [dbl60DaysSum]		=	dbl60Days
				, [dbl90DaysSum]		=	dbl90Days
				, [dbl91DaysSum]		=	dbl91Days
				, [dblTotalDueSum]		=	dblTotalDue
				, [dblAmountPaidSum]	=	dblAmountPaid
				, [dblInvoiceTotalSum]	=	dblInvoiceTotal
				, [dblCreditsSum]		=	dblCredits
				, [dblPrepaidsSum]		=	dblPrepaids
			FROM vyuARCustomerAgingReport
) CAR ON IAR.intEntityCustomerId = CAR.intEntityCustomerId
INNER JOIN (
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
				vyuARCustomer) Cus ON IAR.intEntityCustomerId = Cus.intEntityCustomerId AND CAR.intEntityCustomerId = IAR.intEntityCustomerId
INNER JOIN (
			SELECT 
				intEntityId
					, [intEntityContactId]
					, ysnDefaultContact 
			FROM 
				[tblEMEntityToContact]) CusToCon ON IAR.intEntityCustomerId = CusToCon.intEntityId AND CAR.intEntityCustomerId = CusToCon.intEntityId AND  Cus.intEntityCustomerId = CusToCon.intEntityId AND CusToCon.ysnDefaultContact = 1
LEFT JOIN (
			SELECT 
				intEntityId
				, strPhone 
			FROM 
				tblEMEntityPhoneNumber) EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]