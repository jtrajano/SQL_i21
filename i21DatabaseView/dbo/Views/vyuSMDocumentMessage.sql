CREATE VIEW [dbo].[vyuSMDocumentMaintenanceMessage]
AS 

SELECT 
intDocumentMaintenanceId
,strTitle
,intCompanyLocationId
,intLineOfBusinessId
,intEntityCustomerId
,strSource
,strType
,ysnCopyAll
,strCode
,intHeaderCharacterLimit = NULL
,intFooterCharacterLimit= NULL
,Header AS strHeader
,Footer as strFooter
,strOptionName
FROM
(
 SELECT A.intDocumentMaintenanceId, A.strTitle, A.intCompanyLocationId, A.intLineOfBusinessId, A.intEntityCustomerId, A.strSource, A.strType, A.ysnCopyAll, A.strCode, B.strHeaderFooter, B.strMessage, C.strOptionName FROM tblSMDocumentMaintenance A JOIN tblSMDocumentMaintenanceMessage B 
ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId 
JOIN vyuSMDocumentMessageMaintenanceOption C ON C.intDocumentMaintenanceMessageId = B.intDocumentMaintenanceMessageId and C.ysnValue =1
) d
pivot
(
 MAX(strMessage)
 FOR strHeaderFooter in (Header, Footer)
) piv

--SELECT intDocumentMaintenanceId
--,strTitle
--,intCompanyLocationId
--,intLineOfBusinessId
--,intEntityCustomerId
--,strSource
--,strType
--,ysnCopyAll
--,strCode
--,MAX(intHeaderCharacterLimit) AS intHeaderCharacterLimit
--,MAX(strHeader) AS strHeader
--,MAX(intFooterCharacterLimit) AS intFooterCharacterLimit
--,MAX(strFooter) AS strFooter
--,strOptionName
--FROM (
--		SELECT unpvt.intDocumentMaintenanceId
--		,ac.strTitle AS strTitle 
--		,ac.intCompanyLocationId AS intCompanyLocationId 
--		,ac.intLineOfBusinessId AS intLineOfBusinessId 
--		,ac.intEntityCustomerId AS intEntityCustomerId 
--		,ac.strSource AS strSource 
--		,ac.strType AS strType 
--		,ac.ysnCopyAll AS ysnCopyAll 
--		,ac.strCode AS strCode 
--		,ad.intCharacterLimit AS intHeaderCharacterLimit
--		,ad.strMessage AS strHeader
--		,ae.intCharacterLimit AS intFooterCharacterLimit
--		,ae.strMessage AS strFooter
--		,REPLACE(strProcess, 'ysn', '') AS strOptionName
--		FROM tblSMDocumentMaintenanceMessage a
--		UNPIVOT
--		(
--			ysnValue FOR strProcess IN (ysnRecipe, ysnQuote, ysnSalesOrder, ysnPickList, ysnBOL, ysnInvoice, ysnScaleTicket)
--		) AS unpvt
--		CROSS APPLY (SELECT strTitle, intCompanyLocationId, intLineOfBusinessId, intEntityCustomerId, strSource, strType, ysnCopyAll, strCode FROM tblSMDocumentMaintenance WHERE intDocumentMaintenanceId = unpvt.intDocumentMaintenanceId) ac
--		CROSS APPLY (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' AND intDocumentMaintenanceId = unpvt.intDocumentMaintenanceId) ad
--		CROSS APPLY (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' AND intDocumentMaintenanceId = unpvt.intDocumentMaintenanceId) ae
--		WHERE ysnValue = 1
--) B
--GROUP BY intDocumentMaintenanceId, strTitle, intCompanyLocationId, intLineOfBusinessId, intEntityCustomerId, strSource, strType, ysnCopyAll, strCode, strOptionName

--SELECT intDocumentMaintenanceId
--,strTitle
--,intCompanyLocationId
--,intLineOfBusinessId
--,intEntityCustomerId
--,strSource
--,strType
--,ysnCopyAll
--,strCode
--,intHeaderCharacterLimit
--,strHeader
--,intFooterCharacterLimit
--,strFooter
--,CAST(MAX(ysnRecipe) AS BIT) AS ysnRecipe
--,CAST(MAX(ysnQuote) AS BIT) AS ysnQuote
--,CAST(MAX(ysnSalesOrder) AS BIT) AS ysnSalesOrder
--,CAST(MAX(ysnPickList) AS BIT) AS ysnPickList
--,CAST(MAX(ysnBOL) AS BIT) AS ysnBOL
--,CAST(MAX(ysnInvoice) AS BIT) AS ysnInvoice
--,CAST(MAX(ysnScaleTicket) AS BIT) AS ysnScaleTicket
--FROM
--(
--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,MAX(CAST(a.ysnRecipe AS INT)) AS ysnRecipe
--	,'' AS ysnQuote
--	,'' AS ysnSalesOrder
--	,'' AS ysnPickList
--	,'' AS ysnBOL
--	,'' AS ysnInvoice
--	,'' AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnRecipe = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnRecipe = 1) c
--	WHERE ysnRecipe = 1
--	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

--	UNION ALL

--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,'' AS ysnRecipe
--	,MAX(CAST(a.ysnQuote AS INT)) AS ysnQuote
--	,'' AS ysnSalesOrder
--	,'' AS ysnPickList
--	,'' AS ysnBOL
--	,'' AS ysnInvoice
--	,'' AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnQuote = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnQuote = 1) c
--	WHERE ysnQuote = 1
--	GROUP BY a.intDocumentMaintenanceId, strTitle, intCompanyLocationId, intLineOfBusinessId, intEntityCustomerId, strSource, strType, ysnCopyAll, strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

--	UNION ALL

--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,'' AS ysnRecipe
--	,'' AS ysnQuote
--	,MAX(CAST(a.ysnSalesOrder AS INT)) AS ysnSalesOrder
--	,'' AS ysnPickList
--	,'' AS ysnBOL
--	,'' AS ysnInvoice
--	,'' AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnSalesOrder = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnSalesOrder = 1) c
--	WHERE ysnSalesOrder = 1
--	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

