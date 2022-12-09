CREATE VIEW [dbo].[vyuHDTimeEntry]
AS 

SELECT [intTimeEntryId]					= TimeEntry.[intTimeEntryId]
	  ,[intEntityId]					= TimeEntry.[intEntityId]
	  ,[dtmDateFrom]					= TimeEntry.[dtmDateFrom]
	  ,[dtmDateTo]						= TimeEntry.[dtmDateTo]
	  ,[strComment]						= TimeEntry.[strComment]
	  ,[dtmTimeEntryStartDate]			= ISNULL(TimeEntry.[dtmDateFrom], DATEADD(MONTH, -1, GETDATE()))
	  ,[dtmTimeEntryEndDate]			= ISNULL(TimeEntry.[dtmDateTo], GETDATE())
	  ,[strFullName]					= Entity.[strName]
	  ,[strJIRAUserName]				= UserSecurity.[strJIRAUserName]
	  ,[intConcurrencyId]				= TimeEntry.[intConcurrencyId]
	  ,[intBillingIncrement]			= ISNULL(Setting.[intBillingIncrement], 0)
	  ,[intTimeEntryPeriodDetailId]		= TimeEntry.[intTimeEntryPeriodDetailId] 
	  ,[strPeriodDisplay]				= TimeEntryPeriodDetail.[strPeriodDisplay]
	  ,[strBillingPeriodStatus]			= TimeEntryPeriodDetail.[strBillingPeriodStatus]
	  ,[ysnCanViewOtherCoworker]		= CONVERT(BIT, 0)	
	  ,[dtmBillingPeriodStart]			= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
	  ,[dtmBillingPeriodEnd]			= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
	  ,[dblTotalHours]					= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblTotalHours], 0)
	  ,[dblBillableHours]			    = ISNULL(AgentTimeEntryPeriodDetailSummary.[dblBillableHours], 0)
	  ,[dblNonBillableHours]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblNonBillableHours], 0)
	  ,[dblVacationHolidaySick]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblVacationHolidaySick], 0)
	  ,[intRequiredHours]				= ISNULL(AgentTimeEntryPeriodDetailSummary.[intRequiredHours], 0)
	  ,[dblActualUtilizationAnnually]	= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblActualUtilizationAnnually], 0)
	  ,[dblActualUtilizationWeekly]		= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblActualUtilizationWeekly], 0)
	  ,[dblActualUtilizationMonthly]	= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblActualUtilizationMonthly], 0)
	  ,[dblActualAnnualBudget]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblActualAnnualBudget], 0)
	  ,[dblActualWeeklyBudget]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblActualWeeklyBudget], 0)
	  ,[intUtilizationAnnually]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[intUtilizationAnnually], 0)
	  ,[intUtilizationWeekly]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[intUtilizationWeekly], 0)
	  ,[intUtilizationMonthly]			= ISNULL(AgentTimeEntryPeriodDetailSummary.[intUtilizationMonthly], 0)
	  ,[dblAnnualBudget]				= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblAnnualBudget], 0)
	  ,[dblWeeklyBudget]				= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblWeeklyBudget], 0)
	  ,[dblAnnualHurdle]				= ISNULL(AgentTimeEntryPeriodDetailSummary.[dblAnnualHurdle], 0)
	  ,[ysnVendor]						= CASE WHEN EntityType.strType IS NULL
										  			THEN CONVERT(BIT,0)
										  	   ELSE CONVERT(BIT,1)
										   END 
	  ,[ysnTimeEntryExempt]				= CASE WHEN EntityType.strType IS NOT NULL OR 
													CoworkerSuperVisor.intEntityId IS NOT NULL OR
													CoworkerGoalDetail.intEntityId IS NULL OR
													( CoworkerGoalDetail.intEntityId IS NOT NULL AND CoworkerGoalDetail.ysnActive = CONVERT(BIT,0) )
										  			THEN CONVERT(BIT,1)
										  	   ELSE CONVERT(BIT,0)
										   END 
	   ,[strSelectedDate]				= TimeEntry.[strSelectedDate]
	   ,[ysnFromApproval]				= CONVERT(BIT, 0)	
	   ,strFiscalYear					= TimeEntryPeriodDetail.[strFiscalYear]
