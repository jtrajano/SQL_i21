CREATE VIEW [dbo].[vyuCRMSalesRepSummary]
	AS
		with so as
		(
			select
				tblCRMOpportunity.intInternalSalesPerson
				,tblSOSalesOrder.strSalesOrderNumber
				,tblSOSalesOrder.strTransactionType
				,tblSOSalesOrder.strType
				,tblSOSalesOrder.strOrderStatus
				,tblSOSalesOrder.dblSalesOrderTotal
				,tblSOSalesOrder.dblSalesOrderSubtotal
				,tblSOSalesOrder.dblTax
				,tblSOSalesOrder.dblAmountDue
			from
				tblCRMOpportunity
				,tblHDOpportunityQuote
				,tblSOSalesOrder
			where
				tblHDOpportunityQuote.intProjectId = tblCRMOpportunity.intOpportunityId
				and tblSOSalesOrder.intSalesOrderId = tblHDOpportunityQuote.intSalesOrderId
		)

				Select distinct
					intId = ROW_NUMBER() over(order by RepName)
					,RepId
					,RepName
					,Calls = 0
					,Tasks = 0
					,Meetings = 0
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
					left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblCRMOpportunity.intInternalSalesPerson
					left outer join tblEMEntity on tblEMEntity.intEntityId = tblARSalesperson.intEntitySalespersonId
					left outer join tblCRMOpportunityQuote on tblCRMOpportunityQuote.intOpportunityId = tblCRMOpportunity.intOpportunityId
				where
					tblCRMOpportunity.intInternalSalesPerson is not null 
					and tblCRMOpportunity.intInternalSalesPerson > 0
				) as q1
				group by RepId, RepName