--	UNION ALL

--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,'' AS ysnRecipe
--	,'' AS ysnQuote
--	,'' AS ysnSalesOrder
--	,MAX(CAST(a.ysnPickList AS INT)) AS ysnPickList
--	,'' AS ysnBOL
--	,'' AS ysnInvoice
--	,'' AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnPickList = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnPickList = 1) c
--	WHERE ysnPickList = 1
--	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

--	UNION ALL

--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,'' AS ysnRecipe
--	,'' AS ysnQuote
--	,'' AS ysnSalesOrder
--	,'' AS ysnPickList
--	,MAX(CAST(a.ysnBOL AS INT)) AS ysnBOL
--	,'' AS ysnInvoice
--	,'' AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnBOL = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnBOL = 1) c
--	WHERE ysnBOL = 1
--	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

--	UNION ALL

--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,'' AS ysnRecipe
--	,'' AS ysnQuote
--	,'' AS ysnSalesOrder
--	,'' AS ysnPickList
--	,'' AS ysnBOL
--	,MAX(CAST(a.ysnInvoice AS INT)) AS ysnInvoice
--	,'' AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnInvoice = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnInvoice = 1) c
--	WHERE ysnInvoice = 1
--	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage

--	UNION ALL

--	SELECT a.intDocumentMaintenanceId
--	,d.strTitle
--	,d.intCompanyLocationId
--	,d.intLineOfBusinessId
--	,d.intEntityCustomerId
--	,d.strSource
--	,d.strType
--	,d.ysnCopyAll
--	,d.strCode
--	,b.intCharacterLimit AS intHeaderCharacterLimit
--	,b.strMessage AS strHeader
--	,c.intCharacterLimit AS intFooterCharacterLimit
--	,c.strMessage AS strFooter
--	,'' AS ysnRecipe
--	,'' AS ysnQuote
--	,'' AS ysnSalesOrder
--	,'' AS ysnPickList
--	,'' AS ysnBOL
--	,'' AS ysnInvoice
--	,MAX(CAST(a.ysnScaleTicket AS INT)) AS ysnScaleTicket
--	FROM tblSMDocumentMaintenanceMessage a
--	inner join tblSMDocumentMaintenance d ON a.intDocumentMaintenanceId = d.intDocumentMaintenanceId
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Header' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnScaleTicket = 1) b
--	outer apply (SELECT intCharacterLimit, strMessage FROM tblSMDocumentMaintenanceMessage WHERE strHeaderFooter = 'Footer' and intDocumentMaintenanceId = a.intDocumentMaintenanceId and ysnScaleTicket = 1) c
--	WHERE ysnScaleTicket = 1
--	GROUP BY a.intDocumentMaintenanceId, d.strTitle, d.intCompanyLocationId, d.intLineOfBusinessId, d.intEntityCustomerId, d.strSource, d.strType, d.ysnCopyAll, d.strCode, b.intCharacterLimit, b.strMessage, c.intCharacterLimit, c.strMessage
--) doc
--GROUP BY intDocumentMaintenanceId, strTitle, intCompanyLocationId, intLineOfBusinessId, intEntityCustomerId, strSource, strType, ysnCopyAll, strCode, intHeaderCharacterLimit, strHeader, intFooterCharacterLimit, strFooter

GO
