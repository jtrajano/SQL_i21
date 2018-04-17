CREATE VIEW [dbo].[vyuARServiceChargeInvoiceReport]
AS
SELECT ARI.intInvoiceId
	, ARID.intInvoiceDetailId	
	, ARI.strInvoiceNumber
	, ARI.dtmDate
	, ARI.dtmDueDate
	, ARI.intTermId
	, SMT.strTerm
	, dblInvoiceTotal			= SUMMARY.dblTotal
	, dblBaseInvoiceTotal		= SUMMARY.dblBaseTotal
	, dblTotalDue				= ARID.dblTotal
	, dblBaseTotalDue			= ARID.dblBaseTotal
	, ARI.intEntityCustomerId
	, CUSTOMER.strCustomerNumber
	, strCustomerName			= CUSTOMER.strName
	, CUSTOMER.strAccountNumber
	, strCustomerAddress		= dbo.fnARFormatCustomerAddress(NULL, NULL, CUSTOMER.strName, CUSTOMER.strBillToAddress, CUSTOMER.strBillToCity, CUSTOMER.strBillToState, CUSTOMER.strBillToZipCode, CUSTOMER.strBillToCountry, NULL, NULL)
	, intCompanyLocationId		= SMCS.intCompanyLocationId
	, strCompanyName			= SMCS.strCompanyName
	, strCompanyPhone			= SMCS.strCompanyPhone
	, strCompanyFax				= SMCS.strCompanyFax
	, strCompanyEmail			= SMCS.strCompanyEmail
	, dtmLetterDate				= GETDATE()
	, strCreatedByName = USERPOSTED.strName
	, strCreatedByPhone = USERPOSTED.strPhone
	, strCreatedByEmail = USERPOSTED.strEmail
	, strSalesPersonName = SALESPERSON.strName
FROM (
	SELECT intInvoiceId
		, intEntityCustomerId
		, strInvoiceNumber
		, dtmDate
		, dtmDueDate
		, intTermId
		, dblInvoiceTotal
		, dblBaseInvoiceTotal	
		, intEntityId
		, intPostedById
		, intEntitySalespersonId		
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE strType = 'Service Charge'
	  AND ysnForgiven = 0
	  AND ysnPaid = 0
) ARI 
INNER JOIN (
	SELECT intInvoiceId
		, intInvoiceDetailId
		, dblTotal
		, dblBaseTotal
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
INNER JOIN (
	SELECT intTermID
		 , strTerm 
	FROM dbo.tblSMTerm WITH (NOLOCK)
) SMT ON ARI.intTermId = SMT.intTermID
INNER JOIN (
	SELECT intEntityId 
		 , strCustomerNumber
		 , strName
		 , strAccountNumber
		 , strBillToAddress
		 , strBillToCity
		 , strBillToLocationName
		 , strBillToCountry
		 , strBillToState
		 , strBillToZipCode
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON ARI.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN (
	SELECT intEntityCustomerId
		, dblTotal				= SUM(dblInvoiceTotal)
		, dblBaseTotal			= SUM(dblBaseInvoiceTotal)
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE strType = 'Service Charge'
	  AND ysnForgiven = 0
	  AND ysnPaid = 0
	GROUP BY intEntityCustomerId
) SUMMARY ON CUSTOMER.intEntityId = SUMMARY.intEntityCustomerId
OUTER APPLY (
	SELECT TOP 1 
		  intCompanyLocationId	= intCompanySetupID
		, strCompanyName		= strCompanyName
		, strCompanyAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL)
		, strCompanyPhone		= strPhone
		, strCompanyFax			= strFax
		, strCompanyEmail		= strEmail
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) SMCS
LEFT OUTER JOIN (
	SELECT intEntityId, strName, strPhone, strEmail FROM dbo.tblEMEntity
) USERPOSTED ON USERPOSTED.intEntityId = ARI.intPostedById
LEFT OUTER JOIN(
	SELECT intEntityId, strName FROM dbo.tblEMEntity WITH (NOLOCK)
) SALESPERSON ON SALESPERSON.intEntityId = ARI.intEntitySalespersonId