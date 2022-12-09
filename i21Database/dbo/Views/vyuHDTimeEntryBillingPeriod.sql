CREATE VIEW [dbo].[vyuHDTimeEntryBillingPeriod]
AS 
		SELECT [intTimeEntryPeriodDetailId]		= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
			  ,[strFiscalYear]					= TimeEntryPeriod.[strFiscalYear]
			  ,[strBillingPeriodName]			= TimeEntryPeriodDetail.[strBillingPeriodName]
			  ,[dtmBillingPeriodStart]			= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
			  ,[dtmBillingPeriodEnd]			= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
			  ,[intRequiredHours]				= TimeEntryPeriodDetail.[intRequiredHours]
			  ,[strBillingPeriodStatus]			= TimeEntryPeriodDetail.[strBillingPeriodStatus]
			  ,[intTimeEntryPeriodId]			= TimeEntryPeriodDetail.[intTimeEntryPeriodId]
			  ,[strPeriodDisplay]				= TimeEntryPeriod.[strFiscalYear] + ' - ' + TimeEntryPeriodDetail.[strBillingPeriodName] + ' ( ' + CONVERT(NVARCHAR(100),TimeEntryPeriodDetail.[dtmBillingPeriodStart],101) + ' - ' + CONVERT(NVARCHAR(100),TimeEntryPeriodDetail.[dtmBillingPeriodEnd],101)  + ' ) ' 
			  ,[intConcurrencyId]				= TimeEntryPeriodDetail.[intConcurrencyId]
		FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
			INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
		ON TimeEntryPeriod.intTimeEntryPeriodId = TimeEntryPeriodDetail.intTimeEntryPeriodId


GO