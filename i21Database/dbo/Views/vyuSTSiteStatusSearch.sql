CREATE VIEW [dbo].[vyuSTSiteStatusSearch]
AS
SELECT		a.intStoreId,
			a.intStoreNo,
			a.strDescription,
			ISNULL(b.ysnInternetConnectivity, 0) as ysnInternetConnectivity,
			ISNULL(b.ysnRegisterConnectivity, 0) as ysnRegisterConnectivity
FROM		tblSTStore a
LEFT JOIN	tblSTSiteStatus b
ON			a.intStoreId = b.intStoreId AND
			DATEDIFF(MINUTE, b.dtmStatusDate, GETDATE()) <= 6