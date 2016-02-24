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
		tblSMUserSecurity us, vyuEMEntityContact en, tblEntityCredential ec
	where
		us.[intEntityUserSecurityId] is not null
		and en.intEntityId = us.[intEntityUserSecurityId]
		and ec.intEntityId = us.[intEntityUserSecurityId]
		and en.ysnDefaultContact = 1

	union all

	select
		strName = ec.strUserName
		,intId = etc.intEntityContactId
		,strFullName = en.strName
		,strEmail = en.strEmail
		,intEntityId = us.intEntitySalespersonId
		,ysnDisabled = (case when convert(bit, us.ysnActive) = 0 then 1 else 0 end)
	from
		tblARSalesperson us, tblEntityToContact etc, tblEntity en, tblEntityCredential ec
	where
		us.intEntitySalespersonId is not null
		and etc.intEntityId = us.intEntitySalespersonId
		and en.intEntityId = etc.intEntityContactId
		and ec.intEntityId = etc.intEntityContactId
/*
	select
		strName = ec.strUserName,
		intId = us.[intEntityUserSecurityId],
		strFullName = en.strName,
		strEmail = en.strEmail,
		intEntityId = us.[intEntityUserSecurityId],
		ysnDisabled = us.ysnDisabled
	from
		tblSMUserSecurity us, vyuEMEntityContact en, tblEntityCredential ec
	where
		us.[intEntityUserSecurityId] is not null
		and en.intEntityId = us.[intEntityUserSecurityId]
		and ec.intEntityId = us.[intEntityUserSecurityId]
		and en.ysnDefaultContact = 1
*/