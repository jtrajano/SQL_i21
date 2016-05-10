CREATE VIEW [dbo].[vyuHDOpportunitySearchSummary]
	AS
		select
			intId = ROW_NUMBER() over (order by strSalesPerson)
			,strSalesPerson
			,dblTotalNetOpportunityAmount = (case when sum(dblNetOpportunityAmmount) is null then 0 else sum(dblNetOpportunityAmmount) end)
		from
			vyuHDProjectSearch
		where
			strProjectStatus <> 'Closed'
			and strProjectType = 'CRM'
			and strSalesPerson is not null
		group by
			strSalesPerson
