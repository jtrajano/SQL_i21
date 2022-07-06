CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT intPaymentId				= P.intPaymentId
	 , strRecordNumber			= P.strRecordNumber
	 , intEntityId				= P.intEntityId
	 , intEntityCustomerId		= P.intEntityCustomerId
	 , intBankAccountId			= P.intBankAccountId
	 , strBankName				= LTRIM(RTRIM(B.strBankName))
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
	 , strAccountingPeriod      = AccPeriod.strPeriod
	 , ysnScheduledPayment		= ISNULL(P.ysnScheduledPayment, 0)
	 , dtmScheduledPayment		= P.dtmScheduledPayment
	 , strCreditCardStatus		= P.strCreditCardStatus
	 , strCreditCardNote		= P.strCreditCardNote
FROM tblARPayment P WITH (NOLOCK)
LEFT OUTER JOIN tblEMEntity EM WITH (NOLOCK) ON P.intEntityId = EM.intEntityId
LEFT OUTER JOIN tblSMPaymentMethod PM WITH (NOLOCK) ON P.intPaymentMethodId = PM.intPaymentMethodID
INNER JOIN tblEMEntity E WITH (NOLOCK) ON P.intEntityCustomerId = E.intEntityId
INNER JOIN tblARCustomer C WITH (NOLOCK) ON E.intEntityId = C.intEntityId
LEFT OUTER JOIN tblCMBankAccount BA WITH (NOLOCK) ON P.intBankAccountId = BA.intBankAccountId
LEFT JOIN tblCMBank B WITH (NOLOCK) ON B.intBankId = BA.intBankId
INNER JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON P.intLocationId = CL.intCompanyLocationId
LEFT OUTER JOIN tblEMEntity POSTEDBY WITH (NOLOCK) ON P.intPostedById = POSTEDBY.intEntityId
LEFT OUTER JOIN tblSMCurrency SMC WITH (NOLOCK) ON P.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN vyuARPaymentBankTransaction ARP ON ARP.intPaymentId = P.intPaymentId
LEFT JOIN tblGLFiscalYearPeriod AccPeriod ON P.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
LEFT JOIN (
     SELECT intPaymentId
          , dblDiscount = SUM(ISNULL(dblDiscount, 0))
     FROM dbo.tblARPaymentDetail WITH (NOLOCK)
     WHERE ISNULL(dblDiscount, 0) <> 0
     GROUP BY intPaymentId
) PD ON P.intPaymentId = PD.intPaymentId
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
