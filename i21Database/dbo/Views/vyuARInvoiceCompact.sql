CREATE VIEW [dbo].[vyuARInvoiceCompact]
AS
SELECT     
	 intInvoiceId					= ARI.intInvoiceId
	,strInvoiceNumber				= ARI.strInvoiceNumber
	,strCustomerName				= CE.strName
	,strCustomerNumber				= ARC.strCustomerNumber
	,intEntityCustomerId			= ARC.intEntityCustomerId
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
	,intPaymentMethodId				= ARI.intPaymentMethodId	
	,strPaymentMethod				= CASE WHEN ARI.strTransactionType = 'Overpayment' THEN '' ELSE SMP.strPaymentMethod END
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
	,ysnExcludeForPayment			= CASE WHEN ARI.strTransactionType = 'Customer Prepayment' 
										AND (EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intInvoiceId = ARI.intInvoiceId AND (ISNULL(ysnRestricted, 0) = 1 OR ISNULL(intContractDetailId, 0) <> 0)) 
										OR NOT EXISTS(SELECT NULL FROM tblARInvoice ARI1 INNER JOIN tblARPayment ARP ON ARI1.intPaymentId  = ARP.intPaymentId AND ARP.ysnPosted = 1 AND ARI1.strTransactionType = 'Customer Prepayment'
INNER JOIN
	tblARPaymentDetail ARPD
		ON ARI1.intInvoiceId = ARPD.intInvoiceId)) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM         
	dbo.tblARInvoice AS ARI 
INNER JOIN
	dbo.tblARCustomer AS ARC 
		ON ARI.[intEntityCustomerId] = ARC.[intEntityCustomerId] 
LEFT OUTER JOIN
	dbo.[tblEMEntityToContact] AS EC ON ARC.intEntityCustomerId = EC.intEntityId AND EC.ysnDefaultContact = 1
LEFT OUTER JOIN
	dbo.tblEMEntity AS E ON EC.intEntityContactId = E.intEntityId
INNER JOIN
	dbo.tblEMEntity AS CE 
		ON ARC.[intEntityCustomerId] = CE.intEntityId 
LEFT OUTER JOIN
	dbo.tblSMTerm AS SMT 
		ON ARI.intTermId = SMT.intTermID 
LEFT OUTER JOIN
	dbo.tblSMCompanyLocation AS SML 
		ON ARI.intCompanyLocationId  = SML.intCompanyLocationId 
LEFT OUTER JOIN
	dbo.tblSMPaymentMethod AS SMP 
		ON ARI.intPaymentMethodId = SMP.intPaymentMethodID
LEFT OUTER JOIN
	dbo.tblSMCurrency SMC
		ON ARI.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN
	dbo.tblGLAccount GLA
		ON ARI.intAccountId = GLA.intAccountId
GO


