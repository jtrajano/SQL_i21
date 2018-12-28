CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
	 intInvoiceId					= I.intInvoiceId
	,strInvoiceNumber				= I.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= C.strCustomerNumber
	,intEntityCustomerId			= C.intEntityId
	,strTransactionType				= I.strTransactionType
	,strType						= CASE WHEN (I.strType = 'POS' AND POS.intInvoiceId IS NOT NULL) THEN ISNULL(POS.strEODNo,'Standard') ELSE  ISNULL(I.strType, 'Standard') END
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
	,dblInvoiceTotal				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblInvoiceTotal, 0)  ELSE  ISNULL(I.dblInvoiceTotal, 0) * -1 END
	,dblDiscount					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblDiscount,0)  ELSE  ISNULL(I.dblDiscount,0) * -1 END
	,dblDiscountAvailable			= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblDiscountAvailable,0)  ELSE  ISNULL(I.dblDiscountAvailable,0) * -1 END
	,dblInterest					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblInterest,0)  ELSE  ISNULL(I.dblInterest,0) * -1 END
	,dblAmountDue					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblAmountDue,0)  ELSE  ISNULL(I.dblAmountDue,0) * -1 END
	,dblPayment						= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) 
												THEN ISNULL(I.dblPayment, 0)
												ELSE CASE WHEN POS.intItemCount < 0 THEN ISNULL(POS.dblTotal,0) ELSE ISNULL(I.dblPayment, 0) * -1 END
												END
	,dblInvoiceSubtotal				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblInvoiceSubtotal, 0)  ELSE  ISNULL(I.dblInvoiceSubtotal, 0) * -1 END
	,dblShipping					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblShipping, 0)  ELSE  ISNULL(I.dblShipping, 0) * -1 END
	,dblTax							= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblTax, 0)  ELSE  ISNULL(I.dblTax, 0) * -1 END
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
	,intEntredById					= I.intEntityId
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
	,ysnHasEmailSetup				= EMAILSETUP.ysnHasEmailSetup --CASE WHEN EMAILSETUP.intEmailSetupCount > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	
	,strCurrencyDescription			= CUR.strDescription
	,dblWithholdingTax				= CASE WHEN (I.strTransactionType  IN ('Credit Memo','Customer Prepayment', 'Overpayment'))
									  THEN
									  CASE WHEN ysnPaid = 1 THEN (I.dblPayment - (I.dblPayment - (I.dblPayment * (dblWithholdPercent / 100)))) * -1 ELSE (I.dblAmountDue - (I.dblAmountDue - (I.dblAmountDue * (dblWithholdPercent / 100)))) * -1 END
									  ELSE
									  CASE WHEN ysnPaid = 1 THEN (I.dblPayment - (I.dblPayment - (I.dblPayment * (dblWithholdPercent / 100))))  ELSE I.dblAmountDue - (I.dblAmountDue - (I.dblAmountDue * (dblWithholdPercent / 100))) END
									  END
	,ysnMailSent					= isnull(EMAILSTATUS.ysnMailSent, 0)--CASE WHEN ISNULL(EMAILSTATUS.intTransactionCount, 0) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)  END 
	,strStatus						= CASE WHEN EMAILSETUP.ysnHasEmailSetup = 1 THEN 'Ready' ELSE 'Email not Configured.' END COLLATE Latin1_General_CI_AS
	,dtmForgiveDate					=I.dtmForgiveDate
	,strSalesOrderNumber			=SO.strSalesOrderNumber
	,intBookId						=I.intBookId
	,intSubBookId					=I.intSubBookId
	,strBook						=BOOK.strBook
	,strSubBook						=SUBBOOK.strSubBook
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
LEFT OUTER JOIN (
	SELECT intBookId
		 , strBook 
	FROM dbo.tblCTBook WITH (NOLOCK)
) BOOK ON BOOK.intBookId = I.intBookId
LEFT OUTER JOIN (
	SELECT intSubBookId
		 , strSubBook
	FROM dbo.tblCTSubBook WITH (NOLOCK)
) SUBBOOK ON SUBBOOK.intSubBookId = I.intSubBookId
OUTER APPLY (
	SELECT TOP 1 strBatchId 
	FROM (select intPaymentId from dbo.tblARPayment WITH (NOLOCK))A 
	INNER JOIN (SELECT intPaymentId
					 , intInvoiceId 
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) B ON A.intPaymentId = B.intPaymentId 
	WHERE B.intInvoiceId = I.intInvoiceId
) PAYMENT
LEFT OUTER JOIN (
    SELECT intInvoiceId
         , strReceiptNumber
         , strEODNo
		 , intItemCount
		 , dblTotal
    FROM dbo.tblARPOS POS WITH (NOLOCK)
    INNER JOIN dbo.tblARPOSLog POSLOG WITH (NOLOCK) ON POS.intPOSLogId = POSLOG.intPOSLogId
    INNER JOIN dbo.tblARPOSEndOfDay EOD WITH (NOLOCK) ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
) POS ON I.intInvoiceId = POS.intInvoiceId 
     AND I.strType = 'POS'
