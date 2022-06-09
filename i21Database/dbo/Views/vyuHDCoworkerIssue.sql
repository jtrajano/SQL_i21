CREATE VIEW [dbo].[vyuHDCoworkerIssue]
AS 
SELECT  intId						= CONVERT(INT,ROW_NUMBER() OVER ( ORDER BY CoworkerIssues.intEntityId, CoworkerIssues.intTimeEntryPeriodDetailId ))
	   ,strAgentName				= CoworkerIssues.strFullName
	   ,intTimeEntryPeriodDetailId	= CoworkerIssues.intTimeEntryPeriodDetailId
	   ,intEntityId					= CoworkerIssues.intEntityId
	   ,ysnActive					= CoworkerIssues.ysnActive
	   ,strRemarks					= CoworkerIssues.strNoCoworkerGoal + CoworkerIssues.strNoTimeEntryOrInsufficientHours + CoworkerIssues.strInactiveWithTimeEntry + CoworkerIssues.strUnapprovedTimeEntry
	   ,intConcurrencyId			= 1
FROM (

	SELECT  Agent.strFullName
		   ,intTimeEntryPeriodDetailId						= ISNULL(TimeEntryPeriodDetail.intTimeEntryPeriodDetailId, 0)
		   ,intEntityId										= Agent.intEntityId
		   ,ysnActive										= ISNULL(CoworkerGoalTimeEntryperiodDetails.ysnActive, 0)
		   ,strNoCoworkerGoal								= CASE WHEN CoworkerGoalTimeEntryperiodDetails.intEntityId IS NULL AND hw.intTicketHoursWorkedId IS NOT NULL
																		THEN 'No Coworker Goal Setup but has time entry. '
																	ELSE ''
															  END
		   ,strNoTimeEntryOrInsufficientHours				= CASE WHEN ISNULL(CoworkerGoalTimeEntryperiodDetails.ysnActive, 0) = 1 AND  
																	 ( AgentTimeEntryPeriodDetailSummaries.intAgentTimeEntryPeriodDetailSummaryId IS NULL OR
																		AgentTimeEntryPeriodDetailSummaries.intRequiredHours - AgentTimeEntryPeriodDetailSummaries.dblTotalHours > 0)
																		THEN 'No Time Entry or insufficient time entry. '
																	ELSE ''
															  END
		   ,strInactiveWithTimeEntry						=  CASE WHEN ISNULL(CoworkerGoalTimeEntryperiodDetails.ysnActive, 0) = 0 AND AgentTimeEntryPeriodDetailSummaries.dblTotalHours > 0 AND CoworkerGoalTimeEntryperiodDetails.intEntityId IS NOT NULL 
																			THEN 'Inactive but has a Time Entry. '
																		ELSE ''
																  END
		   ,strUnapprovedTimeEntry					      =  CASE WHEN  ApprovalInfo.strStatus IS NOT NULL AND ( ApprovalInfo.strStatus NOT IN ('Approved', 'No Need for Approval'))
																		THEN 'Has unapproved Time Entry.'
																	ELSE ''
															 END 
	FROM vyuHDAgentDetail Agent
	--	LEFT JOIN
	--	(
	--		SELECT	 intTimeEntryPeriodDetailId = CoworkerGoals.intTimeEntryPeriodDetailId
	--				,intEntityId			  = CoworkerGoals.intEntityId
	--				,ysnActive				  = CoworkerGoals.ysnActive 
	--		FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
	--			LEFT JOIN (
	--				SELECT  intTimeEntryPeriodDetailId = CoworkerGoalDetail.intTimeEntryPeriodDetailId
	--					   ,intEntityId				   = CoworkerGoal.intEntityId
	--					   ,ysnActive				   = CoworkerGoal.ysnActive
	--				FROM tblHDCoworkerGoal CoworkerGoal
	--					INNER JOIN tblHDCoworkerGoalDetail  CoworkerGoalDetail
	--				ON CoworkerGoalDetail.intCoworkerGoalId = CoworkerGoal.intCoworkerGoalId
	--			) CoworkerGoals
	--		ON CoworkerGoals.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
	--) CoworkerGoalTimeEntryperiodDetails
	--ON CoworkerGoalTimeEntryperiodDetails.intEntityId = Agent.intEntityId
		CROSS JOIN (
			SELECT intTimeEntryPeriodDetailId
				   ,dtmBillingPeriodStart
				   ,dtmBillingPeriodEnd
			FROM tblHDTimeEntryPeriodDetail
		) TimeEntryPeriodDetail
		OUTER APPLY(
				SELECT	 TOP 1 intEntityId			  = CoworkerGoals.intEntityId
							  ,ysnActive				  = CoworkerGoals.ysnActive 
				FROM tblHDCoworkerGoal CoworkerGoals
				WHERE CoworkerGoals.intEntityId = Agent.intEntityId
		) CoworkerGoalTimeEntryperiodDetails
		OUTER APPLY(
			SELECT TOP 1 intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
						 ,intRequiredHours						= AgentTimeEntryPeriodDetailSummary.intRequiredHours
						 ,dblTotalHours							= AgentTimeEntryPeriodDetailSummary.dblTotalHours
			FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
			WHERE AgentTimeEntryPeriodDetailSummary.intEntityId = Agent.intEntityId AND
				  AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
		) AgentTimeEntryPeriodDetailSummaries
		OUTER APPLY(
			SELECT TOP 1 hw.intTicketHoursWorkedId
			FROM vyuHDTicketHoursWorked hw
			WHERE dtmDate >= TimeEntryPeriodDetail.dtmBillingPeriodStart AND dtmDate <= TimeEntryPeriodDetail.dtmBillingPeriodEnd AND
				  intAgentEntityId = Agent.intEntityId
					
		) hw
		OUTER APPLY(
			SELECT TOP 1 TimeEntry.intTimeEntryId
			FROM tblHDTimeEntry TimeEntry
			WHERE TimeEntry.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId AND
				  TimeEntry.intEntityId = Agent.intEntityId
		) TimeEntry
		OUTER APPLY(
			SELECT  strStatus = Approval.strStatus 
			FROM tblSMApproval Approval
					INNER JOIN tblSMScreen Screen
			ON Approval.intScreenId = Screen.intScreenId
					INNER JOIN tblSMTransaction SMTransaction
			ON Approval.intTransactionId = SMTransaction.intTransactionId
			WHERE Screen.strScreenName = 'Time Entry' AND
				  SMTransaction.intRecordId = TimeEntry.intTimeEntryId AND
				  Approval.ysnCurrent = 1
		) ApprovalInfo
	WHERE Agent.ysnDisabled = 0
) CoworkerIssues
WHERE CoworkerIssues.strInactiveWithTimeEntry != '' OR
CoworkerIssues.strNoCoworkerGoal != '' OR
CoworkerIssues.strNoTimeEntryOrInsufficientHours != '' OR
CoworkerIssues.strUnapprovedTimeEntry != ''
GO