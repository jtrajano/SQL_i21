﻿CREATE VIEW [dbo].[vyuHDSalesRepSummary]
	AS
		with types as
		(
			select
				tblHDProject.intInternalSalesPerson
				,tblHDTicket.strTicketNumber
				,tblHDTicketType.strType
			from
				tblHDProject
				inner join tblHDProjectTask on tblHDProjectTask.intProjectId = tblHDProject.intProjectId
				inner join tblHDTicket on tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
				inner join tblHDTicketType on tblHDTicketType.intTicketTypeId = tblHDTicket.intTicketTypeId
			where
				tblHDProject.strType = 'CRM'
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
				inner join tblHDOpportunityQuote on tblHDOpportunityQuote.intProjectId = tblHDProject.intProjectId
				inner join tblSOSalesOrder on tblSOSalesOrder.intSalesOrderId = tblHDOpportunityQuote.intSalesOrderId
			where
				tblHDProject.strType = 'CRM'
							
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
					,RepName = (case when tblEMEntity.strName is null then 'No Name' else (case when rtrim(ltrim(tblEMEntity.strName)) = '' then 'No Name' else tblEMEntity.strName end) end) COLLATE Latin1_General_CI_AS
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
