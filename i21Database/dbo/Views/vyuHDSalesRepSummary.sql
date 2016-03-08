CREATE VIEW [dbo].[vyuHDSalesRepSummary]
	AS
		Select
			intId = ROW_NUMBER() over(order by RepName)
			,RepId
			,RepName
			,Calls = count(Calls)
			,Tasks = count(Tasks)
			,Meetings = count(Meetings)
			,Quotes = count(QuoteType)
			,DollarValueOfQuotes = sum(QuoteAmountDue)
			,Orders = count(OrderTransactionType)
			,DollarValueOfOrders = sum(OrderAmountDue)
		From
		(
		select
			RepId = tblEntity.intEntityId
			,RepName = tblEntity.strName
			,tblHDProject.intProjectId
			,tblHDProject.strProjectName
			,tblHDProject.strProjectStatus
			,tblHDTicket.strTicketNumber
			,Calls = calls.strType
			,Tasks = tasks.strType
			,Meetings = meetings.strType

			,QuoteSalesOrderId = quotes.intSalesOrderId
			,QuoteOrderNumber = quotes.strSalesOrderNumber
			,QuoteTransactionType = quotes.strTransactionType
			,QuoteType = quotes.strType
			,QuoteOrderStatus = quotes.strOrderStatus
			,QuoteOrderTotal = quotes.dblSalesOrderTotal
			,QuoteOrderSubtotal = quotes.dblSalesOrderSubtotal
			,QuoteTax = quotes.dblTax
			,QuoteAmountDue = quotes.dblAmountDue

			,OrderSalesOrderId = orders.intSalesOrderId
			,OrderOrderNumber = orders.strSalesOrderNumber
			,OrderTransactionType = orders.strTransactionType
			,OrderType = orders.strType
			,OrderOrderStatus = orders.strOrderStatus
			,OrderOrderTotal = orders.dblSalesOrderTotal
			,OrderOrderSubtotal = orders.dblSalesOrderSubtotal
			,OrderTax = orders.dblTax
			,OrderAmountDue = orders.dblAmountDue
		from
			tblHDProject
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblHDProject.intInternalSalesPerson
			left outer join tblEntity on tblEntity.intEntityId = tblARSalesperson.intEntitySalespersonId
			left outer join tblHDProjectTask on tblHDProjectTask.intProjectId = tblHDProject.intProjectId
			left outer join tblHDTicket on tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
			left outer join tblHDTicketType calls on calls.intTicketTypeId = tblHDTicket.intTicketTypeId and calls.strType = 'Call'
			left outer join tblHDTicketType tasks on tasks.intTicketTypeId = tblHDTicket.intTicketTypeId and tasks.strType = 'Task'
			left outer join tblHDTicketType meetings on meetings.intTicketTypeId = tblHDTicket.intTicketTypeId and meetings.strType = 'Meeting'
			left outer join tblHDOpportunityQuote on tblHDOpportunityQuote.intProjectId = tblHDProject.intProjectId
			left outer join tblSOSalesOrder quotes on quotes.intSalesOrderId = tblHDOpportunityQuote.intSalesOrderId and quotes.strTransactionType = 'Quote'
			left outer join tblSOSalesOrder orders on orders.intSalesOrderId = tblHDOpportunityQuote.intSalesOrderId and orders.strTransactionType = 'Order'
		where
			tblHDProject.strType = 'CRM'
		) as q1
		group by RepId, RepName
