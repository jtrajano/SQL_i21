CREATE VIEW [dbo].[vyuCRMSalesRepSummary]
	AS
		with types as
		(
			select distinct
				a.intInternalSalesPerson
				,c.strActivityNo
				,c.strType
			from
				tblCRMOpportunity a
				,tblSMTransaction b
				,tblSMActivity c
			where
				a.intInternalSalesPerson is not null
				and b.intRecordId = a.intOpportunityId
				and b.intScreenId = (select top 1 d.intScreenId from tblSMScreen d where d.strNamespace = 'CRM.view.Opportunity')
				and c.intTransactionId = b.intTransactionId
		),
		so as
		(
			select
				a.intInternalSalesPerson
				,c.strSalesOrderNumber
				,c.strTransactionType
				,c.strType
				,c.strOrderStatus
				,c.dblSalesOrderTotal
				,c.dblSalesOrderSubtotal
				,c.dblTax
				,c.dblAmountDue
			from
				tblCRMOpportunity a
				,tblCRMOpportunityQuote b
				,tblSOSalesOrder c
			where
				b.intOpportunityId = a.intOpportunityId
				and c.intSalesOrderId = b.intSalesOrderId
		)

				Select distinct
					intId = ROW_NUMBER() over(order by RepName)
					,RepId
					,RepName
					,Calls = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Call')
					,Tasks = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Task')
					,Events = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Event')
					,Emails = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Email')
					,Quotes = (select count(strType) from so where intInternalSalesPerson = RepId and strTransactionType = 'Quote')
					,DollarValueOfQuotes = (select (case when sum(dblAmountDue) is null then 0 else sum(dblAmountDue) end) from so where intInternalSalesPerson = RepId and strTransactionType = 'Quote')
					,Orders = (select count(strType) from so where intInternalSalesPerson = RepId and strTransactionType = 'Order')
					,DollarValueOfOrders = (select (case when sum(dblAmountDue) is null then 0 else sum(dblAmountDue) end) from so where intInternalSalesPerson = RepId and strTransactionType = 'Order')
				From
				(
				select
					RepId = tblEMEntity.intEntityId
					,RepName = (case when tblEMEntity.strName is null then 'No Name' else (case when rtrim(ltrim(tblEMEntity.strName)) = '' then 'No Name' else tblEMEntity.strName end) end)
					,tblCRMOpportunity.intOpportunityId
					,tblCRMOpportunity.strName
					,tblCRMOpportunity.strOpportunityStatus
				from
					tblCRMOpportunity
					left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblCRMOpportunity.intInternalSalesPerson
					left outer join tblEMEntity on tblEMEntity.intEntityId = tblARSalesperson.[intEntityId]
					left outer join tblCRMOpportunityQuote on tblCRMOpportunityQuote.intOpportunityId = tblCRMOpportunity.intOpportunityId
				where
					tblCRMOpportunity.intInternalSalesPerson is not null 
					and tblCRMOpportunity.intInternalSalesPerson > 0
				) as q1
				group by RepId, RepName
/*
with types as
(
	select distinct
		a.intInternalSalesPerson
		,c.strActivityNo
		,c.strCategory
	from
		tblCRMOpportunity a
		,tblSMTransaction b
		,tblSMActivity c
	where
		a.intInternalSalesPerson is not null
		and b.intRecordId = a.intOpportunityId
		and b.intScreenId = (select top 1 d.intScreenId from tblSMScreen d where d.strNamespace = 'CRM.view.Opportunity')
		and c.intTransactionId = b.intTransactionId
),
so as
(
	select
		a.intInternalSalesPerson
		,c.strSalesOrderNumber
		,c.strTransactionType
		,c.strType
		,c.strOrderStatus
		,c.dblSalesOrderTotal
		,c.dblSalesOrderSubtotal
		,c.dblTax
		,c.dblAmountDue
	from
		tblCRMOpportunity a
		,tblCRMOpportunityQuote b
		,tblSOSalesOrder c
	where
		b.intOpportunityId = a.intOpportunityId
		and c.intSalesOrderId = b.intSalesOrderId
)

		Select distinct
			intId = ROW_NUMBER() over(order by RepName)
			,RepId
			,RepName
			,Calls = (select count(strCategory) from types where intInternalSalesPerson = RepId and strCategory = 'Call')
			,Tasks = (select count(strCategory) from types where intInternalSalesPerson = RepId and strCategory = 'Task')
			,Meetings = (select count(strCategory) from types where intInternalSalesPerson = RepId and strCategory = 'Meeting')
			,Quotes = (select count(strType) from so where intInternalSalesPerson = RepId and strTransactionType = 'Quote')
			,DollarValueOfQuotes = (select (case when sum(dblAmountDue) is null then 0 else sum(dblAmountDue) end) from so where intInternalSalesPerson = RepId and strTransactionType = 'Quote')
			,Orders = (select count(strType) from so where intInternalSalesPerson = RepId and strTransactionType = 'Order')
			,DollarValueOfOrders = (select (case when sum(dblAmountDue) is null then 0 else sum(dblAmountDue) end) from so where intInternalSalesPerson = RepId and strTransactionType = 'Order')
		From
		(
		select
			RepId = tblEMEntity.intEntityId
			,RepName = (case when tblEMEntity.strName is null then 'No Name' else (case when rtrim(ltrim(tblEMEntity.strName)) = '' then 'No Name' else tblEMEntity.strName end) end)
			,tblCRMOpportunity.intOpportunityId
			,tblCRMOpportunity.strName
			,tblCRMOpportunity.strOpportunityStatus
		from
			tblCRMOpportunity
			left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblCRMOpportunity.intInternalSalesPerson
			left outer join tblEMEntity on tblEMEntity.intEntityId = tblARSalesperson.[intEntityId]
			left outer join tblCRMOpportunityQuote on tblCRMOpportunityQuote.intOpportunityId = tblCRMOpportunity.intOpportunityId
		where
			tblCRMOpportunity.intInternalSalesPerson is not null 
			and tblCRMOpportunity.intInternalSalesPerson > 0
		) as q1
		group by RepId, RepName
*/
