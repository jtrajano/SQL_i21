CREATE VIEW [dbo].[vyuPOSGetLoggedIn]
	AS 
	SELECT DISTINCT
	  intEntityId			= entity.intEntityId
	 ,strName				= entity.strName
	 ,strUserName			= EC.strUserName
	 ,strEmail				= EC.strEmail
	 ,ysnEmailConfirmed		= EC.ysnEmailConfirmed
	 ,intEntityUserId		= pos.intEntityUserId
	 ,intPOSLogId			= pos.intPOSLogId
	 ,intPOSLogOriginId		= pos.intPOSLogOriginId
	 ,intStoreId			= pos.intStoreId
	 ,intStoreNo			= STORE.intStoreNo
	 ,strStoreDescription	= STORE.strDescription
	 ,intCompanyLocationId	= pos.intCompanyLocationId
	 ,strLocationName		= LOC.strLocationName
	 ,dblEndingBalance		= ISNULL(pos.dblEndingBalance,0)
	 ,dblOpeningBalance		= ISNULL(pos.dblOpeningBalance,0)
	 ,dtmLogin				= pos.dtmLogin
	 ,dtmLogout				= ISNULL(pos.dtmLogout, GETDATE())
	 ,ysnLoggedIn			= pos.ysnLoggedIn
FROM tblEMEntity entity
LEFT JOIN tblARPOSLog pos ON pos.intEntityUserId = entity.intEntityId
LEFT JOIN(
	SELECT
		intEntityId,
		strUserName,
		strEmail,
		ysnEmailConfirmed
	FROM
		tblEMEntityCredential
) EC ON EC.intEntityId = entity.intEntityId
LEFT JOIN(
	SELECT
		intCompanyLocationId,
		strLocationName
	FROM
		tblSMCompanyLocation
) LOC ON LOC.intCompanyLocationId = pos.intCompanyLocationId
LEFT JOIN(
	SELECT
		intStoreId,
		intStoreNo,
		strDescription
	FROM
		tblSTStore
) STORE ON STORE.intStoreId = pos.intStoreId
WHERE pos.ysnLoggedIn = 1