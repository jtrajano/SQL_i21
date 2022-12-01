CREATE VIEW [dbo].[vyuSTSiteStatusSearch]
AS
SELECT		a.intStoreId,
			a.intStoreNo,
			a.strDescription,
			ISNULL(b.ysnInternetConnectivity, 0) as ysnInternetConnectivity,
			ISNULL(b.ysnRegisterConnectivity, 0) as ysnRegisterConnectivity,
			FORMAT(dbo.fnSTGetCurrentBusinessDay(a.intStoreId), 'd','us')  as dtmCurrentBusinessDay
FROM		tblSTStore a
LEFT JOIN	(	SELECT		intStoreId,
							ysnInternetConnectivity,
							ysnRegisterConnectivity,
							dtmStatusDate
				FROM		tblSTSiteStatus
				WHERE		intSiteStatusId IN (	SELECT		MAX(intSiteStatusId) 
													FROM		tblSTSiteStatus
													GROUP BY	intStoreId)) b
ON			a.intStoreId = b.intStoreId AND
			DATEDIFF(MINUTE, b.dtmStatusDate, GETDATE()) <= 2