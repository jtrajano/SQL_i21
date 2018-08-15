CREATE PROCEDURE [dbo].[uspHDGenerateRoughCutCapacity]
	@dtmCriteriaDate datetime
	,@strIdentifier nvarchar(36)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_WARNINGS OFF;

declare @intDateFrom int = convert(int, convert(nvarchar(8), @dtmCriteriaDate, 112));
declare @intDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,48,@dtmCriteriaDate), 112));

declare @intFirstWeekDateFrom int = @intDateFrom;
declare @intFirstWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,6,@dtmCriteriaDate), 112));

declare @intSecondWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,7,@dtmCriteriaDate), 112));
declare @intSecondWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,13,@dtmCriteriaDate), 112));

declare @intThirdWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,14,@dtmCriteriaDate), 112));
declare @intThirdWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,20,@dtmCriteriaDate), 112));

declare @intFourthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,21,@dtmCriteriaDate), 112));
declare @intFourthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,27,@dtmCriteriaDate), 112));

declare @intFifthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,28,@dtmCriteriaDate), 112));
declare @intFifthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,34,@dtmCriteriaDate), 112));

declare @intSixthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,35,@dtmCriteriaDate), 112));
declare @intSixthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,41,@dtmCriteriaDate), 112));

declare @intSeventhWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,42,@dtmCriteriaDate), 112));
declare @intSeventhWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,48,@dtmCriteriaDate), 112));

with hourssm as (
	select
		a.intAgentEntityId
		,a.intTicketId
		,dblHours = sum(a.intHours)
		,intDate = convert(int, convert(nvarchar(8), a.dtmDate, 112))
	from
		tblHDTicketHoursWorked a, tblHDTicket b
	where
		convert(int, convert(nvarchar(8), a.dtmDate, 112)) between @intDateFrom and @intDateTo
		and a.intTicketId = b.intTicketId
	group by
		a.intAgentEntityId
		,a.intTicketId
		,a.dtmDate
)

INSERT INTO tblHDRoughCountCapacity
           (
				intSourceEntityId
				,strSourceName
				,intTicketId
				,strTicketNumber
				,intCustomerEntityId
				,strCustomerName
				,dblFirstWeek
				,dblSecondWeek
				,dblThirdWeek
				,dblForthWeek
				,dblFifthWeek
				,dblSixthWeek
				,dblSeventhWeek
				,dtmPlanDate
				,strFilterKey
		   )
			select distinct 
						intSourceEntityId = b.intAssignedToEntity
						,strSourceName = c.strName
						,intTicketId = b.intTicketId
						,strTicketNumber = b.strTicketNumber
						,intCustomerEntityId = b.intCustomerId
						,strCustomerName = d.strName
						,dblFirstWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)
						,dblSecondWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)
						,dblThirdWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)
						,dblForthWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)
						,dblFifthWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)
						,dblSixthWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)
						,dblSeventhWeek = (select sum(dblHours) from hourssm where intAgentEntityId = b.intAssignedToEntity and intTicketId = b.intTicketId and intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)
						,dtmPlanDate = getdate()
						,strFilterKey = @strIdentifier
			from
				tblHDTicketHoursWorked a
				,tblHDTicket b
				,tblEMEntity c
				,tblEMEntity d
			where
				b.intTicketId = a.intTicketId
				and c.intEntityId = b.intAssignedToEntity
				and d.intEntityId = b.intCustomerId
				and convert(int, convert(nvarchar(8), b.dtmDueDate, 112)) between @intDateFrom and @intDateTo

END