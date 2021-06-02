CREATE VIEW [dbo].[vyuCRMCampaignEntitySalesOrder]
	AS
		with opportunity as(
			select z.intOpportunityId, z.intCustomerContactId, z.strName, z.intCampaignId from tblCRMOpportunity z
		)
		select
			result.intEntityContactId
			,dblQuote = sum(result.dblQuote)
			,dblSalesOrder = sum(result.dblSalesOrder)
			,result.intOpportunityId
			,strOpportunityName = opportunity.strName
		from
			(
			select distinct
				d.intEntityContactId
				,dblQuote = sum(d.dblSalesOrderTotal)
				,dblSalesOrder = 0
				,intOpportunityId = max(e.intOpportunityId)
				,strOpportunityName = null
			from
				tblCRMCampaign a
				inner join tblCRMOpportunity b on b.intCampaignId = a.intCampaignId
				inner join tblCRMOpportunityQuote c on c.intOpportunityId = b.intOpportunityId
				inner join tblSOSalesOrder d on d.intSalesOrderId = c.intSalesOrderId
				inner join opportunity e on e.intCustomerContactId = d.intEntityContactId and e.intCampaignId = a.intCampaignId
			where
				d.strTransactionType = 'Quote'
			group by
				d.intEntityContactId

			union all

			select distinct
				d.intEntityContactId
				,dblQuote = 0
				,dblSalesOrder = sum(d.dblSalesOrderTotal)
				,intOpportunityId = max(e.intOpportunityId)
				,strOpportunityName = null
			from
				tblCRMCampaign a
				inner join tblCRMOpportunity b on b.intCampaignId = a.intCampaignId
				inner join tblCRMOpportunityQuote c on c.intOpportunityId = b.intOpportunityId
				inner join tblSOSalesOrder d on d.intSalesOrderId = c.intSalesOrderId
				inner join opportunity e on e.intCustomerContactId = d.intEntityContactId and e.intCampaignId = a.intCampaignId
			where
				d.strTransactionType = 'Order'
			group by
				d.intEntityContactId
			) as result
			inner join opportunity on 1=1
		where
			opportunity.intOpportunityId = result.intOpportunityId
		group by
			result.intEntityContactId
			,result.intOpportunityId
			,opportunity.strName
