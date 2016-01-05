CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
	I.intInvoiceId, 
	I.strInvoiceNumber,
	CE.strName						AS strCustomerName, 
	C.strCustomerNumber, 
	C.[intEntityCustomerId], 
	I.strTransactionType, 
	ISNULL(I.strType, 'Standard')	AS strType,
	I.strPONumber, 
	T.strTerm,
	I.strBOLNumber,
	I.intTermId, 
	I.intAccountId,
	I.dtmDate,
	I.dtmDueDate, 
	(CASE WHEN I.ysnPosted = 0 THEN NULL ELSE I.dtmPostDate END) AS dtmPostDate,
	I.dtmShipDate,
	I.ysnPosted, 
	I.ysnPaid, 
	I.ysnProcessed, 
	I.ysnForgiven,
	I.ysnCalculated,
	I.dblInvoiceTotal, 
	ISNULL(I.dblDiscount,0)			AS dblDiscount, 
	ISNULL(I.dblDiscountTaken,0)	AS dblDiscountTaken, 
	ISNULL(I.dblAmountDue,0)		AS dblAmountDue, 
	ISNULL(I.dblPayment, 0)			AS dblPayment,
	ISNULL(I.dblInvoiceSubtotal, 0)	AS dblInvoiceSubtotal,
	ISNULL(I.dblShipping, 0)		AS dblShipping,
	ISNULL(I.dblTax, 0)				AS dblTax,
	I.intPaymentMethodId, 
	I.intCompanyLocationId, 
	I.strComments,
	I.intCurrencyId,
	L.strLocationName,
	P.strPaymentMethod,
	0.000000						AS dblPaymentAmount,
	SV.strShipVia,
	SE.strName						AS strSalesPerson,
	E.strEmail						AS strCustomerEmail,
	CUR.strCurrency,		
	ELB.strLocationName				AS strBillToLocationName,
	ELB.strAddress					AS strBillToAddress,
	ELB.strCity						AS strBillToCity,
	ELB.strState					AS strBillToState,
	ELB.strZipCode					AS strBillToZipCode,
	ELB.strCountry					AS strBillToCountry,
	ELS.strLocationName				AS strShipToLocationName,
	ELS.strAddress					AS strShipToAddress,
	ELS.strCity						AS strShipToCity,
	ELS.strState					AS strShipToState,
	ELS.strZipCode					AS strShipToZipCode,
	ELS.strCountry					AS strShipToCountry,
	I.intEntityId					AS intEntredById,
	EB.strName						AS strEnteredBy,
	CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = I.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + I.strTransactionType + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END AS ysnHasEmailSetup
	,GL.dtmDate AS dtmBatchDate
	,GL.strBatchId
	,GL.strName strUserEntered
FROM         
	dbo.tblARInvoice AS I 
INNER JOIN
	dbo.tblARCustomer AS C 
		ON I.[intEntityCustomerId] = C.[intEntityCustomerId] 
LEFT OUTER JOIN
	dbo.tblEntityToContact AS EC ON C.intEntityCustomerId = EC.intEntityId AND EC.ysnDefaultContact = 1
LEFT OUTER JOIN
	dbo.tblEntity AS E ON EC.intEntityContactId = E.intEntityId
LEFT OUTER JOIN
	dbo.tblEntityLocation AS ELB ON C.intBillToId = ELB.intEntityLocationId
LEFT OUTER JOIN
	dbo.tblEntityLocation AS ELS ON C.intShipToId = ELS.intEntityLocationId		
INNER JOIN
	dbo.tblEntity AS CE 
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
	dbo.tblEntity AS SE 
		ON I.[intEntitySalespersonId] = SE.intEntityId 
LEFT OUTER JOIN
	dbo.tblSMCurrency CUR
		ON I.intCurrencyId = CUR.intCurrencyID
LEFT OUTER JOIN
	dbo.tblEntity AS EB 
		ON I.[intEntityId] = EB.intEntityId
LEFT OUTER JOIN
	(
	SELECT --TOP 1
		 G.intTransactionId
		,G.strTransactionId
		,G.intAccountId
		,G.strTransactionType
		,G.dtmDate
		,G.strBatchId
		,E.intEntityId
		,E.strName
	FROM
		tblGLDetail G
	LEFT OUTER JOIN
		tblEntity E
			ON G.intEntityId = E.intEntityId
	WHERE
			G.strTransactionType IN ('Invoice')
		AND G.ysnIsUnposted = 0
		AND G.strCode = 'AR'
	) GL
		ON I.intInvoiceId = GL.intTransactionId
		AND I.intAccountId = GL.intAccountId
		AND I.strInvoiceNumber = GL.strTransactionId					 