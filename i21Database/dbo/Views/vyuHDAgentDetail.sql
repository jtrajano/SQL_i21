﻿CREATE VIEW [dbo].[vyuHDAgentDetail]
	AS
	select
		strName = ec.strUserName,
		intId = us.[intEntityId],
		strFullName = ue.strName,
		strEmail = en.strEmail,
		intEntityId = us.[intEntityId],
		ysnDisabled = us.ysnDisabled,
		strPhone = en.strPhone,
		strMobile = en.strMobile,
		us.strJIRAUserName,
		ysnVendor = (select case when count(*) < 1 then convert(bit,0) else convert(bit,1) end from tblEMEntityType where intEntityId = us.intEntityId and strType = 'Vendor')
	from
		tblSMUserSecurity us
		inner join vyuEMEntityContact en on en.intEntityId = us.[intEntityId] and en.ysnDefaultContact = 1
		inner join [tblEMEntityCredential] ec on ec.intEntityId = us.[intEntityId]
		inner join tblEMEntity ue on ue.intEntityId = us.intEntityId
	where
		us.[intEntityId] is not null

	union all

	select
		strName = ec.strUserName
		,intId = etc.intEntityContactId
		,strFullName = en.strName
		,strEmail = en.strEmail
		,intEntityId = us.[intEntityId]
		,ysnDisabled = (case when convert(bit, us.ysnActive) = 0 then convert(bit, 1) else convert(bit, 0) end),
		strPhone = en.strPhone,
		strMobile = en.strMobile,
		strJIRAUserName = (select strJIRAUserName from tblSMUserSecurity where intEntityId = us.intEntityId),
		ysnVendor = (select case when count(*) < 1 then convert(bit,0) else convert(bit,1) end from tblEMEntityType where intEntityId = us.intEntityId and strType = 'Vendor')
	from
		tblARSalesperson us
		inner join tblEMEntityToContact etc on etc.intEntityId = us.intEntityId
		inner join tblEMEntity en on en.intEntityId = etc.intEntityContactId
		inner join tblEMEntityCredential ec on ec.intEntityId = etc.intEntityContactId
	where
		us.[intEntityId] is not null