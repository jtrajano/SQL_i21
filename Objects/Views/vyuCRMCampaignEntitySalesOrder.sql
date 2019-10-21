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
				,tblCRMOpportunity b
				,tblCRMOpportunityQuote c
				,tblSOSalesOrder d
				,opportunity e
			where
				b.intCampaignId = a.intCampaignId
				and c.intOpportunityId = b.intOpportunityId
				and d.intSalesOrderId = c.intSalesOrderId
				and d.strTransactionType = 'Quote'
				and e.intCustomerContactId = d.intEntityContactId
				and e.intCampaignId = a.intCampaignId
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
				,tblCRMOpportunity b
				,tblCRMOpportunityQuote c
				,tblSOSalesOrder d
				,opportunity e
			where
				b.intCampaignId = a.intCampaignId
				and c.intOpportunityId = b.intOpportunityId
				and d.intSalesOrderId = c.intSalesOrderId
				and d.strTransactionType = 'Order'
				and e.intCustomerContactId = d.intEntityContactId and e.intCampaignId = a.intCampaignId
			group by
				d.intEntityContactId
			) as result, opportunity
		where
			opportunity.intOpportunityId = result.intOpportunityId
		group by
			result.intEntityContactId
			,result.intOpportunityId
			,opportunity.strName