OUTER APPLY (
	SELECT TOP 1 strName
			   , strEmail
			   , intEntityId 
	--FROM dbo.vyuEMEntityContact WITH (NOLOCK) 
	FROM dbo.tblEMEntity WITH (NOLOCK) 
	WHERE I.intEntityContactId = intEntityId
) EC
OUTER APPLY (
	--SELECT intEmailSetupCount = COUNT(intCustomerEntityId) 
	--FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	--WHERE intCustomerEntityId = I.intEntityCustomerId 
	--  AND ISNULL(strEmail, '') <> '' 
	--  AND strEmailDistributionOption LIKE '%' + I.strTransactionType + '%'
	select --intEmailSetupCount  = count(a.intEntityId),
		ysnHasEmailSetup = CASE WHEN  count(a.intEntityId)  > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
		from 
		tblEMEntityToContact a 
			join tblEMEntity b 
				on a.intEntityContactId = b.intEntityId 
		where a.intEntityId = I.intEntityCustomerId 
		and (b.strEmail is not null and isnull(b.strEmail, '') <> '' )	
	  AND strEmailDistributionOption LIKE '%' + I.strTransactionType + '%'
) EMAILSETUP
LEFT OUTER JOIN (
	SELECT intSalesOrderId
		 , strSalesOrderNumber
	FROM dbo.tblSOSalesOrder  
) SO ON I.intSalesOrderId = SO.intSalesOrderId 
left join (
	SELECT 		
		--intTransactionCount = COUNT(SMA.intTransactionId),
		id = SMT.intRecordId ,
		ysnMailSent = CASE WHEN COUNT(SMA.intTransactionId) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)  END 
	FROM (select intRecordId, intTransactionId, intScreenId from tblSMTransaction WITH (NOLOCK)) SMT 
	INNER JOIN (select intScreenId from tblSMScreen where strScreenName = 'Invoice' )SC ON SMT.intScreenId = SC.intScreenId
	INNER JOIN (select intTransactionId, strType, strStatus from tblSMActivity WITH (NOLOCK) where strType = 'Email' and strStatus = 'Sent') SMA on SMA.intTransactionId = SMT.intTransactionId 
	GROUP by SMT.intRecordId

	--SELECT intTransactionCount = COUNT(SMA.intTransactionId) 
	--FROM tblSMTransaction SMT 
	--INNER JOIN tblSMActivity SMA on SMA.intTransactionId = SMT.intTransactionId 
	--WHERE SMT.intRecordId = I.intInvoiceId 
	--  AND SMA.strType = 'Email' 
	--  AND SMA.strStatus = 'Sent'
	--  and SMT.intScreenId = 48
) EMAILSTATUS
	on I.intInvoiceId = EMAILSTATUS.id
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM (select intTicketId, intInvoiceId from dbo.tblARInvoiceDetail WITH(NOLOCK) where intTicketId is not null ) ID 		
		INNER JOIN (
			SELECT intTicketId
				 , strTicketNumber 
			FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intInvoiceId = I.intInvoiceId  and ID.intTicketId is not null
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS
OUTER APPLY (
	SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strCustomerReference AS VARCHAR(200))  + ', '
		FROM (select intTicketId, intInvoiceId from dbo.tblARInvoiceDetail WITH(NOLOCK) where intTicketId is not null ) ID 		
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


GO
