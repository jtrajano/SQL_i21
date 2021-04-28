﻿CREATE PROCEDURE [dbo].[uspHDGenerateRoughCutCapacity]  
 @dtmCriteriaDate datetime  
 ,@strIdentifier nvarchar(36)  
 ,@ysnBillable INT = -1
AS  
BEGIN  
  
SET QUOTED_IDENTIFIER OFF;  
SET ANSI_NULLS ON;  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
SET ANSI_WARNINGS OFF;  
  
declare @intDateFrom int = convert(int, convert(nvarchar(8), @dtmCriteriaDate, 112));  
declare @intDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,83,@dtmCriteriaDate), 112));  
  
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
  
declare @intEighthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,49,@dtmCriteriaDate), 112));  
declare @intEighthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,55,@dtmCriteriaDate), 112));  
  
declare @intNinthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,56,@dtmCriteriaDate), 112));  
declare @intNinthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,62,@dtmCriteriaDate), 112));  
  
declare @intTenthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,63,@dtmCriteriaDate), 112));  
declare @intTenthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,69,@dtmCriteriaDate), 112));  
  
declare @intEleventhWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,70,@dtmCriteriaDate), 112));  
declare @intEleventhWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,76,@dtmCriteriaDate), 112));  
  
declare @intTwelfthWeekDateFrom int = convert(int, convert(nvarchar(8), dateadd(dd,77,@dtmCriteriaDate), 112));  
declare @intTwelfthWeekDateTo int = convert(int, convert(nvarchar(8), dateadd(dd,83,@dtmCriteriaDate), 112));  
  
with booked as (  
 select  
  intAgentEntityId = a.intAgentEntityId  
  ,a.intTicketId  
  ,dblHours = sum(a.intHours)  
  ,dblEstimatedHours = sum(a.dblEstimatedHours)  
  ,intDate = convert(int, convert(nvarchar(8), a.dtmDate, 112))  
  ,ysnBillable = (CASE WHEN ISNULL(@ysnBillable, -1) <> -1 THEN a.ysnBillable ELSE -1 END)
 from  
  tblHDTicketHoursWorked a, tblHDTicket b  
 where  
  convert(int, convert(nvarchar(8), a.dtmDate, 112)) between @intDateFrom and @intDateTo  
  and a.intTicketId = b.intTicketId  

 group by  
  a.intAgentEntityId  
  ,a.intTicketId  
  ,a.dtmDate  
  ,ysnBillable
),

