CREATE VIEW [dbo].[vyuHDTimeEntryBillingPeriod]
AS 
	SELECT [intTimeEntryPeriodDetailId]		= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
		  ,[strFiscalYear]					= TimeEntryPeriod.[strFiscalYear]
		  ,[strBillingPeriodName]			= TimeEntryPeriodDetail.[strBillingPeriodName]
		  ,[dtmBillingPeriodStart]			= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
		  ,[dtmBillingPeriodEnd]			= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		  ,[intRequiredHours]				= TimeEntryPeriodDetail.[intRequiredHours]
		  ,[strPeriodDisplay]				= TimeEntryPeriod.[strFiscalYear] + ' - ' + TimeEntryPeriodDetail.[strBillingPeriodName]
		  ,[intConcurrencyId]				= TimeEntryPeriodDetail.[intConcurrencyId]
	FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
		INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
	ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId	


GO