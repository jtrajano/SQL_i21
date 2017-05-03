CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
	 intInvoiceId					= I.intInvoiceId
	,strInvoiceNumber				= I.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= C.strCustomerNumber
	,intEntityCustomerId			= C.[intEntityId]
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
	,intEntredById					= I.intEntityId
	,strEnteredBy					= EB.strName
	,dtmBatchDate					= --GL.dtmDate	
									  (
										SELECT TOP 1
											G.dtmDate
										FROM
											tblGLDetail G
										WHERE
											I.intInvoiceId = G.intTransactionId
											AND I.strInvoiceNumber = G.strTransactionId
											AND I.intAccountId = G.intAccountId
											AND G.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Customer Prepayment')
											AND G.ysnIsUnposted = 0
											AND G.strCode = 'AR'
										)
	,strBatchId						= CASE WHEN I.strTransactionType = 'Customer Prepayment' 
										THEN  (SELECT TOP 1 strBatchId FROM tblARPayment A 
												INNER JOIN (SELECT intPaymentId, intInvoiceId FROM tblARPaymentDetail ) B ON A.intPaymentId = B.intPaymentId 
												INNER JOIN (SELECT strTransactionId, strBatchId FROM tblGLDetail) C ON A.strRecordNumber = C.strTransactionId 
												WHERE B.intInvoiceId = I.intInvoiceId) 
										ELSE  
											--GL.strBatchId 
											(
											SELECT TOP 1
												G.strBatchId
											FROM
												tblGLDetail G
											WHERE
												I.intInvoiceId = G.intTransactionId
												AND I.strInvoiceNumber = G.strTransactionId
												AND I.intAccountId = G.intAccountId
												AND G.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Customer Prepayment')
												AND G.ysnIsUnposted = 0
												AND G.strCode = 'AR'
											)
										END   
	,strUserEntered					= --GL.strName
									  (
										SELECT TOP 1
											E.strName
										FROM
											tblGLDetail G
										INNER JOIN
											(SELECT intEntityId,
													strName
											 FROM tblEMEntity) E ON G.intEntityId = E.intEntityId
										WHERE
											I.intInvoiceId = G.intTransactionId
											AND I.strInvoiceNumber = G.strTransactionId
											AND I.intAccountId = G.intAccountId
											AND G.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Customer Prepayment')
											AND G.ysnIsUnposted = 0
											AND G.strCode = 'AR'
										)	
	,intEntityContactId				= I.intEntityContactId
	,strContactName					= EC.strName
	,strTicketNumbers				= dbo.fnARGetScaleTicketNumbersFromInvoice(I.intInvoiceId)
	,strCustomerReferences			= dbo.fnARGetCustomerReferencesFromInvoice(I.intInvoiceId)
	,ysnHasEmailSetup				= CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = I.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + I.strTransactionType + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	
	,strCurrencyDescription			= CUR.strDescription
FROM  (SELECT strType, [intEntityCustomerId], intCompanyLocationId, intTermId, intEntityContactId, intPaymentMethodId, [intEntitySalespersonId], intCurrencyId, intShipViaId,[intEntityId],
		intInvoiceId, strInvoiceNumber, intAccountId, strTransactionType, strPONumber, strBOLNumber, strComments, dtmDate, dtmDueDate, dtmPostDate, dtmShipDate, ysnPosted, ysnPaid,
		ysnProcessed, ysnRecurring, ysnForgiven, ysnCalculated, dblInvoiceTotal, dblDiscount, dblDiscountAvailable, dblInterest, dblAmountDue, dblPayment, dblInvoiceSubtotal, dblShipping, dblTax
	 FROM dbo.tblARInvoice WITH (NOLOCK)) AS I 
LEFT OUTER JOIN
	(SELECT TOP 1 strName, strEmail, intEntityContactId FROM vyuEMEntityContact WITH (NOLOCK)) EC ON I.intEntityContactId = EC.intEntityContactId
INNER JOIN
	(SELECT [intEntityId], strCustomerNumber FROM dbo.tblARCustomer WITH (NOLOCK)) AS C 
		ON I.[intEntityCustomerId] = C.[intEntityId] 
INNER JOIN
	(SELECT intEntityId,
			strName
	 FROM 
		dbo.tblEMEntity WITH (NOLOCK)) AS CE ON C.[intEntityId] = CE.intEntityId 
LEFT OUTER JOIN
	(SELECT intTermID,
			strTerm
	 FROM 
		dbo.tblSMTerm WITH (NOLOCK)) AS T ON I.intTermId = T.intTermID 
LEFT OUTER JOIN
	(SELECT intCompanyLocationId,
			strLocationName
	 FROM 
		dbo.tblSMCompanyLocation WITH (NOLOCK)) AS L ON I.intCompanyLocationId  = L.intCompanyLocationId 
LEFT OUTER JOIN
	(SELECT intPaymentMethodID,
			strPaymentMethod
	 FROM 
		dbo.tblSMPaymentMethod WITH (NOLOCK)) AS P ON I.intPaymentMethodId = P.intPaymentMethodID
LEFT OUTER JOIN
	(SELECT intEntityId,
			strShipVia
	 FROM 
		dbo.tblSMShipVia WITH (NOLOCK)) AS SV ON I.intShipViaId = SV.[intEntityId]
LEFT OUTER JOIN
	(SELECT intEntityId,
			strName
	 FROM 
		dbo.tblEMEntity WITH (NOLOCK)) AS SE ON I.[intEntitySalespersonId] = SE.intEntityId 
LEFT OUTER JOIN
	(SELECT intCurrencyID,
			strCurrency,
			strDescription
	 FROM 
		dbo.tblSMCurrency WITH (NOLOCK)) CUR ON I.intCurrencyId = CUR.intCurrencyID
LEFT OUTER JOIN
	(SELECT intEntityId, strName FROM dbo.tblEMEntity WITH (NOLOCK)) AS EB 
		ON I.[intEntityId] = EB.intEntityId