planed as (  
 select  
  a.intTicketId  
  ,d.intAssignedTo  
  ,intDate = convert(int, convert(nvarchar(8), d.dtmStartDate, 112))  
  ,dblHours = (case  
	  when ISNULL(d.dblNumberOfHours, 0) <> 0
		then d.dblNumberOfHours
      when datediff(day,d.dtmStartDate, d.dtmEndDate) > 0 and datediff(hour,d.dtmStartDate, d.dtmEndDate) > 8 and (d.ysnAllDayEvent is null or d.ysnAllDayEvent = convert(bit,0))  
		then sum(convert(numeric(18,6),datediff(day,d.dtmStartDate, d.dtmEndDate)) * convert(numeric(18,6),8.00))  
      when datediff(day,d.dtmStartDate, d.dtmEndDate) > 0 and datediff(hour,d.dtmStartDate, d.dtmEndDate) < 8 and (d.ysnAllDayEvent is null or d.ysnAllDayEvent = convert(bit,0))  
		then sum(convert(numeric(18,6),datediff(hour,d.dtmStartDate, d.dtmEndDate)))  
      when d.ysnAllDayEvent = convert(bit,1)  
		then 8.00  
      when datediff(day,d.dtmStartDate, d.dtmEndDate) = 0 and (d.ysnAllDayEvent is null or d.ysnAllDayEvent = convert(bit,0))  
		then sum(convert(numeric(18,6),datediff(minute,d.dtmStartDate, d.dtmEndDate))/60.00)  
      else 0.00  
     end)
  ,ysnBillable = (CASE WHEN ISNULL(@ysnBillable, -1) <> -1 THEN d.ysnBillable ELSE -1 END)
 from  
  tblHDTicket a  
  ,tblSMTransaction b  
  ,tblSMScreen c  
  ,tblSMActivity d  
 where
  convert(int, convert(nvarchar(8), d.dtmStartDate, 112)) between @intDateFrom and @intDateTo  
  and c.strModule = 'Help Desk'  
  and c.strNamespace = 'HelpDesk.view.Ticket'  
  and b.intRecordId = a.intTicketId  
  and b.intScreenId = c.intScreenId  
  and d.intTransactionId = b.intTransactionId  
  and d.dtmStartDate is not null  
  and d.dtmEndDate is not null  
 group by   
  a.intTicketId  
  ,d.intAssignedTo
  ,a.dtmDueDate  
  ,d.dtmStartDate  
  ,d.dtmEndDate  
  ,d.ysnAllDayEvent  
  ,d.dblNumberOfHours
  ,ysnBillable
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
    ,dblPlanEighthWeek  
    ,dblPlanNinthWeek  
    ,dblPlanTenthWeek  
    ,dblPlanEleventhWeek  
    ,dblPlanTwelfthWeek  
    ,dblEstimateFirstWeek  
    ,dblEstimateSecondWeek  
    ,dblEstimateThirdWeek  
    ,dblEstimateForthWeek  
    ,dblEstimateFifthWeek  
    ,dblEstimateSixthWeek  
    ,dblEstimateSeventhWeek  
    ,dblEstimateEighthWeek  
    ,dblEstimateNinthWeek  
    ,dblEstimateTenthWeek  
    ,dblEstimateEleventhWeek  
    ,dblEstimateTwelfthWeek  
    ,dblFirstWeek  
    ,dblSecondWeek  
    ,dblThirdWeek  
    ,dblForthWeek  
    ,dblFifthWeek  
    ,dblSixthWeek  
    ,dblSeventhWeek  
    ,dblEighthWeek  
    ,dblNinthWeek  
    ,dblTenthWeek  
    ,dblEleventhWeek  
    ,dblTwelfthWeek  
    ,dtmPlanDate  
    ,strFilterKey  
     )

	--FROM TIME ENTRY
   select distinct   
      intSourceEntityId = b.intAssignedToEntity  
      ,strSourceName = c.strName  
      ,intTicketId = b.intTicketId  
      ,strTicketNumber = b.strTicketNumber  
      ,intCustomerEntityId = b.intCustomerId  
      ,strCustomerName = d.strName  
        
      ,dblPlanFirstWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)  
      ,dblPlanSecondWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)  
      ,dblPlanThirdWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)  
      ,dblPlanForthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)  
      ,dblPlanFifthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)  
      ,dblPlanSixthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)  
      ,dblPlanSeventhWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)  
      ,dblPlanEighthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intEighthWeekDateFrom and @intEighthWeekDateTo)  
      ,dblPlanNinthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intNinthWeekDateFrom and @intNinthWeekDateTo)  
      ,dblPlanTenthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intTenthWeekDateFrom and @intTenthWeekDateTo)  
      ,dblPlanEleventhWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intEleventhWeekDateFrom and @intEleventhWeekDateTo)  
      ,dblPlanTwelfthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAgentEntityId and planed.intTicketId = b.intTicketId and planed.intDate between @intTwelfthWeekDateFrom and @intTwelfthWeekDateTo)  
        
      ,dblEstimateFirstWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)  
      ,dblEstimateSecondWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)  
      ,dblEstimateThirdWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)  
      ,dblEstimateForthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)  
      ,dblEstimateFifthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)  
      ,dblEstimateSixthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)  
      ,dblEstimateSeventhWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)  
      ,dblEstimateEighthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intEighthWeekDateFrom and @intEighthWeekDateTo)  
      ,dblEstimateNinthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intNinthWeekDateFrom and @intNinthWeekDateTo)  
      ,dblEstimateTenthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intTenthWeekDateFrom and @intTenthWeekDateTo)  
      ,dblEstimateEleventhWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intEleventhWeekDateFrom and @intEleventhWeekDateTo)
      ,dblEstimateTwelfthWeek = (select sum(booked.dblEstimatedHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = b.intAssignedToEntity and booked.intTicketId = b.intTicketId and booked.intDate between @intTwelfthWeekDateFrom and @intTwelfthWeekDateTo)  
        
      ,dblFirstWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)  
      ,dblSecondWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)  
      ,dblThirdWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)  
      ,dblForthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)  
      ,dblFifthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)  
      ,dblSixthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)  
      ,dblSeventhWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)  
      ,dblEighthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intEighthWeekDateFrom and @intEighthWeekDateTo)  
      ,dblNinthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intNinthWeekDateFrom and @intNinthWeekDateTo)  
      ,dblTenthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intTenthWeekDateFrom and @intTenthWeekDateTo)  
      ,dblEleventhWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intEleventhWeekDateFrom and @intEleventhWeekDateTo)  
      ,dblTwelfthWeek = (select sum(booked.dblHours) from booked where booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId and booked.intTicketId = b.intTicketId and booked.intDate between @intTwelfthWeekDateFrom and @intTwelfthWeekDateTo)  
      ,dtmPlanDate = getdate()  
      ,strFilterKey = @strIdentifier  
	  --,ysnBillable
   from  
    tblHDTicketHoursWorked a
    join tblHDTicket b  on b.intTicketId = a.intTicketId  
    join tblEMEntity c on c.intEntityId = a.intAgentEntityId  
    join tblEMEntity d on d.intEntityId = b.intCustomerId  
   where  
	convert(int, convert(nvarchar(8), a.dtmDate, 112)) between @intDateFrom and @intDateTo
	and b.intAssignedToEntity is not null and b.intAssignedToEntity <> 0

	----FROM ACTIVITY SCREEN
	--union all
	--select distinct   
 --     intSourceEntityId = a.intAssignedTo  
 --     ,strSourceName = e.strName  
 --     ,intTicketId = d.intTicketId  
 --     ,strTicketNumber = d.strTicketNumber  
 --     ,intCustomerEntityId = d.intCustomerId  
 --     ,strCustomerName = f.strName  
        
 --     ,dblPlanFirstWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intFirstWeekDateFrom and @intFirstWeekDateTo)  
 --     ,dblPlanSecondWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intSecondWeekDateFrom and @intSecondWeekDateTo)  
 --     ,dblPlanThirdWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intThirdWeekDateFrom and @intThirdWeekDateTo)  
 --     ,dblPlanForthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intFourthWeekDateFrom and @intFourthWeekDateTo)  
 --     ,dblPlanFifthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intFifthWeekDateFrom and @intFifthWeekDateTo)  
 --     ,dblPlanSixthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intSixthWeekDateFrom and @intSixthWeekDateTo)  
 --     ,dblPlanSeventhWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intSeventhWeekDateFrom and @intSeventhWeekDateTo)  
 --     ,dblPlanEighthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intEighthWeekDateFrom and @intEighthWeekDateTo)  
 --     ,dblPlanNinthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intNinthWeekDateFrom and @intNinthWeekDateTo)  
 --     ,dblPlanTenthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intTenthWeekDateFrom and @intTenthWeekDateTo)  
 --     ,dblPlanEleventhWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intEleventhWeekDateFrom and @intEleventhWeekDateTo)  
 --     ,dblPlanTwelfthWeek = (select sum(planed.dblHours) from planed where planed.ysnBillable = @ysnBillable AND planed.intAssignedTo = a.intAssignedTo and planed.intTicketId = d.intTicketId and planed.intDate between @intTwelfthWeekDateFrom and @intTwelfthWeekDateTo)  
        
 --     ,dblEstimateFirstWeek = NULL 
 --     ,dblEstimateSecondWeek = NULL 
 --     ,dblEstimateThirdWeek = NULL 
 --     ,dblEstimateForthWeek = NULL 
 --     ,dblEstimateFifthWeek = NULL 
 --     ,dblEstimateSixthWeek = NULL 
 --     ,dblEstimateSeventhWeek = NULL 
 --     ,dblEstimateEighthWeek = NULL 
 --     ,dblEstimateNinthWeek = NULL 
 --     ,dblEstimateTenthWeek = NULL 
 --     ,dblEstimateEleventhWeek = NULL 
 --     ,dblEstimateTwelfthWeek = NULL 
        
 --     ,dblFirstWeek = NULL 
 --     ,dblSecondWeek = NULL 
 --     ,dblThirdWeek = NULL 
 --     ,dblForthWeek = NULL 
 --     ,dblFifthWeek = NULL 
 --     ,dblSixthWeek = NULL 
 --     ,dblSeventhWeek = NULL 
 --     ,dblEighthWeek = NULL
 --     ,dblNinthWeek = NULL 
 --     ,dblTenthWeek = NULL 
 --     ,dblEleventhWeek = NULL
 --     ,dblTwelfthWeek = NULL
 --     ,dtmPlanDate = getdate()  
 --     ,strFilterKey = @strIdentifier  
	--  --,ysnBillable
	--from  
 --   tblSMActivity a
 --   join tblSMTransaction b  on b.intTransactionId = a.intTransactionId
	--join tblSMScreen c on c.intScreenId = b.intScreenId
	--join tblHDTicket d on d.intTicketId = b.intRecordId
 --   join tblEMEntity e on e.intEntityId = a.intAssignedTo
 --   join tblEMEntity f on f.intEntityId = d.intCustomerId  
 --  	where  
	--convert(int, convert(nvarchar(8), a.dtmStartDate, 112)) between @intDateFrom and @intDateTo
	--and c.strModule = 'Help Desk'  
	--and c.strNamespace = 'HelpDesk.view.Ticket'

END

