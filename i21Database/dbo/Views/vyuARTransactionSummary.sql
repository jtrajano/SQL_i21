CREATE VIEW vyuARTransactionSummary
AS
SELECT  intYear 					= YEAR(SAR.dtmDate)
	  , intMonth 					= MONTH(SAR.dtmDate) 
	  , dtmTransactionDate 			= SAR.dtmDate
	  , dtmTransactionDateEnding 	= SAR.dtmDate
	  , intEntityCustomerId 		= SAR.intEntityCustomerId
	  , intCompanyLocationId		= SAR.intCompanyLocationId
	  , strName 					= SAR.strCustomerName
	  , strCustomerName 			= SAR.strCustomerName
	  , strCustomerNumber 			= SAR.strCustomerNumber
	  , intSourceId					= SAR.intSourceId
	  , strInvoiceOriginId			= SAR.strInvoiceOriginId
	  , intItemId 					= SAR.intItemId
	  , strItemNo 					= SAR.strItemName
	  , strDescription 				= SAR.strItemDesc
	  , intCategoryId 				= SAR.intCategoryId
	  , strCategoryCode 			= SAR.strCategoryName
	  , strCategoryDescription 		= SAR.strCategoryDescription
	  , strSalesPersonEntityNo 		= SAR.strSalespersonName
	  , strSalesPersonName 			= SAR.strSalespersonName
	  , intSalesPersonId 			= SAR.intEntitySalespersonId
	  , dblSalesAmount 				= SAR.dblLineTotal
	  , dblQuantity 				= SAR.dblQtyShipped
	  , dblBeginSalesAmount 		= 0
	  , dblBeginQuantity 			= 0
	  , dblEndSalesAmount 			= 0
	  , dblEndQuantity 				= 0
	  , dtmBeginDate				= '' COLLATE Latin1_General_CI_AS
	  , dtmEndingDate 				= '' COLLATE Latin1_General_CI_AS
	  , dblCost 					= SAR.dblTotalCost
	  , strAccountStatusCode		= SAR.strAccountStatusCode
	  , strSource					= SAR.strType
	  , strLocationName				= strLocationName
	  , strCompanyName				= COMPANY.strCompanyName
	  , strCompanyAddress			= COMPANY.strCompanyAddress

FROM vyuARSalesAnalysisReport SAR

 OUTER APPLY (SELECT
       TOP 1 strCompanyName,
       strCompanyAddress = dbo.[fnARFormatCustomerAddress]
       (NULL, NULL, NULL, strAddress, strCity,
       strState, strZip, strCountry, NULL, 0)
       COLLATE Latin1_General_CI_AS FROM
       dbo.tblSMCompanySetup WITH (NOLOCK))
       COMPANY