CREATE VIEW [dbo].[vyuHDGetAgentTimeEntryPeriodDetailInfo]
AS 
	SELECT [intId]							= CONVERT(int,ROW_NUMBER() OVER(ORDER BY AgentTimeEntryPeriodDetailSummary.[intTimeEntryPeriodDetailId])) 
		  ,[intTimeEntryPeriodDetailId]		= AgentTimeEntryPeriodDetailSummary.intTimeEntryPeriodDetailId
		  ,[intAgentEntityId]				= AgentTimeEntryPeriodDetailSummary.intEntityId
		  ,[dtmBillingPeriodStart]			= AgentTimeEntryPeriodDetailSummary.[dtmBillingPeriodStart]
		  ,[dtmBillingPeriodEnd]			= AgentTimeEntryPeriodDetailSummary.[dtmBillingPeriodEnd]
		  ,[dblTotalHours]					= AgentTimeEntryPeriodDetailSummary.dblTotalHours
		  ,[totalBillableHours]				= AgentTimeEntryPeriodDetailSummary.dblBillableHours
		  ,[totalNonBillableHours]			= AgentTimeEntryPeriodDetailSummary.dblNonBillableHours
		  ,[budgetedHours]					= AgentTimeEntryPeriodDetailSummary.dblBudgetedHours
		  ,[vlHolidaySickHours]				= AgentTimeEntryPeriodDetailSummary.dblVacationHolidaySick
		  ,[intRequiredHours]				= AgentTimeEntryPeriodDetailSummary.intRequiredHours
		  ,[intUtilizationWeekly]			= AgentTimeEntryPeriodDetailSummary.[intUtilizationWeekly]
		  ,[intUtilizationAnnually]		    = AgentTimeEntryPeriodDetailSummary.[intUtilizationAnnually]
		  ,[intUtilizationMonthly]		    = AgentTimeEntryPeriodDetailSummary.[intUtilizationMonthly]
		  ,[dblActualUtilizationWeekly]		= AgentTimeEntryPeriodDetailSummary.dblActualUtilizationWeekly
		  ,[dblActualUtilizationAnnually]	= AgentTimeEntryPeriodDetailSummary.[dblActualUtilizationAnnually]
		  ,[dblActualUtilizationMonthly]	= AgentTimeEntryPeriodDetailSummary.dblActualUtilizationMonthly
		  ,[dblAnnualHurdle]				= AgentTimeEntryPeriodDetailSummary.[dblAnnualHurdle]
		  ,[intConcurrencyId]				= AgentTimeEntryPeriodDetailSummary.[intConcurrencyId]
	FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntryPeriodDetailSummary
GO