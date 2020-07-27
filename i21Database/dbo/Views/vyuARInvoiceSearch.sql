CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
	 intInvoiceId					= I.intInvoiceId
	,strInvoiceNumber				= I.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= C.strCustomerNumber
	,intEntityCustomerId			= C.intEntityId
	,strTransactionType				= I.strTransactionType
	,strType						= CASE WHEN (I.strType = 'POS' AND (POS.intInvoiceId IS NOT NULL OR POSMixedTransactionCreditMemo.intCreditMemoId IS NOT NULL)) THEN ISNULL(POS.strEODNo,ISNULL(POSMixedTransactionCreditMemo.strEODNo,'Standard')) ELSE  ISNULL(I.strType, 'Standard') END
	,strPONumber					= I.strPONumber
	,strTerm						= T.strTerm
	,strBOLNumber					= I.strBOLNumber
	,intTermId						= I.intTermId
	,intAccountId					= I.intAccountId
	,dtmDate						= CAST(I.dtmDate AS DATE)
	,dtmDueDate						= I.dtmDueDate
	,dtmPostDate					= I.dtmPostDate
	,dtmShipDate					= I.dtmShipDate
	,ysnPosted						= I.ysnPosted
	,ysnPaid						= CASE WHEN (I.strTransactionType  IN ('Customer Prepayment') AND I.ysnPaid = 0)  THEN I.ysnPaidCPP ELSE I.ysnPaid END
	,ysnPaidCPP						= I.ysnPaidCPP
	,ysnProcessed					= I.ysnProcessed
	,ysnForgiven					= I.ysnForgiven
	,ysnCalculated					= I.ysnCalculated
	,ysnRecurring					= I.ysnRecurring
	,dblInvoiceTotal				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblInvoiceTotal, 0)
										   WHEN (I.strTransactionType  IN ('Customer Prepayment')) THEN CASE WHEN I.ysnRefundProcessed = 1 THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE 0 END
										   ELSE ISNULL(I.dblInvoiceTotal, 0) * -1 END
	,dblDiscount					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblDiscount,0)  ELSE  ISNULL(I.dblDiscount,0) * -1 END
	,dblDiscountAvailable			= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblDiscountAvailable,0)  ELSE  ISNULL(I.dblDiscountAvailable,0) * -1 END
	,dblInterest					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblInterest,0)  ELSE  ISNULL(I.dblInterest,0) * -1 END
	,dblAmountDue					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblAmountDue,0)  ELSE  ISNULL(I.dblAmountDue,0) * -1 END
	,dblPayment						= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblPayment, 0)
										   WHEN (I.strTransactionType  IN ('Customer Prepayment')) THEN CASE WHEN I.ysnRefundProcessed = 1 THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
										   ELSE CASE WHEN POS.intItemCount < 0 THEN ISNULL(POS.dblTotal,0)
												ELSE ISNULL(I.dblPayment, 0) * -1 END
									  END
	,dblInvoiceSubtotal				= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblInvoiceSubtotal, 0)  ELSE  ISNULL(I.dblInvoiceSubtotal, 0) * -1 END
	,dblShipping					= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblShipping, 0)  ELSE  ISNULL(I.dblShipping, 0) * -1 END
	,dblTax							= CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(I.dblTax, 0)  ELSE  ISNULL(I.dblTax, 0) * -1 END
	,intPaymentMethodId				= I.intPaymentMethodId
	,intCompanyLocationId			= I.intCompanyLocationId
	,strComments					= dbo.fnStripHtml(I.strComments)
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
	,dtmForgiveDate					= I.dtmForgiveDate
	,strSalesOrderNumber			= SO.strSalesOrderNumber
	,intBookId						= I.intBookId
	,intSubBookId					= I.intSubBookId
	,strBook						= BOOK.strBook
	,strSubBook						= SUBBOOK.strSubBook
	,blbSignature					= I.blbSignature
	,intTicketId					= SCALETICKETID.intTicketId
	,strPOSPayMethods				= PAYMETHODS.strPOSPayMethods
	,ysnProcessedToNSF				= ISNULL(ISNULL(PAYMENT.ysnProcessedToNSF, I.ysnProcessedToNSF), 0)
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
	SELECT TOP 1 strBatchId, A.ysnProcessedToNSF 
	FROM (select intPaymentId, ysnProcessedToNSF from dbo.tblARPayment WITH (NOLOCK))A 
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
LEFT OUTER JOIN (
	SELECT intCreditMemoId
         , strReceiptNumber
         , strEODNo
		 , intItemCount
		 , dblTotal
    FROM dbo.tblARPOS POS WITH (NOLOCK)
    INNER JOIN dbo.tblARPOSLog POSLOG WITH (NOLOCK) ON POS.intPOSLogId = POSLOG.intPOSLogId
    INNER JOIN dbo.tblARPOSEndOfDay EOD WITH (NOLOCK) ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId 
	WHERE intCreditMemoId IS NOT NULL
) POSMixedTransactionCreditMemo ON I.intInvoiceId = POSMixedTransactionCreditMemo.intCreditMemoId
AND I.strType = 'POS'
OUTER APPLY (
	SELECT TOP 1 strName
			   , strEmail
			   , intEntityId 
	FROM dbo.tblEMEntity WITH (NOLOCK) 
	WHERE I.intEntityContactId = intEntityId
) EC
OUTER APPLY (
	SELECT ysnHasEmailSetup = CASE WHEN COUNT(ETC.intEntityId)  > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	FROM tblEMEntityToContact ETC WITH (NOLOCK)
	INNER JOIN tblEMEntity EM WITH (NOLOCK) ON ETC.intEntityContactId = EM.intEntityId 
	WHERE ETC.intEntityId = I.intEntityCustomerId 
	  AND ISNULL(EM.strEmail, '') <> ''
	  AND strEmailDistributionOption LIKE '%' + I.strTransactionType + '%'
) EMAILSETUP
LEFT OUTER JOIN (
	SELECT intSalesOrderId
		 , strSalesOrderNumber
	FROM dbo.tblSOSalesOrder  
) SO ON I.intSalesOrderId = SO.intSalesOrderId 
LEFT JOIN (
	SELECT intRecordId	= SMT.intRecordId 
	     , ysnMailSent	= CASE WHEN COUNT(SMA.intTransactionId) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)  END 
	FROM tblSMTransaction SMT WITH (NOLOCK)
	INNER JOIN tblSMScreen SC WITH (NOLOCK) ON SMT.intScreenId = SC.intScreenId
	INNER JOIN tblSMActivity SMA WITH (NOLOCK) ON SMA.intTransactionId = SMT.intTransactionId 
	WHERE SC.strScreenName = 'Invoice'
	  AND SMA.strType = 'Email' 
	  AND SMA.strStatus = 'Sent'
	GROUP by SMT.intRecordId
) EMAILSTATUS ON I.intInvoiceId = EMAILSTATUS.intRecordId
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM (SELECT intTicketId, intInvoiceId FROM dbo.tblARInvoiceDetail WITH(NOLOCK) WHERE intTicketId IS NOT NULL) ID 		
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
		FROM (SELECT intTicketId, intInvoiceId FROM dbo.tblARInvoiceDetail WITH(NOLOCK) WHERE intTicketId IS NOT NULL) ID 		
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
OUTER APPLY (
	SELECT TOP 1 intTicketId
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	WHERE ID.intInvoiceId = I.intInvoiceId
	  AND ID.intTicketId IS NOT NULL
) SCALETICKETID
OUTER APPLY
(
SELECT strPOSPayMethods = LEFT(strPaymentMethod, LEN(strPaymentMethod) - 1)
FROM
	(SELECT DISTINCT CAST(PAYM.strPaymentMethod AS VARCHAR(200))  + ', '  
		FROM tblARPaymentDetail PAYD
		INNER JOIN tblARPayment PAY
		ON PAYD.intPaymentId = PAY.intPaymentId
		INNER JOIN tblSMPaymentMethod PAYM
		ON PAY.intPaymentMethodId = PAYM.intPaymentMethodID
		WHERE PAYD.intInvoiceId = I.intInvoiceId AND I.strType = 'POS'
		FOR XML PATH ('')
	) C (strPaymentMethod)
) PAYMETHODS

GO
