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
	 , dtmAccountingPeriod      = CASE WHEN ysnPosted = 1 
								  THEN DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, P.dtmDatePaid) + 1, 0))
								  ELSE NULL END
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
											   AND ARP.strRecordNumber = P.strRecordNumber	
OUTER APPLY (
	SELECT strTransactionId = LEFT(strTransactionId, LEN(strTransactionId) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTransactionId AS VARCHAR(200))  + ', '
		FROM (
			SELECT strTransactionId = strInvoiceNumber
			FROM dbo.tblARInvoice I WITH(NOLOCK)
			INNER JOIN (
				SELECT intInvoiceId
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
				WHERE intPaymentId = P.intPaymentId
				  AND intInvoiceId IS NOT NULL
				  AND dblPayment <> 0
			) ARDETAILS ON I.intInvoiceId = ARDETAILS.intInvoiceId

			UNION ALL

			SELECT strTransactionId = strBillId
			FROM dbo.tblAPBill BILL WITH(NOLOCK)
			INNER JOIN (
				SELECT intBillId
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
				WHERE intPaymentId = P.intPaymentId
				  AND intBillId IS NOT NULL
				  AND dblPayment <> 0
			) BILLDETAILS ON BILL.intBillId = BILLDETAILS.intBillId
		) T		
		FOR XML PATH ('')
	) TRANS (strTransactionId)
) TRANSACTIONS
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)
		INNER JOIN (
			SELECT intInvoiceId
			FROM dbo.tblARPaymentDetail WITH (NOLOCK)
			WHERE intPaymentId = P.intPaymentId
		) DETAILS ON ID.intInvoiceId = DETAILS.intInvoiceId
		INNER JOIN (
			SELECT intTicketId
				 , strTicketNumber 
			FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS
OUTER APPLY (
	SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strCustomerReference AS VARCHAR(200))  + ', '
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)
		INNER JOIN (
			SELECT intInvoiceId
			FROM dbo.tblARPaymentDetail WITH (NOLOCK)
			WHERE intPaymentId = P.intPaymentId
		) DETAILS ON ID.intInvoiceId = DETAILS.intInvoiceId
		INNER JOIN (
			SELECT intTicketId
				 , strCustomerReference 
			FROM dbo.tblSCTicket WITH(NOLOCK)
			WHERE ISNULL(strCustomerReference, '') <> ''
		) T ON ID.intTicketId = T.intTicketId
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strCustomerReference
		FOR XML PATH ('')
	) INV (strCustomerReference)
) CUSTOMERREFERENCES