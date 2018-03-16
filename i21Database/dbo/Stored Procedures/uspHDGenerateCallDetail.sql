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

delete from tblHDCallDetail where intCreatedDate < convert(int, convert(nvarchar(8), DATEADD(day,-1,getdate()), 112)) or strFilterKey = @strIdentifier;

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
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
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
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
	group by
		b.intEntityId
		,b.strName
)

INSERT INTO tblHDCallDetail
           (
		   intEntityId
           ,strName
           ,strFirstName
           ,intClosedCalls
           ,intOpenCalls
           ,intTotalCalls
           ,intStartDate
           ,intEndDate
           ,strFilterKey
           ,intRequestedByEntityId
           ,intCreatedDate
           ,intConcurrencyId
		   )

select distinct
		intEntityId = b.intEntityId
		,strName = ltrim(rtrim(b.strName))
		,strFirstName = SUBSTRING(ltrim(rtrim(b.strName)),1,CHARINDEX(' ',ltrim(rtrim(b.strName)),1))
		,intClosedCalls = isnull((select intClosedCalls from closedCalls where intEntityId = b.intEntityId),0)
		,intOpenCalls = isnull((select intOpenCalls from openCalls where intEntityId = b.intEntityId),0)
		,intTotalCalls = isnull((select intTotalCalls from totalCalls where intEntityId = b.intEntityId),0)
		,intStartDate = @DateFrom
		,intEndDate = @DateTo
		,strFilterKey = @strIdentifier
		,intRequestedByEntityId = 0
		,intCreatedDate = convert(int, convert(nvarchar(8), getdate(), 112))
		,intConcurrencyId = 1
from
		tblHDTicket a
		,tblEMEntity b
where
		a.intAssignedToEntity is not null
		and b.intEntityId = a.intAssignedToEntity
		and convert(int, convert(nvarchar(8), a.dtmCreated, 112)) between @DateFrom and @DateTo
order by
		strName

END