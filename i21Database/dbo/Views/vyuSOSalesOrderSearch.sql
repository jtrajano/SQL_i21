CREATE VIEW dbo.vyuSOSalesOrderSearch
AS
SELECT     
	 intSalesOrderId		= SO.intSalesOrderId
	,strSalesOrderNumber	= SO.strSalesOrderNumber
	,strCustomerName		= NTT.strName
	,strCustomerNumber		= CUS.strCustomerNumber 
	,intEntityCustomerId	= CUS.intEntityCustomerId
	,strTransactionType		= SO.strTransactionType
	,strType				= ISNULL(SO.strType, 'Standard')
	,strOrderStatus			= SO.strOrderStatus
	,strTerm				= TERM.strTerm
	,intTermId				= SO.intTermId
	,intAccountId			= SO.intAccountId
	,dtmDate				= SO.dtmDate
	,dtmDueDate				= SO.dtmDueDate
	,ysnProcessed			= SO.ysnProcessed
	,dblSalesOrderTotal		= SO.dblSalesOrderTotal
	,dblDiscount			= ISNULL(SO.dblDiscount,0)
	,dblAmountDue			= ISNULL(SO.dblAmountDue,0) 
	,dblPayment				= ISNULL(SO.dblPayment, 0)
	,intCompanyLocationId	= SO.intCompanyLocationId
	,intCurrencyId			= SO.intCurrencyId
	,strLocationName		= CL.strLocationName
	,dblPaymentAmount		= 0.000000
	,intQuoteTemplateId		= SO.intQuoteTemplateId
	,strTemplateName		= QT.strTemplateName
	,ysnPreliminaryQuote	= SO.ysnPreliminaryQuote
	,intOrderedById			= SO.intOrderedById
	,strOrderedByName		= OE.strName
	,intSplitId				= SO.intSplitId
	,strSplitNumber			= ES.strSplitNumber
	,intEntitySalespersonId	= SO.intEntitySalespersonId
	,strSalespersonId		= CASE WHEN SP.strSalespersonId = '' THEN NTT.strEntityNo ELSE SP.strSalespersonId END
	,strSalespersonName		= ESP.strName
	,strLostQuoteCompetitor	= SO.strLostQuoteCompetitor
	,strLostQuoteReason		= SO.strLostQuoteReason
	,strLostQuoteComment	= SO.strLostQuoteComment
	,ysnRecurring			= SO.ysnRecurring
	,intEntityContactId		= SO.intEntityContactId
	,strContactName			= EC.strName
	,ysnHasEmailSetup		= CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = SO.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + SO.strTransactionType + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM         
	dbo.tblSOSalesOrder AS SO 
LEFT OUTER JOIN
	dbo.tblARCustomer AS CUS 
		ON SO.[intEntityCustomerId] = CUS.[intEntityCustomerId] 
LEFT OUTER JOIN
	dbo.tblEMEntity AS NTT 
		ON CUS.[intEntityCustomerId] = NTT.intEntityId 
LEFT OUTER JOIN
	dbo.vyuEMEntityContact AS EC 
		ON SO.intEntityContactId = EC.intEntityContactId 
LEFT OUTER JOIN
	dbo.tblSMTerm AS TERM 
		ON SO.intTermId = TERM.intTermID 
LEFT OUTER JOIN
	dbo.tblSMCompanyLocation AS CL 
		ON SO.intCompanyLocationId  = CL.intCompanyLocationId 
LEFT OUTER JOIN
	dbo.tblARQuoteTemplate AS QT 
		ON SO.intQuoteTemplateId = QT.intQuoteTemplateId 
LEFT OUTER JOIN
	dbo.[tblEMEntitySplit] AS ES 
		ON SO.intSplitId = ES.intSplitId 
LEFT OUTER JOIN
	dbo.tblEMEntity AS OE 
		ON SO.intOrderedById = OE.intEntityId 
LEFT OUTER JOIN
	(dbo.tblARSalesperson AS SP 
		INNER JOIN tblEMEntity ESP 
			ON SP.intEntitySalespersonId = ESP.intEntityId) 
		ON SO.intEntitySalespersonId = SP.intEntitySalespersonId