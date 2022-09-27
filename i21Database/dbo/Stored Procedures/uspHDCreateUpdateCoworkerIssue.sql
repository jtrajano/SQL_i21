﻿CREATE PROCEDURE [dbo].[uspHDCreateUpdateCoworkerIssue]
(
	 @UserId INT
	,@TimeEntryPeriodDetailId INT
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

BEGIN

			DELETE FROM tblHDCoworkerIssue
			WHERE intUserId = @UserId AND
				  intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId

			--Start Sync Time Off Request

			EXEC [dbo].[uspHDSyncTimeOffRequest] @TimeEntryPeriodDetailId

			--End Sync Time Off Request

			DECLARE @strFiscalYear NVARCHAR(10) = NULL

			INSERT INTO tblHDCoworkerIssue		
				(	
					 [intUserId]					
					,[intTimeEntryPeriodDetailId]
					,[intEntityId]			
					,[strAgentName]				
					,[ysnActive]					
					,[strRemarks]				
					,[intConcurrencyId] 						
				)

				SELECT   [intUserId]					= @UserId
						,[intTimeEntryPeriodDetailId]	= @TimeEntryPeriodDetailId
						,[intEntityId]					= CoworkerIssues.intEntityId
						,[strAgentName]					= CoworkerIssues.strFullName
						,[ysnActive]					= CoworkerIssues.ysnActive
						,[strRemarks]					= CoworkerIssues.strNoCoworkerGoal + CoworkerIssues.strNoTimeEntryOrInsufficientHours + CoworkerIssues.strInactiveWithTimeEntry + CoworkerIssues.strUnapprovedTimeEntry
						,[intConcurrencyId]				= 1
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
						   ,strInactiveWithTimeEntry						=  ''
						   ,strUnapprovedTimeEntry					      =  CASE WHEN  hw.intTicketHoursWorkedId IS NOT NULL AND ApprovalInfo.strStatus IS NOT NULL AND ( ApprovalInfo.strStatus NOT IN ('Approved', 'No Need for Approval', 'Approved with Modifications'))
																						THEN 'Has unapproved Time Entry.'
																					ELSE ''
																			 END 
					FROM vyuHDAgentDetail Agent
						OUTER APPLY (
							SELECT intTimeEntryPeriodDetailId
								   ,dtmBillingPeriodStart
								   ,dtmBillingPeriodEnd
							FROM tblHDTimeEntryPeriodDetail
							WHERE intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId
						) TimeEntryPeriodDetail
						OUTER APPLY(
								SELECT	 TOP 1 intEntityId			  = CoworkerGoals.intEntityId
											  ,ysnActive				  = CoworkerGoals.ysnActive 
								FROM tblHDCoworkerGoal CoworkerGoals
										INNER JOIN tblHDCoworkerGoalDetail CoworkerGoalDetail
								ON CoworkerGoals.intCoworkerGoalId = CoworkerGoalDetail.intCoworkerGoalId
								WHERE CoworkerGoals.intEntityId = Agent.intEntityId AND
									  CoworkerGoalDetail.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId AND
									  CoworkerGoals.strFiscalYear = @strFiscalYear
						) CoworkerGoalTimeEntryperiodDetails
						OUTER APPLY(
							SELECT TOP 1 intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
										 ,intRequiredHours						= AgentTimeEntryPeriodDetailSummary.intRequiredHours
										 ,dblTotalHours							= AgentTimeEntryPeriodDetailSummary.dblTotalHours
							FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
							WHERE AgentTimeEntryPeriodDetailSummary.intEntityId = Agent.intEntityId AND
								  AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId
						) AgentTimeEntryPeriodDetailSummaries
						OUTER APPLY(
							SELECT TOP 1  TimeEntry.intTimeEntryId
										 ,TimeEntry.intEntityId
							FROM tblHDTimeEntry TimeEntry
							WHERE TimeEntry.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId AND
								  TimeEntry.intEntityId = Agent.intEntityId
						) TimeEntry
						OUTER APPLY(
							SELECT TOP 1 a.intTicketHoursWorkedId 
							FROM vyuHDTicketHoursWorked a 
								INNER JOIN tblEMEntity b 
							ON a.intAgentEntityId = b.intEntityId
							WHERE a.dtmDate >= TimeEntryPeriodDetail.dtmBillingPeriodStart AND a.dtmDate <= TimeEntryPeriodDetail.dtmBillingPeriodEnd AND
								  b.intEntityId = TimeEntry.intEntityId
					
						) hw
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
					WHERE Agent.ysnDisabled = CONVERT(BIT, 0) AND
						  Agent.ysnVendor = CONVERT(BIT, 0) AND
						  Agent.ysnTimeEntryExempt = CONVERT(BIT, 0) AND 
						  ( 
						    ( CoworkerGoalTimeEntryperiodDetails.intEntityId IS NOT NULL AND CoworkerGoalTimeEntryperiodDetails.ysnActive = CONVERT(BIT, 1) ) OR
							  CoworkerGoalTimeEntryperiodDetails.intEntityId IS NULL
						  )
				) CoworkerIssues
				WHERE ( CoworkerIssues.strInactiveWithTimeEntry != '' OR
				CoworkerIssues.strNoCoworkerGoal != '' OR
				CoworkerIssues.strNoTimeEntryOrInsufficientHours != '' OR
				CoworkerIssues.strUnapprovedTimeEntry != '' ) 
				AND intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId
			
END
GO