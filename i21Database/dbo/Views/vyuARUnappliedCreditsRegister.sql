CREATE VIEW [dbo].[vyuARUnappliedCreditsRegister]
AS
SELECT CREDITS.*
	 , strCustomerNumber	= CUSTOMER.strCustomerNumber
	 , strCustomerName		= CUSTOMER.strCustomerName
	 , strName				= CUSTOMER.strDisplayName
	 , strContact			= CUSTOMER.strContact
	 , strLocationName		= LOCATION.strLocationName
	 , strCompanyName		= COMPANY.strCompanyName
	 , strCompanyAddress	= COMPANY.strCompanyAddress
FROM (
	SELECT DISTINCT 
		  I.intEntityCustomerId
		, strInvoiceNumber
		, strTransactionType	
		, I.intCompanyLocationId
		, dtmDate
		, dblAmount				= ISNULL(dblInvoiceTotal, 0) * -1
		, dblUsed				= ISNULL(PD.dblPayment, 0)
		, dblRemaining			= (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment)
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
		) P ON PD.intPaymentId = P.intPaymentId
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId	
	WHERE I.ysnPosted = 1
	  AND I.ysnPaid = 0
	  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	  AND I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Customer Prepayment')
	  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

	UNION ALL

	SELECT DISTINCT 
		  I.intEntityCustomerId
		, strInvoiceNumber
		, strTransactionType	
		, I.intCompanyLocationId
		, dtmDate
		, dblAmount				= ISNULL(dblInvoiceTotal, 0) * -1
		, dblUsed				= ISNULL(PD.dblPayment, 0)
		, dblRemaining			= (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
	) P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment)
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND ysnInvoicePrepayment = 0
		) P ON PD.intPaymentId = P.intPaymentId
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	WHERE I.ysnPosted = 1
	  AND I.ysnPaid = 0
	  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	  AND I.strTransactionType = 'Customer Prepayment'
	  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
) CREDITS
INNER JOIN (
	SELECT intEntityCustomerId  = C.intEntityId
		 , strCustomerNumber	= C.strCustomerNumber
		 , strCustomerName		= E.strName
		 , strDisplayName       = RTRIM(C.strCustomerNumber) + ' - ' + E.strName
		 , strContact			= [dbo].fnARFormatCustomerAddress(CONTACT.strPhone, CONTACT.strEmail, BILLTO.strLocationName, BILLTO.strAddress, BILLTO.strCity, BILLTO.strState, BILLTO.strZipCode, BILLTO.strCountry, NULL, 0)
	FROM dbo.tblARCustomer C WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) E ON C.intEntityId = E.intEntityId
	INNER JOIN (
		SELECT CC.intEntityId
			 , strPhone
			 , strEmail
		FROM dbo.tblEMEntityToContact CC WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strPhone
				 , strEmail
			FROM dbo.tblEMEntity WITH (NOLOCK)
		) ECC ON CC.intEntityContactId = ECC.intEntityId
		WHERE ysnDefaultContact = 1
	) CONTACT ON C.intEntityId = CONTACT.intEntityId
	LEFT JOIN (
		SELECT intEntityLocationId
			 , strLocationName
			 , strAddress
			 , strCity
			 , strState
			 , strZipCode
			 , strCountry
		FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	) BILLTO ON C.intBillToId = BILLTO.intEntityLocationId
) CUSTOMER ON CREDITS.intEntityCustomerId = CUSTOMER.intEntityCustomerId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATION ON CREDITS.intCompanyLocationId = LOCATION.intCompanyLocationId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY