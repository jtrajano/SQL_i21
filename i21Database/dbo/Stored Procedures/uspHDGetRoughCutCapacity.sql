CREATE PROCEDURE [dbo].[uspHDGetRoughCutCapacity]  
 @dtmCriteriaDate DATETIME
 ,@intEntityId INT = 1  
 ,@ysnBillable INT = -1
AS  
BEGIN  
  
SET QUOTED_IDENTIFIER OFF;  
SET ANSI_NULLS ON;  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
SET ANSI_WARNINGS OFF;  
 
DELETE tblHDRoughCutCapacity WHERE intEntityId = @intEntityId

DECLARE 
    @dtmDateFrom DATETIME = @dtmCriteriaDate,
    @dtmDateTo DATETIME = DATEADD(DAY, 83, @dtmCriteriaDate),

    @dtmFirstWeekDateFrom DATETIME = @dtmCriteriaDate,
    @dtmFirstWeekDateTo DATETIME = DATEADD(DAY, 6, @dtmCriteriaDate),

    @dtmSecondWeekDateFrom DATETIME = DATEADD(DAY, 7, @dtmCriteriaDate),
    @dtmSecondWeekDateTo DATETIME = DATEADD(DAY, 13, @dtmCriteriaDate), 

    @dtmThirdWeekDateFrom DATETIME = DATEADD(DAY,  14, @dtmCriteriaDate), 
    @dtmThirdWeekDateTo DATETIME = DATEADD(DAY, 20, @dtmCriteriaDate),

    @dtmFourthWeekDateFrom DATETIME = DATEADD(DAY, 21, @dtmCriteriaDate),
    @dtmFourthWeekDateTo DATETIME = DATEADD(DAY, 27, @dtmCriteriaDate),
  
    @dtmFifthWeekDateFrom DATETIME = DATEADD(DAY, 28, @dtmCriteriaDate),
    @dtmFifthWeekDateTo DATETIME = DATEADD(DAY, 34, @dtmCriteriaDate),
  
    @dtmSixthWeekDateFrom DATETIME = DATEADD(DAY, 35, @dtmCriteriaDate),
    @dtmSixthWeekDateTo DATETIME = DATEADD(DAY, 41, @dtmCriteriaDate),
  
    @dtmSeventhWeekDateFrom DATETIME = DATEADD(DAY, 42, @dtmCriteriaDate),
    @dtmSeventhWeekDateTo DATETIME = DATEADD(DAY, 48, @dtmCriteriaDate),
  
    @dtmEighthWeekDateFrom DATETIME = DATEADD(DAY, 49, @dtmCriteriaDate),
    @dtmEighthWeekDateTo DATETIME = DATEADD(DAY, 55, @dtmCriteriaDate),
  
    @dtmNinthWeekDateFrom DATETIME = DATEADD(DAY, 56, @dtmCriteriaDate),
    @dtmNinthWeekDateTo DATETIME = DATEADD(DAY, 62, @dtmCriteriaDate),
  
    @dtmTenthWeekDateFrom DATETIME = DATEADD(DAY, 63, @dtmCriteriaDate),
    @dtmTenthWeekDateTo DATETIME = DATEADD(DAY, 69, @dtmCriteriaDate),
  
    @dtmEleventhWeekDateFrom DATETIME = DATEADD(DAY,  70, @dtmCriteriaDate),
    @dtmEleventhWeekDateTo DATETIME = DATEADD(DAY, 76, @dtmCriteriaDate),
  
    @dtmTwelfthWeekDateFrom DATETIME = DATEADD(DAY, 77, @dtmCriteriaDate),
    @dtmTwelfthWeekDateTo DATETIME = DATEADD(DAY, 83, @dtmCriteriaDate);

