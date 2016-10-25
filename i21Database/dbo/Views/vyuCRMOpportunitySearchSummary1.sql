CREATE VIEW [dbo].[vyuCRMOpportunitySearchSummary1]
	AS
		select
			intId = ROW_NUMBER() over (order by strSalesPerson)
			,strSalesPerson
			,dblTotalNetOpportunityAmount = (case when sum(dblNetOpportunityAmmount) is null then 0 else sum(dblNetOpportunityAmmount) end)
		from
			vyuCRMOpportunitySearch
		where
			strOpportunityStatus <> 'Closed'
			and strSalesPerson is not null
		group by
			strSalesPerson
