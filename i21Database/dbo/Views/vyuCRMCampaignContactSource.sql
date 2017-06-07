CREATE VIEW [dbo].[vyuCRMCampaignContactSource]
	AS
		select
			intId = convert(int, ROW_NUMBER() over (order by strContactName))
			,strContactName
			,strCompanyName
			,strEmail
			,intContactId
			,strEntityType = strEntityType
		from
			(
				select distinct
					strContactName = vyuEMEntityContact.strName
					,strCompanyName = vyuEMEntityContact.strEntityName
					,vyuEMEntityContact.strEmail
					,intContactId = vyuEMEntityContact.intEntityContactId
					,strEntityType = 
						dbo.fnCRMCoalesceEntityType((select top 1 a.intEntityId from tblEMEntityToContact a where a.intEntityContactId = vyuEMEntityContact.intEntityContactId))
				from
					vyuEMEntityContact
			) as result
