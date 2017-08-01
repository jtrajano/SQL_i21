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
	,dtmBatchDate					= I.dtmBatchDate
	,strBatchId						= CASE WHEN I.strTransactionType = 'Customer Prepayment' 
										   THEN PAYMENT.strBatchId
										   ELSE I.strBatchId
									  END
	,strUserEntered					= USERENTERED.strName
	,intEntityContactId				= I.intEntityContactId
	,strContactName					= EC.strName
	,strTicketNumbers				= dbo.fnARGetScaleTicketNumbersFromInvoice(I.intInvoiceId)
	,strCustomerReferences			= dbo.fnARGetCustomerReferencesFromInvoice(I.intInvoiceId)
	,ysnHasEmailSetup				= CASE WHEN EMAILSETUP.intEmailSetupCount > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	
	,strCurrencyDescription			= CUR.strDescription
FROM (SELECT strType, [intEntityCustomerId], intCompanyLocationId, intTermId, intEntityContactId, intPaymentMethodId, [intEntitySalespersonId], intCurrencyId, intShipViaId,[intEntityId],
		intInvoiceId, strInvoiceNumber, intAccountId, strTransactionType, strPONumber, strBOLNumber, strComments, dtmDate, dtmDueDate, dtmPostDate, dtmShipDate, ysnPosted, ysnPaid,
		ysnProcessed, ysnRecurring, ysnForgiven, ysnCalculated, dblInvoiceTotal, dblDiscount, dblDiscountAvailable, dblInterest, dblAmountDue, dblPayment, dblInvoiceSubtotal, dblShipping, dblTax,
	    strBatchId, dtmBatchDate, intPostedById
	 FROM dbo.tblARInvoice WITH (NOLOCK)) AS I 
INNER JOIN
	(SELECT [intEntityCustomerId], strCustomerNumber FROM dbo.tblARCustomer WITH (NOLOCK)) AS C 
		ON I.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	(SELECT intEntityId,
			strName
	 FROM 
		dbo.tblEMEntity WITH (NOLOCK)) AS CE ON C.[intEntityCustomerId] = CE.intEntityId 
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
	(SELECT intEntityShipViaId,
			strShipVia
	 FROM 
		dbo.tblSMShipVia WITH (NOLOCK)) AS SV ON I.intShipViaId = SV.[intEntityShipViaId]
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