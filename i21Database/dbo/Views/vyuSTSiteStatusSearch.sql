CREATE VIEW [dbo].[vyuSTSiteStatusSearch]
AS
SELECT		a.intStoreId,
			a.intStoreNo,
			a.strDescription,
			ISNULL(b.ysnInternetConnectivity, 0) as ysnInternetConnectivity,
			ISNULL(b.ysnRegisterConnectivity, 0) as ysnRegisterConnectivity,
			ISNULL(c.dblUploadSpeed,0) as dblUploadSpeed,
			FORMAT(dbo.fnSTGetCurrentBusinessDay(a.intStoreId), 'd','us')  as dtmCurrentBusinessDay,
			a.ysnConsignmentStore,
			reg.strStoreAppFileVersion as strStoreAppVersion
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