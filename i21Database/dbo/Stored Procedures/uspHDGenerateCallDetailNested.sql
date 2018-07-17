CREATE PROCEDURE [dbo].[uspHDGenerateCallDetailNested]
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
		,tblHDTicketType c
		,tblHDTicketPriority d
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and a.intTicketStatusId = (select top 1 intTicketStatusId from tblHDTicketStatus where strStatus = 'Closed')
		and c.intTicketTypeId = a.intTicketTypeId
		and d.intTicketPriorityId = a.intTicketPriorityId
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
		,tblHDTicketType c
		,tblHDTicketPriority d
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and a.intTicketStatusId <> (select top 1 intTicketStatusId from tblHDTicketStatus where strStatus = 'Closed')
		and c.intTicketTypeId = a.intTicketTypeId
		and d.intTicketPriorityId = a.intTicketPriorityId
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
		,tblHDTicketType c
		,tblHDTicketPriority d
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and c.intTicketTypeId = a.intTicketTypeId
		and d.intTicketPriorityId = a.intTicketPriorityId
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
		,tblHDTicketHistory c
		,tblHDTicketStatus d
		,tblHDTicketType e
		,tblHDTicketPriority f
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and d.strStatus = 'Reopen'
		and c.intTicketId = a.intTicketId and c.strField = 'intTicketStatusId' and convert(int,c.strNewValue) = d.intTicketStatusId
		and e.intTicketTypeId = a.intTicketTypeId
		and f.intTicketPriorityId = a.intTicketPriorityId
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
		,tblHDTicketHoursWorked b
		,tblHDTicketType c
		,tblHDTicketPriority d
	where
		b.intAgentEntityId is not null
		and a.strType = 'HD'
		and b.intTicketId = a.intTicketId
		and b.ysnBillable = convert(bit,1)
		and c.intTicketTypeId = a.intTicketTypeId
		and d.intTicketPriorityId = a.intTicketPriorityId
	group by
		b.intAgentEntityId
		,convert(int, convert(nvarchar(8), b.dtmDate, 112))
		,c.intTicketTypeId
		,c.strType
		,d.intTicketPriorityId
		,d.strPriority
)
select
	intId = convert(int,ROW_NUMBER() over (order by intEntityId))
	,intEntityId
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
	,strFilterKey
	,intRequestedByEntityId
	,intCreatedDate
	,intTotalBilledHours
	,dblTotalBillableAmount
	,intCallsRated
	,dblAverageRating
	,intDaysOutstanding
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
		,strFilterKey = @strIdentifier
		,intRequestedByEntityId = 0
		,intCreatedDate = convert(int, convert(nvarchar(8), getdate(), 112))
		,intTotalBilledHours = isnull((select sum(intTotalBilledHours) from billedhours where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0)
		,dblTotalBillableAmount = isnull((select sum(dblTotalBillableAmount) from billedhours where intEntityId = b.intEntityId and intTicketTypeId = a.intTicketTypeId and intTicketPriorityId = a.intTicketPriorityId and dtmDate between @DateFrom and @DateTo),0.00)
		,intCallsRated = null
		,dblAverageRating = null
		,intDaysOutstanding = null
		,intConcurrencyId = 1
from
		tblHDTicket a
		,tblEMEntity b
		,tblHDTicketType c
		,tblHDTicketPriority d
where
		a.intAssignedToEntity is not null
		and a.intAssignedToEntity = @EntityId
		and a.strType = 'HD'
		and b.intEntityId = a.intAssignedToEntity
		and c.intTicketTypeId = a.intTicketTypeId
		and d.intTicketPriorityId = a.intTicketPriorityId
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
) as result
order by
		strName

END