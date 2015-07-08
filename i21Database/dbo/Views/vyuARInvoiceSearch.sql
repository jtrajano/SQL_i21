CREATE VIEW dbo.vyuARInvoiceSearch
AS
	SELECT     
		I.intInvoiceId, 
		I.strInvoiceNumber,
		CE.strName					AS strCustomerName, 
		C.strCustomerNumber, 
		C.[intEntityCustomerId], 
		I.strTransactionType, 
		I.strPONumber, 
		T.strTerm,
		I.intTermId, 
		I.intAccountId,
		I.dtmDate,
		I.dtmDueDate, 
		I.dtmPostDate,
		I.dtmShipDate,
		I.ysnPosted, 
		I.ysnPaid, 
		I.dblInvoiceTotal, 
		ISNULL(I.dblDiscount,0)			AS dblDiscount, 
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
		ELS.strCountry					AS strShipToCountry
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