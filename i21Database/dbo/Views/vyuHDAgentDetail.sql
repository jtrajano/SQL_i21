CREATE VIEW [dbo].[vyuHDAgentDetail]
	AS
	select
		strName = ec.strUserName,
		intId = us.[intEntityUserSecurityId],
		strFullName = en.strName,
		strEmail = en.strEmail,
		intEntityId = us.[intEntityUserSecurityId],
		ysnDisabled = us.ysnDisabled,
		strPhone = en.strPhone,
		strMobile = en.strMobile
	from
		tblSMUserSecurity us
		inner join vyuEMEntityContact en on en.intEntityId = us.[intEntityUserSecurityId] and en.ysnDefaultContact = 1
		inner join [tblEMEntityCredential] ec on ec.intEntityId = us.[intEntityUserSecurityId]
	where
		us.[intEntityUserSecurityId] is not null

	union all

	select
		strName = ec.strUserName
		,intId = etc.intEntityContactId
		,strFullName = en.strName
		,strEmail = en.strEmail
		,intEntityId = us.[intEntityId]
		,ysnDisabled = (case when convert(bit, us.ysnActive) = 0 then convert(bit, 1) else convert(bit, 0) end),
		strPhone = en.strPhone,
		strMobile = en.strMobile
	from
		tblARSalesperson us, [tblEMEntityToContact] etc, tblEMEntity en, [tblEMEntityCredential] ec
	where
		us.[intEntityId] is not null
		and etc.intEntityId = us.[intEntityId]
		and en.intEntityId = etc.intEntityContactId
		and ec.intEntityId = etc.intEntityContactId