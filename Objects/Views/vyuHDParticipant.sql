CREATE VIEW [dbo].[vyuHDParticipant]
	AS
		select distinct
			intId = vyuEMEntityContact2.intEntityContactId
			,intEntityId = vyuEMEntityContact2.intEntityId
			,strName = vyuEMEntityContact2.strName
			,strFullName = vyuEMEntityContact2.strName
			,strEmail = vyuEMEntityContact2.strEmail
			,ysnDisabled = (case when vyuEMEntityContact2.ysnActive = convert(bit,1) then convert(bit,0) else convert(bit,1) end)
			,strPhone = vyuEMEntityContact2.strPhone
			,strMobile = vyuEMEntityContact2.strMobile
			,strType = vyuEMEntityContact2.strContactType
			,strEntityName = vyuEMEntityContact2.strEntityName
		from
			vyuEMEntityContact2
		where
			vyuEMEntityContact2.strName is not null
			and ltrim(rtrim(vyuEMEntityContact2.strName)) <> ''