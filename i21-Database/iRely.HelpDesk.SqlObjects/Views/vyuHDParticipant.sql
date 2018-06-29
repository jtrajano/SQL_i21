CREATE VIEW [dbo].[vyuHDParticipant]
	AS
		select
			intId = vyuEMEntityContact2.intEntityContactId
			,intEntityId = vyuEMEntityContact2.intEntityId
			,strName = vyuEMEntityContact2.strName
			,strFullName = vyuEMEntityContact2.strName
			,strEmail = vyuEMEntityContact2.strEmail
			,ysnDisabled = (case when vyuEMEntityContact2.ysnActive = convert(bit,1) then convert(bit,0) else convert(bit,1) end)
			,strPhone = vyuEMEntityContact2.strPhone
			,strMobile = vyuEMEntityContact2.strMobile
			,strType = vyuEMEntityContact2.strContactType
		from
			vyuEMEntityContact2
		where
			ysnDefaultContact = convert(bit,1)
			and strName is not null

	/*
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
	*/
