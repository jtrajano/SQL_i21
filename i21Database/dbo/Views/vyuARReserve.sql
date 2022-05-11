CREATE VIEW [dbo].[vyuARReserve]
AS
SELECT
	 ARCAD.intInvoiceId
	,ARCAD.strCustomerName
	,ARCAD.dblCreditLimit
	,ARCAD.strInvoiceNumber
	,strGLLocation			= GLLA.strDescription
	,strGLLineOfBusiness	= GLLOB.strDescription
	,dbl30Days				= SUM(ARCAD.dbl30Days)
	,dbl60Days				= SUM(ARCAD.dbl60Days)
	,dbl90Days				= SUM(ARCAD.dbl90Days)
	,dbl120Days				= SUM(ARCAD.dbl120Days)
	,dbl30DaysReserve		= SUM(ARCAD.dbl30Days) * (dblReserveBucket30Percentage / 100)
	,dbl60DaysReserve		= SUM(ARCAD.dbl60Days) * (dblReserveBucket60Percentage / 100)
	,dbl90DaysReserve		= SUM(ARCAD.dbl90Days) * (dblReserveBucket90Percentage / 100)
	,dbl120DaysReserve		= SUM(ARCAD.dbl120Days) * (dblReserveBucket120Percentage / 100)
	,dblTotalReserve		= (SUM(ARCAD.dbl30Days) * (dblReserveBucket30Percentage / 100)) + (SUM(ARCAD.dbl60Days) * (dblReserveBucket60Percentage / 100)) + (SUM(ARCAD.dbl90Days) * (dblReserveBucket90Percentage / 100)) + (SUM(ARCAD.dbl120Days) * (dblReserveBucket120Percentage / 100))
	,dblNewReserve			= ISNULL(ARR.dblNewReserve, 0)
FROM fnARCustomerAgingDetail(NULL, GETDATE(), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ARCAD
LEFT JOIN vyuGLLocationAccountId GLLA ON ARCAD.intAccountId = GLLA.intAccountId
LEFT JOIN (
	SELECT GLTCS.intAccountId, GLAS.strDescription
	FROM tblGLTempCOASegment GLTCS
	JOIN tblGLAccountSegment GLAS ON GLTCS.[Line of business] COLLATE Latin1_General_CI_AS = GLAS.strCode
	JOIN tblGLAccountStructure GLASt ON GLASt.intAccountStructureId = GLAS.intAccountStructureId
	WHERE GLASt.strStructureName = 'Line of business'
) GLLOB ON ARCAD.intAccountId = GLLOB.intAccountId
LEFT JOIN tblARReserve ARR ON ARCAD.intInvoiceId = ARR.intInvoiceId
OUTER APPLY (
	SELECT TOP 1
		 dblReserveBucket30Percentage
		,dblReserveBucket60Percentage
		,dblReserveBucket90Percentage
		,dblReserveBucket120Percentage
	FROM tblARCompanyPreference
) ARCP
WHERE ISNULL(ARCAD.intInvoiceId, 0) <> 0
GROUP BY 
	 ARCAD.intInvoiceId
	,ARCAD.strCustomerName
	,ARCAD.dblCreditLimit
	,ARCAD.strInvoiceNumber
	,GLLA.strDescription
	,GLLOB.strDescription
	,dblReserveBucket30Percentage
	,dblReserveBucket60Percentage
	,dblReserveBucket90Percentage
	,dblReserveBucket120Percentage
	,dblNewReserve