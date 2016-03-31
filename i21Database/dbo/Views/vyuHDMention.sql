﻿CREATE VIEW [dbo].[vyuHDMention]
	AS
	select
		strId = NEWID()
		,cu.intEntityCustomerId
		,cu.strCustomerNumber
		,intEntityContactId = con.intEntityId
		,con.strName
		,con.strEmail
		,con.imgPhoto
		,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = cu.intEntityCustomerId and et.strType in ('Customer','Prospect'))
	from
		tblARCustomer cu
		--left outer join tblARCustomerToContact cc on cc.intEntityCustomerId = cu.intEntityCustomerId
		left outer join [tblEMEntityToContact] cc on cc.intEntityId = cu.intEntityCustomerId
		left outer join tblEMEntity con on con.intEntityId = cc.intEntityContactId and con.ysnActive = 1
	where cu.ysnActive = 1
	union all
	select
		strId = NEWID()
		,intEntityCustomerId = us.[intEntityUserSecurityId]
		,strCustomerNumber = 'INTERNALUSER'
		,intEntityContactId = con.intEntityId
		,con.strName
		,con.strEmail
		,con.imgPhoto
		,strEntityType = 'Agent'
	from
		tblSMUserSecurity us
		left outer join vyuEMEntityContact con on con.intEntityId = us.[intEntityUserSecurityId] and con.ysnDefaultContact = 1
		--left outer join tblEntity con on con.intEntityId = us.[intEntityUserSecurityId]
	where us.ysnDisabled <> 1
