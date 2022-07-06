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
			inner join tblHDGroupUserConfig gc on gc.intTicketGroupId = g.intTicketGroupId
			inner join tblSMUserSecurity u on u.[intEntityId] = gc.intUserSecurityId
			inner join vyuEMEntityContact e on e.intEntityId = u.[intEntityId]
			inner join tblEMEntityCredential c on c.intEntityId = u.[intEntityId]
		where
			e.ysnDefaultContact = 1