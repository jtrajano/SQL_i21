CREATE VIEW [dbo].[vyuARPOSSearchLoggedIn]
AS 
SELECT DISTINCT POS.intEntityId, EN.strUserName, POS.ysnLoggedIn
FROM dbo.tblARPOSLog POS WITH(NOLOCK)
INNER JOIN (
	SELECT intEntityId, strUserName 
	FROM dbo.tblSMUserSecurity WITH(NOLOCK)
)EN ON POS.intEntityId = EN.intEntityId
