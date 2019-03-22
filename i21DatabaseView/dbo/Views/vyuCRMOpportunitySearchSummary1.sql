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
				strSalesPerson
				,strLineOfBusiness
				,dblTotalNetOpportunityAmount = (cast(round(dblProbability/100,2) as numeric (36,2))*(sum(isnull(dblSalesOrderTotal,0))))
			from 
				(select distinct
					strSalesPerson = d.strName
					,i.strLineOfBusiness
					,e.dblProbability
					,c.dblSalesOrderTotal
					,c.intSalesOrderId
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
				) as rawResult
			group by
				strSalesPerson
				,strLineOfBusiness
				,dblProbability
		) as result
		group by
			strSalesPerson
			,strLineOfBusiness