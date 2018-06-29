CREATE VIEW [dbo].[vyuHDProjectSearchSummary]
	AS
		select
			intId = ROW_NUMBER() over (order by strProjectType)
			,intCustomerId
			,strProjectType
			,strCustomerName
			,dblTotalNetOpportunityAmount = (case when sum(dblNetOpportunityAmmount) is null then 0 else sum(dblNetOpportunityAmmount) end)
		from
			vyuHDProjectSearch
		where
			strProjectStatus <> 'Closed'
		group by
			intCustomerId
			,strProjectType
			,strCustomerName
