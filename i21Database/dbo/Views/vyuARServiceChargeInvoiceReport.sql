CREATE VIEW [dbo].[vyuARServiceChargeInvoiceReport]
AS
SELECT intInvoiceId				= ARI.intInvoiceId
	, intInvoiceDetailId		= ARID.intInvoiceDetailId	
	, strInvoiceNumber			= ARI.strInvoiceNumber
	, dtmDate					= ARI.dtmDate
	, dtmDueDate				= ARI.dtmDueDate
	, intTermId					= ARI.intTermId
	, strTerm					= SMT.strTerm
	, dblInvoiceTotal			= SUMMARY.dblTotal
	, dblBaseInvoiceTotal		= SUMMARY.dblBaseTotal
	, dblTotalDue				= ARID.dblTotal
	, dblBaseTotalDue			= ARID.dblBaseTotal
	, intEntityCustomerId		= ARI.intEntityCustomerId
	, strCustomerNumber			= CUSTOMER.strCustomerNumber
	, strCustomerName			= E.strName
	, strAccountNumber			= CUSTOMER.strAccountNumber
	, strCustomerAddress		= ISNULL(RTRIM(E.strName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(B.strAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(B.strCity), '') + ISNULL(RTRIM(', ' + B.strState), '') + ISNULL(RTRIM(', ' + B.strZipCode), '') + ISNULL(RTRIM(', ' + B.strCountry), '')
	, intCompanyLocationId		= SMCS.intCompanyLocationId
	, strCompanyName			= SMCS.strCompanyName
	, strCompanyPhone			= SMCS.strCompanyPhone
	, strCompanyFax				= SMCS.strCompanyFax
	, strCompanyEmail			= SMCS.strCompanyEmail
	, dtmLetterDate				= GETDATE()
	, strCreatedByName			= USERPOSTED.strName
	, strCreatedByPhone			= USERPOSTED.strPhone
	, strCreatedByEmail			= USERPOSTED.strEmail
	, strSalesPersonName		= SALESPERSON.strName
FROM tblARInvoice ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.intInvoiceId = ARID.intInvoiceId
INNER JOIN tblSMTerm SMT ON ARI.intTermId = SMT.intTermID
INNER JOIN tblARCustomer CUSTOMER ON ARI.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN tblEMEntity E ON CUSTOMER.intEntityId = E.intEntityId
LEFT JOIN tblEMEntityLocation B ON CUSTOMER.intEntityId = B.intEntityId AND B.ysnDefaultLocation = 1
LEFT JOIN tblEMEntity USERPOSTED ON USERPOSTED.intEntityId = ARI.intPostedById
LEFT JOIN tblEMEntity SALESPERSON ON SALESPERSON.intEntityId = ARI.intEntitySalespersonId
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
		, strCompanyAddress		= strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
		, strCompanyPhone		= strPhone
		, strCompanyFax			= strFax
		, strCompanyEmail		= strEmail
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) SMCS
WHERE ARI.strType = 'Service Charge'
  AND ARI.ysnForgiven = 0
  AND ARI.ysnPaid = 0  