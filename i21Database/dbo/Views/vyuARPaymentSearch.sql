CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT intPaymentId				= P.intPaymentId
	 , strRecordNumber			= P.strRecordNumber
	 , intEntityId				= P.intEntityId
	 , intEntityCustomerId		= P.intEntityCustomerId
	 , intBankAccountId			= P.intBankAccountId
	 , strBankName				= LTRIM(RTRIM(BA.strBankName))
	 , strBankAccountNo			= dbo.fnAESDecryptASym(BA.strBankAccountNo)
	 , strBankAccountNoEncrypt  = ISNULL(LTRIM(RTRIM(BA.strBankAccountNo)), '')
	 , strCustomerName			= LTRIM(RTRIM(E.strName))
	 , strCustomerNumber		= ISNULL(C.strCustomerNumber, E.strEntityNo)
	 , dtmDatePaid				= P.dtmDatePaid
	 , intPaymentMethodId		= P.intPaymentMethodId
	 , strPaymentMethod			= PM.strPaymentMethod
	 , dblAmountPaid			= P.dblAmountPaid
     , dblDiscount				= ISNULL(PD.dblDiscount, 0)
	 , ysnPosted				= P.ysnPosted
	 , strPaymentType			= 'Payment' COLLATE Latin1_General_CI_AS
	 , strInvoices				= P.strInvoices
	 , intLocationId			= P.intLocationId 
	 , strLocationName			= CL.strLocationName
	 , dtmBatchDate				= P.dtmBatchDate
	 , strBatchId				= P.strBatchId
	 , strUserEntered			= POSTEDBY.strName
	 , strEnteredBy				= EM.strName
	 , strTicketNumbers			= SCALETICKETS.strTicketNumbers
	 , strCustomerReferences	= CUSTOMERREFERENCES.strCustomerReferences
	 , intCurrencyId			= P.intCurrencyId
	 , strCurrency				= SMC.strCurrency
     , strCurrencyDescription	= SMC.strDescription
	 , strPaymentInfo			= P.strPaymentInfo
	 , ysnProcessedToNSF		= P.ysnProcessedToNSF
	 , strTransactionId			= ISNULL(ARP.strTransactionId, '')
	 , strAccountingPeriod      = AccPeriod.strAccountingPeriod
	 , ysnScheduledPayment		= ISNULL(P.ysnScheduledPayment, 0)
	 , dtmScheduledPayment		= P.dtmScheduledPayment
FROM (
	SELECT intPaymentId
		 , strRecordNumber 
		 , intEntityId
		 , intEntityCustomerId
		 , intBankAccountId
		 , dtmDatePaid
		 , intPaymentMethodId
		 , dblAmountPaid
		 , ysnPosted
		 , intLocationId
		 , intAccountId 
		 , intCurrencyId
		 , dtmBatchDate
		 , intPostedById
		 , strBatchId
		 , strPaymentInfo
		 , ysnProcessedToNSF
		 , intPeriodId
		 , strInvoices
		 , ysnScheduledPayment
		 , dtmScheduledPayment
	FROM dbo.tblARPayment WITH (NOLOCK)
) P 
LEFT JOIN (
     SELECT intPaymentId
          , dblDiscount = SUM(ISNULL(dblDiscount, 0))
     FROM dbo.tblARPaymentDetail WITH (NOLOCK)
     WHERE ISNULL(dblDiscount, 0) <> 0
     GROUP BY intPaymentId
) PD ON P.intPaymentId = PD.intPaymentId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) EM ON P.intEntityId = EM.intEntityId
LEFT OUTER JOIN (
	SELECT intPaymentMethodID
		 , strPaymentMethod 
	FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
INNER JOIN (
	SELECT intEntityId 
		 , strEntityNo
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON P.intEntityCustomerId = E.intEntityId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strCustomerNumber 
	FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON E.intEntityId = C.intEntityId
LEFT OUTER JOIN (
	SELECT intBankAccountId
		 , BA.intBankId
		 , strBankAccountNo
		 , B.strBankName 
	FROM dbo.tblCMBankAccount BA WITH (NOLOCK)
	INNER JOIN (
		SELECT intBankId
			 , strBankName 
		FROM dbo.tblCMBank WITH (NOLOCK)
	) B ON B.intBankId = BA.intBankId
) BA ON P.intBankAccountId = BA.intBankAccountId
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON P.intLocationId = CL.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) POSTEDBY ON P.intPostedById = POSTEDBY.intEntityId
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , strCurrency
		 , strDescription 
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) SMC ON P.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN vyuARPaymentBankTransaction ARP ON ARP.intPaymentId = P.intPaymentId
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(I.strTicketNumbers AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD WITH(NOLOCK)
		INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
		WHERE PD.intPaymentId = P.intPaymentId
		  AND I.strTicketNumbers IS NOT NULL
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS
OUTER APPLY (
	SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(I.strCustomerReferences AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD WITH(NOLOCK)
		INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
		WHERE PD.intPaymentId = P.intPaymentId
		  AND I.strCustomerReferences IS NOT NULL
		FOR XML PATH ('')
	) INV (strCustomerReference)
) CUSTOMERREFERENCES
LEFT JOIN (
	SELECT intGLFiscalYearPeriodId
		 , strAccountingPeriod = P.strPeriod
	FROM tblGLFiscalYearPeriod P	
) AccPeriod ON P.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
