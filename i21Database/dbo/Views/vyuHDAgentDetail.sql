CREATE VIEW [dbo].[vyuHDAgentDetail]
	AS
	select
		strName = ec.strUserName,
		intId = us.[intEntityUserSecurityId],
		strFullName = en.strName,
		strEmail = en.strEmail,
		intEntityId = us.[intEntityUserSecurityId],
		ysnDisabled = us.ysnDisabled
	from
		--tblSMUserSecurity us, tblEntity en, tblEntityCredential ec
		tblSMUserSecurity us, vyuEMEntityContact en, tblEntityCredential ec
	where
		us.[intEntityUserSecurityId] is not null
		and en.intEntityId = us.[intEntityUserSecurityId]
		and ec.intEntityId = us.[intEntityUserSecurityId]
		and en.ysnDefaultContact = 1