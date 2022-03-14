CREATE VIEW [dbo].[vyuARInvoicePaymentInfo]
AS
SELECT intInvoiceId				= I.intInvoiceId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , intEntityCustomerId		= I.intEntityCustomerId 
	 , strCustomerName			= C.strName
	 , strCustomerNumber		= C.strCustomerNumber
	 , intEntityContactId		= I.intEntityContactId
	 , strContactName			= EC.strName
	 , strType					= I.strType
	 , strTransactionType		= I.strTransactionType
	 , intTermId				= I.intTermId
	 , strTerm					= T.strTerm
	 , strBOLNumber				= I.strBOLNumber
	 , strTicketNumbers			= SCALETICKETS.strTicketNumbers
	 , strCustomerReferences	= CUSTOMERREFERENCES.strCustomerReferences
	 , dtmDate					= I.dtmDate
	 , dblInvoiceTotal			= I.dblInvoiceTotal
	 , dtmDueDate				= I.dtmDueDate
	 , intPaymentId				= CASE WHEN I.strTransactionType = 'Cash' THEN BT.intTransactionId ELSE P.intPaymentId END
	 , strRecordNumber			= CASE WHEN I.strTransactionType = 'Cash' THEN BT.strTransactionId ELSE P.strRecordNumber END
	 , dblDiscount				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblDiscount,0)  ELSE  ISNULL(I.dblDiscount,0) * -1 END
	 , dblDiscountAvailable		= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblDiscountAvailable,0)  ELSE  ISNULL(I.dblDiscountAvailable,0) * -1 END
	 , dblInterest				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblInterest,0)  ELSE  ISNULL(I.dblInterest,0) * -1 END
	 , dblAmountDue				= I.dblAmountDue
	 , dblPayment				= CASE WHEN I.strTransactionType = 'Cash' THEN I.dblPayment ELSE P.dblPayment END 
	 , intPaymentMethodId		= CASE WHEN I.strTransactionType = 'Cash' THEN I.intPaymentMethodId ELSE P.intPaymentMethodId END
	 , strPaymentMethod			= PM.strPaymentMethod
	 , dtmDatePaid				= CASE WHEN I.strTransactionType = 'Cash' THEN I.dtmPostDate ELSE P.dtmDatePaid END
	 , ysnPosted				= I.ysnPosted
	 , dtmPostDate				= I.dtmPostDate
	 , ysnPaid					= I.ysnPaid
	 , ysnProcessed				= I.ysnProcessed
	 , ysnRecurring				= I.ysnRecurring
	 , strComments				= I.strComments
	 , strBatchId				= CASE WHEN I.strTransactionType = 'Customer Prepayment' THEN P.strBatchId ELSE I.strBatchId END
	 , intCompanyLocationId		= I.intCompanyLocationId
	 , strLocationName			= L.strLocationName
	 , strEnteredBy				= EB.strName
	 , strUserEntered			= USERENTERED.strName
	 , intCurrencyId			= I.intCurrencyId
	 , strCurrency				= CUR.strCurrency
	 , strPaymentInfo			= P.strPaymentInfo
	 , strNotes					= P.strNotes
	 , strAccountingPeriod		= AccPeriod.strAccountingPeriod
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN (
	SELECT AP.intPaymentId
		 , APD.intInvoiceId
		 , AP.ysnPosted
		 , AP.intPaymentMethodId
		 , APD.dblPayment
		 , APD.dblAmountDue
		 , AP.strBatchId
		 , AP.strRecordNumber
		 , AP.dtmDatePaid
		 , AP.strPaymentInfo
		 , AP.strNotes
	FROM tblARPayment AP
	LEFT JOIN (
		SELECT intPaymentId
			, intInvoiceId
			, dblPayment
			, dblAmountDue 
		FROM tblARPaymentDetail
	) APD ON APD.intPaymentId = AP.intPaymentId	
	WHERE AP.ysnPosted = 1
) P ON P.intInvoiceId = I.intInvoiceId
LEFT JOIN (
	SELECT intPaymentMethodID
		 , strPaymentMethod 
	FROM tblSMPaymentMethod
) PM ON PM.intPaymentMethodID = CASE WHEN I.strTransactionType = 'Cash' THEN I.intPaymentMethodId ELSE P.intPaymentMethodId END
INNER JOIN (
	SELECT EME.intEntityId
		 , EME.strName
		 , ARC.strCustomerNumber
	FROM dbo.tblEMEntity EME WITH (NOLOCK)  
	LEFT JOIN (
		SELECT intEntityId
			 , strCustomerNumber
		FROM dbo.tblARCustomer WITH (NOLOCK)
	) ARC ON EME.intEntityId = ARC.intEntityId
) C ON I.intEntityCustomerId = C.intEntityId
OUTER APPLY (
	SELECT TOP 1 strName , strEmail, intEntityContactId 
	FROM dbo.vyuEMEntityContact WITH (NOLOCK) 
	WHERE I.intEntityContactId = intEntityContactId
) EC
LEFT OUTER JOIN (
	SELECT intTermID, strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) T ON I.intTermId = T.intTermID
INNER JOIN (
	SELECT intCompanyLocationId
			, strLocationName
			, dblWithholdPercent
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) L ON I.intCompanyLocationId  = L.intCompanyLocationId  
LEFT JOIN (
	SELECT intInvoiceId		= ID.intInvoiceId
		 , strTicketNumbers = STRING_AGG(T.strTicketNumber, ', ')
	FROM (
		SELECT DISTINCT ID.intInvoiceId
			 , ID.intTicketId 
		FROM tblARInvoiceDetail ID
		WHERE ID.intTicketId IS NOT NULL
		GROUP BY ID.intInvoiceId, ID.intTicketId
	) ID
	INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
	GROUP BY ID.intInvoiceId
) SCALETICKETS ON SCALETICKETS.intInvoiceId = I.intInvoiceId
LEFT JOIN (
	SELECT intInvoiceId				= ID.intInvoiceId
		 , strCustomerReferences	= STRING_AGG(T.strCustomerReference, ', ')
	FROM (
		SELECT DISTINCT ID.intInvoiceId
			 , ID.intTicketId 
		FROM tblARInvoiceDetail ID
		WHERE ID.intTicketId IS NOT NULL
		GROUP BY ID.intInvoiceId, ID.intTicketId
	) ID
	INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
	WHERE T.strCustomerReference IS NOT NULL
	  AND T.strCustomerReference <> ''
	GROUP BY ID.intInvoiceId
) CUSTOMERREFERENCES ON CUSTOMERREFERENCES.intInvoiceId = I.intInvoiceId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) EB ON I.intEntityId = EB.intEntityId
LEFT OUTER JOIN (
	SELECT intCurrencyID
		  , strCurrency
		 , strDescription
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CUR ON I.intCurrencyId = CUR.intCurrencyID
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERENTERED ON USERENTERED.intEntityId = I.intPostedById
LEFT JOIN (
	SELECT intGLFiscalYearPeriodId
		 , strAccountingPeriod = P.strPeriod
	FROM tblGLFiscalYearPeriod P	
) AccPeriod ON I.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
LEFT JOIN tblCMUndepositedFund UF ON I.intInvoiceId = UF.intSourceTransactionId AND I.strInvoiceNumber = UF.strSourceTransactionId
LEFT JOIN tblCMBankTransaction BT ON UF.intBankDepositId = BT.intTransactionId AND BT.intBankTransactionTypeId = 1
WHERE ((P.intPaymentId IS NOT NULL AND I.strTransactionType <> 'Cash') OR I.strTransactionType = 'Cash')