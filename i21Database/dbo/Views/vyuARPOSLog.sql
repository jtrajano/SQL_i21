CREATE VIEW [dbo].[vyuARPOSLog]
	AS 
SELECT
		 intPOSLogId					=	POSLog.intPOSLogId
		,intEntityId					=	POSLog.intEntityUserId
		,intCompanyLocationId			=	POSLog.intCompanyLocationId
		,intCashOverShort				=	LOC.intCashOverShort
		,intCompanyLocationPOSDrawerId	=	POSLog.intCompanyLocationPOSDrawerId
		,intStoreId						=	POSLog.intStoreId
		,intPOSLogOriginId				=	POSLog.intPOSLogOriginId
		,dblOpeningBalance				=	POSLog.dblOpeningBalance
		,dblEndingBalance				=	POSLog.dblEndingBalance
		,strUsername					=	ENTITY.strUserName
		,strLocationName				=	LOC.strLocationName
		,strPOSDrawerName				=	DRAWER.strPOSDrawerName
		,strStoreName					=	STORE.strDescription
		,dtmLogin						=	POSLog.dtmLogin
		,dtmLogout						=	POSLog.dtmLogout
		,ysnLoggedIn					=	POSLog.ysnLoggedIn
		,ysnAllowMultipleUser			=	DRAWER.ysnAllowMultipleUser
 FROM tblARPOSLog POSLog WITH (NOLOCK)
INNER JOIN (
	SELECT
		intCompanyLocationId
		,strLocationName
		,intCashOverShort
	FROM tblSMCompanyLocation WITH (NOLOCK)
 ) LOC ON POSLog.intCompanyLocationId = LOC.intCompanyLocationId
LEFT JOIN(
	SELECT
		intCompanyLocationPOSDrawerId
		,strPOSDrawerName
		,ysnAllowMultipleUser
	FROM tblSMCompanyLocationPOSDrawer WITH (NOLOCK)
) DRAWER ON POSLog.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
LEFT JOIN (
	SELECT 
		intStoreId
		,strDescription
	FROM tblSTStore WITH (NOLOCK)
) STORE ON POSLog.intStoreId = STORE.intStoreId
INNER JOIN (
	SELECT intEntityId
		 , strUserName 
	FROM dbo.tblEMEntityCredential WITH (NOLOCK)
) ENTITY ON POSLog.intEntityUserId = ENTITY.intEntityId
