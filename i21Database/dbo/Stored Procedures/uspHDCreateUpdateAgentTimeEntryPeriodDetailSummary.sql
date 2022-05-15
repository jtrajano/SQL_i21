CREATE PROCEDURE [dbo].[uspHDCreateUpdateAgentTimeEntryPeriodDetailSummary]
(
	  @EntityId INT
)
AS
BEGIN

	IF @EntityId IS NULL
		RETURN

		
	IF @EntityId IS NULL
		RETURN


	DELETE FROM tblHDAgentTimeEntryPeriodDetailSummary
	WHERE [intEntityId] = @EntityId

	DECLARE @dblUtilizationWeekly INT = 0,
			@dblUtilizationAnnually INT = 0,
			@dblUtilizationMonthly INT = 0

	SELECT TOP 1 @dblUtilizationWeekly	 = intUtilizationTargetWeekly
				,@dblUtilizationAnnually = intUtilizationTargetAnnual
				,@dblUtilizationMonthly  = intUtilizationTargetMonthly
	FROM tblHDCoworkerGoal
	WHERE intEntityId = @EntityId


	INSERT INTO tblHDAgentTimeEntryPeriodDetailSummary
	(
		     [intEntityId]							
			,[intTimeEntryPeriodDetailId]			
			,[dtmBillingPeriodStart]					
			,[dtmBillingPeriodEnd]					
			,[dblTotalHours]							
			,[dblBillableHours]						
			,[dblNonBillableHours]					
			,[dblBudgetedHours]					
			,[dblVacationHolidaySick]				
			,[intUtilizationWeekly]					
			,[intUtilizationAnnually]					
			,[intUtilizationMonthly]					
			,[dblActualUtilizationWeekly]			
			,[dblActualUtilizationAnnually]			
			,[dblActualUtilizationMonthly]	
			,[dblAnnualHurdle]	
			,[intRequiredHours]						
			,[intConcurrencyId] 
	)

	
