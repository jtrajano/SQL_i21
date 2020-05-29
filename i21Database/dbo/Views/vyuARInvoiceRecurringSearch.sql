CREATE VIEW [dbo].[vyuARInvoiceRecurringSearch]
AS
SELECT     
	 intInvoiceId					= I.intInvoiceId
	,strInvoiceNumber				= I.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= C.strCustomerNumber
	,intEntityCustomerId			= C.intEntityId
	,strTransactionType				= I.strTransactionType
	,strType						= ISNULL(I.strType, 'Standard')
	,strPONumber					= I.strPONumber
	,strTerm						= T.strTerm
	,strBOLNumber					= I.strBOLNumber
	,intTermId						= I.intTermId
	,intAccountId					= I.intAccountId
	,dtmDate						= I.dtmDate
	,dtmDueDate						= I.dtmDueDate
	,dtmPostDate					= I.dtmPostDate
	,dtmShipDate					= I.dtmShipDate
	,ysnPosted						= I.ysnPosted
	,ysnPaid						= I.ysnPaid
	,ysnProcessed					= I.ysnProcessed
	,ysnForgiven					= I.ysnForgiven
	,ysnCalculated					= I.ysnCalculated
	,ysnRecurring					= I.ysnRecurring
	,dblInvoiceTotal				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblInvoiceTotal, 0)  ELSE  ISNULL(I.dblInvoiceTotal, 0) * -1 END
	,dblDiscount					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblDiscount,0)  ELSE  ISNULL(I.dblDiscount,0) * -1 END
	,dblDiscountAvailable			= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblDiscountAvailable,0)  ELSE  ISNULL(I.dblDiscountAvailable,0) * -1 END
	,dblInterest					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblInterest,0)  ELSE  ISNULL(I.dblInterest,0) * -1 END
	,dblAmountDue					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblAmountDue,0)  ELSE  ISNULL(I.dblAmountDue,0) * -1 END
	,dblPayment						= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblPayment, 0)  ELSE  ISNULL(I.dblPayment, 0) * -1 END
	,dblInvoiceSubtotal				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblInvoiceSubtotal, 0)  ELSE  ISNULL(I.dblInvoiceSubtotal, 0) * -1 END
	,dblShipping					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblShipping, 0)  ELSE  ISNULL(I.dblShipping, 0) * -1 END
	,dblTax							= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblTax, 0)  ELSE  ISNULL(I.dblTax, 0) * -1 END
	,intPaymentMethodId				= I.intPaymentMethodId
	,intCompanyLocationId			= I.intCompanyLocationId
	,strComments					= I.strComments
	,intCurrencyId					= I.intCurrencyId
	,strLocationName				= L.strLocationName
	,strPaymentMethod				= P.strPaymentMethod
	,strShipVia						= SV.strShipVia
	,strSalesPerson					= SE.strName
	,strCustomerEmail				= EC.strEmail
	,strCurrency					= CUR.strCurrency
	,intEnteredById					= I.intEntityId
	,strEnteredBy					= EB.strName
	,dtmBatchDate					= I.dtmBatchDate
	,strBatchId						= CASE WHEN I.strTransactionType = 'Customer Prepayment' 
										   THEN PAYMENT.strBatchId
										   ELSE I.strBatchId
									  END
	,strUserEntered					= USERENTERED.strName
	,intEntityContactId				= I.intEntityContactId
	,strContactName					= EC.strName
	,strTicketNumbers				= SCALETICKETS.strTicketNumbers
	,strCustomerReferences			= CUSTOMERREFERENCES.strCustomerReferences
	,ysnHasEmailSetup				= CASE WHEN EMAILSETUP.intEmailSetupCount > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	
	,strCurrencyDescription			= CUR.strDescription
	,dblWithholdingTax				= CASE WHEN (I.strTransactionType  IN ('Credit Memo','Customer Prepayment', 'Overpayment'))
									  THEN
									  CASE WHEN ysnPaid = 1 THEN (I.dblPayment - (I.dblPayment - (I.dblPayment * (dblWithholdPercent / 100)))) * -1 ELSE (I.dblAmountDue - (I.dblAmountDue - (I.dblAmountDue * (dblWithholdPercent / 100)))) * -1 END
									  ELSE
									  CASE WHEN ysnPaid = 1 THEN (I.dblPayment - (I.dblPayment - (I.dblPayment * (dblWithholdPercent / 100))))  ELSE I.dblAmountDue - (I.dblAmountDue - (I.dblAmountDue * (dblWithholdPercent / 100))) END
									  END
	,ysnMailSent					= CASE WHEN ISNULL(EMAILSTATUS.intTransactionCount, 0) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)  END 
	,strStatus						= CASE WHEN EMAILSETUP.intEmailSetupCount > 0 THEN 'Ready' ELSE 'Email not Configured.' END	COLLATE Latin1_General_CI_AS
	,dtmForgiveDate					= I.dtmForgiveDate
	,strSalesOrderNumber			= SO.strSalesOrderNumber
	,dtmAccountingPeriod			= I.dtmAccountingPeriod

	, intRecurringId = RECUR.intRecurringId
	, strFrequency = RECUR.strFrequency
	, dtmLastProcess = RECUR.dtmLastProcess
	, dtmNextProcess = RECUR.dtmNextProcess
	, dtmStartDate = RECUR.dtmStartDate
	, dtmEndDate = RECUR.dtmEndDate
	, intIteration = RECUR.intIteration
	, intWarningDays = RECUR.intWarningDays
	, strResponsibleUser = RECUR.strResponsibleUser
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
		 , strCustomerNumber 
	FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON I.intEntityCustomerId = C.intEntityId
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) CE ON C.intEntityId = CE.intEntityId 
LEFT OUTER JOIN (
	SELECT intTermID
		 , strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) T ON I.intTermId = T.intTermID 
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
		 , dblWithholdPercent
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) L ON I.intCompanyLocationId  = L.intCompanyLocationId 
LEFT OUTER JOIN (
	SELECT intPaymentMethodID
		 , strPaymentMethod
	FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
) P ON I.intPaymentMethodId = P.intPaymentMethodID
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strShipVia
	FROM dbo.tblSMShipVia WITH (NOLOCK)
) SV ON I.intShipViaId = SV.intEntityId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) AS SE ON I.intEntitySalespersonId = SE.intEntityId 
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
) EB ON I.intEntityId = EB.intEntityId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERENTERED ON USERENTERED.intEntityId = I.intPostedById
OUTER APPLY (
	SELECT TOP 1 strBatchId 
	FROM dbo.tblARPayment A WITH (NOLOCK)
	INNER JOIN (SELECT intPaymentId
					 , intInvoiceId 
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) B ON A.intPaymentId = B.intPaymentId 
	WHERE B.intInvoiceId = I.intInvoiceId
) PAYMENT
OUTER APPLY (
	SELECT TOP 1 strName
			   , strEmail
			   , intEntityContactId 
	FROM dbo.vyuEMEntityContact WITH (NOLOCK) 
	WHERE I.intEntityContactId = intEntityContactId
) EC
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE intCustomerEntityId = I.intEntityCustomerId 
	  AND ISNULL(strEmail, '') <> '' 
	  AND strEmailDistributionOption LIKE '%' + I.strTransactionType + '%'
) EMAILSETUP
LEFT OUTER JOIN (
	SELECT intSalesOrderId
		 , strSalesOrderNumber
	FROM dbo.tblSOSalesOrder 
) SO ON I.intSalesOrderId = SO.intSalesOrderId
OUTER APPLY (
	SELECT intTransactionCount = COUNT(*) 
	FROM tblSMTransaction SMT 
	INNER JOIN tblSMActivity SMA on SMA.intTransactionId = SMT.intTransactionId 
	WHERE SMT.intRecordId = intInvoiceId 
	  AND SMA.strType = 'Email' 
	  AND SMA.strStatus = 'Sent'
) EMAILSTATUS
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
		INNER JOIN (
			SELECT intTicketId
				 , strTicketNumber 
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
			SELECT intTicketId
				 , strCustomerReference 
			FROM dbo.tblSCTicket WITH(NOLOCK)
			WHERE ISNULL(strCustomerReference, '') <> ''
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intInvoiceId = I.intInvoiceId
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strCustomerReference
		FOR XML PATH ('')
	) INV (strCustomerReference)
) CUSTOMERREFERENCES
LEFT OUTER JOIN (
	SELECT intTransactionId
		, intRecurringId
		, strFrequency
		, dtmLastProcess
		, dtmNextProcess
		, dtmStartDate
		, dtmEndDate
		, intIteration
		, intWarningDays
		, strResponsibleUser
	FROM tblSMRecurringTransaction
	WHERE strTransactionType = 'Invoice'
) RECUR ON RECUR.intTransactionId = I.intInvoiceId
WHERE I.ysnRecurring = 1