;WITH booked AS (  
    SELECT
        intAgentEntityId = a.intAgentEntityId  
        ,a.intTicketId  
        ,dblHours = SUM(a.intHours)  
        ,dblEstimatedHours = SUM(a.dblEstimatedHours)  
        ,dtmDate = a.dtmDate
        ,ysnBillable = (CASE WHEN ISNULL(@ysnBillable, -1) <> -1 THEN a.ysnBillable ELSE -1 END)
		,a.intItemId
    FROM tblHDTicketHoursWorked a
    LEFT JOIN tblHDTicket b ON b.intTicketId = a.intTicketId
    WHERE
        a.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
    GROUP BY
         a.intAgentEntityId  
        ,a.intTicketId 
		,a.intItemId 
        ,a.dtmDate  
        ,ysnBillable
),
planned AS (  
    SELECT
        a.intTicketId  
        ,d.intAssignedTo  
        ,dtmDate = d.dtmStartDate
        ,dblHours = (CASE  
	          WHEN ISNULL(d.dblNumberOfHours, 0) <> 0
		        THEN d.dblNumberOfHours
              WHEN DATEDIFF(DAY, d.dtmStartDate, d.dtmEndDate) > 0 AND DATEDIFF(HOUR, d.dtmStartDate, d.dtmEndDate) > 8 AND (d.ysnAllDayEvent IS NULL OR d.ysnAllDayEvent = CONVERT(BIT, 0))  
		        THEN SUM(CONVERT(numeric(18,6),DATEDIFF(DAY, d.dtmStartDate, d.dtmEndDate)) * CONVERT(numeric(18,6),8.00))  
              WHEN DATEDIFF(DAY, d.dtmStartDate, d.dtmEndDate) > 0 AND DATEDIFF(HOUR, d.dtmStartDate, d.dtmEndDate) < 8 AND (d.ysnAllDayEvent IS NULL OR d.ysnAllDayEvent = CONVERT(BIT, 0))  
		        THEN SUM(CONVERT(numeric(18,6),DATEDIFF(HOUR, d.dtmStartDate, d.dtmEndDate)))  
              WHEN d.ysnAllDayEvent = CONVERT(BIT, 1)  
		        THEN 8.00  
              WHEN DATEDIFF(DAY, d.dtmStartDate, d.dtmEndDate) = 0 AND (d.ysnAllDayEvent IS NULL OR d.ysnAllDayEvent = CONVERT(BIT, 0))  
		        THEN SUM(CONVERT(numeric(18,6),DATEDIFF(MINUTE, d.dtmStartDate, d.dtmEndDate))/60.00)  
              ELSE 0.00  
             END)
    ,ysnBillable = (CASE WHEN ISNULL(@ysnBillable, -1) <> -1 THEN d.ysnBillable ELSE -1 END)
	,intItemId = Item.intItemId
    FROM tblHDTicket a  
    JOIN tblSMTransaction b ON b.intRecordId = a.intTicketId
    JOIN tblSMScreen c ON c.intScreenId = b.intScreenId
    JOIN tblSMActivity d ON d.intTransactionId = b.intTransactionId
	OUTER APPLY
	(
	    SELECT TOP 1 intItemId
	    FROM
	    tblHDTicketHoursWorked
	    WHERE intAgentEntityId = d.intAssignedTo AND
	         intTicketId = a.intTicketId and
		     dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	) Item
    WHERE
        d.dtmStartDate BETWEEN @dtmDateFrom AND @dtmDateTo
        AND c.strModule = 'Help Desk'
        AND c.strNamespace = 'HelpDesk.view.Ticket'
        AND d.dtmStartDate IS NOT NULL
        AND d.dtmEndDate IS NOT NULL
    GROUP BY  
        a.intTicketId  
        ,d.intAssignedTo
        ,a.dtmDueDate  
        ,d.dtmStartDate  
        ,d.dtmEndDate  
        ,d.ysnAllDayEvent  
        ,d.dblNumberOfHours
        ,ysnBillable
		,Item.intItemId
		
)  
  
INSERT INTO tblHDRoughCutCapacity  
(  
    intSourceEntityId  
    ,intTicketId  
    ,intCustomerEntityId  
	,intItemId
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
    ,intEntityId
)

