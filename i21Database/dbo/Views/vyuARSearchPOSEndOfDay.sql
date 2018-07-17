CREATE VIEW [dbo].[vyuARSearchPOSEndOfDay]
AS 
SELECT intPOSLogId			= POSLOG.intPOSLogId
	 , intEntityUserId		= POSLOG.intEntityUserId
	 , intCompanyLocationId	= POSLOG.intCompanyLocationId
	 , intStoreId			= POSLOG.intStoreId	 
	 , dtmLogin				= POSLOG.dtmLogin
	 , dtmLogout			= POSLOG.dtmLogout
	 , dblOpeningBalance	= POSLOG.dblOpeningBalance
	 , dblEndingBalance		= POSLOG.dblEndingBalance
	 , strLocation			= COMPANYLOCATION.strLocationName
	 , strStoreName			= STORE.strDescription
	 , strUserName			= USERNAME.strName
FROM dbo.tblARPOSLog POSLOG WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERNAME ON POSLOG.intEntityUserId = USERNAME.intEntityId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) COMPANYLOCATION ON POSLOG.intCompanyLocationId = COMPANYLOCATION.intCompanyLocationId
LEFT JOIN (
	SELECT intStoreId
		 , strDescription
	FROM dbo.tblSTStore WITH (NOLOCK)
) STORE ON POSLOG.intStoreId = STORE.intStoreId
WHERE POSLOG.dtmLogout IS NOT NULL