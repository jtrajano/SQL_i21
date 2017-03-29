CREATE VIEW [dbo].[vyuARUnappliedCreditsRegister]
AS

SELECT * FROM
(
SELECT DISTINCT 
      C.strCustomerNumber
	, strName				= RTRIM(C.strCustomerNumber) + ' - ' + C.strName
	, I.intEntityCustomerId
	, strInvoiceNumber
	, strTransactionType	
	, L.strLocationName
	, dtmDate
	, dblAmount				= ISNULL(dblInvoiceTotal, 0) * -1
	, dblUsed				= ISNULL(PD.dblPayment, 0)
	, dblRemaining			= (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1
	, strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)	
    , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
    , strCompanyAddress		= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
FROM tblARInvoice I
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.[intEntityId] = CC.[intEntityId] AND ysnDefaultContact = 1) 
		ON I.intEntityCustomerId = C.[intEntityId]
	INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId	
WHERE I.ysnPosted = 1
AND I.ysnPaid = 0
AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
AND I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Customer Prepayment')
AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT DISTINCT 
      C.strCustomerNumber
	, strName				= RTRIM(C.strCustomerNumber) + ' - ' + C.strName
	, I.intEntityCustomerId
	, strInvoiceNumber
	, strTransactionType	
	, L.strLocationName
	, dtmDate
	, dblAmount				= ISNULL(dblInvoiceTotal, 0) * -1
	, dblUsed				= ISNULL(PD.dblPayment, 0)
	, dblRemaining			= (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1
	, strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)	
    , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
    , strCompanyAddress		= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
FROM tblARInvoice I
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.[intEntityId] = CC.[intEntityId] AND ysnDefaultContact = 1) 
		ON I.intEntityCustomerId = C.[intEntityId]
	INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
	INNER JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1
	LEFT JOIN (
		(SELECT SUM(PD.dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD 
				INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
WHERE I.ysnPosted = 1
AND I.ysnPaid = 0
AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
AND I.strTransactionType = 'Customer Prepayment'
AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
) AS A