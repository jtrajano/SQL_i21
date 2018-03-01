CREATE VIEW [dbo].[vyuCRMCampaignEntityLink]
	AS
		with opportunity as (
			select z.intOpportunityId, z.intCustomerContactId, z.strName from tblCRMOpportunity z
		)
		select
			link.intEntityId
			,link.strContactName
			,link.strEntityName
			,link.strEntityType
			,link.strEmail
			,link.intActivityId
			,link.strActivityType
			,link.strActivityNo
			,link.intEntityEntityId
			,link.dblQuote
			,link.dblSalesOrder
			,intOpportunityId = max(f.intOpportunityId)
			,strOpportunityName = (select top 1 g.strName from opportunity g where g.intOpportunityId = max(f.intOpportunityId))
		from (
			select
				intEntityId = a.intEntityContactId
				,strContactName = b.strName
				,strEntityName = c.strName
				,strEntityType = (select top 1 d.strType from tblEMEntityType d where d.intEntityId = a.intEntityId)
				,strEmail = b.strEmail
				,d.intActivityId
				,strActivityType = d.strType
				,d.strActivityNo
				,intEntityEntityId = c.intEntityId
				,e.dblQuote
				,e.dblSalesOrder
			from tblEMEntityToContact a
			join tblEMEntity b on b.intEntityId = a.intEntityContactId
			join tblEMEntity c on c.intEntityId = a.intEntityId
			left join tblSMActivity d on d.intActivityId = (select max(d.intActivityId) from tblSMActivity d where d.intEntityContactId = a.intEntityContactId)
			left join vyuCRMCampaignEntitySalesOrder e on e.intEntityContactId = a.intEntityContactId
		) as link 
		left join opportunity f on f.intCustomerContactId = link.intEntityId
		where link.strEntityType is not null
		group by
			link.intEntityId
			,link.strContactName
			,link.strEntityName
			,link.strEntityType
			,link.strEmail
			,link.intActivityId
			,link.strActivityType
			,link.strActivityNo
			,link.intEntityEntityId
			,link.dblQuote
			,link.dblSalesOrder