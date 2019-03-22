CREATE VIEW [dbo].[vyuCRMOpportunitySearchSummary]
	AS
		select
			intId = ROW_NUMBER() over (order by strProjectType)
			,intCustomerId
			,strProjectType
			,strCustomerName
			,dblTotalNetOpportunityAmount = (case when sum(dblNetOpportunityAmmount) is null then 0 else sum(dblNetOpportunityAmmount) end)
		from
			vyuCRMOpportunitySearch
		where
			strOpportunityStatus <> 'Closed'
		group by
			intCustomerId
			,strProjectType
			,strCustomerName
