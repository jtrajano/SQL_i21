CREATE VIEW [dbo].[vyuARPOSOpenDrawers]
	AS 
	SELECT DISTINCT 
			intCompanyLocationPOSDrawerId	=	POSLOG.intCompanyLocationPOSDrawerId,
			strPOSDrawerName				=	DRAWER.strPOSDrawerName,
			dblOpeningBalance				=	POSLOG.dblOpeningBalance,
			dblEndingBalance				=	SUM(ISNULL(dblEndingBalance,0))

	FROM tblARPOSLog POSLOG
	LEFT JOIN (
		SELECT
			intCompanyLocationPOSDrawerId,
			strPOSDrawerName
		FROM tblSMCompanyLocationPOSDrawer
	) DRAWER ON POSLOG.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
	WHERE POSLOG.intCompanyLocationPOSDrawerId IS NOT NULL AND ysnLoggedIn = 1
	GROUP BY POSLOG.intCompanyLocationPOSDrawerId, dblOpeningBalance, DRAWER.strPOSDrawerName

