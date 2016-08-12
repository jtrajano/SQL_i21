CREATE VIEW [dbo].[vyuSMDocumentMaintenanceMessage]
AS 
SELECT intDocumentMaintenanceId
,strTitle
,intCompanyLocationId
,intLineOfBusinessId
,intEntityCustomerId
,strSource
,strType
,ysnCopyAll
,strCode
,intHeaderCharacterLimit
,strHeader
,intFooterCharacterLimit
,strFooter
,CAST(MAX(ysnRecipe) AS BIT) AS ysnRecipe
,CAST(MAX(ysnQuote) AS BIT) AS ysnQuote
,CAST(MAX(ysnSalesOrder) AS BIT) AS ysnSalesOrder
,CAST(MAX(ysnPickList) AS BIT) AS ysnPickList
,CAST(MAX(ysnBOL) AS BIT) AS ysnBOL
,CAST(MAX(ysnInvoice) AS BIT) AS ysnInvoice
,CAST(MAX(ysnScaleTicket) AS BIT) AS ysnScaleTicket
FROM
(
	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,MAX(CAST(a.ysnRecipe AS INT)) AS ysnRecipe
	,'' AS ysnQuote
	,'' AS ysnSalesOrder
	,'' AS ysnPickList
	,'' AS ysnBOL
	,'' AS ysnInvoice
	,'' AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnRecipe = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnRecipe = 1) c
	WHERE ysnRecipe = 1
	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

	UNION ALL

	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,'' AS ysnRecipe
	,MAX(CAST(a.ysnQuote AS INT)) AS ysnQuote
	,'' AS ysnSalesOrder
	,'' AS ysnPickList
	,'' AS ysnBOL
	,'' AS ysnInvoice
	,'' AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnQuote = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnQuote = 1) c
	WHERE ysnQuote = 1
	GROUP BY a.intDocumentMaintenanceId, strTitle, intCompanyLocationId, intLineOfBusinessId, intEntityCustomerId, strSource, strType, ysnCopyAll, strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

	UNION ALL

	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,'' AS ysnRecipe
	,'' AS ysnQuote
	,MAX(CAST(a.ysnSalesOrder AS INT)) AS ysnSalesOrder
	,'' AS ysnPickList
	,'' AS ysnBOL
	,'' AS ysnInvoice
	,'' AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnSalesOrder = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnSalesOrder = 1) c
	WHERE ysnSalesOrder = 1
	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

	UNION ALL

	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,'' AS ysnRecipe
	,'' AS ysnQuote
	,'' AS ysnSalesOrder
	,MAX(CAST(a.ysnPickList AS INT)) AS ysnPickList
	,'' AS ysnBOL
	,'' AS ysnInvoice
	,'' AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnPickList = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnPickList = 1) c
	WHERE ysnPickList = 1
	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

	UNION ALL

	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,'' AS ysnRecipe
	,'' AS ysnQuote
	,'' AS ysnSalesOrder
	,'' AS ysnPickList
	,MAX(CAST(a.ysnBOL AS INT)) AS ysnBOL
	,'' AS ysnInvoice
	,'' AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnBOL = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnBOL = 1) c
	WHERE ysnBOL = 1
	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

	UNION ALL

	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,'' AS ysnRecipe
	,'' AS ysnQuote
	,'' AS ysnSalesOrder
	,'' AS ysnPickList
	,'' AS ysnBOL
	,MAX(CAST(a.ysnInvoice AS INT)) AS ysnInvoice
	,'' AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnInvoice = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnInvoice = 1) c
	WHERE ysnInvoice = 1
	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

	UNION ALL

	SELECT a.intDocumentMaintenanceId
	,d.strTitle
	,d.intCompanyLocationId
	,d.intLineOfBusinessId
	,d.intEntityCustomerId
	,d.strSource
	,d.strType
	,d.ysnCopyAll
	,d.strCode
	,b.intCharacterLimit AS intHeaderCharacterLimit
	,b.strMessage AS strHeader
	,c.intCharacterLimit AS intFooterCharacterLimit
	,c.strMessage AS strFooter
	,'' AS ysnRecipe
	,'' AS ysnQuote
	,'' AS ysnSalesOrder
	,'' AS ysnPickList
	,'' AS ysnBOL
	,'' AS ysnInvoice
	,MAX(CAST(a.ysnScaleTicket AS INT)) AS ysnScaleTicket
	FROM tblSMDocumentMaintenanceMessage a
	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnScaleTicket = 1) b
	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnScaleTicket = 1) c
	WHERE ysnScaleTicket = 1
	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage
) doc
GROUP BY intDocumentMaintenanceId, strTitle, intCompanyLocationId, intLineOfBusinessId, intEntityCustomerId, strSource, strType, ysnCopyAll, strCode, intHeaderCharacterLimit, strHeader, intFooterCharacterLimit, strFooter

GO