FROM tblHDTimeEntry TimeEntry
		LEFT JOIN tblEMEntity Entity
ON Entity.intEntityId = TimeEntry.intEntityId
	OUTER APPLY
	(
		SELECT TOP 1 EntityType.strType
		FROM tblEMEntityType EntityType
		WHERE EntityType.intEntityId = TimeEntry.intEntityId AND
			  EntityType.strType = 'Vendor'
	) EntityType
	CROSS APPLY
	(
		SELECT TOP 1 intBillingIncrement
		FROM tblHDSetting WITH (NOLOCK)
	) Setting
	CROSS APPLY
	(
		SELECT TOP 1 strPeriodDisplay		    = TimeEntryPeriod.[strFiscalYear] + ' - ' + TimeEntryPeriodDetail.[strBillingPeriodName] --+ ' (' + FORMAT(TimeEntryPeriodDetail.[dtmBillingPeriodStart], 'MM/dd/yy') + '-' + FORMAT(TimeEntryPeriodDetail.[dtmBillingPeriodEnd], 'MM/dd/yy') + ')'
					,[strBillingPeriodStatus]   = TimeEntryPeriodDetail.strBillingPeriodStatus
					,dtmBillingPeriodStart      = TimeEntryPeriodDetail.dtmBillingPeriodStart
					,dtmBillingPeriodEnd		= TimeEntryPeriodDetail.dtmBillingPeriodEnd	
					,strFiscalYear				= TimeEntryPeriod.[strFiscalYear]
		FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
			INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
		ON TimeEntryPeriodDetail.intTimeEntryPeriodId = TimeEntryPeriod.intTimeEntryPeriodId AND
		   TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = TimeEntry.[intTimeEntryPeriodDetailId]
	) TimeEntryPeriodDetail
	OUTER APPLY
	(
		SELECT	 TOP 1 intEntityId	= CoworkerGoals.intEntityId
					  ,ysnActive	= CoworkerGoals.ysnActive 
		FROM tblHDCoworkerGoal CoworkerGoals
				INNER JOIN tblHDCoworkerGoalDetail CoworkerGoalDetail
		ON CoworkerGoals.intCoworkerGoalId = CoworkerGoalDetail.intCoworkerGoalId
		WHERE CoworkerGoals.intEntityId = TimeEntry.intEntityId AND
			  CoworkerGoalDetail.intTimeEntryPeriodDetailId = TimeEntry.[intTimeEntryPeriodDetailId] AND
			  CoworkerGoals.strFiscalYear = TimeEntryPeriodDetail.strFiscalYear
	) CoworkerGoalDetail
	OUTER APPLY(
		SELECT TOP 1 intEntityId
		FROM vyuHDExemptedAgent
		WHERE intEntityId = TimeEntry.intEntityId	
	) CoworkerSuperVisor
	LEFT JOIN tblSMUserSecurity UserSecurity
ON UserSecurity.intEntityId = Entity.intEntityId
	OUTER APPLY 
	(
		SELECT TOP 1  dblTotalHours
					 ,dblBillableHours
					 ,dblNonBillableHours
					 ,dblVacationHolidaySick
					 ,intRequiredHours
					 ,dblActualUtilizationAnnually
					 ,dblActualUtilizationWeekly
					 ,dblActualUtilizationMonthly
					 ,dblActualAnnualBudget
					 ,dblActualWeeklyBudget
					 ,intUtilizationAnnually
					 ,intUtilizationWeekly
					 ,intUtilizationMonthly
					 ,dblAnnualBudget
					 ,dblWeeklyBudget = dblBudgetedHours
					 ,dblAnnualHurdle
		FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
		WHERE AgentTimeEntryPeriodDetailSummary.intEntityId = TimeEntry.intEntityId AND
			  AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId = TimeEntry.intTimeEntryPeriodDetailId
	 
	) AgentTimeEntryPeriodDetailSummary
WHERE TimeEntry.[intTimeEntryPeriodDetailId] IS NOT NULL


GO