SELECT      [intEntityId]							    = @EntityId
		   ,[intTimeEntryPeriodDetailId]			= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
		   ,[dtmBillingPeriodStart]					= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
		   ,[dtmBillingPeriodEnd]					= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		   ,[dblTotalHours]							= ISNULL(TimeEntryPeriodDetailInfo.[dblTotalHours], 0) 
		   ,[dblBillableHours]						= ISNULL(TimeEntryPeriodDetailInfo.[totalBillableHours], 0)  
		   ,[dblNonBudgetedHours]					= ISNULL(TimeEntryPeriodDetailInfo.[totalNonBillableHours], 0)  
		   ,[dblBudgetedHours]						= ISNULL(CoworkerGoals.dblBudget, 0)  
		   ,[dblVacationHolidaySick]				= ISNULL(TimeEntryPeriodDetailInfo.[vlHolidaySickHours], 0)  
		   ,[intUtilizationWeekly]					= ISNULL(CoworkerGoals.intUtilizationTargetWeekly, 0) 
		   ,[intUtilizationAnnually]				= ISNULL(CoworkerGoals.intUtilizationTargetAnnual, 0) 
		   ,[intUtilizationMonthly]					= ISNULL(CoworkerGoals.intUtilizationTargetMonthly, 0) 
		   ,[dblActualUtilizationWeekly]			= ISNULL(TimeEntryPeriodDetailInfo.[dblActualUtilizationWeekly], 0)  
		   ,[dblActualUtilizationAnnually]			= ISNULL(TimeEntryPeriodDetailInfo.[dblActualUtilizationAnnually], 0) 
		   ,[dblActualUtilizationMonthly]			= ISNULL(TimeEntryPeriodDetailInfo.[dblActualUtilizationMonthly], 0) 
		   ,[dblAnnualHurdle]						= ISNULL(CoworkerGoals.[dblAnnualHurdle], 0) 
		   ,[intRequiredHours]						= ISNULL(TimeEntryPeriodDetailInfo.[intRequiredHours], 0) 
		   ,[intConcurrencyId]						= 1
		FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
				INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
		ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId
		OUTER APPLY(
		   SELECT  intUtilizationTargetAnnual
				  ,intUtilizationTargetMonthly
				  ,intUtilizationTargetWeekly
				  ,dblAnnualHurdle
				  ,dblBudget
		   FROM tblHDCoworkerGoal CoworkerGoal
				INNER JOIN tblHDCoworkerGoalDetail CoworkerGoalDetail
		   ON CoworkerGoal.intCoworkerGoalId = CoworkerGoalDetail.intCoworkerGoalId
		   WHERE CoworkerGoal.intEntityId = @EntityId AND
				 CoworkerGoal.strFiscalYear = TimeEntryPeriod.strFiscalYear AND
				 CoworkerGoalDetail.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
		 ) CoworkerGoals
		LEFT JOIN

		( SELECT   [intTimeEntryPeriodDetailId]		= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
				  ,[dblTotalHours]					= AgentInfoWeekly.[totalHours]
				  ,[totalBillableHours]				= AgentInfoWeekly.[totalBillableHours]
				  ,[totalNonBillableHours]			= AgentInfoWeekly.[totalNonBillableHours]
				  ,[vlHolidaySickHours]				= VacationHolidaySick.dblRequest
				  ,[intRequiredHours]				= ISNULL(TimeEntryPeriodDetail.intRequiredHours, 0)
				  ,[dblActualUtilizationWeekly]		= AgentInfoWeekly.[totalBillableHours] / ( TotalWeeklyRequiredHours.totalHours - ISNULL(VacationHolidaySick.dblRequest, 0) ) * 100
				  ,[dblActualUtilizationAnnually]	= AgentInfoAnnually.[totalBillableHours] / ( TotalAnnualRequiredHours.totalHours - ISNULL(VacationHolidaySick.dblRequest, 0) ) * 100
				  ,[dblActualUtilizationMonthly]	= AgentInfoMonthly.[totalBillableHours] / ( TotalMonthlyRequiredHours.totalHours - ISNULL(VacationHolidaySick.dblRequest, 0) ) * 100
			FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
				INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
			ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId
				CROSS APPLY(
					SELECT SUM(b.dblRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  tblPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId
		
				) VacationHolidaySick
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM([totalHours])
						   ,[totalBillableHours]	= SUM([totalBillableHours])
						   ,[totalNonBillableHours]	= SUM([totalNonBillableHours])
					FROM (		
								SELECT  [totalHours]			= SUM(dblHours)
									   ,[totalBillableHours]	= CASE WHEN ysnBillable = 1
																			THEN SUM(dblHours)
																		ELSE 0
																  END
									   ,[totalNonBillableHours]	= CASE WHEN ysnBillable = 0
																			THEN SUM(dblHours)
																		ELSE 0
																  END								
								FROM vyuHDTicketHoursWorked
								WHERE [dtmDate] >= TimeEntryPeriodDetail.[dtmBillingPeriodStart] AND
									  [dtmDate] <= TimeEntryPeriodDetail.[dtmBillingPeriodEnd] AND
									  intAgentEntityId = @EntityId
								GROUP BY [ysnBillable]
					) TotalHours
				) AgentInfoWeekly
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM([totalHours])
						   ,[totalBillableHours]	= SUM([totalBillableHours])
						   ,[totalNonBillableHours]	= SUM([totalNonBillableHours])
					FROM (		
								SELECT  [totalHours]			= SUM(dblHours)
									   ,[totalBillableHours]	= CASE WHEN ysnBillable = 1
																			THEN SUM(dblHours)
																		ELSE 0
																  END
									   ,[totalNonBillableHours]	= CASE WHEN ysnBillable = 0
																			THEN SUM(dblHours)
																		ELSE 0
																  END								
								FROM vyuHDTicketHoursWorked
								WHERE DATEPART(YEAR, dtmDate) = TimeEntryPeriod.strFiscalYear AND
										  DATEPART(month, dtmDate) = DATEPART(month, TimeEntryPeriodDetail.dtmBillingPeriodStart) AND
										  intAgentEntityId = @EntityId
								GROUP BY [ysnBillable]
					) TotalHours
				) AgentInfoAnnually
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM([totalHours])
						   ,[totalBillableHours]	= SUM([totalBillableHours])
						   ,[totalNonBillableHours]	= SUM([totalNonBillableHours])
					FROM (		
								SELECT  [totalHours]			= SUM(dblHours)
									   ,[totalBillableHours]	= CASE WHEN ysnBillable = 1
																			THEN SUM(dblHours)
																		ELSE 0
																  END
									   ,[totalNonBillableHours]	= CASE WHEN ysnBillable = 0
																			THEN SUM(dblHours)
																		ELSE 0
																  END								
								FROM vyuHDTicketHoursWorked
								WHERE DATEPART(YEAR, dtmDate) = TimeEntryPeriod.strFiscalYear AND
									  DATEPART(month, dtmDate) = DATEPART(month, TimeEntryPeriodDetail.dtmBillingPeriodStart) AND
									  intAgentEntityId = @EntityId
								GROUP BY [ysnBillable]
					) TotalHours
				) AgentInfoMonthly
				CROSS APPLY
				(
					SELECT  intTimeEntryPeriodDetailId
						   ,[totalHours]			= SUM(intRequiredHours)							
					FROM tblHDTimeEntryPeriodDetail a
					WHERE a.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId 
					GROUP BY intTimeEntryPeriodDetailId
				) TotalWeeklyRequiredHours
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(intRequiredHours)							
					FROM tblHDTimeEntryPeriodDetail a
							INNER JOIN tblHDTimeEntryPeriod b
					ON a.intTimeEntryPeriodId = b.intTimeEntryPeriodId
					WHERE b.strFiscalYear = TimeEntryPeriod.strFiscalYear
				) TotalAnnualRequiredHours
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(intRequiredHours)							
					FROM tblHDTimeEntryPeriodDetail a
							INNER JOIN tblHDTimeEntryPeriod b
					ON a.intTimeEntryPeriodId = b.intTimeEntryPeriodId
					WHERE b.strFiscalYear = TimeEntryPeriod.strFiscalYear AND
						  DATEPART(month, a.dtmBillingPeriodStart) = DATEPART(month, TimeEntryPeriodDetail.dtmBillingPeriodStart)
				) TotalMonthlyRequiredHours
		) TimeEntryPeriodDetailInfo
		ON TimeEntryPeriodDetailInfo.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId






END
GO