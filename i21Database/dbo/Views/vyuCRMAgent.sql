﻿CREATE VIEW [dbo].[vyuCRMAgent]
	AS
		select
			c.intEntityId
			,c.strName
			,b.strUserName
			,a.ysnDisabled
		from
			tblSMUserSecurity a
			,tblEMEntityCredential b
			,tblEMEntity c
		where
			b.intEntityId = a.intEntityUserSecurityId
			and c.intEntityId = b.intEntityId
