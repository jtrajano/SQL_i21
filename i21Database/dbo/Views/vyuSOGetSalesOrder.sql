CREATE VIEW [dbo].[vyuSOGetSalesOrder]
AS 
SELECT 
	SO.intSalesOrderId,
    SO.strSalesOrderNumber,
    SO.intEntityCustomerId,
    SO.dtmDate,
    SO.dtmDueDate,
    SO.dtmExpirationDate,
    SO.intCurrencyId,
    SO.intCompanyLocationId,
    SO.intEntitySalespersonId,
    SO.intShipViaId,
    SO.strPONumber,
    SO.strBOLNumber,
    SO.intTermId,
    SO.dblSalesOrderSubtotal,
    SO.dblBaseSalesOrderSubtotal,
    SO.dblShipping,
    SO.dblBaseShipping,
    SO.dblTax,
    SO.dblBaseTax,
    SO.dblSalesOrderTotal,
    SO.dblBaseSalesOrderTotal,
    SO.dblDiscount,
    SO.dblBaseDiscount,
    SO.dblTotalDiscount,
    SO.dblBaseTotalDiscount,
    SO.dblAmountDue,
    SO.dblBaseAmountDue,
    SO.dblPayment,

    SO.strTransactionType,
    SO.strType,
    SO.strOrderStatus,
    SO.intAccountId,
    SO.dtmProcessDate,
    SO.ysnProcessed,
    SO.ysnShipped,
    SO.strComments,
    SO.strFooterComments,
    SO.intFreightTermId,
    SO.intShipToLocationId,
    SO.strShipToLocationName,
    SO.strShipToAddress,
    SO.strShipToCity,
    SO.strShipToState,
    SO.strShipToZipCode,
    SO.strShipToCountry,
    SO.intBillToLocationId,
    SO.strBillToLocationName,
    SO.strBillToAddress,
    SO.strBillToCity,
    SO.strBillToState,
    SO.strBillToZipCode,
    SO.strBillToCountry,
    SO.intEntityId,
    SO.intQuoteTemplateId,
    SO.ysnRecurring,
    SO.ysnQuote,
    SO.ysnPreliminaryQuote,
	SO.ysnRejected,
    SO.intOrderedById,
    SO.intSplitId,
    SO.strLostQuoteCompetitor,
    SO.strLostQuoteReason,
    SO.strLostQuoteComment,
    SO.strQuoteType,
    SO.dblTotalWeight,
    SO.intEntityContactId,
    SO.intEntityApplicatorId,
    SO.intDocumentMaintenanceId,
    SO.intRecipeGuideId,
    SO.dblTotalTermDiscount,
    SO.dblDiscountAvailable,
    SO.intConcurrencyId,
    SO.strSalesOrderOriginId,    
    SO.intOpportunityId,
    SO.intLineOfBusinessId,


	strCustomerNumber = CUS.strCustomerNumber,
    strCustomerName = CUS.strName,
	dblCreditLimit = CUS.dblCreditLimit,
    dblARBalance = CUS.dblARBalance,
    ysnPORequired = CUS.ysnPORequired,	
    intEntityLineOfBusinessIds = CUS.intEntityLineOfBusinessIds,

	strContactName = CON.strName,
	strApplicatorName = APER.strName,
	strTerm = TERM.strTerm,
    strAccountId = ACCT.strAccountId,
    strFobPoint = FTERMS.strFobPoint,
	ysnQuotePriceOnly = CAST(CASE WHEN  ISNULL(QUOTE.strQuoteType, '') =  'Price Only' THEN  1 ELSE 0 END AS BIT),

	strLocationName = CLOC.strLocationName,
    strCurrency = CUR.strCurrency,
    strSalespersonName = SPER.strName,
    strShipVia = SHIPVIA.strShipVia,

	strOrderedBy = OPER.strName,
    strFreightTerm = FTERMS.strFreightTerm,
    strTemplateName = TEMP.strTemplateName,
    strSplitNumber = SPLIT.strSplitNumber,
    strCode = DOC.strCode,
    strTitle = DOC.strTitle,
	strOpportunityName = OPUR.strName,
    strLineOfBusiness = SB.strLineOfBusiness,
	intCreditStopDays = CUS.intCreditStopDays,
	strCreditCode = CUS.strCreditCode,
	

    ysnProspect = CTYPE.Prospect,
	intCreditLimitReached = CUS.intCreditLimitReached,
	dtmCreditLimitReached = CUS.dtmCreditLimitReached

	FROM tblSOSalesOrder SO
		JOIN ( SELECT	intEntityId,			strCustomerNumber,
						intEntityContactId,		strName,
						dblCreditLimit,			dblARBalance,
						ysnPORequired,			intEntityLineOfBusinessIds,
						intCreditStopDays,		strCreditCode,
						intCreditLimitReached,  dtmCreditLimitReached
			FROM vyuARCustomerSearch WITH (NOLOCK) ) CUS
				ON CUS.intEntityId = SO.intEntityCustomerId 
        LEFT JOIN ( SELECT intEntityId,		Customer,       Prospect
			FROM vyuEMEntityType  WITH (NOLOCK)) CTYPE
                ON SO.intEntityCustomerId = CTYPE.intEntityId
		LEFT JOIN ( SELECT intEntityId,		strName
			FROM tblEMEntity  WITH (NOLOCK)) CON
				ON CON.intEntityId = SO.intEntityContactId
		LEFT JOIN ( SELECT intEntityId,		strName
			FROM tblEMEntity  WITH (NOLOCK)) APER
				ON APER.intEntityId = SO.intEntityApplicatorId
		JOIN (SELECT intTermID, strTerm 
					FROM tblSMTerm WITH ( NOLOCK) ) TERM
			ON SO.intTermId = TERM.intTermID
		LEFT JOIN ( SELECT  intFreightTermId, strFreightTerm,
							strFobPoint
					FROM tblSMFreightTerms WITH ( NOLOCK) ) FTERMS
			ON SO.intFreightTermId = FTERMS.intFreightTermId
		LEFT JOIN ( SELECT intAccountId, strAccountId 
						FROM tblGLAccount WITH ( NOLOCK) ) ACCT
			ON SO.intAccountId = ACCT.intAccountId
		LEFT JOIN ( SELECT strSalesOrderOriginId, strQuoteType 
						FROM vyuARProcessedQuotes) QUOTE
			ON SO.strSalesOrderOriginId = QUOTE.strSalesOrderOriginId
		LEFT JOIN (SELECT intCompanyLocationId, strLocationName 
					FROM tblSMCompanyLocation WITH ( NOLOCK) ) CLOC
			ON SO.intCompanyLocationId = CLOC.intCompanyLocationId
		LEFT JOIN (SELECT intDocumentMaintenanceId, strCode, strTitle 
						FROM tblSMDocumentMaintenance WITH ( NOLOCK)  )DOC
			ON SO.intDocumentMaintenanceId = DOC.intDocumentMaintenanceId
		JOIN ( SELECT intCurrencyID, strCurrency 
						FROM tblSMCurrency WITH ( NOLOCK)  ) CUR
			ON SO.intCurrencyId = CUR.intCurrencyID
		LEFT JOIN ( SELECT intEntityId,		strName
			FROM tblEMEntity  WITH (NOLOCK)) SPER
				ON SPER.intEntityId = SO.intEntitySalespersonId
		LEFT JOIN (SELECT intEntityId, strShipVia
						FROM tblSMShipVia WITH ( NOLOCK) ) SHIPVIA
			ON SO.intShipViaId = SHIPVIA.intEntityId
		LEFT JOIN ( SELECT intEntityId,		strName
			FROM tblEMEntity  WITH (NOLOCK)) OPER
				ON OPER.intEntityId = SO.intOrderedById
		LEFT JOIN ( SELECT intQuoteTemplateId, strTemplateName 
			FROM tblARQuoteTemplate ) TEMP
				ON SO.intQuoteTemplateId =  TEMP.intQuoteTemplateId 
		LEFT JOIN (SELECT intSplitId, strSplitNumber 
			FROM tblEMEntitySplit WITH ( NOLOCK) ) SPLIT
				ON SO.intSplitId = SPLIT.intSplitId
		LEFT JOIN ( SELECT intOpportunityId, strName
			FROM tblCRMOpportunity ) OPUR
				ON SO.intOpportunityId = OPUR.intOpportunityId
		LEFT JOIN ( SELECT intLineOfBusinessId, strLineOfBusiness
			FROM tblSMLineOfBusiness ) SB
				ON SO.intLineOfBusinessId = SB.intLineOfBusinessId 
