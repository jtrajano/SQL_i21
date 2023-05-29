CREATE VIEW [dbo].[vyuSOGetSalesOrder]
AS 
SELECT intSalesOrderId				= SO.intSalesOrderId
     , strSalesOrderNumber			= SO.strSalesOrderNumber
     , intEntityCustomerId			= SO.intEntityCustomerId
     , dtmDate						= SO.dtmDate
     , dtmDueDate					= SO.dtmDueDate
     , dtmExpirationDate			= SO.dtmExpirationDate
     , intCurrencyId				= SO.intCurrencyId
     , intCompanyLocationId			= SO.intCompanyLocationId
     , intEntitySalespersonId		= SO.intEntitySalespersonId
     , intShipViaId					= SO.intShipViaId
     , strPONumber					= SO.strPONumber
     , strBOLNumber					= SO.strBOLNumber
     , intTermId					= SO.intTermId
     , dblSalesOrderSubtotal		= SO.dblSalesOrderSubtotal
     , dblBaseSalesOrderSubtotal	= SO.dblBaseSalesOrderSubtotal
     , dblShipping					= SO.dblShipping
     , dblBaseShipping				= SO.dblBaseShipping
     , dblTax						= SO.dblTax
     , dblBaseTax					= SO.dblBaseTax
     , dblSalesOrderTotal			= SO.dblSalesOrderTotal
     , dblBaseSalesOrderTotal		= SO.dblBaseSalesOrderTotal
     , dblDiscount					= SO.dblDiscount
     , dblBaseDiscount				= SO.dblBaseDiscount
     , dblTotalDiscount				= SO.dblTotalDiscount
     , dblBaseTotalDiscount			= SO.dblBaseTotalDiscount
     , dblAmountDue					= SO.dblAmountDue
     , dblBaseAmountDue				= SO.dblBaseAmountDue
     , dblPayment					= SO.dblPayment
	 , dblCurrencyExchangeRate		= SO.dblCurrencyExchangeRate
     , strTransactionType			= SO.strTransactionType
     , strType						= SO.strType
     , strOrderStatus				= SO.strOrderStatus
     , intAccountId					= SO.intAccountId
     , dtmProcessDate				= SO.dtmProcessDate
     , ysnProcessed					= SO.ysnProcessed
     , ysnShipped					= SO.ysnShipped
     , strComments					= SO.strComments
     , strFooterComments			= SO.strFooterComments
     , intFreightTermId				= SO.intFreightTermId
     , intShipToLocationId			= SO.intShipToLocationId
     , strShipToLocationName		= SO.strShipToLocationName
     , strShipToAddress				= SO.strShipToAddress
     , strShipToCity				= SO.strShipToCity
     , strShipToState				= SO.strShipToState
     , strShipToZipCode				= SO.strShipToZipCode
     , strShipToCountry				= SO.strShipToCountry
     , intBillToLocationId			= SO.intBillToLocationId
     , strBillToLocationName		= SO.strBillToLocationName
     , strBillToAddress				= SO.strBillToAddress
     , strBillToCity				= SO.strBillToCity
     , strBillToState				= SO.strBillToState
     , strBillToZipCode				= SO.strBillToZipCode
     , strBillToCountry				= SO.strBillToCountry
     , intEntityId					= SO.intEntityId
     , intQuoteTemplateId			= SO.intQuoteTemplateId
     , ysnRecurring					= SO.ysnRecurring
     , ysnQuote						= SO.ysnQuote
     , ysnPreliminaryQuote			= SO.ysnPreliminaryQuote
	 , ysnRejected					= SO.ysnRejected
     , ysnFromItemContract			= SO.ysnFromItemContract
     , intOrderedById				= SO.intOrderedById
     , intSplitId					= SO.intSplitId
     , strLostQuoteCompetitor		= SO.strLostQuoteCompetitor
     , strLostQuoteReason			= SO.strLostQuoteReason
     , strLostQuoteComment			= SO.strLostQuoteComment
     , strQuoteType					= SO.strQuoteType
     , dblTotalWeight				= SO.dblTotalWeight
     , dblTotalStandardWeight           = SO.dblTotalStandardWeight
     , intEntityContactId			= SO.intEntityContactId
     , intEntityApplicatorId		= SO.intEntityApplicatorId
     , intDocumentMaintenanceId		= SO.intDocumentMaintenanceId
     , intRecipeGuideId				= SO.intRecipeGuideId
     , dblTotalTermDiscount			= SO.dblTotalTermDiscount
     , dblDiscountAvailable			= SO.dblDiscountAvailable
     , intConcurrencyId				= SO.intConcurrencyId
     , strSalesOrderOriginId		= SO.strSalesOrderOriginId
     , intOpportunityId				= SO.intOpportunityId
     , intLineOfBusinessId			= SO.intLineOfBusinessId
	 , strCustomerNumber			= CUSTOMER.strCustomerNumber
     , strCustomerName				= CUSTOMER.strName
	 , dblCreditLimit				= CUSTOMER.dblCreditLimit
     , dblARBalance					= CUSTOMER.dblARBalance
     , ysnPORequired				= CUSTOMER.ysnPORequired
     , intEntityLineOfBusinessIds	= CUSTOMER.intEntityLineOfBusinessIds
	 , intCreditStopDays			= CUSTOMER.intCreditStopDays
	 , strCreditCode				= CUSTOMER.strCreditCode
	 , intCreditLimitReached		= CUSTOMER.intCreditLimitReached
	 , dtmCreditLimitReached		= CUSTOMER.dtmCreditLimitReached
	 , strContactName				= CONTACT.strName
	 , strApplicatorName			= APPLICATOR.strEntityNo
	 , strTerm						= TERM.strTerm
     , strAccountId					= ACCT.strAccountId
     , strFobPoint					= FREIGHT.strFobPoint
	 , ysnQuotePriceOnly			= CAST(CASE WHEN  ISNULL(QUOTE.strQuoteType, '') =  'Price Only' THEN  1 ELSE 0 END AS BIT)
	 , strLocationName				= LOCATION.strLocationName
     , strCurrency					= CURRENCY.strCurrency
     , strSalespersonName			= SALESPERSON.strName
     , strShipVia					= SHIPVIA.strShipVia
	 , strOrderedBy					= OPER.strName
     , strFreightTerm				= FREIGHT.strFreightTerm
     , strTemplateName				= TEMP.strTemplateName
     , strSplitNumber				= SPLIT.strSplitNumber
     , strCode						= DOC.strCode
     , strTitle						= DOC.strTitle
	 , strOpportunityName			= OPUR.strName
     , strLineOfBusiness			= SB.strLineOfBusiness
     , ysnProspect					= CTYPE.Prospect	
