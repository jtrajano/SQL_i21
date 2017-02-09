-- Contains all event configuration scripts. Will run this only when customer needs it.

-- Quality Event Configuration Scripts
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblCTEvent WHERE strEventName = 'Unapproved Contract Samples')
BEGIN
	INSERT INTO tblCTEvent (
		[strEventName]
		,[strEventDescription]
		,[intActionId]
		,[strAlertType]
		,[strNotificationType]
		,[ysnSummarized]
		,[ysnActive]
		,[intDaysToRemind]
		,[strReminderCondition]
		,[intAlertFrequency]
		,[strSubject]
		,[strMessage]
		,[intConcurrencyId]
		)
	VALUES (
		'Unapproved Contract Samples'
		,'Unapproved Contract Samples'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,15
		,'day(s) before due date'
		,1
		,''
		,''
		,1
		)
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblCTEvent WHERE strEventName = 'Unapproved FOB Contract Samples')
BEGIN
	INSERT INTO tblCTEvent (
		[strEventName]
		,[strEventDescription]
		,[intActionId]
		,[strAlertType]
		,[strNotificationType]
		,[ysnSummarized]
		,[ysnActive]
		,[intDaysToRemind]
		,[strReminderCondition]
		,[intAlertFrequency]
		,[strSubject]
		,[strMessage]
		,[intConcurrencyId]
		)
	VALUES (
		'Unapproved FOB Contract Samples'
		,'Unapproved FOB Contract Samples'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,21
		,'day(s) before due date'
		,1
		,''
		,''
		,1
		)
END
GO
