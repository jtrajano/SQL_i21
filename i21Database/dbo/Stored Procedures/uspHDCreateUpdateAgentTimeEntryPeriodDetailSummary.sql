CREATE PROCEDURE [dbo].[uspHDCreateUpdateAgentTimeEntryPeriodDetailSummary]
(
	    @intEntityId INT
	   ,@intTimeEntryPeriodDetail int 
	   ,@intTimeEntryId INT 
	   ,@ysnNewCoworkerGoal BIT = 0
	   ,@ysnSyncAllColumn BIT = 1
)
AS
BEGIN

	--Developer Note: tblHDAgentTimeEntryPeriodDetailSummary is the summary table of the time entry. In this sp, we will sync the records of agent per period


	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS ON  

	DECLARE  @EntityId INT
			,@TimeEntryPeriodDetailId int 
			,@TimeEntryId INT 
			,@NewCoworkerGoal BIT
			,@SyncAllColumn BIT

	SET     @EntityId				 = @intEntityId
	SET		@TimeEntryPeriodDetailId = @intTimeEntryPeriodDetail 
	SET		@TimeEntryId			 = @intTimeEntryId 
	SET	    @NewCoworkerGoal		 = CONVERT(BIT, @ysnNewCoworkerGoal)
	SET		@SyncAllColumn			 = CONVERT(BIT, @ysnSyncAllColumn)

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
			,@dblNonBillableHours				NUMERIC(18,6)
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
			,@intTimeEntryPeriodId				INT
			,@strBillingPeriodName				NVARCHAR(100)
			,@strName							NVARCHAR(100) = ''

	SELECT TOP 1 @strName = strFullName
	FROM vyuHDAgentDetail
	WHERE intEntityId = @EntityId AND
		  ysnDisabled = CONVERT(BIT, 0)

	--if new records(created from duplicate,import or new coworker goal)
	IF @NewCoworkerGoal = CONVERT(BIT, 1)
	BEGIN
		
			SELECT TOP 1 @intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
						,@dtmBillingPeriodStart		 = TimeEntryPeriodDetail.dtmBillingPeriodStart
						,@dtmBillingPeriodEnd		 = TimeEntryPeriodDetail.dtmBillingPeriodEnd
						,@intUtilizationWeekly		 = CoworkerGoal.intUtilizationTargetWeekly
						,@intUtilizationMonthly		 = CoworkerGoal.intUtilizationTargetMonthly
						,@intUtilizationAnnually	 = CoworkerGoal.intUtilizationTargetAnnual
						,@dblAnnualHurdle			 = CoworkerGoal.dblAnnualHurdle
						,@dblAnnualBudget			 = CoworkerGoal.dblAnnualBudget
						,@intRequiredHours			 = TimeEntryPeriodDetail.intRequiredHours
						,@intTimeEntryPeriodId		 = TimeEntryPeriodDetail.intTimeEntryPeriodId
						,@strBillingPeriodName		 = TimeEntryPeriodDetail.strBillingPeriodName
						,@dblBudgetedHours			 = CoworkerGoalDetail.dblBudget
			FROM tblHDCoworkerGoal CoworkerGoal 
				INNER JOIN tblHDCoworkerGoalDetail CoworkerGoalDetail
			ON CoworkerGoal.intCoworkerGoalId = CoworkerGoalDetail.intCoworkerGoalId
				INNER JOIN tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
			ON TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = CoworkerGoalDetail.intTimeEntryPeriodDetailId
			WHERE CoworkerGoal.intEntityId = @intEntityId AND
				  TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId

			SET @dblTotalHours					= 0
		    SET @dblBillableHours				= 0
			SET @dblNonBillableHours			= 0
			SET @dblVacationHolidaySick			= 0    
			SET @dblActualUtilizationWeekly		= 0
			SET @dblActualUtilizationAnnually	= 0
			SET @dblActualUtilizationMonthly	= 0				
			SET @dblActualAnnualBudget			= 0
			SET @dblActualWeeklyBudget			= 0			
			
	END
	
	IF @SyncAllColumn = CONVERT(BIT, 1)		 
	BEGIN							 

			SELECT  --[intEntityId]							= @EntityId
		    @intTimeEntryPeriodDetailId				= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
		   ,@dtmBillingPeriodStart					= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
		   ,@dtmBillingPeriodEnd					= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		   ,@dblTotalHours							= ISNULL(TimeEntryPeriodDetailInfo.[dblTotalHours], 0) 
		   ,@dblBillableHours						= ISNULL(TimeEntryPeriodDetailInfo.[totalBillableHours], 0)  
		   ,@dblNonBillableHours					= ISNULL(TimeEntryPeriodDetailInfo.[totalNonBillableHours], 0)  
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
		   ,@intTimeEntryPeriodId					= ISNULL(TimeEntryPeriod.intTimeEntryPeriodId, 0) 
		   ,@strBillingPeriodName					= TimeEntryPeriodDetailInfo.[strBillingPeriodName]
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
					,[vlHolidaySickHours]				= ISNULL(WeeklyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoWeekly.totalHolidayHours, 0)
					,[intRequiredHours]					= ISNULL(TimeEntryPeriodDetail.intRequiredHours, 0)
					,[dblActualUtilizationWeekly]		= CASE WHEN ( ISNULL(TotalWeeklyRequiredHours.totalHours, 0) - ( ISNULL(WeeklyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoWeekly.totalHolidayHours, 0) ) ) = 0
																	THEN 0
															   ELSE AgentInfoWeekly.[totalBillableHours] / ( ISNULL(TotalWeeklyRequiredHours.totalHours, 0) - ( ISNULL(WeeklyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoWeekly.totalHolidayHours, 0) ) ) * 100
														  END 
					,[dblActualUtilizationAnnually]		= CASE WHEN ( ISNULL(TotalAnnualRequiredHours.totalHours, 0) - ( ISNULL(AnnuallyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoAnnually.totalHolidayHours, 0) ) ) = 0
																	THEN 0
															   ELSE AgentInfoAnnually.[totalBillableHours] / ( ISNULL(TotalAnnualRequiredHours.totalHours, 0) - ( ISNULL(AnnuallyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoAnnually.totalHolidayHours, 0) ) ) * 100
														   END 
					,[dblActualUtilizationMonthly]		= CASE WHEN ( ISNULL(TotalMonthlyRequiredHours.totalHours, 0) - ( ISNULL(MonthlyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoMonthly.totalHolidayHours, 0) ) ) = 0
																	THEN 0
															   ELSE AgentInfoMonthly.[totalBillableHours] / ( ISNULL(TotalMonthlyRequiredHours.totalHours, 0) - ( ISNULL(MonthlyVacationHolidaySick.dblRequest, 0) + ISNULL(AgentInfoMonthly.totalHolidayHours, 0) ) ) * 100
														  END 
					,[dblActualAnnualBudget]			= AgentInfoAnnually.[totalBaseAmount]
					,[dblActualWeeklyBudget]			= AgentInfoWeekly.[totalBaseAmount]
					,[strBillingPeriodName]				= LTRIM(RTRIM(REPLACE(SUBSTRING(LTRIM(RTRIM(TimeEntryPeriodDetail.strBillingPeriodName)),1,CHARINDEX(' ',LTRIM(RTRIM(TimeEntryPeriodDetail.strBillingPeriodName)),1)),',', ''))) + ' ' + FORMAT(TimeEntryPeriodDetail.intBillingPeriod, '00')
			FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
				INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
			ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId
				OUTER APPLY(
					SELECT SUM(a.dblPRRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  vyuPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					--INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId AND
						  a.dtmPRDate >= TimeEntryPeriodDetail.[dtmBillingPeriodStart] AND
						  a.dtmPRDate <= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		
				) WeeklyVacationHolidaySick
				OUTER APPLY(
					SELECT SUM(a.dblPRRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  vyuPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					--INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId AND
						  DATEPART(YEAR, a.dtmPRDate) = TimeEntryPeriod.strFiscalYear
		
				) AnnuallyVacationHolidaySick
				OUTER APPLY(
					SELECT SUM(a.dblPRRequest)  dblRequest FROM tblHDTimeOffRequest a
					INNER JOIN  vyuPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
					--INNER JOIN  tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
					INNER JOIN  tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
					WHERE d.intEntityId = @EntityId AND
						  DATEPART(YEAR, a.dtmPRDate) = TimeEntryPeriod.strFiscalYear AND
						  DATEPART(month, a.dtmPRDate) = DATEPART(month, TimeEntryPeriodDetail.dtmBillingPeriodStart)
				) MonthlyVacationHolidaySick
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(ISNULL([totalHours],0))
						   ,[totalBillableHours]	= SUM(ISNULL([totalBillableHours],0))
						   ,[totalNonBillableHours]	= SUM(ISNULL([totalNonBillableHours],0))
						   ,[totalBaseAmount]		= SUM(ISNULL([totalBaseAmount],0))
						   ,[totalHolidayHours]		= SUM(ISNULL([totalHolidayHours],0))
					FROM (		
								SELECT  [totalHours]			= SUM(ISNULL(TicketHoursWorked.dblHours,0))
									   ,[totalBillableHours]	= CASE WHEN TicketHoursWorked.ysnBillable = 1 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
									   ,[totalNonBillableHours]	= CASE WHEN TicketHoursWorked.ysnBillable = 0 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
									   ,[totalHolidayHours] = CASE WHEN LOWER(Item.strItemNo) = 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
									   ,[totalBaseAmount] = CASE WHEN TicketHoursWorked.ysnBillable = 1 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblBaseAmount,0))
																		ELSE 0
																  END
								FROM vyuHDTicketHoursWorked TicketHoursWorked
									LEFT JOIN tblICItem Item ON Item.intItemId = TicketHoursWorked.intItemId
								WHERE TicketHoursWorked.[dtmDate] >= TimeEntryPeriodDetail.[dtmBillingPeriodStart] AND
									  TicketHoursWorked.[dtmDate] <= TimeEntryPeriodDetail.[dtmBillingPeriodEnd] AND
									  intAgentEntityId = @EntityId
								GROUP BY  TicketHoursWorked.[ysnBillable]
										 ,Item.strItemNo
					) TotalHours
				) AgentInfoWeekly
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(ISNULL([totalHours],0))
						   ,[totalBillableHours]	= SUM(ISNULL([totalBillableHours],0))
						   ,[totalNonBillableHours]	= SUM(ISNULL([totalNonBillableHours],0))
						   ,[totalBaseAmount]		= SUM(ISNULL([totalBaseAmount],0))
						   ,[totalHolidayHours]		= SUM(ISNULL([totalHolidayHours],0))
					FROM (		
								SELECT  [totalHours]			= SUM(ISNULL(TicketHoursWorked.dblHours,0))
									   ,[totalBillableHours]	= CASE WHEN TicketHoursWorked.ysnBillable = 1 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
									   ,[totalNonBillableHours]	= CASE WHEN TicketHoursWorked.ysnBillable = 0 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END	

										,[totalHolidayHours] = CASE WHEN LOWER(Item.strItemNo) = 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
										,[totalBaseAmount]      = CASE WHEN TicketHoursWorked.ysnBillable = 1 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblBaseAmount,0))
																		ELSE 0
																  END
								FROM vyuHDTicketHoursWorked TicketHoursWorked
									LEFT JOIN tblICItem Item ON Item.intItemId = TicketHoursWorked.intItemId
								WHERE DATEPART(YEAR, dtmDate) = TimeEntryPeriod.strFiscalYear AND
										  intAgentEntityId = @EntityId
								GROUP BY TicketHoursWorked.[ysnBillable]
										,Item.strItemNo
					) TotalHours
				) AgentInfoAnnually
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(ISNULL([totalHours],0))
						   ,[totalBillableHours]	= SUM(ISNULL([totalBillableHours],0))
						   ,[totalNonBillableHours]	= SUM(ISNULL([totalNonBillableHours],0))
						   ,[totalHolidayHours]		= SUM(ISNULL([totalHolidayHours],0))
					FROM (		
								SELECT  [totalHours]			= SUM(TicketHoursWorked.dblHours)
									   ,[totalBillableHours]	= CASE WHEN TicketHoursWorked.ysnBillable = 1 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
									   ,[totalNonBillableHours]	= CASE WHEN TicketHoursWorked.ysnBillable = 0 AND LOWER(Item.strItemNo) <> 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
									   ,[totalHolidayHours] = CASE WHEN LOWER(Item.strItemNo) = 'holiday'
																			THEN SUM(ISNULL(TicketHoursWorked.dblHours,0))
																		ELSE 0
																  END
								FROM vyuHDTicketHoursWorked TicketHoursWorked
									LEFT JOIN tblICItem Item ON Item.intItemId = TicketHoursWorked.intItemId 
								WHERE DATEPART(YEAR, dtmDate) = TimeEntryPeriod.strFiscalYear AND
									  DATEPART(month, dtmDate) = DATEPART(month, TimeEntryPeriodDetail.dtmBillingPeriodStart) AND
									  intAgentEntityId = @EntityId
								GROUP BY TicketHoursWorked.[ysnBillable]
										,Item.strItemNo
					) TotalHours
				) AgentInfoMonthly
				CROSS APPLY
				(
					SELECT  intTimeEntryPeriodDetailId
						   ,[totalHours]			= SUM(ISNULL(intRequiredHours,0))							
					FROM tblHDTimeEntryPeriodDetail a
					WHERE a.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId 
					GROUP BY intTimeEntryPeriodDetailId
				) TotalWeeklyRequiredHours
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(ISNULL(intRequiredHours,0))							
					FROM tblHDTimeEntryPeriodDetail a
							INNER JOIN tblHDTimeEntryPeriod b
					ON a.intTimeEntryPeriodId = b.intTimeEntryPeriodId
					WHERE b.strFiscalYear = TimeEntryPeriod.strFiscalYear
				) TotalAnnualRequiredHours
				CROSS APPLY
				(
					SELECT  [totalHours]			= SUM(ISNULL(intRequiredHours, 0))							
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
	
	END

	IF EXISTS (  SELECT TOP 1 ''
				 FROM tblHDAgentTimeEntryPeriodDetailSummary
				 WHERE [intEntityId] = @EntityId AND
					  [intTimeEntryPeriodDetailId] = @TimeEntryPeriodDetailId
			  )
		BEGIN 

			IF @SyncAllColumn = CONVERT(BIT, 1)
			BEGIN

				UPDATE tblHDAgentTimeEntryPeriodDetailSummary
						SET [dtmBillingPeriodStart]					= @dtmBillingPeriodStart					
						   ,[dtmBillingPeriodEnd]					= @dtmBillingPeriodEnd					
						   ,[dblTotalHours]							= @dblTotalHours							
						   ,[dblBillableHours]						= @dblBillableHours						
						   ,[dblNonBillableHours]					= @dblNonBillableHours					
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
						   ,[intTimeEntryPeriodId]					= @intTimeEntryPeriodId
						   ,[strBillingPeriodName]					= @strBillingPeriodName
						   ,[strName]								= @strName
						   ,[dblWeeklyBudget]						= @dblBudgetedHours
						WHERE [intEntityId] = @EntityId AND
							  [intTimeEntryPeriodDetailId] = @TimeEntryPeriodDetailId 

			END
			ELSE
			BEGIN --This will only update the weekly budget, annual budget, annual hurdle and utilization target
				UPDATE tblHDAgentTimeEntryPeriodDetailSummaryToUpdate
				SET  dblWeeklyBudget = CoworkerGoalDetail.dblBudget  
					,intUtilizationAnnually = CoworkerGoal.intUtilizationTargetAnnual
					,intUtilizationMonthly  = CoworkerGoal.intUtilizationTargetMonthly
					,intUtilizationWeekly   = CoworkerGoal.intUtilizationTargetWeekly 
					,dblAnnualHurdle		= CoworkerGoal.dblAnnualHurdle 
					,dblAnnualBudget		= CoworkerGoal.dblAnnualBudget 
				FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
						INNER JOIN tblHDAgentTimeEntryPeriodDetailSummary tblHDAgentTimeEntryPeriodDetailSummaryToUpdate
				ON tblHDAgentTimeEntryPeriodDetailSummaryToUpdate.intAgentTimeEntryPeriodDetailSummaryId = AgentTimeEntryPeriodDetailSummary.intAgentTimeEntryPeriodDetailSummaryId
						INNER JOIN tblHDCoworkerGoalDetail CoworkerGoalDetail
				ON CoworkerGoalDetail.intTimeEntryPeriodDetailId =  AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId	
						INNER JOIN tblHDCoworkerGoal CoworkerGoal
				ON CoworkerGoal.intCoworkerGoalId = CoworkerGoalDetail.intCoworkerGoalId AND
				   CoworkerGoal.intEntityId = AgentTimeEntryPeriodDetailSummary.intEntityId
				WHERE AgentTimeEntryPeriodDetailSummary.intEntityId = @EntityId AND
					  CoworkerGoalDetail.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId
			END
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
					,[intTimeEntryPeriodId]
					,[strBillingPeriodName]
					,[strName]
					,[dblWeeklyBudget]	

			)

			SELECT  [intEntityId]							= @EntityId
				   ,[intTimeEntryPeriodDetailId]			= @TimeEntryPeriodDetailId				
				   ,[dtmBillingPeriodStart]					= @dtmBillingPeriodStart					
				   ,[dtmBillingPeriodEnd]					= @dtmBillingPeriodEnd					
				   ,[dblTotalHours]							= @dblTotalHours							
				   ,[dblBillableHours]						= @dblBillableHours						
				   ,[dblNonBillableHours]					= @dblNonBillableHours				
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
				   ,[intTimeEntryPeriodId]					= @intTimeEntryPeriodId
				   ,[strBillingPeriodName]					= @strBillingPeriodName
				   ,[strName]								= @strName
				   ,[dblWeeklyBudget]						= @dblBudgetedHours

	END

	--This will update the intAgentTimeEntryPeriodDetailSummaryId of detail tables tblHDTicketHoursWorked and tblHDTimeOffRequest 
	--That fk will be use in power bi report to connect it to summary table which is tblHDAgentTimeEntryPeriodDetailSummary
	EXEC [dbo].[uspHDSyncAgentTimeEntrySummaryDetail] @intEntityId, @TimeEntryPeriodDetailId
END

GO