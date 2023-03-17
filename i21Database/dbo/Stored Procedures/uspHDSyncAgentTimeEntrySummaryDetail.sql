CREATE PROCEDURE [dbo].[uspHDSyncAgentTimeEntrySummaryDetail]
(
	@EntityId INT,
	@TimeEntryPeriodDetailId INT
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

BEGIN

	DECLARE @intEntityId INT,
			@intTimeEntryPeriodDetailId INT 

	SET @intEntityId  = @EntityId
	SET	@intTimeEntryPeriodDetailId  = @TimeEntryPeriodDetailId

	--Time Off Request
	UPDATE tblHDTimeOffRequestToUpdate
	SET intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
	FROM tblHDTimeOffRequest TimeOffRequest
		INNER JOIN tblHDTimeOffRequest tblHDTimeOffRequestToUpdate
	ON TimeOffRequest.intTimeOffRequestId = tblHDTimeOffRequestToUpdate.intTimeOffRequestId
		CROSS APPLY
		(
			SELECT TOP 1 intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
			FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
			WHERE TimeEntryPeriodDetail.dtmBillingPeriodStart <= TimeOffRequest.dtmPRDate AND
				  TimeEntryPeriodDetail.dtmBillingPeriodEnd >= 	TimeOffRequest.dtmPRDate AND
				  TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = @intTimeEntryPeriodDetailId
		) TimeEntryPeriodDetail
		CROSS APPLY
		(
			SELECT TOP 1 intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
			FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
			WHERE AgentTimeEntryPeriodDetailSummary.intEntityId = TimeOffRequest.intPREntityEmployeeId AND
				  AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
		) AgentTimeEntryPeriodDetailSummary
	WHERE TimeOffRequest.intPREntityEmployeeId = @intEntityId

	--Ticket Hours Worked
	UPDATE tblHDTicketHoursWorkedToUpdate
	SET intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
	FROM tblHDTicketHoursWorked TicketHoursWorked
		INNER JOIN tblHDTicketHoursWorked tblHDTicketHoursWorkedToUpdate
	ON TicketHoursWorked.intTicketHoursWorkedId = tblHDTicketHoursWorkedToUpdate.intTicketHoursWorkedId
		CROSS APPLY
		(
			SELECT TOP 1 intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
			FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
			WHERE TimeEntryPeriodDetail.dtmBillingPeriodStart <= TicketHoursWorked.dtmDate AND
				  TimeEntryPeriodDetail.dtmBillingPeriodEnd >= 	TicketHoursWorked.dtmDate AND
				  TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = @intTimeEntryPeriodDetailId
		) TimeEntryPeriodDetail
		CROSS APPLY
		(
			SELECT TOP 1 intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
			FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
			WHERE AgentTimeEntryPeriodDetailSummary.intEntityId = TicketHoursWorked.intAgentEntityId AND
				  AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
		) AgentTimeEntryPeriodDetailSummary
	WHERE TicketHoursWorked.intAgentEntityId = @intEntityId
		
END
GO