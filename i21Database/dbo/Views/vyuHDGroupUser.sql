﻿CREATE VIEW [dbo].[vyuHDGroupUser]
	AS
		select
			intId = ROW_NUMBER() over (order by g.intTicketGroupId)
			,intTicketGroupId = g.intTicketGroupId
			,intUserSecurityId = u.[intEntityUserSecurityId]
			,intEntityId = u.[intEntityUserSecurityId]
			,strUserName = c.strUserName
			,strFullName = e.strName
			,strEmail = e.strEmail
			,ysnOwner = gc.ysnOwner
			,ysnEscalation = gc.ysnEscalation
			,intGroupUserConfigId = gc.intGroupUserConfigId
		from
			tblHDTicketGroup g
			,tblHDGroupUserConfig gc
			,tblSMUserSecurity u
			--,tblEntity e
			,vyuEMEntityContact e
			,[tblEMEntityCredential] c
		where
			gc.intTicketGroupId = g.intTicketGroupId
			and u.[intEntityUserSecurityId] = gc.intUserSecurityId
			and e.intEntityId = u.[intEntityUserSecurityId]
			and c.intEntityId = u.[intEntityUserSecurityId]
			and e.ysnDefaultContact = 1