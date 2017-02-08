CREATE VIEW [dbo].[vyuHDParticipant]
	AS
	select
		intId = (case when result.ysnPortalAccess = 1 then result.intEntityContactId else result.intEntityId end)
		,intEntityId = (case when result.ysnPortalAccess = 1 then result.intEntityContactId else result.intEntityId end)
		,strName = (case when result.ysnPortalAccess = 1 then result.strEmail else (select top 1 tblEMEntityCredential.strUserName from tblEMEntityCredential where tblEMEntityCredential.intEntityId = result.intEntityId) end)
		,strFullName = result.strName
		,result.strEmail
		,ysnDisabled = (case when result.ysnActive = 1 then 0 else 1 end)
		,result.strPhone
		,result.strMobile
		,strType = (case when result.ysnPortalAccess = 1 then 'Contact' else 'User' end)
	from
	(
	select * from vyuEMEntityContact where [User] = 1 and ysnPortalAccess = 0
	union all
	select * from vyuEMEntityContact where [User] <> 1 and ysnPortalAccess = 1
	) as result
