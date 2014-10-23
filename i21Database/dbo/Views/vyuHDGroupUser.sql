CREATE VIEW [dbo].[vyuHDGroupUser]
	AS
		select
			intId = ROW_NUMBER() over (order by g.intTicketGroupId)
			,intTicketGroupId = g.intTicketGroupId
			,intUserSecurityId = u.intUserSecurityID
			,intEntityId = u.intEntityId
			,strUserName = c.strUserName
			,strFullName = e.strName
			,strEmail = e.strEmail
			,ysnOwner = gc.ysnOwner
			,intGroupUserConfigId = gc.intGroupUserConfigId
		from
			tblHDTicketGroup g
			,tblHDGroupUserConfig gc
			,tblSMUserSecurity u
			,tblEntity e
			,tblEntityCredential c
		where
			gc.intTicketGroupId = g.intTicketGroupId
			and u.intUserSecurityID = gc.intUserSecurityId
			and e.intEntityId = u.intEntityId
			and c.intEntityId = u.intEntityId