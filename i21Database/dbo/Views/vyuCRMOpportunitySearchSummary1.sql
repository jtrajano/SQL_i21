CREATE VIEW [dbo].[vyuCRMOpportunitySearchSummary1]
	AS
		select
			intId = convert(int,ROW_NUMBER() over (order by strSalesPerson))
			,strSalesPerson
			,strLineOfBusiness = isnull(strLineOfBusiness, 'Undefined LOB')
			,strLineOfBusinessColumn = 'str'+replace(isnull(strLineOfBusiness,'UndefinedLOB'), ' ', '')
			,dblTotalNetOpportunityAmount = sum(dblTotalNetOpportunityAmount)
		from
		(
		select
			strSalesPerson = d.strName
			,i.strLineOfBusiness
			,dblTotalNetOpportunityAmount = (cast(round(e.dblProbability/100,2) as numeric (36,2))*(sum(isnull(c.dblSalesOrderTotal,0))))
		from
			tblCRMOpportunity a
			left join tblCRMSalesPipeStatus e on e.intSalesPipeStatusId = a.intSalesPipeStatusId
			left join tblEMEntity d on d.intEntityId = a.intInternalSalesPerson
			left join tblCRMOpportunityQuote b on b.intOpportunityId = a.intOpportunityId
			left join tblSOSalesOrder c on c.intSalesOrderId = b.intSalesOrderId and c.strTransactionType = 'Quote' and c.strOrderStatus <> 'Expired'
			left join tblSOSalesOrderDetail f on f.intSalesOrderId = c.intSalesOrderId
			left join tblICItem g on g.intItemId = f.intItemId
			left join tblICCategory h on h.intCategoryId = g.intCategoryId
			left join tblSMLineOfBusiness i on i.intLineOfBusinessId = h.intLineOfBusinessId
		where
			a.strOpportunityStatus <> 'Closed'
			and a.intInternalSalesPerson is not null
		group by
			d.strName
			,i.strLineOfBusiness
			,e.dblProbability
		) as result
		group by
			strSalesPerson
			,strLineOfBusiness
		/*
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
		*/
