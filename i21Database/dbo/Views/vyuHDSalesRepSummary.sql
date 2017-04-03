CREATE VIEW [dbo].[vyuHDSalesRepSummary]
	AS
		with types as
		(
			select
				tblHDProject.intInternalSalesPerson
				,tblHDTicket.strTicketNumber
				,tblHDTicketType.strType
			from
				tblHDProject
				,tblHDProjectTask
				,tblHDTicket
				,tblHDTicketType
			where
				tblHDProject.strType = 'CRM'
				and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
				and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
				and tblHDTicketType.intTicketTypeId = tblHDTicket.intTicketTypeId
		),
		so as
		(
			select
				tblHDProject.intInternalSalesPerson
				,tblSOSalesOrder.strSalesOrderNumber
				,tblSOSalesOrder.strTransactionType
				,tblSOSalesOrder.strType
				,tblSOSalesOrder.strOrderStatus
				,tblSOSalesOrder.dblSalesOrderTotal
				,tblSOSalesOrder.dblSalesOrderSubtotal
				,tblSOSalesOrder.dblTax
				,tblSOSalesOrder.dblAmountDue
			from
				tblHDProject
				,tblHDOpportunityQuote
				,tblSOSalesOrder
			where
				tblHDProject.strType = 'CRM'
				and tblHDOpportunityQuote.intProjectId = tblHDProject.intProjectId
				and tblSOSalesOrder.intSalesOrderId = tblHDOpportunityQuote.intSalesOrderId
		)

				Select distinct
					intId = ROW_NUMBER() over(order by RepName)
					,RepId
					,RepName
					,Calls = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Call')
					,Tasks = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Task')
					,Meetings = (select count(strType) from types where intInternalSalesPerson = RepId and strType = 'Meeting')
					,Quotes = (select count(strType) from so where intInternalSalesPerson = RepId and strTransactionType = 'Quote')
					,DollarValueOfQuotes = (select (case when sum(dblAmountDue) is null then 0 else sum(dblAmountDue) end) from so where intInternalSalesPerson = RepId and strTransactionType = 'Quote')
					,Orders = (select count(strType) from so where intInternalSalesPerson = RepId and strTransactionType = 'Order')
					,DollarValueOfOrders = (select (case when sum(dblAmountDue) is null then 0 else sum(dblAmountDue) end) from so where intInternalSalesPerson = RepId and strTransactionType = 'Order')
				From
				(
				select
					RepId = tblEMEntity.intEntityId
					,RepName = (case when tblEMEntity.strName is null then 'No Name' else (case when rtrim(ltrim(tblEMEntity.strName)) = '' then 'No Name' else tblEMEntity.strName end) end)
					,tblHDProject.intProjectId
					,tblHDProject.strProjectName
					,tblHDProject.strProjectStatus
				from
					tblHDProject
					left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblHDProject.intInternalSalesPerson
					left outer join tblEMEntity on tblEMEntity.intEntityId = tblARSalesperson.[intEntityId]
					left outer join tblHDOpportunityQuote on tblHDOpportunityQuote.intProjectId = tblHDProject.intProjectId
				where
					tblHDProject.strType = 'CRM'
					and tblHDProject.intInternalSalesPerson is not null 
					and tblHDProject.intInternalSalesPerson > 0
				) as q1
				group by RepId, RepName
