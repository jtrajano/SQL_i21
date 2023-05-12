CREATE VIEW [dbo].[vyuSTSiteStatusSearch]
AS
SELECT		a.intStoreId,
			a.intStoreNo,
			a.strDescription,
			ISNULL(b.ysnInternetConnectivity, 0) as ysnInternetConnectivity,
			ISNULL(b.ysnRegisterConnectivity, 0) as ysnRegisterConnectivity,
			ISNULL(c.dblUploadSpeed,0) as dblUploadSpeed,
			(CASE WHEN FORMAT(dbo.fnSTGetCurrentBusinessDay(a.intStoreId), 'd','us') = FORMAT(GETDATE(), 'd','us') THEN 'Current'
				ELSE FORMAT(dbo.fnSTGetCurrentBusinessDay(a.intStoreId), 'd','us') END) as dtmCurrentBusinessDay,
			a.ysnConsignmentStore,
			reg.strStoreAppFileVersion as strStoreAppVersion,
			ISNULL((
				SELECT (CASE WHEN ch.ysnPosted = 1 THEN 'Posted' ELSE ch.strCheckoutStatus END) 
				FROM tblSTCheckoutHeader ch
				WHERE 
				ch.intStoreId = a.intStoreId 
				AND
				ch.dtmCheckoutDate = dbo.fnSTGetCurrentBusinessDay(a.intStoreId)
			), 'No Open End of Day') AS strEODStatus
FROM		tblSTStore a
LEFT JOIN	(	SELECT		intStoreId,
							ysnInternetConnectivity,
							ysnRegisterConnectivity,
							dblUploadSpeed,
							dtmStatusDate
				FROM		tblSTSiteStatus
				WHERE		intSiteStatusId IN (	SELECT		MAX(intSiteStatusId) 
													FROM		tblSTSiteStatus
													GROUP BY	intStoreId)) b
ON			a.intStoreId = b.intStoreId AND
			DATEDIFF(MINUTE, b.dtmStatusDate, GETDATE()) <= 2
LEFT JOIN	(	SELECT		intStoreId,
							dblUploadSpeed
				FROM		tblSTSiteStatus
				WHERE		intSiteStatusId IN (	SELECT		MAX(intSiteStatusId) 
													FROM		tblSTSiteStatus
													GROUP BY	intStoreId)) c
ON			a.intStoreId = c.intStoreId
INNER JOIN	vyuSTRegister reg ON a.intStoreId = reg.intStoreId