FROM tblSOSalesOrder SO
LEFT JOIN ( 
	SELECT intEntityId
		 , strCustomerNumber
		 , intEntityContactId
		 , strName
		 , dblCreditLimit
		 , dblARBalance
		 , ysnPORequired
		 , intEntityLineOfBusinessIds
		 , intCreditStopDays
		 , strCreditCode
		 , intCreditLimitReached
		 , dtmCreditLimitReached
	FROM vyuARCustomerSearch WITH (NOLOCK) 
) CUSTOMER ON CUSTOMER.intEntityId = SO.intEntityCustomerId 
LEFT JOIN (
	SELECT intEntityId
		 , Customer
		 , Prospect
	FROM vyuEMEntityType WITH (NOLOCK)
) CTYPE ON SO.intEntityCustomerId = CTYPE.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK)
) CONTACT ON CONTACT.intEntityId = SO.intEntityContactId
LEFT JOIN (
	SELECT intEntityId
		 , strName
           , strEntityNo
	FROM tblEMEntity WITH (NOLOCK)
) APPLICATOR ON APPLICATOR.intEntityId = SO.intEntityApplicatorId
JOIN (
	SELECT intTermID
		 , strTerm 
	FROM tblSMTerm WITH (NOLOCK)
) TERM ON SO.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
		 , strFobPoint
	FROM tblSMFreightTerms WITH (NOLOCK)
) FREIGHT ON SO.intFreightTermId = FREIGHT.intFreightTermId
LEFT JOIN (
	SELECT intAccountId
		 , strAccountId 
	FROM tblGLAccount WITH (NOLOCK)
) ACCT ON SO.intAccountId = ACCT.intAccountId
LEFT JOIN (
	SELECT strSalesOrderOriginId
		 , strQuoteType 
	FROM vyuARProcessedQuotes
) QUOTE ON SO.strSalesOrderOriginId = QUOTE.strSalesOrderOriginId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM tblSMCompanyLocation WITH (NOLOCK)
) LOCATION ON SO.intCompanyLocationId = LOCATION.intCompanyLocationId
LEFT JOIN (
	SELECT intDocumentMaintenanceId
		 , strCode
	     , strTitle 
	FROM tblSMDocumentMaintenance WITH (NOLOCK)
) DOC ON SO.intDocumentMaintenanceId = DOC.intDocumentMaintenanceId
JOIN ( 
	SELECT intCurrencyID
		 , strCurrency 
	FROM tblSMCurrency WITH (NOLOCK)
) CURRENCY ON SO.intCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK)
) SALESPERSON ON SALESPERSON.intEntityId = SO.intEntitySalespersonId
LEFT JOIN (
	SELECT intEntityId
		 , strShipVia
	FROM tblSMShipVia WITH (NOLOCK)
) SHIPVIA ON SO.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK)
) OPER ON OPER.intEntityId = SO.intOrderedById
LEFT JOIN (
	SELECT intQuoteTemplateId
		 , strTemplateName 
	FROM tblARQuoteTemplate WITH (NOLOCK)
) TEMP ON SO.intQuoteTemplateId =  TEMP.intQuoteTemplateId 
LEFT JOIN (
	SELECT intSplitId
		 , strSplitNumber 
	FROM tblEMEntitySplit WITH (NOLOCK)
) SPLIT ON SO.intSplitId = SPLIT.intSplitId
LEFT JOIN (
	SELECT intOpportunityId
		 , strName
	FROM tblCRMOpportunity WITH (NOLOCK)
) OPUR ON SO.intOpportunityId = OPUR.intOpportunityId
LEFT JOIN (
	SELECT intLineOfBusinessId
		 , strLineOfBusiness
	FROM tblSMLineOfBusiness WITH (NOLOCK)
) SB ON SO.intLineOfBusinessId = SB.intLineOfBusinessId 
