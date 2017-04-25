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
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Contract Without Shipping Instruction')
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
		'Contract Without Shipping Instruction'
		,'Contract Without Shipping Instruction'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,30
		,'day(s) before due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Contract Without Shipping Advice')
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
		'Contract Without Shipping Advice'
		,'Contract Without Shipping Advice'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,5
		,'day(s) after due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Contract Without Document')
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
		'Contract Without Document'
		,'Contract Without Document'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,7
		,'day(s) before due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Contract Without Weight Claim')
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
		'Contract Without Weight Claim'
		,'Contract Without Weight Claim'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,37
		,'day(s) after due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Weight Claims w/o Debit Note')
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
		'Weight Claims w/o Debit Note'
		,'Weight Claims w/o Debit Note'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,28
		,'day(s) after due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Contracts w/o 4C')
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
		'Contracts w/o 4C'
		,'Contracts w/o 4C'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,28
		,'day(s) after due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblCTEvent WHERE strEventName = 'Contracts w/o TC')
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
		'Contracts w/o TC'
		,'Contracts w/o TC'
		,NULL
		,'Reminder'
		,'Screen'
		,0
		,1
		,28
		,'day(s) after due date'
		,1
		,''
		,''
		,1)
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblCTEvent WHERE strEventName = 'Sample Notification to Supervisors')
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
		'Sample Notification to Supervisors'
		,'Sample Notification to Supervisors'
		,NULL
		,'Event'
		,'Both'
		,0
		,1
		,1
		,''
		,NULL
		,'Sample No: {SampleNumber}'
		,'Name: {PropertyName}
Value: {Value}
Result: {Result}'
		,1
		)
END
GO

GO
	INSERT	INTO tblCTEvent 
	(
		[strEventName],[strEventDescription],[intActionId],[strAlertType],[strNotificationType],[ysnSummarized],
		[ysnActive],[intDaysToRemind],[strReminderCondition],[intAlertFrequency],[strSubject],[strMessage],[intConcurrencyId]
	)
	SELECT	CASE	WHEN	strReminder =  'Unconfirmed'		THEN	'Unconfirmed contract'
					WHEN	strReminder =  'Empty'				THEN	'Contract without a sequence'
					WHEN	strReminder =  'Unsigned'			THEN	'Unsubmitted Contract Alert'
					WHEN	strReminder =  'Unsubmitted'		THEN	'Unsigned Contract Alert' 
					WHEN	strReminder =  'Mail Not Sent For'	THEN	'Approved Contract Mail Not Sent'
			END,
			CASE	WHEN	strReminder =  'Unconfirmed'		THEN	'Unconfirmed contract'
					WHEN	strReminder =  'Empty'				THEN	'Contract without a sequence'
					WHEN	strReminder =  'Unsigned'			THEN	'Unsubmitted Contract Alert'
					WHEN	strReminder =  'Unsubmitted'		THEN	'Unsigned Contract Alert' 
					WHEN	strReminder =  'Mail Not Sent For'	THEN	'Approved Contract Mail Not Sent'
			END,
			CASE	WHEN	strReminder =  'Unconfirmed'		THEN	1
					WHEN	strReminder =  'Empty'				THEN	2
					WHEN	strReminder =  'Unsigned'			THEN	NULL
					WHEN	strReminder =  'Unsubmitted'		THEN	NULL
					WHEN	strReminder =  'Mail Not Sent For'	THEN	NULL
			END,
			'Event','Screen',0,1,0,'',NULL,'','',1
	FROM	tblSMReminderList 
	WHERE	strNamespace LIKE '%ContractManagement.view.ContractAlerts%'
	AND		strReminder NOT IN 
			(	
				SELECT ISNULL(	CASE	WHEN	strEventName =  'Unconfirmed contract'				THEN	'Unconfirmed'
										WHEN	strEventName =  'Contract without a sequence'		THEN	'Empty'	
										WHEN	strEventName =	'Unsubmitted Contract Alert'		THEN	'Unsigned'
										WHEN	strEventName =  'Unsigned Contract Alert'			THEN	'Unsubmitted'
										WHEN	strEventName =  'Approved Contract Mail Not Sent'	THEN	'Mail Not Sent For'
								END,'') 
				FROM tblCTEvent
			)
GO