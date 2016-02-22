CREATE VIEW [dbo].[vyuHDProjectSearchSummary]
	AS
		select
			intId = ROW_NUMBER() over (order by strProjectType)
			,strProjectType
			,strCustomerName
			,dblTotalNetOpportunityAmount = sum(dblNetOpportunityAmmount)
		from
			vyuHDProjectSearch
		group by
			strProjectType
			,strCustomerName
