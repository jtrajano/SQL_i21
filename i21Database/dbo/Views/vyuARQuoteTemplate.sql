﻿CREATE VIEW [dbo].[vyuARQuoteTemplate]
AS
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , intQuoteTemplateId		= TEMPLATE.intQuoteTemplateId
	 , intQuoteTemplateDetailId	= TEMPLATE.intQuoteTemplateDetailId
	 , intQuotePageId			= ISNULL(TEMPLATE.intQuotePageId, 0)
     , strSectionName			= ISNULL(TEMPLATE.strSectionName, 'Quote Order')
     , intSort					= TEMPLATE.intSort
	 , dtmDate					= SO.dtmDate
	 , strTransactionType		= SO.strTransactionType
	 , ysnHasEmailSetup			= CASE WHEN (ISNULL(EMAILSETUP.intEmailSetupCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
LEFT JOIN (
	SELECT QTD.*
	FROM dbo.tblARQuoteTemplate QT WITH (NOLOCK)
	INNER JOIN (
		SELECT intQuoteTemplateId
			 , intQuoteTemplateDetailId
			 , intSort
			 , intQuotePageId
			 , strSectionName
		FROM dbo.tblARQuoteTemplateDetail WITH (NOLOCK)
	) QTD ON QT.intQuoteTemplateId = QTD.intQuoteTemplateId
) TEMPLATE ON SO.intQuoteTemplateId = TEMPLATE.intQuoteTemplateId 
OUTER APPLY (
	SELECT COUNT(*) AS intEmailSetupCount
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE intCustomerEntityId = SO.intEntityCustomerId 
	  AND ISNULL(strEmail, '') <> '' 
	  AND strEmailDistributionOption LIKE '%' + CASE WHEN SO.ysnQuote = 1 THEN 'Quote Order' ELSE 'Sales Order' END + '%'
) EMAILSETUP
WHERE ysnQuote = 1 
  AND strTransactionType = 'Quote'