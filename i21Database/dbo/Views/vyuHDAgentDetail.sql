CREATE VIEW [dbo].[vyuHDAgentDetail]
	AS
		select
			strName = ec.strUserName,
			intId = us.intUserSecurityID,
			strFullName = en.strName,
			strEmail = en.strEmail,
			intEntityId = us.intEntityId
		from
			tblSMUserSecurity us, tblEntity en, tblEntityCredential ec
		where
			us.intEntityId is not null
			and en.intEntityId = us.intEntityId
			and ec.intEntityId = us.intEntityId
