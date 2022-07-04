CREATE PROCEDURE [dbo].[uspHDCreateUpdateAgentTimeEntryPeriodDetailSummary]
(
	    @EntityId INT
	   ,@TimeEntryPeriodDetailId int 
	   ,@TimeEntryId INT 
)
AS
BEGIN

	IF @EntityId IS NULL OR @TimeEntryPeriodDetailId IS NULL
		RETURN

	IF @TimeEntryPeriodDetailId = 0 AND @TimeEntryId = 0
		RETURN

	IF @TimeEntryPeriodDetailId = 0
	BEGIN
		SELECT TOP 1 @TimeEntryPeriodDetailId = intTimeEntryPeriodDetailId
		FROM tblHDTimeEntry
		WHERE intTimeEntryId = @TimeEntryId

	END

	DECLARE  @intTimeEntryPeriodDetailId		INT
			,@dtmBillingPeriodStart				DATETIME
			,@dtmBillingPeriodEnd				DATETIME
			,@dblTotalHours						NUMERIC(18,6)
		    ,@dblBillableHours					NUMERIC(18,6)
			,@dblNonBudgetedHours				NUMERIC(18,6)
			,@dblBudgetedHours					NUMERIC(18,6)
			,@dblVacationHolidaySick			NUMERIC(18,6)
			,@intUtilizationWeekly			    INT
			,@intUtilizationAnnually		    INT
			,@intUtilizationMonthly		        INT
			,@dblActualUtilizationWeekly		NUMERIC(18,6)
			,@dblActualUtilizationAnnually		NUMERIC(18,6)
			,@dblActualUtilizationMonthly		NUMERIC(18,6)
			,@dblAnnualHurdle					NUMERIC(18,6)
			,@dblAnnualBudget					NUMERIC(18,6)
			,@dblActualAnnualBudget				NUMERIC(18,6)
			,@dblActualWeeklyBudget				NUMERIC(18,6)
			,@intRequiredHours					INT

	SELECT  --[intEntityId]							= @EntityId
		    @intTimeEntryPeriodDetailId				= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
		   ,@dtmBillingPeriodStart					= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
		   ,@dtmBillingPeriodEnd					= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		   ,@dblTotalHours							= ISNULL(TimeEntryPeriodDetailInfo.[dblTotalHours], 0) 
		   ,@dblBillableHours						= ISNULL(TimeEntryPeriodDetailInfo.[totalBillableHours], 0)  
		   ,@dblNonBudgetedHours					= ISNULL(TimeEntryPeriodDetailInfo.[totalNonBillableHours], 0)  
		   ,@dblBudgetedHours						= ISNULL(CoworkerGoals.dblBudget, 0)  
		   ,@dblVacationHolidaySick					= ISNULL(TimeEntryPeriodDetailInfo.[vlHolidaySickHours], 0)  
		   ,@intUtilizationWeekly					= ISNULL(CoworkerGoals.intUtilizationTargetWeekly, 0) 
		   ,@intUtilizationAnnually					= ISNULL(CoworkerGoals.intUtilizationTargetAnnual, 0) 
		   ,@intUtilizationMonthly					= ISNULL(CoworkerGoals.intUtilizationTargetMonthly, 0) 
		   ,@dblActualUtilizationWeekly				= ISNULL(TimeEntryPeriodDetailInfo.[dblActualUtilizationWeekly], 0)  
		   ,@dblActualUtilizationAnnually			= ISNULL(TimeEntryPeriodDetailInfo.[dblActualUtilizationAnnually], 0) 
		   ,@dblActualUtilizationMonthly			= ISNULL(TimeEntryPeriodDetailInfo.[dblActualUtilizationMonthly], 0) 
		   ,@dblAnnualHurdle						= ISNULL(CoworkerGoals.[dblAnnualHurdle], 0) 
		   ,@dblAnnualBudget						= ISNULL(CoworkerGoals.[dblAnnualBudget], 0) 
		   ,@dblActualAnnualBudget					= ISNULL(TimeEntryPeriodDetailInfo.[dblActualAnnualBudget], 0) 
		   ,@dblActualWeeklyBudget					= ISNULL(TimeEntryPeriodDetailInfo.[dblActualWeeklyBudget], 0) 
		   ,@intRequiredHours						= ISNULL(TimeEntryPeriodDetailInfo.[intRequiredHours], 0) 
		   --,[intConcurrencyId]						= 1
		FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
				INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
		ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId
		OUTER APPLY(
		   SELECT  intUtilizationTargetAnnual
				  ,intUtilizationTargetMonthly
				  ,intUtilizationTargetWeekly
				  ,dblAnnualHurdle
				  ,dblAnnualBudget
				  ,dblBudget
		   FROM tblHDCoworkerGoal CoworkerGoal
				INNER JOIN tblHDCoworkerGoalDetail CoworkerGoalDetail
		   ON CoworkerGoal.intCoworkerGoalId = CoworkerGoalDetail.intCoworkerGoalId
		   WHERE CoworkerGoal.intEntityId = @EntityId AND
				 CoworkerGoal.strFiscalYear = TimeEntryPeriod.strFiscalYear AND
				 CoworkerGoalDetail.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
		 ) CoworkerGoals
		LEFT JOIN

		(
			SELECT   [intTimeEntryPeriodDetailId]		= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
					,[dblTotalHours]					= AgentInfoWeekly.[totalHours]
					,[totalBillableHours]				= AgentInfoWeekly.[totalBillableHours]
					,[totalNonBillableHours]			= AgentInfoWeekly.[totalNonBillableHours]
					,[vlHolidaySickHours]				= WeeklyVacationHolidaySick.dblRequest
					,[intRequiredHours]					= ISNULL(TimeEntryPeriodDetail.intRequiredHours, 0)
					,[dblActualUtilizationWeekly]		= CASE WHEN ISNULL(TotalWeeklyRequiredHours.totalHours, 0) - ISNULL(WeeklyVacationHolidaySick.dblRequest, 0) = 0
																	THEN 0
															   ELSE AgentInfoWeekly.[totalBillableHours] / ( ISNULL(TotalWeeklyRequiredHours.totalHours, 0) - ISNULL(WeeklyVacationHolidaySick.dblRequest, 0) ) * 100
														  END 
					,[dblActualUtilizationAnnually]		= CASE WHEN ISNULL(TotalAnnualRequiredHours.totalHours, 0) - ISNULL(AnnuallyVacationHolidaySick.dblRequest, 0) = 0
																	THEN 0
															   ELSE AgentInfoAnnually.[totalBillableHours] / ( ISNULL(TotalAnnualRequiredHours.totalHours, 0) - ISNULL(AnnuallyVacationHolidaySick.dblRequest, 0) ) * 100
														   END 
					,[dblActualUtilizationMonthly]		= CASE WHEN ISNULL(TotalMonthlyRequiredHours.totalHours, 0) - ISNULL(MonthlyVacationHolidaySick.dblRequest, 0) = 0
																	THEN 0
															   ELSE AgentInfoMonthly.[totalBillableHours] / ( ISNULL(TotalMonthlyRequiredHours.totalHours, 0) - ISNULL(MonthlyVacationHolidaySick.dblRequest, 0) ) * 100
														  END 
					,[dblActualAnnualBudget]			= AgentInfoAnnually.[totalBaseAmount]
					,[dblActualWeeklyBudget]			= AgentInfoWeekly.[totalBaseAmount]
			FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
				INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
			ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId
				OUTER APPLY(
					SELECT SUM(a.dblPRRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  tblPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId AND
						  a.dtmPRDate >= TimeEntryPeriodDetail.[dtmBillingPeriodStart] AND
						  a.dtmPRDate <= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		
				) WeeklyVacationHolidaySick
				OUTER APPLY(
					SELECT SUM(a.dblPRRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  tblPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId AND
						  DATEPART(YEAR, a.dtmPRDate) = TimeEntryPeriod.strFiscalYear
		
				) AnnuallyVacationHolidaySick
				OUTER APPLY(
					SELECT SUM(a.dblPRRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  tblPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId AND
						  DATEPART(YEAR, a.dtmPRDate) = TimeEntryPeriod.strFiscalYear AND
						  DATEPART(month, a.dtmPRDate) = DATEPART(month, TimeEntryPeriodDetail.dtmBillingPeriodStart)
				) MonthlyVacationHolidaySick
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM([totalHours])
						   ,[totalBillableHours]	= SUM([totalBillableHours])
						   ,[totalNonBillableHours]	= SUM([totalNonBillableHours])
						   ,[totalBaseAmount]		= SUM([totalBaseAmount])
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
									   ,[totalBaseAmount] = CASE WHEN ysnBillable = 1
																			THEN SUM(dblBaseAmount)
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
						   ,[totalBaseAmount]		= SUM([totalBaseAmount])
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
										,[totalBaseAmount]      = CASE WHEN ysnBillable = 1
																			THEN SUM(dblBaseAmount)
																		ELSE 0
																  END
								FROM vyuHDTicketHoursWorked
								WHERE DATEPART(YEAR, dtmDate) = TimeEntryPeriod.strFiscalYear AND
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
		WHERE TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId
		) TimeEntryPeriodDetailInfo
		ON TimeEntryPeriodDetailInfo.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
		WHERE TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId

	IF EXISTS (  SELECT TOP 1 ''
				 FROM tblHDAgentTimeEntryPeriodDetailSummary
				 WHERE [intEntityId] = @EntityId AND
					  [intTimeEntryPeriodDetailId] = @TimeEntryPeriodDetailId
			  )
	BEGIN 
			UPDATE tblHDAgentTimeEntryPeriodDetailSummary
			SET [dtmBillingPeriodStart]					= @dtmBillingPeriodStart					
		       ,[dtmBillingPeriodEnd]					= @dtmBillingPeriodEnd					
		       ,[dblTotalHours]							= @dblTotalHours							
		       ,[dblBillableHours]						= @dblBillableHours						
		       ,[dblNonBillableHours]					= @dblNonBudgetedHours					
		       ,[dblBudgetedHours]						= @dblBudgetedHours						
		       ,[dblVacationHolidaySick]				= @dblVacationHolidaySick					
		       ,[intUtilizationWeekly]					= @intUtilizationWeekly					
		       ,[intUtilizationAnnually]				= @intUtilizationAnnually					
		       ,[intUtilizationMonthly]					= @intUtilizationMonthly					
		       ,[dblActualUtilizationWeekly]			= @dblActualUtilizationWeekly				
		       ,[dblActualUtilizationAnnually]			= @dblActualUtilizationAnnually			
		       ,[dblActualUtilizationMonthly]			= @dblActualUtilizationMonthly			
		       ,[dblAnnualHurdle]						= @dblAnnualHurdle						
		       ,[dblAnnualBudget]						= @dblAnnualBudget						
		       ,[dblActualAnnualBudget]					= @dblActualAnnualBudget					
		       ,[dblActualWeeklyBudget]					= @dblActualWeeklyBudget					
		       ,[intRequiredHours]						= @intRequiredHours		
			WHERE [intEntityId] = @EntityId AND
				  [intTimeEntryPeriodDetailId] = @TimeEntryPeriodDetailId 

	END
	ELSE 
	BEGIN
	
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
				,[dblAnnualBudget]
				,[dblActualAnnualBudget]
				,[dblActualWeeklyBudget]
				,[intRequiredHours]						
				,[intConcurrencyId] 
		)

		SELECT  [intEntityId]							= @EntityId
		       ,[intTimeEntryPeriodDetailId]			= @TimeEntryPeriodDetailId				
		       ,[dtmBillingPeriodStart]					= @dtmBillingPeriodStart					
		       ,[dtmBillingPeriodEnd]					= @dtmBillingPeriodEnd					
		       ,[dblTotalHours]							= @dblTotalHours							
		       ,[dblBillableHours]						= @dblBillableHours						
		       ,[dblNonBillableHours]					= @dblNonBudgetedHours					
		       ,[dblBudgetedHours]						= @dblBudgetedHours						
		       ,[dblVacationHolidaySick]				= @dblVacationHolidaySick					
		       ,[intUtilizationWeekly]					= @intUtilizationWeekly					
		       ,[intUtilizationAnnually]				= @intUtilizationAnnually					
		       ,[intUtilizationMonthly]					= @intUtilizationMonthly					
		       ,[dblActualUtilizationWeekly]			= @dblActualUtilizationWeekly				
		       ,[dblActualUtilizationAnnually]			= @dblActualUtilizationAnnually			
		       ,[dblActualUtilizationMonthly]			= @dblActualUtilizationMonthly			
		       ,[dblAnnualHurdle]						= @dblAnnualHurdle						
		       ,[dblAnnualBudget]						= @dblAnnualBudget						
		       ,[dblActualAnnualBudget]					= @dblActualAnnualBudget					
		       ,[dblActualWeeklyBudget]					= @dblActualWeeklyBudget					
		       ,[intRequiredHours]						= @intRequiredHours						
		       ,[intConcurrencyId]						= 1

	END

	--DELETE FROM tblHDAgentTimeEntryPeriodDetailSummary
	--WHERE [intEntityId] = @EntityId AND
	--	  [intTimeEntryPeriodDetailId] = @TimeEntryPeriodDetailId

	--DECLARE @dblUtilizationWeekly INT = 0,
	--		@dblUtilizationAnnually INT = 0,
	--		@dblUtilizationMonthly INT = 0

	--SELECT TOP 1 @dblUtilizationWeekly	 = intUtilizationTargetWeekly
	--			,@dblUtilizationAnnually = intUtilizationTargetAnnual
	--			,@dblUtilizationMonthly  = intUtilizationTargetMonthly
	--FROM tblHDCoworkerGoal
	--WHERE intEntityId = @EntityId


	


END

GO