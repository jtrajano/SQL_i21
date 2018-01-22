CREATE VIEW [dbo].[vyuCRMCampaignContactSource]
	AS
		select
			intId = convert(int, ROW_NUMBER() over (order by strContactName))
			,strContactName
			,strCompanyName
			,strEmail
			,intContactId
			,strEntityType = strEntityType
			,d.intActivityId
			,strActivityType = d.strType
			,d.strActivityNo
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
			left join tblSMActivity d on d.intActivityId = (select max(d.intActivityId) from tblSMActivity d where d.intEntityContactId = result.intContactId)
