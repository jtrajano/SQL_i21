CREATE VIEW [dbo].[vyuCRMAgent]
	AS
		select
			c.intEntityId
			,c.strName
			,b.strUserName
			,a.ysnDisabled
		from
			tblSMUserSecurity a
			inner join tblEMEntityCredential b on b.intEntityId = a.[intEntityId]
			inner join tblEMEntity c on c.intEntityId = b.intEntityId