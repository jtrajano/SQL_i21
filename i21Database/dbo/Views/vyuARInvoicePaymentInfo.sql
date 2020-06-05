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
	 , intPaymentId				= P.intPaymentId
	 , strRecordNumber			= P.strRecordNumber
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
	 , dtmAccountingPeriod		= AccPeriod.dtmAccountingPeriod
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
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
		INNER JOIN (
			SELECT intTicketId, strTicketNumber 
			FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intInvoiceId = I.intInvoiceId
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
			SELECT intTicketId, strCustomerReference 
			FROM dbo.tblSCTicket WITH(NOLOCK)
			WHERE ISNULL(strCustomerReference, '') <> ''
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intInvoiceId = I.intInvoiceId
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strCustomerReference
		FOR XML PATH ('')
	) INV (strCustomerReference)
) CUSTOMERREFERENCES
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
OUTER APPLY(
	SELECT dtmAccountingPeriod = dtmEndDate from tblGLFiscalYearPeriod P
	WHERE I.intPeriodId = P.intGLFiscalYearPeriodId
) AccPeriod
WHERE ((P.intPaymentId IS NOT NULL AND I.strTransactionType <> 'Cash') OR I.strTransactionType = 'Cash')