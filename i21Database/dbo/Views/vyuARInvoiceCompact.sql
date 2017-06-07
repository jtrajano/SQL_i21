CREATE VIEW [dbo].[vyuARInvoiceCompact]
AS
SELECT     
	 intInvoiceId					= ARI.intInvoiceId
	,strInvoiceNumber				= ARI.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= ARC.strCustomerNumber
	,intEntityCustomerId			= ARC.[intEntityId]
	,strTransactionType				= ARI.strTransactionType
	,strType						= ISNULL(ARI.strType, 'Standard')	
	,dtmDate						= ARI.dtmDate
	,dtmDueDate						= ARI.dtmDueDate
	,dtmPostDate					= ARI.dtmPostDate
	,dtmShipDate					= ARI.dtmShipDate
	,ysnPosted						= ARI.ysnPosted
	,ysnPaid						= ARI.ysnPaid
	,ysnProcessed					= ARI.ysnProcessed
	,ysnForgiven					= ARI.ysnForgiven
	,ysnCalculated					= ARI.ysnCalculated
	,dblInvoiceTotal				= ISNULL(ARI.dblInvoiceTotal, 0)
	,dblDiscount					= ISNULL(ARI.dblDiscount, 0)
	,dblDiscountAvailable			= ISNULL(ARI.dblDiscountAvailable, 0)
	,dblInterest					= ISNULL(ARI.dblInterest, 0)
	,dblAmountDue					= ISNULL(ARI.dblAmountDue, 0)
	,dblPayment						= ISNULL(ARI.dblPayment, 0)
	,dblInvoiceSubtotal				= ISNULL(ARI.dblInvoiceSubtotal, 0)
	,dblShipping					= ISNULL(ARI.dblShipping, 0)
	,dblTax							= ISNULL(ARI.dblTax, 0)
	,dblPaymentAmount				= 0.000000
	,intAccountId					= ARI.intAccountId
	,strAccountId					= GLA.strAccountId
	,intCompanyLocationId			= ARI.intCompanyLocationId	
	,strLocationName				= SML.strLocationName
	,intPaymentMethodId				= ARC.intPaymentMethodId	
	,strPaymentMethod				= SMP.strPaymentMethod
	,strCustomerEmail				= E.strEmail
	,intCurrencyId					= ARI.intCurrencyId
	,strCurrency					= SMC.strCurrency
	,intTermId						= ARI.intTermId
	,strTerm						= SMT.strTerm
	,strTermType					= SMT.strType 
	,intTermDiscountDay				= SMT.intDiscountDay 
	,dtmTermDiscountDate			= SMT.dtmDiscountDate
	,dblTermDiscountEP				= SMT.dblDiscountEP
	,intTermBalanceDue				= SMT.intBalanceDue
	,dtmTermDueDate					= SMT.dtmDueDate
	,dblTermAPR						= SMT.dblAPR	
	,ysnHasEmailSetup				= CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = ARI.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + ARI.strTransactionType + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	,dblTotalTermDiscount			= ARI.dblTotalTermDiscount
	,strTicketNumbers				= dbo.fnARGetScaleTicketNumbersFromInvoice(ARI.intInvoiceId)
	,strCustomerReferences			= dbo.fnARGetCustomerReferencesFromInvoice(ARI.intInvoiceId)
	,ysnExcludeForPayment			= CASE WHEN ARI.strTransactionType = 'Customer Prepayment' 
										AND (EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intInvoiceId = ARI.intInvoiceId AND (ISNULL(ysnRestricted, 0) = 1 OR ISNULL(intContractDetailId, 0) <> 0)) 
										--OR NOT EXISTS(SELECT NULL FROM tblARInvoice ARI1 INNER JOIN tblARPayment ARP ON ARI1.intPaymentId  = ARP.intPaymentId AND ARI1.intInvoiceId = ARI.intInvoiceId  AND ARP.ysnPosted = 1 AND ARI1.strTransactionType = 'Customer Prepayment'
										--INNER JOIN
										--	tblARPaymentDetail ARPD
										--		ON ARI1.intInvoiceId = ARPD.intInvoiceId)
										) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END 	
	,strInvoiceReportNumber			= CFT.strInvoiceReportNumber
FROM         
	(SELECT 
		intInvoiceId,
		strInvoiceNumber,
		strTransactionType,
		strType,
		dtmDate,
		dtmDueDate, 
		dtmPostDate, 
		dtmShipDate, 
		ysnPosted, 
		ysnPaid, 
		ysnProcessed, 
		ysnForgiven, 
		ysnCalculated, 
		dblInvoiceTotal, 
		dblDiscount, 
		dblDiscountAvailable, 
		dblInterest, 
		dblAmountDue, 
		dblPayment, 
		dblInvoiceSubtotal, 
		dblShipping, 
		dblTax, 
		intAccountId, 
		intCompanyLocationId, 
		intPaymentMethodId, 
		intCurrencyId, 
		intTermId,
		intEntityCustomerId,
		dblTotalTermDiscount
	 FROM 
		dbo.tblARInvoice) AS ARI 
INNER JOIN
	(SELECT 
		strCustomerNumber,
		[intEntityId],
		intPaymentMethodId
	 FROM 
		dbo.tblARCustomer) AS ARC ON ARI.[intEntityCustomerId] = ARC.[intEntityId] 
LEFT OUTER JOIN
	(SELECT
		intEntityId,
		intEntityContactId,
		ysnDefaultContact
	FROM 
		dbo.[tblEMEntityToContact]) AS EC ON ARC.[intEntityId] = EC.intEntityId AND EC.ysnDefaultContact = 1
LEFT OUTER JOIN
	(SELECT 
		intEntityId,
		strEmail
	 FROM
	dbo.tblEMEntity) AS E ON EC.intEntityContactId = E.intEntityId
INNER JOIN
	(SELECT	
		intEntityId,
		strName
	 FROM
		dbo.tblEMEntity) AS CE ON ARC.[intEntityId] = CE.intEntityId 
LEFT OUTER JOIN
	(SELECT 
		intTermID,
		strTerm,
		strType,
		intDiscountDay,
		dtmDiscountDate, 
		dblDiscountEP, 
		intBalanceDue, 
		dtmDueDate, 
		dblAPR
	FROM
		dbo.tblSMTerm) AS SMT ON ARI.intTermId = SMT.intTermID 
LEFT OUTER JOIN
	(SELECT 
		intCompanyLocationId,
		strLocationName
	 FROM 
		dbo.tblSMCompanyLocation) AS SML ON ARI.intCompanyLocationId  = SML.intCompanyLocationId 
LEFT OUTER JOIN
	(SELECT 
		intPaymentMethodID,
		strPaymentMethod
	 FROM
		dbo.tblSMPaymentMethod) AS SMP ON ARC.intPaymentMethodId = SMP.intPaymentMethodID
LEFT OUTER JOIN
	(SELECT 
		intCurrencyID,
		strCurrency
	 FROM 
		dbo.tblSMCurrency) SMC ON ARI.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN
	(SELECT
		intAccountId,
		strAccountId
	 FROM
		dbo.tblGLAccount) GLA ON ARI.intAccountId = GLA.intAccountId
LEFT OUTER JOIN 
	(SELECT
		intInvoiceId		
		, strInvoiceReportNumber
	 FROM
		dbo.tblCFTransaction) CFT ON ARI.intInvoiceId = CFT.intInvoiceId
WHERE ARI.strType <> 'CF Tran'
GO