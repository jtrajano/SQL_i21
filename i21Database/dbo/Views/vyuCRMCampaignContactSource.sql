CREATE VIEW [dbo].[vyuCRMCampaignContactSource]
	AS
		with opportunity as(
			select z.intOpportunityId, z.intCustomerContactId, z.strName from tblCRMOpportunity z
		)
		select
			intId = convert(int, ROW_NUMBER() over (order by result.strContactName))
			,result.strContactName
			,result.strCompanyName
			,result.strEmail
			,result.intContactId
			,strEntityType = result.strEntityType
			,d.intActivityId
			,strActivityType = d.strType
			,d.strActivityNo
			,result.intEntityId
			,e.dblQuote
			,e.dblSalesOrder
			,intOpportunityId = max(f.intOpportunityId)
			,strOpportunityName = (select strName from opportunity where intOpportunityId = max(f.intOpportunityId))
		from
			(
				select distinct
					strContactName = vyuEMEntityContact.strName
					,strCompanyName = vyuEMEntityContact.strEntityName
					,vyuEMEntityContact.strEmail
					,intEntityId = vyuEMEntityContact.intEntityId
					,intContactId = vyuEMEntityContact.intEntityContactId
					,strEntityType = 
						dbo.fnCRMCoalesceEntityType((select top 1 a.intEntityId from tblEMEntityToContact a where a.intEntityContactId = vyuEMEntityContact.intEntityContactId))
				from
					vyuEMEntityContact
			) as result
			left join tblSMActivity d on d.intActivityId = (select max(d.intActivityId) from tblSMActivity d where d.intEntityContactId = result.intContactId)
			left join vyuCRMCampaignEntitySalesOrder e on e.intEntityContactId = result.intContactId
			left join opportunity f on f.intCustomerContactId = result.intContactId
		group by
			result.strContactName
			,result.strContactName
			,result.strCompanyName
			,result.strEmail
			,result.intContactId
			,result.strEntityType
			,d.intActivityId
			,d.strType
			,d.strActivityNo
			,result.intEntityId
			,e.dblQuote
			,e.dblSalesOrder
