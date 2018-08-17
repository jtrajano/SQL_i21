﻿CREATE PROCEDURE [dbo].[uspHDGenerateRoughCutCapacity]
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

with booked as (
	select
		intAgentEntityId = b.intAssignedToEntity
		,a.intTicketId
		,dblHours = sum(a.intHours)
		,intDate = convert(int, convert(nvarchar(8), a.dtmDate, 112))
	from
		tblHDTicketHoursWorked a, tblHDTicket b
	where
		convert(int, convert(nvarchar(8), a.dtmDate, 112)) between @intDateFrom and @intDateTo
		and a.intTicketId = b.intTicketId
	group by
		b.intAssignedToEntity
		,a.intTicketId
		,a.dtmDate
),
estimate as (
	select
		a.intAssignedToEntity
		,a.intTicketId
		--,dblHours = convert(numeric(18,6),datediff(minute,a.dtmCreated, a.dtmDueDate)) / convert(numeric(18,6),60)
		,dblHours = convert(numeric(18,6),a.dblQuotedHours)
		,intDate = convert(int, convert(nvarchar(8), a.dtmDueDate, 112))
	from
		tblHDTicket a
	where
		a.dtmDueDate is not null
		and convert(int, convert(nvarchar(8), a.dtmDueDate, 112)) between @intDateFrom and @intDateTo
),
planed as (
	select
		a.intTicketId
		,a.intAssignedToEntity
		,intDate = convert(int, convert(nvarchar(8), a.dtmDueDate, 112))
		--,dblHours = sum(convert(numeric(18,6),datediff(day,d.dtmStartDate, d.dtmEndDate)) / convert(numeric(18,6),8))
		,dblHours = sum((convert(numeric(18,6),datediff(hour,d.dtmStartDate, d.dtmEndDate)) / convert(numeric(18,6),24.00)) * convert(numeric(18,6),8.00))
	from
		tblHDTicket a
		,tblSMTransaction b
		,tblSMScreen c
		,tblSMActivity d
	where
		a.dtmDueDate is not null
		and convert(int, convert(nvarchar(8), a.dtmDueDate, 112)) between @intDateFrom and @intDateTo
		and c.strModule = 'Help Desk'
		and c.strNamespace = 'HelpDesk.view.Ticket'
		and b.intRecordId = a.intTicketId
		and b.intScreenId = c.intScreenId
		and d.intTransactionId = b.intTransactionId
		and d.dtmStartDate is not null
		and d.dtmEndDate is not null
	group by 
		a.intTicketId
		,a.intAssignedToEntity
		,a.dtmDueDate
)

INSERT INTO tblHDRoughCountCapacity
           (
				intSourceEntityId
				,strSourceName
				,intTicketId
				,strTicketNumber
				,intCustomerEntityId
				,strCustomerName
				,dblPlanFirstWeek
				,dblPlanSecondWeek
				,dblPlanThirdWeek
				,dblPlanForthWeek
				,dblPlanFifthWeek
				,dblPlanSixthWeek
				,dblPlanSeventhWeek
				,dblEstimateFirstWeek
				,dblEstimateSecondWeek
				,dblEstimateThirdWeek
				,dblEstimateForthWeek
				,dblEstimateFifthWeek
				,dblEstimateSixthWeek
				,dblEstimateSeventhWeek
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
						
						,dblPlanFirstWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)
						,dblPlanSecondWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)
						,dblPlanThirdWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)
						,dblPlanForthWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)
						,dblPlanFifthWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)
						,dblPlanSixthWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)
						,dblPlanSeventhWeek = (select sum(planed.dblHours) from planed where planed.intAssignedToEntity = b.intAssignedToEntity and planed.intTicketId = b.intTicketId and planed.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)
						
						,dblEstimateFirstWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)
						,dblEstimateSecondWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)
						,dblEstimateThirdWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)
						,dblEstimateForthWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)
						,dblEstimateFifthWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)
						,dblEstimateSixthWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)
						,dblEstimateSeventhWeek = (select sum(estimate.dblHours) from estimate where estimate.intAssignedToEntity = b.intAssignedToEntity and estimate.intTicketId = b.intTicketId and estimate.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)
						
						,dblFirstWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)
						,dblSecondWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)
						,dblThirdWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)
						,dblForthWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)
						,dblFifthWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)
						,dblSixthWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)
						,dblSeventhWeek = (select sum(booked.dblHours) from booked where booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)
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