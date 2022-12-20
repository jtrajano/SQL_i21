CREATE VIEW [dbo].[vyuHDTimeEntryLegacyBillingPeriod]
AS 
	SELECT [intTimeEntryPeriodDetailId]		= TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
		  ,[strFiscalYear]					= TimeEntryPeriodDetail.[strFiscalYear]
		  ,[strBillingPeriodName]			= TimeEntryPeriodDetail.[strBillingPeriodName]
		  ,[dtmBillingPeriodStart]			= TimeEntryPeriodDetail.[dtmBillingPeriodStart]
		  ,[dtmBillingPeriodEnd]			= TimeEntryPeriodDetail.[dtmBillingPeriodEnd]
		  ,[intRequiredHours]				= TimeEntryPeriodDetail.[intRequiredHours]
		  ,[strPeriodDisplay]				= TimeEntryPeriodDetail.[strPeriodDisplay]
		  ,[intConcurrencyId]				= TimeEntryPeriodDetail.[intConcurrencyId]
	FROM vyuHDTimeEntryBillingPeriod TimeEntryPeriodDetail 

	UNION ALL

	SELECT [intTimeEntryPeriodDetailId]		= 0
		  ,[strFiscalYear]					= '2022'
		  ,[strBillingPeriodName]			= 'Legacy Week'
		  ,[dtmBillingPeriodStart]			= NULL
		  ,[dtmBillingPeriodEnd]			= NULL
		  ,[intRequiredHours]				= 0
		  ,[strPeriodDisplay]				= 'Legacy Week'
		  ,[intConcurrencyId]				= 1
GO