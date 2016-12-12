﻿CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
	 intInvoiceId					= I.intInvoiceId
	,strInvoiceNumber				= I.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= C.strCustomerNumber
	,intEntityCustomerId			= C.intEntityCustomerId
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
	,dblInvoiceTotal				= ISNULL(I.dblInvoiceTotal, 0)
	,dblDiscount					= ISNULL(I.dblDiscount,0)
	,dblDiscountAvailable			= ISNULL(I.dblDiscountAvailable,0)
	,dblInterest					= ISNULL(I.dblInterest,0)
	,dblAmountDue					= ISNULL(I.dblAmountDue,0)
	,dblPayment						= ISNULL(I.dblPayment, 0)
	,dblInvoiceSubtotal				= ISNULL(I.dblInvoiceSubtotal, 0)
	,dblShipping					= ISNULL(I.dblShipping, 0)
	,dblTax							= ISNULL(I.dblTax, 0)
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
											tblEMEntity E
												ON G.intEntityId = E.intEntityId
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
FROM         
	dbo.tblARInvoice AS I 
INNER JOIN
	dbo.tblARCustomer AS C 
		ON I.[intEntityCustomerId] = C.[intEntityCustomerId] 
LEFT OUTER JOIN
	(SELECT TOP 1 strName, strEmail, intEntityContactId FROM vyuEMEntityContact) EC ON I.intEntityContactId = EC.intEntityContactId	
INNER JOIN
	dbo.tblEMEntity AS CE 
		ON C.[intEntityCustomerId] = CE.intEntityId 
LEFT OUTER JOIN
	dbo.tblSMTerm AS T 
		ON I.intTermId = T.intTermID 
LEFT OUTER JOIN
	dbo.tblSMCompanyLocation AS L 
		ON I.intCompanyLocationId  = L.intCompanyLocationId 
LEFT OUTER JOIN
	dbo.tblSMPaymentMethod AS P 
		ON I.intPaymentMethodId = P.intPaymentMethodID
LEFT OUTER JOIN
	dbo.tblSMShipVia AS SV 
		ON I.intShipViaId = SV.[intEntityShipViaId]
LEFT OUTER JOIN
	dbo.tblEMEntity AS SE 
		ON I.[intEntitySalespersonId] = SE.intEntityId 
LEFT OUTER JOIN
	dbo.tblSMCurrency CUR
		ON I.intCurrencyId = CUR.intCurrencyID
LEFT OUTER JOIN
	dbo.tblEMEntity AS EB 
		ON I.[intEntityId] = EB.intEntityId
--LEFT OUTER JOIN
--	(
--	SELECT TOP 1
--		 G.intTransactionId
--		,G.strTransactionId
--		,G.intAccountId
--		,G.strTransactionType
--		,G.dtmDate
--		,G.strBatchId
--		,E.intEntityId
--		,E.strName
--	FROM
--		tblGLDetail G
--	LEFT OUTER JOIN
--		tblEMEntity E
--			ON G.intEntityId = E.intEntityId
--	WHERE
--		G.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Customer Prepayment')
--		AND G.ysnIsUnposted = 0
--		AND G.strCode = 'AR'
--	) GL
--		ON I.intInvoiceId = GL.intTransactionId
--		AND I.intAccountId = GL.intAccountId
--		AND I.strInvoiceNumber = GL.strTransactionId					 