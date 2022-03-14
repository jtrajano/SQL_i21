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
	 , strInvoices				= TRANSACTIONS.strTransactionId
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
FROM tblARPayment P WITH (NOLOCK)
INNER JOIN tblEMEntity E WITH (NOLOCK) ON P.intEntityCustomerId = E.intEntityId
LEFT JOIN tblEMEntity EM WITH (NOLOCK) ON P.intEntityId = EM.intEntityId
LEFT JOIN tblSMPaymentMethod PM WITH (NOLOCK) ON P.intPaymentMethodId = PM.intPaymentMethodID
LEFT JOIN tblARCustomer C WITH (NOLOCK) ON E.intEntityId = C.intEntityId
LEFT JOIN tblCMBankAccount BA WITH (NOLOCK) ON P.intBankAccountId = BA.intBankAccountId
LEFT JOIN tblCMBank B WITH (NOLOCK) ON B.intBankId = BA.intBankId
LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON P.intLocationId = CL.intCompanyLocationId
LEFT JOIN tblEMEntity POSTEDBY WITH (NOLOCK) ON P.intPostedById = POSTEDBY.intEntityId
LEFT JOIN tblSMCurrency SMC WITH (NOLOCK) ON P.intCurrencyId = SMC.intCurrencyID
LEFT JOIN tblGLFiscalYearPeriod AccPeriod ON P.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
LEFT JOIN vyuARPaymentBankTransaction ARP ON ARP.intPaymentId = P.intPaymentId AND ARP.strRecordNumber = P.strRecordNumber	
LEFT JOIN (
     SELECT intPaymentId
          , dblDiscount = SUM(dblDiscount)
     FROM dbo.tblARPaymentDetail WITH (NOLOCK)
     WHERE dblDiscount <> 0
     GROUP BY intPaymentId
) PD ON P.intPaymentId = PD.intPaymentId
LEFT JOIN (
	SELECT intPaymentId		= PD.intPaymentId
		 , strTransactionId	= STRING_AGG(CAST(PD.strTransactionNumber AS NVARCHAR(MAX)), ', ')
	FROM tblARPaymentDetail PD
	WHERE PD.dblPayment <> 0 
	  AND PD.strTransactionNumber <> ''
	  AND PD.strTransactionNumber IS NOT NULL
	GROUP BY PD.intPaymentId
) TRANSACTIONS ON TRANSACTIONS.intPaymentId = P.intPaymentId
LEFT JOIN (
	SELECT intPaymentId		= PD.intPaymentId
		 , strTicketNumbers	= STRING_AGG(ID.strTicketNumber, ', ')
	FROM tblARPaymentDetail PD
	INNER JOIN (
		SELECT DISTINCT ID.intInvoiceId
			          , T.strTicketNumber 
		FROM tblARInvoiceDetail ID
		INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
		WHERE T.strTicketNumber IS NOT NULL
		  AND T.strTicketNumber <> ''
		  AND ID.intTicketId IS NOT NULL
		GROUP BY ID.intInvoiceId, T.strTicketNumber
	) ID ON PD.intInvoiceId = ID.intInvoiceId	
	GROUP BY PD.intPaymentId
) SCALETICKETS ON SCALETICKETS.intPaymentId = P.intPaymentId
LEFT JOIN (
	SELECT intPaymentId				= PD.intPaymentId
		 , strCustomerReferences	= STRING_AGG(ID.strCustomerReference, ', ')
	FROM tblARPaymentDetail PD
	INNER JOIN (
		SELECT DISTINCT ID.intInvoiceId
			          , T.strCustomerReference 
		FROM tblARInvoiceDetail ID
		INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
		WHERE T.strCustomerReference IS NOT NULL
		  AND T.strCustomerReference <> ''
		  AND ID.intTicketId IS NOT NULL
		GROUP BY ID.intInvoiceId, T.strCustomerReference
	) ID ON PD.intInvoiceId = ID.intInvoiceId	
	GROUP BY PD.intPaymentId
) CUSTOMERREFERENCES ON CUSTOMERREFERENCES.intPaymentId = P.intPaymentId

