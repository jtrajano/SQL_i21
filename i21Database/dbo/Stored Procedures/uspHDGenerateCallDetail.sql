CREATE PROCEDURE [dbo].[uspHDGenerateCallDetail]
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

--delete from tblHDCallDetail where intCreatedDate < convert(int, convert(nvarchar(8), DATEADD(day,-1,getdate()), 112)) or strFilterKey = @strIdentifier;

with closedCalls as
(
	select
		b.intEntityId
		,b.strName
		,intClosedCalls = count(a.intTicketId)
	from
		tblHDTicket a
		,tblEMEntity b
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
		and a.intTicketStatusId = (select top 1 intTicketStatusId from tblHDTicketStatus where strStatus = 'Closed')
	group by
		b.intEntityId
		,b.strName
),
openCalls as
(
	select
		b.intEntityId
		,b.strName
		,intOpenCalls = count(a.intTicketId)
	from
		tblHDTicket a
		,tblEMEntity b
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and b.intEntityId = a.intAssignedToEntity
		--and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
		and a.intTicketStatusId <> (select top 1 intTicketStatusId from tblHDTicketStatus where strStatus = 'Closed')
	group by
		b.intEntityId
		,b.strName
),
totalCalls as
(
	select
		b.intEntityId
		,b.strName
		,intTotalCalls = count(a.intTicketId)
	from
		tblHDTicket a
		,tblEMEntity b
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
	group by
		b.intEntityId
		,b.strName
),
reopenCalls as
(
	select
		b.intEntityId
		,b.strName
		,intReopenCalls = count(c.strNewValue)
	from
		tblHDTicket a
		,tblEMEntity b
		,tblHDTicketHistory c
		,tblHDTicketStatus d
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
		and d.strStatus = 'Reopen'
		and c.intTicketId = a.intTicketId and c.strField = 'intTicketStatusId' and convert(int,c.strNewValue) = d.intTicketStatusId
	group by
		b.intEntityId
		,b.strName
),
billedhours as
(
	select
		intEntityId = a.intAssignedToEntity
		,intTotalBilledHours = sum(isnull(b.intHours,0))
		,dblTotalBillableAmount = sum(isnull(b.intHours,0)*isnull(b.dblRate,0))
	from
		tblHDTicket a
		,tblHDTicketHoursWorked b
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
		and b.intTicketId = a.intTicketId
		and b.ysnBillable = convert(bit,1)
	group by
		a.intAssignedToEntity
),
rating as
(
	select
		intEntityId = a.intAssignedToEntity
		,intCallsRated = count(isnull(a.intFeedbackWithRepresentativeId,0))
		,dblAverageRating = isnull(convert(numeric(18,6),sum(isnull(a.intFeedbackWithRepresentativeId,0.00))) / count(convert(numeric(18,6),isnull(a.intFeedbackWithRepresentativeId,0.00))),0.00)
	from
		tblHDTicket a
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
		and a.intFeedbackWithRepresentativeId is not null
	group by
		a.intAssignedToEntity
),
daysoutstanding as
(
	select distinct
		intEntityId = a.intAssignedToEntity
		,intDaysOutstanding = datediff(day,a.dtmCreated,a.dtmCompleted)
	from
		tblHDTicket a
	where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
		and a.dtmCreated is not null
		and a.dtmCompleted is not null
		and a.intTicketId = (select max(b.intTicketId) from tblHDTicket b where b.dtmCreated is not null and b.dtmCompleted is not null and b.intAssignedToEntity = a.intAssignedToEntity)
)

INSERT INTO tblHDCallDetail
           (
		   intEntityId
           ,strName
           ,strFirstName
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
		   )

select distinct
		intEntityId = b.intEntityId
		,strName = ltrim(rtrim(b.strName))
		,strFirstName = SUBSTRING(ltrim(rtrim(b.strName)),1,CHARINDEX(' ',ltrim(rtrim(b.strName)),1))
		,intClosedCalls = isnull((select intClosedCalls from closedCalls where intEntityId = b.intEntityId),0)
		,intOpenCalls = isnull((select intOpenCalls from openCalls where intEntityId = b.intEntityId),0)
		,intTotalCalls = isnull((select intTotalCalls from totalCalls where intEntityId = b.intEntityId),0)
		,intReopenCalls = isnull((select intReopenCalls from reopenCalls where intEntityId = b.intEntityId),0)
		,intStartDate = @DateFrom
		,intEndDate = @DateTo
		,strFilterKey = @strIdentifier
		,intRequestedByEntityId = 0
		,intCreatedDate = convert(int, convert(nvarchar(8), getdate(), 112))
		,intTotalBilledHours = isnull((select intTotalBilledHours from billedhours where intEntityId = b.intEntityId),0)
		,dblTotalBillableAmount = isnull((select dblTotalBillableAmount from billedhours where intEntityId = b.intEntityId),0)
		,intCallsRated = isnull((select intCallsRated from rating where intEntityId = b.intEntityId),0)
		,dblAverageRating = isnull((select isnull(dblAverageRating,0.00) from rating where intEntityId = b.intEntityId),0.00)
		,intDaysOutstanding = isnull((select intDaysOutstanding from daysoutstanding where intEntityId = b.intEntityId),0)
		,intConcurrencyId = 1
from
		tblHDTicket a
		,tblEMEntity b
where
		a.intAssignedToEntity is not null
		and a.strType = 'HD'
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
order by
		strName

	exec('IF EXISTS(select * FROM sys.views where name = ''vyuHDCallDetail'') begin drop view vyuHDCallDetail; end');
	exec('
	create view vyuHDCallDetail as
	select
		intCallDetailId = convert(int,row_number() over (order by strName))
		,intEntityId
		,strName
		,strFirstName
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
			intEntityId
			,strName
			,strFirstName
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
			tblHDCallDetail
	) as r
	');

END