CREATE VIEW [dbo].[vyuHDGroupUser]
	AS
		select
			intId = ROW_NUMBER() over (order by g.intTicketGroupId)
			,intTicketGroupId = g.intTicketGroupId
			,intUserSecurityId = u.[intEntityId]
			,intEntityId = u.[intEntityId]
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
			--,tblEMEntity e
			,vyuEMEntityContact e
			,[tblEMEntityCredential] c
		where
			gc.intTicketGroupId = g.intTicketGroupId
			and u.[intEntityId] = gc.intUserSecurityId
			and e.intEntityId = u.[intEntityId]
			and c.intEntityId = u.[intEntityId]
			and e.ysnDefaultContact = 1