--FROM TIME ENTRY
SELECT DISTINCT   
    intSourceEntityId = a.intAgentEntityId  
    --,strSourceName = c.strName
    ,intTicketId = b.intTicketId  
    --,strTicketNumber = b.strTicketNumber  
    ,intCustomerEntityId = b.intCustomerId  
    --,strCustomerName = d.strName  
    ,intItemId = a.intItemId
    ,dblPlanFirstWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmFirstWeekDateFrom AND @dtmFirstWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanSecondWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmSecondWeekDateFrom AND @dtmSecondWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanThirdWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmThirdWeekDateFrom AND @dtmThirdWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanForthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmFourthWeekDateFrom AND @dtmFourthWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanFifthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmFifthWeekDateFrom AND @dtmFifthWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanSixthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmSixthWeekDateFrom AND @dtmSixthWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanSeventhWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmSeventhWeekDateFrom AND @dtmSeventhWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanEighthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmEighthWeekDateFrom AND @dtmEighthWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanNinthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmNinthWeekDateFrom AND @dtmNinthWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanTenthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmTenthWeekDateFrom AND @dtmTenthWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanEleventhWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmEleventhWeekDateFrom AND @dtmEleventhWeekDateTo AND planned.intItemId = e.intItemId)  
    ,dblPlanTwelfthWeek = (SELECT SUM(planned.dblHours) FROM planned WHERE planned.ysnBillable = @ysnBillable AND planned.intAssignedTo = a.intAgentEntityId AND planned.intTicketId = b.intTicketId AND planned.dtmDate between @dtmTwelfthWeekDateFrom AND @dtmTwelfthWeekDateTo AND planned.intItemId = e.intItemId)  
        
    ,dblEstimateFirstWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId  AND booked.dtmDate between @dtmFirstWeekDateFrom AND @dtmFirstWeekDateTo)  
    ,dblEstimateSecondWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmSecondWeekDateFrom AND @dtmSecondWeekDateTo)  
    ,dblEstimateThirdWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmThirdWeekDateFrom AND @dtmThirdWeekDateTo)  
    ,dblEstimateForthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmFourthWeekDateFrom AND @dtmFourthWeekDateTo)  
    ,dblEstimateFifthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmFifthWeekDateFrom AND @dtmFifthWeekDateTo)  
    ,dblEstimateSixthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmSixthWeekDateFrom AND @dtmSixthWeekDateTo)  
    ,dblEstimateSeventhWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmSeventhWeekDateFrom AND @dtmSeventhWeekDateTo)  
    ,dblEstimateEighthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmEighthWeekDateFrom AND @dtmEighthWeekDateTo)  
    ,dblEstimateNinthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmNinthWeekDateFrom AND @dtmNinthWeekDateTo)  
    ,dblEstimateTenthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmTenthWeekDateFrom AND @dtmTenthWeekDateTo)  
    ,dblEstimateEleventhWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmEleventhWeekDateFrom AND @dtmEleventhWeekDateTo)
    ,dblEstimateTwelfthWeek = (SELECT SUM(booked.dblEstimatedHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmTwelfthWeekDateFrom AND @dtmTwelfthWeekDateTo)  
        
    ,dblFirstWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmFirstWeekDateFrom AND @dtmFirstWeekDateTo)  
    ,dblSecondWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmSecondWeekDateFrom AND @dtmSecondWeekDateTo)  
    ,dblThirdWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmThirdWeekDateFrom AND @dtmThirdWeekDateTo)  
    ,dblForthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmFourthWeekDateFrom AND @dtmFourthWeekDateTo)  
    ,dblFifthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmFifthWeekDateFrom AND @dtmFifthWeekDateTo)  
    ,dblSixthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmSixthWeekDateFrom AND @dtmSixthWeekDateTo)  
    ,dblSeventhWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId  AND booked.dtmDate between @dtmSeventhWeekDateFrom AND @dtmSeventhWeekDateTo)  
    ,dblEighthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId  AND booked.dtmDate between @dtmEighthWeekDateFrom AND @dtmEighthWeekDateTo)  
    ,dblNinthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmNinthWeekDateFrom AND @dtmNinthWeekDateTo)  
    ,dblTenthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmTenthWeekDateFrom AND @dtmTenthWeekDateTo)  
    ,dblEleventhWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmEleventhWeekDateFrom AND @dtmEleventhWeekDateTo)  
    ,dblTwelfthWeek = (SELECT SUM(booked.dblHours) FROM booked WHERE booked.ysnBillable = @ysnBillable AND booked.intAgentEntityId = a.intAgentEntityId AND booked.intTicketId = b.intTicketId AND booked.intItemId = e.intItemId AND booked.dtmDate between @dtmTwelfthWeekDateFrom AND @dtmTwelfthWeekDateTo)  
    
    ,dtmPlanDate = GETDATE()
    ,intEntityId = @intEntityId
FROM tblHDTicketHoursWorked a
JOIN tblHDTicket b ON b.intTicketId = a.intTicketId  
JOIN tblEMEntity c ON c.intEntityId = a.intAgentEntityId  
JOIN tblEMEntity d ON d.intEntityId = b.intCustomerId 
JOIN tblICItem e ON e.intItemId = a.intItemId   
WHERE  
    a.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
    AND b.intAssignedToEntity IS NOT NULL AND b.intAssignedToEntity <> 0

END


GO