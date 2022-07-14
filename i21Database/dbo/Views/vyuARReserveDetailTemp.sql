CREATE VIEW [dbo].[vyuARReserveDetailTemp]
AS
SELECT
	 ARCATS.intEntityUserId
	,ARCATS.intInvoiceId
	,ARCATS.strCustomerName
	,ARCATS.dblCreditLimit
	,ARCATS.strInvoiceNumber
	,strGLLocation			= ISNULL(GLLA.strDescription, '')
	,strGLLineOfBusiness	= ISNULL(GLLOB.strDescription, '')
	,dbl30Days				= SUM(ARCATS.dbl30Days)
	,dbl60Days				= SUM(ARCATS.dbl60Days)
	,dbl90Days				= SUM(ARCATS.dbl90Days)
	,dbl120Days				= SUM(ARCATS.dbl120Days)
FROM tblARCustomerAgingStagingTable ARCATS
LEFT JOIN vyuGLLocationAccountId GLLA ON ARCATS.intAccountId = GLLA.intAccountId
LEFT JOIN (
	SELECT TOP 1 GLASM.intAccountId, GLAS.strDescription
	FROM tblGLAccountSegmentMapping GLASM
	INNER JOIN tblGLAccountSegment GLAS ON GLAS.intAccountSegmentId = GLASM.intAccountSegmentId
	INNER JOIN  tblGLAccountStructure GLASt ON GLASt.intAccountStructureId = GLAS.intAccountStructureId
	WHERE GLASt.intStructureType = 5

) GLLOB ON ARCATS.intAccountId = GLLOB.intAccountId
WHERE ISNULL(ARCATS.intInvoiceId, 0) <> 0
GROUP BY 
	 ARCATS.intInvoiceId
	,ARCATS.strCustomerName
	,ARCATS.dblCreditLimit
	,ARCATS.strInvoiceNumber
	,GLLA.strDescription
	,GLLOB.strDescription
	,ARCATS.intEntityUserId