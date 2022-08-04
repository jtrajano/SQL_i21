﻿CREATE PROCEDURE [dbo].[uspHDGenerateCallDetailNested]
	@DateFrom int
	,@DateTo int
	,@EntityId int
AS
BEGIN

SET QUOTED_IDENTIFIER OFF;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_WARNINGS OFF;

declare @strIdentifier nvarchar(36) = newid();

with closedCalls as
(
	select
		intEntityId = a.intAssignedToEntity
		,dtmDate = convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
		,intClosedCalls = count(a.intTicketId)
	from
		tblHDTicket a
		inner join tblHDTicketType c on c.intTicketTypeId = a.intTicketTypeId
		inner join tblHDTicketPriority d on d.intTicketPriorityId = a.intTicketPriorityId
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and a.intTicketStatusId = (select top 1 intTicketStatusId from tblHDTicketStatus where strStatus = 'Closed')
		
	group by
		a.intAssignedToEntity
		,convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
),
openCalls as
(
	select
		intEntityId = a.intAssignedToEntity
		,dtmDate = convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
		,intOpenCalls = count(a.intTicketId)
	from
		tblHDTicket a
		inner join tblHDTicketType c on c.intTicketTypeId = a.intTicketTypeId
		inner join tblHDTicketPriority d on d.intTicketPriorityId = a.intTicketPriorityId
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and a.intTicketStatusId <> (select top 1 intTicketStatusId from tblHDTicketStatus where strStatus = 'Closed')

	group by
		 a.intAssignedToEntity
		,convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
),
totalCalls as
(
	select
		intEntityId = a.intAssignedToEntity
		,dtmDate = convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
		,intTotalCalls = count(a.intTicketId)
	from
		tblHDTicket a
		inner join tblHDTicketType c on c.intTicketTypeId = a.intTicketTypeId
		inner join tblHDTicketPriority d on d.intTicketPriorityId = a.intTicketPriorityId
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
	group by
		 a.intAssignedToEntity
		,convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
),
reopenCalls as
(
	select
		intEntityId = a.intAssignedToEntity
		,dtmDate = convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,e.intTicketTypeId
		,e.strType
		,f.intTicketPriorityId
		,f.strPriority
		,intReopenCalls = count(c.strNewValue)
	from
		tblHDTicket a
		inner join tblHDTicketHistory c on a.intTicketId = c.intTicketId
		inner join tblHDTicketStatus d on a.intTicketStatusId = d.intTicketStatusId
		inner join tblHDTicketType e on e.intTicketTypeId = a.intTicketTypeId
		inner join tblHDTicketPriority f on f.intTicketPriorityId = a.intTicketPriorityId
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and d.strStatus = 'Reopen'
		and c.strField = 'intTicketStatusId' and convert(int,c.strNewValue) = d.intTicketStatusId
	group by
		a.intAssignedToEntity
		,convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,e.intTicketTypeId
		,e.strType
		,f.intTicketPriorityId
		,f.strPriority
),
billedhours as
(
	select
		intEntityId = b.intAgentEntityId
		,dtmDate = convert(int, convert(nvarchar(8), b.dtmDate, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
		,intTotalBilledHours = sum(isnull(b.intHours,0.00))
		,dblTotalBillableAmount = sum(isnull(b.intHours,0.00)*isnull(b.dblRate,0.00))
	from
		tblHDTicket a
		inner join tblHDTicketHoursWorked b on b.intTicketId = a.intTicketId
		inner join tblHDTicketType c on c.intTicketTypeId = a.intTicketTypeId
		inner join tblHDTicketPriority d on d.intTicketPriorityId = a.intTicketPriorityId
	where
		b.intAgentEntityId is not null
		and a.strType = 'HD'
		and b.ysnBillable = convert(bit,1)
	group by
		b.intAgentEntityId
		,convert(int, convert(nvarchar(8), b.dtmDate, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
),
daysoutstanding as
(
	select
		intEntityId = a.intAssignedToEntity
		,a.intTicketPriorityId
		,a.intTicketTypeId
		,intDate = convert(int, convert(nvarchar(8), a.dtmCreated, 112))
		,a.intTicketId
		,intDaysOutstanding = convert(numeric(18,6),datediff(hour,a.dtmCreated,a.dtmCompleted)) / convert(numeric(18,6),24.000000)
	from
		tblHDTicket a
		inner join tblHDTicketStatus b on a.intTicketStatusId = b.intTicketStatusId
	where
		a.intTicketPriorityId is not null
		and a.intTicketTypeId is not null
		and a.dtmCreated is not null
		and a.dtmCompleted is not null
		and b.strStatus = 'Closed'
		and a.intAssignedToEntity is not null
		and a.strType = 'HD'
)

--alter table tblHDCallDetailNested alter column intDaysOutstanding numeric(16,8) null;
insert into tblHDCallDetailNested
(
	intEntityId
	,strName
	,strFirstName
	,intTicketTypeId
	,strType
	,intTicketPriorityId
	,strPriority
	,intClosedCalls
	,intOpenCalls
	,intTotalCalls
	,intReopenCalls
	,intStartDate
	,intEndDate
	,dtmStartDate
	,dtmEndDate
	,strFilterKey
	,intRequestedByEntityId
	,intCreatedDate
	,intTotalBilledHours
	,dblTotalBillableAmount
	,intCallsRated
	,dblAverageRating
	,intDaysOutstanding
	,dtmCreatedDate
	,intConcurrencyId
)
select
	intEntityId
	,strName
	,strFirstName
	,intTicketTypeId
	,strType
	,intTicketPriorityId
	,strPriority
	,intClosedCalls
	,intOpenCalls
	,intTotalCalls
	,intReopenCalls
	,intStartDate
	,intEndDate
	,dtmStartDate
	,dtmEndDate
	,strFilterKey
	,intRequestedByEntityId
	,intCreatedDate
	,intTotalBilledHours
	,dblTotalBillableAmount
	,intCallsRated
	,dblAverageRating
	,intDaysOutstanding
	,dtmCreatedDate
	,intConcurrencyId
from
(
select distinct
		intEntityId = b.intEntityId
		,strName = ltrim(rtrim(b.strName))
		,strFirstName = SUBSTRING(ltrim(rtrim(b.strName)),1,CHARINDEX(' ',ltrim(rtrim(b.strName)),1))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
		,intClosedCalls = isnull((select sum(intClosedCalls) from closedCalls where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0)
		,intOpenCalls = isnull((select sum(intOpenCalls) from openCalls where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId),0)
		,intTotalCalls = isnull((select sum(intTotalCalls) from totalCalls where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0)
		,intReopenCalls = isnull((select sum(intReopenCalls) from reopenCalls where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0)
		,intStartDate = @DateFrom
		,intEndDate = @DateTo
		,dtmStartDate = Convert(DATETIME, LEFT(@DateFrom, 8))
		,dtmEndDate = Convert(DATETIME, LEFT(@DateTo, 8))
		,strFilterKey = @strIdentifier
		,intRequestedByEntityId = 0
		,intCreatedDate = convert(int, convert(nvarchar(8), getdate(), 112))
		,intTotalBilledHours = isnull((select sum(intTotalBilledHours) from billedhours where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0)
		,dblTotalBillableAmount = isnull((select sum(dblTotalBillableAmount) from billedhours where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0.00)
		,intCallsRated = null
		,dblAverageRating = null
		,intDaysOutstanding = isnull((select sum(isnull(daysoutstanding.intDaysOutstanding,0.00)) from daysoutstanding where daysoutstanding.intEntityId = b.intEntityId and daysoutstanding.intTicketTypeId = a.intTicketTypeId and daysoutstanding.intTicketPriorityId = a.intTicketPriorityId and daysoutstanding.intDate between @DateFrom and @DateTo),0.00)
		,dtmCreatedDate = getdate()
		,intConcurrencyId = 1
from
		tblHDTicket a
		inner join tblEMEntity b on b.intEntityId = a.intAssignedToEntity
		inner join tblHDTicketType c on c.intTicketTypeId = a.intTicketTypeId
		inner join tblHDTicketPriority d on d.intTicketPriorityId = a.intTicketPriorityId 
where
		a.intAssignedToEntity is not null
		and a.intAssignedToEntity = (case when @EntityId = 0 then a.intAssignedToEntity else @EntityId end)
		and a.strType = 'HD'
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
) as result
order by
		strName

select @strIdentifier;

END