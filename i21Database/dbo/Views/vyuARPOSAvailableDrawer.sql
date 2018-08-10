CREATE VIEW [dbo].[vyuARPOSAvailableDrawer]
	AS 
	SELECT DISTINCT intPOSLogId,
	   DRAWER.intCompanyLocationPOSDrawerId, 
	   intCompanyLocationId, 
	   strPOSDrawerName, 
	   ysnAllowMultipleUser, 
	   ysnLoggedIn

FROM tblSMCompanyLocationPOSDrawer DRAWER
LEFT JOIN (
	SELECT intPOSLogId,
			intCompanyLocationPOSDrawerId,
			ysnLoggedIn
	FROM vyuPOSGetLoggedIn
) POSLOG ON  POSLOG.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
WHERE ysnAllowMultipleUser = 1
OR (ysnAllowMultipleUser = 0 AND ISNULL(ysnLoggedIn, 0) = 0) --single user drawer with no logged user