CREATE VIEW dbo.vyuSOSalesOrderSearch
AS
SELECT     
	 intSalesOrderId		= SO.intSalesOrderId
	,strSalesOrderNumber	= SO.strSalesOrderNumber
	,strCustomerName		= NTT.strName
	,strCustomerNumber		= CUS.strCustomerNumber 
	,intEntityCustomerId	= CUS.[intEntityId]
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
	,ysnHasEmailSetup		= CASE WHEN EMAILSETUP.intEmailSetupCount > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	
	,strCurrency			= SMC.strCurrency
	,strCurrencyDescription	= SMC.strDescription
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
LEFT OUTER JOIN (
	 SELECT intEntityId
		  , strCustomerNumber
	 FROM dbo.tblARCustomer WITH (NOLOCK)
) CUS ON SO.[intEntityCustomerId] = CUS.[intEntityId] 
LEFT OUTER JOIN (
	 SELECT intEntityId
		  , strName
		  , strEntityNo
	 FROM dbo.tblEMEntity WITH (NOLOCK)
) NTT ON CUS.[intEntityId] = NTT.intEntityId 
LEFT OUTER JOIN (
	 SELECT intTermID
		  , strTerm
	 FROM dbo.tblSMTerm WITH (NOLOCK)
) TERM ON SO.intTermId = TERM.intTermID 
LEFT OUTER JOIN (
	 SELECT intCompanyLocationId
		  , strLocationName 
	 FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON SO.intCompanyLocationId  = CL.intCompanyLocationId 
LEFT OUTER JOIN (
	 SELECT intQuoteTemplateId,
			strTemplateName
	 FROM dbo.tblARQuoteTemplate WITH (NOLOCK)
) QT ON SO.intQuoteTemplateId = QT.intQuoteTemplateId 
LEFT OUTER JOIN (
	 SELECT intSplitId
		  , strSplitNumber
	 FROM dbo.tblEMEntitySplit WITH (NOLOCK)
) ES ON SO.intSplitId = ES.intSplitId 
LEFT OUTER JOIN (
	 SELECT intEntityId 
		  , strName
	 FROM dbo.tblEMEntity WITH (NOLOCK)
) OE ON SO.intOrderedById = OE.intEntityId 
LEFT OUTER JOIN (
	  (SELECT intEntityId
		   , strSalespersonId				
	  FROM dbo.tblARSalesperson WITH (NOLOCK)
	  ) AS SP 
	  INNER JOIN (SELECT intEntityId 
				       , strName
				  FROM dbo.tblEMEntity WITH (NOLOCK) 
				  ) ESP ON SP.intEntityId = ESP.intEntityId
) ON SO.intEntitySalespersonId = SP.intEntityId
LEFT OUTER JOIN (
	SELECT intCurrencyID, 
			strCurrency, 
			strDescription 
	FROM dbo.tblSMCurrency  WITH (NOLOCK) 
) SMC ON SO.intCurrencyId = SMC.intCurrencyID
OUTER APPLY (
	SELECT TOP 1 strName
			   , strEmail
			   , intEntityContactId 
	FROM dbo.vyuEMEntityContact WITH (NOLOCK) 
	WHERE SO.intEntityContactId = intEntityContactId
) EC
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE intCustomerEntityId = SO.intEntityCustomerId 
	  AND ISNULL(strEmail, '') <> '' 
	  AND strEmailDistributionOption LIKE '%' + SO.strTransactionType + '%'
) EMAILSETUP