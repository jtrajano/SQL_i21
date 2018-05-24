CREATE PROCEDURE [dbo].[uspCRMGenerateSalesRepSummary]
	@DateFrom int
	,@DateTo int
	,@strIdentifier nvarchar(36)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_WARNINGS OFF;

	--delete from tblCRMSalesRepSummaryResult where intCreatedDate < convert(int, convert(nvarchar(8), DATEADD(day,-1,getdate()), 112)) or strFilterKey = @strIdentifier;

	with sales as
	(
		select
			a.dtmDate
			,intDate = convert(int, convert(nvarchar(8), a.dtmDate, 112))
			,a.intEntitySalespersonId
			,c.strName
			,a.dblAmountDue
			,a.intSalesOrderId
			,strType = a.strTransactionType
		from
			tblSOSalesOrder a
			,tblEMEntity c
		where
			a.intEntitySalespersonId is not null
			and a.intSalesOrderId in (select b.intSalesOrderId from tblCRMOpportunityQuote b)
			and c.intEntityId = a.intEntitySalespersonId
	),
	activity as
	(
		select distinct
			intEntitySalespersonId = a.intInternalSalesPerson
			,c.strType
			,dtmDate = c.dtmCreated
			,intDate = convert(int, convert(nvarchar(8), c.dtmCreated, 112))
		from
			tblCRMOpportunity a
			,tblSMTransaction b
			,tblSMActivity c
		where
			a.intInternalSalesPerson is not null
			and b.intRecordId = a.intOpportunityId
			and b.intScreenId = (select top 1 d.intScreenId from tblSMScreen d where d.strNamespace = 'CRM.view.Opportunity')
			and c.intTransactionId = b.intTransactionId
	)
	INSERT INTO tblCRMSalesRepSummaryResult
           (
		   intSalesRepId
           ,strSalesRepName
           ,intCalls
           ,intTasks
           ,intEvents
           ,intEmails
           ,intQuotes
           ,dblDollarValueOfQuotes
           ,intOrders
           ,dblDollarValueOfOrders
           ,intStartDate
           ,intEndDate
           ,strFilterKey
           ,intRequestedByEntityId
		   ,intCreatedDate
		   ,strDisplayType
           ,intConcurrencyId
		   )
	select
		intSalesRepId = salesrep.intEntitySalespersonId
		,strSalesRepName = a.strName
		,intCalls = (select count(strType) from activity where intEntitySalespersonId = salesrep.intEntitySalespersonId and intDate between @DateFrom and @DateTo and strType = 'Call')
		,intTasks = (select count(strType) from activity where intEntitySalespersonId = salesrep.intEntitySalespersonId and intDate between @DateFrom and @DateTo and strType = 'Task')
		,intEvents = (select count(strType) from activity where intEntitySalespersonId = salesrep.intEntitySalespersonId and intDate between @DateFrom and @DateTo and strType = 'Event')
		,intEmails = (select count(strType) from activity where intEntitySalespersonId = salesrep.intEntitySalespersonId and intDate between @DateFrom and @DateTo and strType = 'Email')
		,intQuotes = (select count(intSalesOrderId) from sales where intEntitySalespersonId = salesrep.intEntitySalespersonId and intDate between @DateFrom and @DateTo and strType = 'Quote')
		,dblDollarValueOfQuotes = (select isnull(sum(dblAmountDue),0) from sales where intEntitySalespersonId = salesrep.intEntitySalespersonId and strType = 'Quote')
		,intOrders = (select count(intSalesOrderId) from sales where intEntitySalespersonId = salesrep.intEntitySalespersonId and intDate between @DateFrom and @DateTo and strType = 'Order')
		,dblDollarValueOfOrders = (select isnull(sum(dblAmountDue),0) from sales where intEntitySalespersonId = salesrep.intEntitySalespersonId and strType = 'Order')
		,intStartDate = @DateFrom
		,intEndDate = @DateTo
		,strFilterKey = @strIdentifier
		,intRequestedByEntityId = 0
		,intCreatedDate = convert(int, convert(nvarchar(8), getdate(), 112))
		,strDisplayType = 'grid'
		,intConcurrencyId = 1
	from
	(
		select distinct intEntitySalespersonId from
		(
		select distinct intEntitySalespersonId from sales where intDate between @DateFrom and @DateTo
		union all
		select distinct intEntitySalespersonId from activity where intDate between @DateFrom and @DateTo
		) as salesrepid
	) as salesrep
	left join tblEMEntity a on a.intEntityId = salesrep.intEntitySalespersonId

	exec('IF EXISTS(select * FROM sys.views where name = ''vyuCRMSalesRepSummaryResult'') begin drop view vyuCRMSalesRepSummaryResult; end');
	exec('
	create view vyuCRMSalesRepSummaryResult as
	select
		intSalesRepSummaryFilterId = convert(int,row_number() over (order by strSalesRepName))
		,intSalesRepId
		,strSalesRepName
		,intCalls
		,intTasks
		,intEvents
		,intEmails
		,intQuotes
		,dblDollarValueOfQuotes
		,intOrders
		,dblDollarValueOfOrders
		,intStartDate
		,intEndDate
		,strFilterKey
		,intRequestedByEntityId
		,intCreatedDate
		,strDisplayType
		,intConcurrencyId
	from
	(
		select distinct
			intSalesRepId
			,strSalesRepName
			,intCalls
			,intTasks
			,intEvents
			,intEmails
			,intQuotes
			,dblDollarValueOfQuotes
			,intOrders
			,dblDollarValueOfOrders
			,intStartDate
			,intEndDate
			,strFilterKey
			,intRequestedByEntityId
			,intCreatedDate
			,strDisplayType
			,intConcurrencyId
		from 
			tblCRMSalesRepSummaryResult
	) as r
	');

END