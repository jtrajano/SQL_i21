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
FROM tblHDTimeEntry TimeEntry
		LEFT JOIN tblEMEntity Entity
ON Entity.intEntityId = TimeEntry.intEntityId
	CROSS APPLY
	(
		SELECT TOP 1 intBillingIncrement
		FROM tblHDSetting WITH (NOLOCK)
	) Setting
	CROSS APPLY
	(
		SELECT TOP 1 strPeriodDisplay			= TimeEntryPeriod.[strFiscalYear] + ' - ' + TimeEntryPeriodDetail.[strBillingPeriodName] --+ ' (' + FORMAT(TimeEntryPeriodDetail.[dtmBillingPeriodStart], 'MM/dd/yy') + '-' + FORMAT(TimeEntryPeriodDetail.[dtmBillingPeriodEnd], 'MM/dd/yy') + ')'
					,[strBillingPeriodStatus] = TimeEntryPeriodDetail.strBillingPeriodStatus
		FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail 
			INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
		ON TimeEntryPeriodDetail.intTimeEntryPeriodId = TimeEntryPeriod.intTimeEntryPeriodId AND
		   TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = TimeEntry.[intTimeEntryPeriodDetailId]
	) TimeEntryPeriodDetail
	LEFT JOIN tblSMUserSecurity UserSecurity
ON UserSecurity.intEntityId = Entity.intEntityId
WHERE TimeEntry.[intTimeEntryPeriodDetailId] IS NOT NULL
GO