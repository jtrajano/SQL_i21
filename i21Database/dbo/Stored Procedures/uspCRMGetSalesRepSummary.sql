CREATE PROCEDURE [dbo].[uspCRMGetSalesRepSummary]
	@DateFrom int
	,@DateTo int
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	declare @strIdentifier nvarchar(36);
	set @strIdentifier = NEWID();

	insert into tblCRMSalesRepSummary
	(
		strIdentifier
		,RepId
		,RepName
		,Calls
		,Tasks
		,Events
		,Emails
		,Quotes
		,DollarValueOfQuotes
		,Orders
		,DollarValueOfOrders
	)
	select
			--intId = convert(int,ROW_NUMBER() over (order by RepId))
			strIdentifier = @strIdentifier
			,RepId
			,RepName
			,Calls  = sum(Calls)
			,Tasks = sum(Tasks)
			,Events = sum(Events)
			,Emails = sum(Emails)
			,Quotes = sum(Quotes)
			,DollarValueOfQuotes = sum(DollarValueOfQuotes)
			,Orders = sum(Orders)
			,DollarValueOfOrders = sum(DollarValueOfOrders)
	from (
		select 
			RepId = a.intInternalSalesPerson
			,RepName = d.strName
			,Calls  = (case when c.strType = 'Call' then 1 else 0 end)
			,Tasks = (case when c.strType = 'Task' then 1 else 0 end)
			,Events = (case when c.strType = 'Event' then 1 else 0 end)
			,Emails = (case when c.strType = 'Email' then 1 else 0 end)
			,Quotes = 0
			,DollarValueOfQuotes = 0
			,Orders = 0
			,DollarValueOfOrders = 0
			,Date = cast(convert(varchar(8),c.dtmCreated,112) as int)
		from
			tblCRMOpportunity a
			inner join tblSMTransaction b on b.intRecordId = a.intOpportunityId
			inner join tblSMActivity c on c.intTransactionId = b.intTransactionId
			inner join tblEMEntity d on d.intEntityId = a.intInternalSalesPerson
		where
			a.intInternalSalesPerson is not null
			and b.intScreenId = (select top 1 d.intScreenId from tblSMScreen d where d.strNamespace = 'CRM.view.Opportunity')

		union all

		select 
			RepId = tblCRMOpportunity.intInternalSalesPerson
			,RepName = tblEMEntity.strName
			,Calls  = 0
			,Tasks = 0
			,[Events] = 0
			,Emails = 0
			,Quotes = (case when tblSOSalesOrder.strTransactionType = 'Quote' then 1 else 0 end)
			,DollarValueOfQuotes = (case when tblSOSalesOrder.strTransactionType = 'Quote' then tblSOSalesOrder.dblAmountDue else 0 end)
			,Orders = (case when tblSOSalesOrder.strTransactionType = 'Order' then 1 else 0 end)
			,DollarValueOfOrders = (case when tblSOSalesOrder.strTransactionType = 'Order' then tblSOSalesOrder.dblAmountDue else 0 end)
			,[Date] = cast(convert(varchar(8),tblSOSalesOrder.dtmDate,112) as int)
		from
			tblCRMOpportunity
			inner join tblEMEntity on tblEMEntity.intEntityId = tblCRMOpportunity.intInternalSalesPerson
			inner join tblCRMOpportunityQuote on tblCRMOpportunityQuote.intOpportunityId = tblCRMOpportunity.intOpportunityId
			inner join tblSOSalesOrder on tblSOSalesOrder.intSalesOrderId = tblCRMOpportunityQuote.intSalesOrderId 
		where
			tblCRMOpportunity.intInternalSalesPerson is not null 
			and tblCRMOpportunity.intInternalSalesPerson > 0
			and tblSOSalesOrder.strTransactionType in ('Quote', 'Order')
	) as Result
	where [Date] between @DateFrom and @DateTo
	group by RepId ,RepName

	select @strIdentifier;

END