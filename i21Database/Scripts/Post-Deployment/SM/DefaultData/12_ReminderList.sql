GO

	IF EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'General Journal Recurring')
	BEGIN
		UPDATE [tblSMReminderList] SET [strType] = 'General Journal' WHERE [strReminder] = N'Process' AND [strType] = N'General Journal Recurring'
	END

	IF EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Transaction')
	BEGIN
		UPDATE [tblSMReminderList] SET [strReminder] = 'Unapproved' WHERE [strReminder] = N'Approve' AND [strType] = N'Transaction'
	END

GO

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Invoice')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Invoice',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Invoice'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Invoice'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        1

		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Invoice' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'General Journal')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'General Journal',
				   [strMessage]			=        N'{0} Recurring Journal {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''General Journal'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''General Journal'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        2

		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} Recurring Journal {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'General Journal' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Voucher')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Voucher',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Voucher'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Voucher'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        3
		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Voucher' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Purchase Order')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Purchase Order',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Purchase Order'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Purchase Order'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        4
		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Purchase Order' 
		END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bill Template')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Bill Template',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bill Template'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bill Template'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        5
		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bill Template' 
		END

	IF EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Voucher')
		BEGIN
			DELETE FROM [tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Voucher'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Update' AND [strType] = N'Invoice')
	BEGIN
		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Update',
				[strType]        	=        N'Invoice',
				[strMessage]		=        N'{0} Customer''s Budget need to update for final budget.',
				[strQuery]  		=        N'SELECT intEntityCustomerId, DATEADD(MONTH, 1, MAX(dtmBudgetDate)) AS dtmBudgetEndDate FROM tblARCustomerBudget GROUP BY intEntityCustomerId HAVING GETDATE() > DATEADD(MONTH, 1, MAX(dtmBudgetDate))',
				[strNamespace]      =        N'AccountsReceivable.view.Invoice', 
				[intSort]           =        7
	END	

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Post' AND [strType] = N'General Journal')
	BEGIN
		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Post',
				[strType]        	=        N'General Journal',
				[strMessage]		=        N'{0} {1} {2} left unposted.',
				[strQuery]  		=        N'Select intJournalId FROM vyuGLPostRemind WHERE intEntityId = {0}',
				[strNamespace]      =        N'i21.view.BatchPosting?module=General Ledger',--N'GeneralLedger.view.GeneralJournal?unposted=1',
				[intSort]           =        8
	END	
	ELSE
	BEGIN
		UPDATE [tblSMReminderList] SET [strNamespace] = 'i21.view.BatchPosting?module=General Ledger' 
		WHERE [strReminder] = N'Post' AND [strType] = N'General Journal'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 9)
	BEGIN
		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Overdue',
				[strType]        	=        N'Scale Ticket',
				[strMessage]		=        N'{0} Overdue Ticket(s).',
				[strQuery]  		=        N'SELECT intTicketUncompletedDaysAlert,ysnHasGeneratedTicketNumber,strTicketStatus from tblSCUncompletedTicketAlert SCAlert
												LEFT JOIN tblSCTicket SCTicket ON SCAlert.intCompanyLocationId = SCTicket.intProcessingLocationId
												WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
												AND ysnHasGeneratedTicketNumber = 1
												AND strTicketStatus = ''O''
												AND SCAlert.intEntityId = {0}',
				[strNamespace]      =        N'Grain.view.ScaleStationSelection?showSearch=true&searchCommand=reminderSearchConfig',
				[intSort]           =        9
	END
	ELSE
		UPDATE [tblSMReminderList] SET [strNamespace] = N'Grain.view.ScaleStationSelection?showSearch=true&searchCommand=reminderSearchConfig'
		,[strQuery] = N'SELECT intTicketUncompletedDaysAlert,ysnHasGeneratedTicketNumber,strTicketStatus from tblSCUncompletedTicketAlert SCAlert
		LEFT JOIN tblSCTicket SCTicket ON SCAlert.intCompanyLocationId = SCTicket.intProcessingLocationId
		WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
		AND ysnHasGeneratedTicketNumber = 1
		AND (strTicketStatus = ''O'' OR strTicketStatus = ''A'')
		AND SCAlert.intEntityId = {0}'  
		WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 9
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 10)
	BEGIN
		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Overdue',
				[strType]        	=        N'Scale Ticket',
				[strMessage]		=        N'{0} Overdue Ticket(s).',
				[strQuery]  		=        N'SELECT intTicketUncompletedDaysAlert,ysnHasGeneratedTicketNumber,strTicketStatus,intProcessingLocationId,SCAlert.intEntityId from tblSCUncompletedTicketAlert SCAlert,tblSCTicket SCTicket
												WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
												AND ysnHasGeneratedTicketNumber = 1
												AND (strTicketStatus = ''O'' OR strTicketStatus = ''A'')
												AND ISNULL(intCompanyLocationId,0) = 0
												AND SCAlert.intEntityId = {0}',
				[strNamespace]      =        N'Grain.view.ScaleStationSelection?showSearch=true&searchCommand=reminderSearchConfig',
				[intSort]           =        10
	END
	ELSE
		UPDATE [tblSMReminderList] SET [strQuery] = N'SELECT intTicketUncompletedDaysAlert,ysnHasGeneratedTicketNumber,strTicketStatus,intProcessingLocationId,SCAlert.intEntityId from tblSCUncompletedTicketAlert SCAlert,tblSCTicket SCTicket
		WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
		AND ysnHasGeneratedTicketNumber = 1
		AND (strTicketStatus = ''O'' OR strTicketStatus = ''A'')
		AND ISNULL(intCompanyLocationId,0) = 0
		AND SCAlert.intEntityId = {0}' 
		, [strNamespace] = N'Grain.view.ScaleStationSelection?showSearch=true&searchCommand=reminderSearchConfig'
		WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 10


	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unapproved' AND [strType] = N'Transaction')
	BEGIN
		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT	[strReminder]		=        N'Unapproved',
				[strType]			=        N'Transaction',
				[strMessage]		=        N'{0} {1} {2} unapproved.',
				[strQuery]			=        N'SELECT intTransactionId               
												FROM tblSMApproval A              
												left outer join tblSMApproverConfigurationForApprovalGroup B on A.intApprovalId = B.intApprovalId
												WHERE  A.ysnCurrent = 1 AND                
												A.strStatus = ''Waiting for Approval'' and 
												(A.intApproverId = {0} OR B.intApproverId = {0})',
				[strNamespace]		=        N'i21.view.Approval?activeTab=Pending',
				[intSort]			=        11
	END
	ELSE
	BEGIN
		UPDATE [tblSMReminderList]
		SET	[strQuery] =        N'SELECT intTransactionId               
								FROM tblSMApproval A              
								left outer join tblSMApproverConfigurationForApprovalGroup B on A.intApprovalId = B.intApprovalId
								WHERE  A.ysnCurrent = 1 AND                
								A.strStatus = ''Waiting for Approval'' and 
								(A.intApproverId = {0} OR B.intApproverId = {0})'
		WHERE [strReminder] = N'Unapproved' AND [strType] = N'Transaction'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Approved' AND [strType] = N'Transaction')
	BEGIN
		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
		SELECT [strReminder]        =        N'Approved',
				[strType]           =        N'Transaction',
				[strMessage]        =        N'{0} Transaction(s) {2} approved.',
				[strQuery]          =        N'select intApprovalId from tblSMApprovalHistory
												where intEntityId = {0} and ysnApproved = 1 and ysnRead = 0',
				[strNamespace]      =        N'i21.view.Approval?activeTab=Approved',
				[intSort]           =        12

	END
	ELSE
	BEGIN
		UPDATE [tblSMReminderList]
		SET	[strQuery] =       N'select intApprovalId from tblSMApprovalHistory
								where intEntityId = {0} and ysnApproved = 1 and ysnRead = 0'
		WHERE [strReminder] = N'Approved' AND [strType] = N'Transaction'
	END

    IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Closed' AND [strType] = N'Transaction')
    BEGIN
        INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Closed',
                [strType]           =        N'Transaction',
                [strMessage]        =        N'{0} Transaction(s) {2} closed.',
                [strQuery]          =        N'select intApprovalId from tblSMApprovalHistory
												where intEntityId = {0} and ysnClosed = 1 and ysnRead = 0
												and intEntityId not in (
													select intEntityContactId from  tblEMEntityToContact where ysnPortalAccess = 1
												)',
                [strNamespace]      =        N'i21.view.Approval?activeTab=Closed',
                [intSort]           =        13
    END
	ELSE
	BEGIN
		UPDATE [tblSMReminderList]
		SET	[strQuery]				=        N'select intApprovalId from tblSMApprovalHistory
												where intEntityId = {0} and ysnClosed = 1 and ysnRead = 0
												and intEntityId not in (
													select intEntityContactId from  tblEMEntityToContact where ysnPortalAccess = 1
												)'
		WHERE [strReminder] = N'Closed' AND [strType] = N'Transaction'
	END    
  
    IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unsubmitted' AND [strType] = N'Transaction')
    BEGIN
        INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Unsubmitted',
                [strType]           =        N'Transaction',
                [strMessage]        =        N'{0} Transaction(s) {2} unsubmitted.',
                [strQuery]          =        N'    SELECT 
                                                    intTransactionId 
                                                FROM tblSMApproval 
                                                WHERE    ysnCurrent = 1 AND 
                                                        strStatus IN (''Waiting for Submit'') AND 
                                                        intSubmittedById= {0}',
                [strNamespace]      =        N'i21.view.Approval?activeTab=Unsubmitted',
                [intSort]           =        14
    END 
	ELSE
	BEGIN
		UPDATE tblSMReminderList SET strNamespace = N'i21.view.Approval?activeTab=Unsubmitted'
		WHERE [strReminder] = N'Unsubmitted' AND [strType] = N'Transaction'
	END  
  
    IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Rejected' AND [strType] = N'Transaction')
    BEGIN
        INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Rejected',
                [strType]           =        N'Transaction',
                [strMessage]        =        N'{0} Transaction(s) {2} rejected.',
                [strQuery]          =        N'select intEntityId from tblSMApprovalHistory              
												where intEntityId = {0} and ysnRejected = 1 and ysnRead = 0              
												and intEntityId not in (               select intEntityContactId from tblEMEntityToContact where ysnPortalAccess = 1              )',
                [strNamespace]      =        N'i21.view.Approval?activeTab=Rejected',
                [intSort]           =        15
    END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strQuery]			=		N'select intEntityId from tblSMApprovalHistory              
												where intEntityId = {0} and ysnRejected = 1 and ysnRead = 0              
												and intEntityId not in (               select intEntityContactId from tblEMEntityToContact where ysnPortalAccess = 1              )'
			WHERE [strReminder] = N'Rejected' AND [strType] = N'Transaction' 
		END


	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Activity' AND [strType] = N'Reminder')
    BEGIN
        INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Activity',
                [strType]           =        N'Reminder',
                [strMessage]        =        N'{0} Activity Reminders.',
                [strQuery]          =        N'SELECT	A.intActivityId, 
														B.intEntityId,
														strSubject, 
														strType,
														dtmStartDate
												FROM tblSMActivity A LEFT OUTER JOIN tblSMActivityAttendee B
													ON A.intActivityId = B.intActivityId AND B.intEntityId = {0}
												WHERE ysnRemind = 1 AND 
													(intCreatedBy = {0} OR intAssignedTo = {0}) AND 
													(ysnDismiss = 0 OR ysnDismiss IS NULL) AND
													strStatus != ''Closed'' AND strStatus != ''Complete'' AND
														CASE WHEN strReminder = ''0 minutes'' THEN dtmStartDate
															 WHEN strReminder = ''5 minutes'' THEN DATEADD(MINUTE, -5, dtmStartDate)
															 WHEN strReminder = ''10 minutes'' THEN DATEADD(MINUTE, -10, dtmStartDate)
															 WHEN strReminder = ''15 minutes'' THEN DATEADD(MINUTE, -15, dtmStartDate)
															 WHEN strReminder = ''30 minutes'' THEN DATEADD(MINUTE, -30, dtmStartDate)
															 WHEN strReminder = ''1 hour'' THEN DATEADD(HOUR, -1, dtmStartDate)
															 WHEN strReminder = ''2 hours'' THEN DATEADD(HOUR, -2, dtmStartDate)
															 WHEN strReminder = ''3 hours'' THEN DATEADD(HOUR, -3, dtmStartDate)
															 WHEN strReminder = ''4 hours'' THEN DATEADD(HOUR, -4, dtmStartDate)
															 WHEN strReminder = ''5 hours'' THEN DATEADD(HOUR, -5, dtmStartDate)
															 WHEN strReminder = ''6 hours'' THEN DATEADD(HOUR, -6, dtmStartDate)
															 WHEN strReminder = ''7 hours'' THEN DATEADD(HOUR, -7, dtmStartDate)
															 WHEN strReminder = ''8 hours'' THEN DATEADD(HOUR, -8, dtmStartDate)
															 WHEN strReminder = ''9 hours'' THEN DATEADD(HOUR, -9, dtmStartDate)
															 WHEN strReminder = ''10 hours'' THEN DATEADD(HOUR, -10, dtmStartDate)
															 WHEN strReminder = ''11 hours'' THEN DATEADD(HOUR, -11, dtmStartDate)
															 WHEN strReminder = ''12 hours'' THEN DATEADD(HOUR, -12, dtmStartDate)
															 WHEN strReminder = ''18 hours'' THEN DATEADD(HOUR, -18, dtmStartDate)
															 WHEN strReminder = ''1 day'' THEN DATEADD(DAY, -1, dtmStartDate)
															 WHEN strReminder = ''2 days'' THEN DATEADD(DAY, -2, dtmStartDate)
															 WHEN strReminder = ''3 days'' THEN DATEADD(DAY, -3, dtmStartDate)
															 WHEN strReminder = ''4 days'' THEN DATEADD(DAY, -4, dtmStartDate)
															 WHEN strReminder = ''1 week'' THEN DATEADD(WEEK, -1, dtmStartDate)
															 WHEN strReminder = ''2 weeks'' THEN DATEADD(WEEK, -2, dtmStartDate)
														END <= GETUTCDATE()',
                [strNamespace]      =        N'GlobalComponentEngine.view.ActivityReminder',
                [intSort]           =        1
    END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strQuery] = N'SELECT	A.intActivityId, 
														B.intEntityId,
														strSubject, 
														strType,
														dtmStartDate
												FROM tblSMActivity A LEFT OUTER JOIN tblSMActivityAttendee B
													ON A.intActivityId = B.intActivityId AND B.intEntityId = {0}
												WHERE ysnRemind = 1 AND 
													(intCreatedBy = {0} OR intAssignedTo = {0}) AND 
													(ysnDismiss = 0 OR ysnDismiss IS NULL) AND
													strStatus != ''Closed'' AND strStatus != ''Complete'' AND
														CASE WHEN strReminder = ''0 minutes'' THEN dtmStartDate
															 WHEN strReminder = ''5 minutes'' THEN DATEADD(MINUTE, -5, dtmStartDate)
															 WHEN strReminder = ''10 minutes'' THEN DATEADD(MINUTE, -10, dtmStartDate)
															 WHEN strReminder = ''15 minutes'' THEN DATEADD(MINUTE, -15, dtmStartDate)
															 WHEN strReminder = ''30 minutes'' THEN DATEADD(MINUTE, -30, dtmStartDate)
															 WHEN strReminder = ''1 hour'' THEN DATEADD(HOUR, -1, dtmStartDate)
															 WHEN strReminder = ''2 hours'' THEN DATEADD(HOUR, -2, dtmStartDate)
															 WHEN strReminder = ''3 hours'' THEN DATEADD(HOUR, -3, dtmStartDate)
															 WHEN strReminder = ''4 hours'' THEN DATEADD(HOUR, -4, dtmStartDate)
															 WHEN strReminder = ''5 hours'' THEN DATEADD(HOUR, -5, dtmStartDate)
															 WHEN strReminder = ''6 hours'' THEN DATEADD(HOUR, -6, dtmStartDate)
															 WHEN strReminder = ''7 hours'' THEN DATEADD(HOUR, -7, dtmStartDate)
															 WHEN strReminder = ''8 hours'' THEN DATEADD(HOUR, -8, dtmStartDate)
															 WHEN strReminder = ''9 hours'' THEN DATEADD(HOUR, -9, dtmStartDate)
															 WHEN strReminder = ''10 hours'' THEN DATEADD(HOUR, -10, dtmStartDate)
															 WHEN strReminder = ''11 hours'' THEN DATEADD(HOUR, -11, dtmStartDate)
															 WHEN strReminder = ''12 hours'' THEN DATEADD(HOUR, -12, dtmStartDate)
															 WHEN strReminder = ''18 hours'' THEN DATEADD(HOUR, -18, dtmStartDate)
															 WHEN strReminder = ''1 day'' THEN DATEADD(DAY, -1, dtmStartDate)
															 WHEN strReminder = ''2 days'' THEN DATEADD(DAY, -2, dtmStartDate)
															 WHEN strReminder = ''3 days'' THEN DATEADD(DAY, -3, dtmStartDate)
															 WHEN strReminder = ''4 days'' THEN DATEADD(DAY, -4, dtmStartDate)
															 WHEN strReminder = ''1 week'' THEN DATEADD(WEEK, -1, dtmStartDate)
															 WHEN strReminder = ''2 weeks'' THEN DATEADD(WEEK, -2, dtmStartDate)
														END <= GETUTCDATE()'
			WHERE [strReminder] = N'Activity' AND [strType] = N'Reminder'
		END

	IF EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Purchase Order')
		BEGIN
			DELETE FROM [tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Purchase Order'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Sales Order')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Sales Order',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Sales Order'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Sales Order'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        17
		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Sales Order' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transfer')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Bank Transfer',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bank Transfer'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bank Transfer'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        1

		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transfer' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transaction')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Bank Transaction',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bank Transaction'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bank Transaction'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        1

		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transaction' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bank Deposit')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Bank Deposit',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bank Deposit'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bank Deposit'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        1

		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bank Deposit' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Misc Checks')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'Misc Checks',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
				   [strQuery]  			=        N'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Misc Checks'' ' +
												  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'UNION ' +
												  'SELECT intRecurringId ' +
												  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Misc Checks'' ' +
												  'AND ysnActive = 1 ' +
												  'AND intEntityId = {0} ' +
												  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
												  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
				   [strNamespace]       =        N'i21.view.RecurringTransaction', 
				   [intSort]            =        1

		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Misc Checks' 
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unlock' AND [strType] = N'Transaction')
		BEGIN
			INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
			SELECT	[strReminder]		=        N'Unlock',
					[strType]			=        N'Transaction',
					[strMessage]		=        N'{0} {1} {2} locked.',
					[strQuery]			=        N'SELECT intTransactionId
												FROM tblSMTransaction A
												WHERE	ysnLocked = 1 AND 
														DATEDIFF(MINUTE, dtmLockedDate, GETUTCDATE()) < (SELECT TOP 1 intLockedRecordExpiration FROM tblSMCompanyPreference) AND 
														(intLockedBy = {0} OR 
														EXISTS 
															(SELECT intEntityId 
																FROM tblSMUserSecurity 
																WHERE intEntityId = {0} AND ysnAdmin = 1))',
					[strNamespace]		=        N'GlobalComponentEngine.view.LockedRecord',
					[intSort]			=        1
		END
	ELSE
		BEGIN
			UPDATE [tblSMReminderList]
			SET	[strQuery] = N'SELECT intTransactionId
							FROM tblSMTransaction A
							WHERE	ysnLocked = 1 AND 
									DATEDIFF(MINUTE, dtmLockedDate, GETUTCDATE()) < (SELECT TOP 1 intLockedRecordExpiration FROM tblSMCompanyPreference) AND 
									(intLockedBy = {0} OR 
									EXISTS 
										(SELECT intEntityId 
											FROM tblSMUserSecurity 
											WHERE intEntityId = {0} AND ysnAdmin = 1))'
			WHERE [strReminder] = N'Unlock' AND [strType] = N'Transaction'
		END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Error' AND [strType] = N'Scale Service')
BEGIN
	DECLARE @intMaxSortOrder INT
	SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
	SELECT [strReminder]        =        N'Error',
			[strType]        	=        N'Scale Service',
			[strMessage]		=        N'{0} Scale service is not currently working. <br> Please check scale configuration.',
			[strQuery]  		=        N'SELECT SI.intDeviceInterfaceFileId FROM tblSCDeviceInterfaceFile SI 
											INNER JOIN tblSCScaleDevice SD ON SD.intPhysicalEquipmentId = SI.intScaleDeviceId
											INNER JOIN tblSCScaleSetup SS ON SD.intScaleDeviceId = SS.intInScaleDeviceId
											OUTER APPLY( SELECT intEntityContactId FROM tblEMEntityToContact WHERE intEntityContactId = {0} AND ysnPortalAccess = 1) EM 
											WHERE DATEDIFF(SECOND,dtmScaleTime,GETDATE()) >= 15 AND ISNULL(EM.intEntityContactId,0) = 0',
			[strNamespace]      =        N'',
			[intSort]           =        @intMaxSortOrder + 1
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
	SELECT [strReminder]        =        N'Error',
			[strType]        	=        N'Scale Service',
			[strMessage]		=        N'{0} Scale service is not currently working. <br> Please check scale configuration.',
			[strQuery]  		=        N'SELECT SI.intDeviceInterfaceFileId FROM tblSCDeviceInterfaceFile SI 
											INNER JOIN tblSCScaleDevice SD ON SD.intPhysicalEquipmentId = SI.intScaleDeviceId
											INNER JOIN tblSCScaleSetup SS ON SD.intScaleDeviceId = SS.intOutScaleDeviceId
											OUTER APPLY( SELECT intEntityContactId FROM tblEMEntityToContact WHERE intEntityContactId = {0} AND ysnPortalAccess = 1) EM 
											WHERE DATEDIFF(SECOND,dtmScaleTime,GETDATE()) >= 15 AND ISNULL(EM.intEntityContactId,0) = 0',
			[strNamespace]      =        N'',
			[intSort]           =        @intMaxSortOrder + 2
END
ELSE
BEGIN
	DELETE FROM [tblSMReminderList] WHERE [strReminder] = N'Error' AND [strType] = N'Scale Service'
	SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
	SELECT [strReminder]        =        N'Error',
			[strType]        	=        N'Scale Service',
			[strMessage]		=        N'{0} Scale service is not currently working. <br> Please check scale configuration.',
			[strQuery]  		=        N'SELECT SI.intDeviceInterfaceFileId FROM tblSCDeviceInterfaceFile SI 
											INNER JOIN tblSCScaleDevice SD ON SD.intPhysicalEquipmentId = SI.intScaleDeviceId
											INNER JOIN tblSCScaleSetup SS ON SD.intScaleDeviceId = SS.intInScaleDeviceId
											OUTER APPLY( SELECT intEntityContactId FROM tblEMEntityToContact WHERE intEntityContactId = {0} AND ysnPortalAccess = 1) EM 
											WHERE DATEDIFF(SECOND,dtmScaleTime,GETDATE()) >= 15 AND ISNULL(EM.intEntityContactId,0) = 0',
			[strNamespace]      =        N'',
			[intSort]           =        @intMaxSortOrder + 1
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
	SELECT [strReminder]        =        N'Error',
			[strType]        	=        N'Scale Service',
			[strMessage]		=        N'{0} Scale service is not currently working. <br> Please check scale configuration.',
			[strQuery]  		=        N'SELECT SI.intDeviceInterfaceFileId FROM tblSCDeviceInterfaceFile SI 
											INNER JOIN tblSCScaleDevice SD ON SD.intPhysicalEquipmentId = SI.intScaleDeviceId
											INNER JOIN tblSCScaleSetup SS ON SD.intScaleDeviceId = SS.intOutScaleDeviceId
											OUTER APPLY( SELECT intEntityContactId FROM tblEMEntityToContact WHERE intEntityContactId = {0} AND ysnPortalAccess = 1) EM 
											WHERE DATEDIFF(SECOND,dtmScaleTime,GETDATE()) >= 15 AND ISNULL(EM.intEntityContactId,0) = 0',
			[strNamespace]      =        N'',
			[intSort]           =        @intMaxSortOrder + 2
END

--	IF EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Post' AND [strType] = N'General Journal')
--	DELETE FROM [tblSMReminderList] WHERE [strReminder] = N'Post' AND [strType] = N'General Journal'

--GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unconfirmed' AND [strType] = N'Contract')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Unconfirmed',
			[strType]        	=        N'Contract',
			[strMessage]		=        N'{0} {1} {2} unconfirmed.',
			[strQuery]  		=        N'	SELECT	intContractHeaderId 
											FROM	tblCTContractDetail CD,	
													tblCTEvent EV
											JOIN	tblCTAction	AC	ON	AC.intActionId = EV.intActionId
											JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
											WHERE	intContractStatusId = 2 AND AC.strInternalCode = ''Unconfirmed Sequence'' AND ER.intEntityId = {0}
											',
			[strNamespace]       =        N'ContractManagement.view.ContractAlerts?activeTab=Unconfirmed', 
			[intSort]            =        18
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage] = N'{0} {1} {2} unconfirmed.',
		[strQuery]  =       N'	SELECT	DISTINCT CD.intContractHeaderId 
							FROM	tblCTContractDetail CD
							CROSS JOIN		tblCTEvent EV	
							JOIN	tblCTAction	AC	ON	AC.intActionId = EV.intActionId
							JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
							JOIN	tblCTContractHeader	CH	ON CH.intContractHeaderId	=	CD.intContractHeaderId
							LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							WHERE	intContractStatusId = 2 AND AC.strInternalCode = ''Unconfirmed Sequence'' AND ER.intEntityId = {0}
							AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)
							'
	WHERE [strReminder] = N'Unconfirmed' AND [strType] = N'Contract' 
END

GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Empty' AND [strType] = N'Contract')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Empty',
			[strType]        	=        N'Contract',
			[strMessage]		=        N'{0} {1} {2} without sequence.',
			[strQuery]  		=        N'	SELECT	CH.intContractHeaderId 
											FROM	tblCTContractHeader CH	CROSS	
											JOIN	tblCTEvent			EV	
											JOIN	tblCTAction			AC	ON	AC.intActionId			=	EV.intActionId
											JOIN	tblCTEventRecipient ER	ON	ER.intEventId			=	EV.intEventId	LEFT
											JOIN	tblCTContractDetail CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
											WHERE	CD.intContractHeaderId IS NULL AND AC.strInternalCode = ''Contract without Sequence'' AND ER.intEntityId = {0}
											GROUP BY CH.intContractHeaderId',
			[strNamespace]       =        N'ContractManagement.view.ContractAlerts?activeTab=Empty', 
			[intSort]            =        19
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage] = N'{0} {1} {2} without sequence.',
		[strQuery]  =	N'	SELECT	DISTINCT CH.intContractHeaderId 
						FROM	tblCTContractHeader CH	CROSS	
						JOIN	tblCTEvent			EV	
						JOIN	tblCTAction			AC	ON	AC.intActionId			=	EV.intActionId
						JOIN	tblCTEventRecipient ER	ON	ER.intEventId			=	EV.intEventId	LEFT
						JOIN	tblCTContractDetail CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
						LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
						WHERE	CD.intContractHeaderId IS NULL AND AC.strInternalCode = ''Contract without Sequence'' AND ER.intEntityId = {0}
						AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)
						GROUP BY CH.intContractHeaderId'
	WHERE [strReminder] = N'Empty' AND [strType] = N'Contract' 
END

GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unsigned' AND [strType] = N'Contract')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Unsigned',
			[strType]        	=        N'Contract',
			[strMessage]		=        N'{0} {1} {2} Unsigned.',
			[strQuery]  		=        N'	SELECT	intContractHeaderId 
											FROM	tblCTContractHeader CH,	
													tblCTEvent EV											
											JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
											WHERE	ISNULL(ysnSigned,0) = 0 AND EV.strEventName = ''Unsigned Contract Alert'' AND ER.intEntityId = {0}
											',
			[strNamespace]       =        N'ContractManagement.view.ContractAlerts?activeTab=Unsigned', 
			[intSort]            =        20
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage] = N'{0} {1} {2} Unsigned.',
		[strQuery]  =	N'	SELECT	DISTINCT CH.intContractHeaderId 
							FROM	tblCTContractHeader CH
							CROSS JOIN		tblCTEvent EV
							JOIN	tblCTContractDetail CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId											
							JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
							LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							WHERE	ISNULL(ysnSigned,0) = 0 AND EV.strEventName = ''Unsigned Contract Alert'' AND ER.intEntityId = {0}
							AND CD.intContractStatusId <> 3
							AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)
							'
	WHERE [strReminder] = N'Unsigned' AND [strType] = N'Contract' 
END

GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unsubmitted' AND [strType] = N'Contract')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Unsubmitted',
			[strType]        	=        N'Contract',
			[strMessage]		=        N'{0} {1} {2} Unsubmitted.',
			[strQuery]  		=        N'	SELECT	intContractHeaderId 
											FROM	tblCTContractHeader CH,	
													tblCTEvent EV											
											JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
											WHERE	CH.intContractHeaderId NOT IN(SELECT intRecordId FROM tblSMApproval A INNER JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId WHERE strStatus=''Submitted'') 
											AND     CH.intContractHeaderId   IN(SELECT intContractHeaderId FROM tblCTContractDetail WHERE LTRIM(RTRIM(ISNULL(strERPPONumber,''''))) = '''')
											AND		EV.strEventName  =  ''Unsubmitted Contract Alert'' AND ER.intEntityId = {0}
											',
			[strNamespace]       =        N'ContractManagement.view.ContractAlerts?activeTab=Unsubmitted', 
			[intSort]            =        21
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage] = N'{0} {1} {2} Unsubmitted.',
		[strQuery]=   N'SELECT DISTINCT	CH.intContractHeaderId 
						FROM	tblCTContractHeader CH	
						CROSS JOIN tblCTEvent EV											
						JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
						LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId  AND ER.intEventId = RF.intEventId
						LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
						WHERE	CH.intContractHeaderId NOT IN(SELECT intRecordId FROM tblSMApproval A INNER JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId WHERE strStatus=''Submitted'') 
						AND		CH.intContractHeaderId	NOT IN (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId = 2)
						AND		EV.strEventName = ''Unsubmitted Contract Alert'' AND ER.intEntityId = {0}
						AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)
						AND CD.intContractDetailId IS NOT NULL AND CD.intContractStatusId <> 3
						'
	WHERE [strReminder] = N'Unsubmitted' AND [strType] = N'Contract' 
END
GO

GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unapproved Contract' AND [strType] = N'Quality Sample')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Unapproved Contract',
			[strType]        	=        N'Quality Sample',
			[strMessage]		=        N'{0} {1} {2} unapproved.',
			[strQuery]  		=        N'	SELECT CA.intContractDetailId
											FROM vyuQMSampleContractAlert CA
											JOIN tblCTEventRecipient ER ON ER.intEventId = CA.intEventId
											WHERE ER.intEntityId = {0}',
			[strNamespace]       =        N'Quality.view.QualityAlerts?activeTab=Unapproved', 
			[intSort]            =        22
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage] = N'{0} {1} {2} unapproved.',
			[strQuery]  		=        N'	SELECT CA.intContractDetailId
											FROM vyuQMSampleContractAlert CA
											JOIN tblCTEventRecipient ER ON ER.intEventId = CA.intEventId
											WHERE ER.intEntityId = {0}'
	WHERE [strReminder] = N'Unapproved Contract' AND [strType] = N'Quality Sample' 
END
GO

GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Unapproved FOB Contract' AND [strType] = N'Quality Sample')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Unapproved FOB Contract',
			[strType]        	=        N'Quality Sample',
			[strMessage]		=        N'{0} {1} {2} unapproved.',
			[strQuery]  		=        N'	SELECT CA.intContractDetailId
											FROM vyuQMSampleFOBContractAlert CA
											JOIN tblCTEventRecipient ER ON ER.intEventId = CA.intEventId
											WHERE ER.intEntityId = {0}',
			[strNamespace]       =        N'Quality.view.QualityAlerts?activeTab=UnapprovedFOB', 
			[intSort]            =        23
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage] = N'{0} {1} {2} unapproved.',
			[strQuery]  		=        N'	SELECT CA.intContractDetailId
											FROM vyuQMSampleFOBContractAlert CA
											JOIN tblCTEventRecipient ER ON ER.intEventId = CA.intEventId
											WHERE ER.intEntityId = {0}'
	WHERE [strReminder] = N'Unapproved FOB Contract' AND [strType] = N'Quality Sample' 
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Contract w/o shipping instruction')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]

	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Contract w/o shipping instruction'
		,[strMessage]		= N'{0} Contracts are w/o shipping instruction.'
		,[strQuery]			= N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId  AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o shipping instruction'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Contract%20w%2Fo%20shipping%20instruction'
		,[intSort]			= ISNULL(@intMaxSortOrder,0)+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Contracts are w/o shipping instruction.',
		[strQuery]	 = N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o shipping instruction'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
	WHERE [strReminder] = N''
		AND [strType] = N'Contract w/o shipping instruction'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Contracts w/o shipping advice')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]
	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Contracts w/o shipping advice'
		,[strMessage]		= N'{0} Contracts are w/o shipping advice.'
		,[strQuery]			= N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o shipping advice'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Contract%20w%2Fo%20shipping%20advice'
		,[intSort]			= @intMaxSortOrder+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Contracts are w/o shipping advice.',
		[strQuery]	 = N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o shipping advice'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
	WHERE [strReminder] = N''
		AND [strType] = N'Contracts without Shipping Advice'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Contracts w/o document')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]

	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Contracts w/o document'
		,[strMessage]		= N'{0} Contracts are w/o document.'
		,[strQuery]			= N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o document'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Contract%20w%2Fo%20document'
		,[intSort]			= @intMaxSortOrder+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Contracts are w/o document.',
		[strQuery]	 = N' SELECT intContractHeaderId
						  FROM vyuLGNotifications vyu
						  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
						  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
						  WHERE vyu.strType = ''Contracts w/o document'' AND ER.intEntityId = {0}
						  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
	WHERE [strReminder] = N''
		AND [strType] = N'Contracts w/o document'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Contracts w/o weight claim')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]

	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Contracts w/o weight claim'
		,[strMessage]		= N'{0} Contracts are w/o weight claim.'
		,[strQuery]			=N'SELECT * FROM (
									  SELECT 
											 A.intCommodityId,
											 B.intEventId   
									   FROM (  
											   SELECT
												   CH.intContractHeaderId,
												   CH.intCommodityId, 
												   intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETAPOD, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
											   FROM tblCTContractHeader CH  
											   JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId  
											   JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId  
											   JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10  
											   JOIN tblICItem I ON I.intItemId = CD.intItemId  
											   JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId  
											   JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId  
											   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId  
											   WHERE L.intLoadId NOT IN (  
														  SELECT WC.intLoadId  
														  FROM tblLGWeightClaim WC  
														  JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId  
											   )  
											   AND CH.intContractTypeId = 1  
											   AND CO.intCommodityId = 1  
											   AND CH.intContractHeaderId IN (SELECT DISTINCT intOrderId FROM tblICInventoryReceiptItem)  
											   AND CD.intContractStatusId IN (1,2,4)  
									   ) A,
										(SELECT TOP 1 intEventId, intDaysToRemind FROM tblCTEvent WHERE strEventName = ''Contract Without Weight Claim'') B
										WHERE A.intDayToShipment >= B.intDaysToRemind    
							   ) vyuLGNotifications   
									  WHERE 
										EXISTS(
											SELECT TOP 1 1 
											FROM tblCTEventRecipient X 
												LEFT JOIN tblCTEventRecipientFilter Y ON X.intEntityId = Y.intEntityId AND X.intEventId = Y.intEventId
											WHERE vyuLGNotifications.intEventId  = X.intEventId AND 
												  vyuLGNotifications.intCommodityId = ISNULL(Y.intCommodityId, vyuLGNotifications.intCommodityId) AND
												  X.intEntityId = {0}  )'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Contract%20w%2Fo%20weight%20claim'
		,[intSort]			= ISNULL(@intMaxSortOrder,0)+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Contracts are w/o weight claim.',
	[strQuery]		 = N'SELECT * FROM (
							  SELECT 
									 A.intCommodityId,
									 B.intEventId   
							   FROM (  
									   SELECT
										   CH.intContractHeaderId,
										   CH.intCommodityId, 
										   intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETAPOD, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
									   FROM tblCTContractHeader CH  
									   JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId  
									   JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId  
									   JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10  
									   JOIN tblICItem I ON I.intItemId = CD.intItemId  
									   JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId  
									   JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId  
									   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId  
									   WHERE L.intLoadId NOT IN (  
												  SELECT WC.intLoadId  
												  FROM tblLGWeightClaim WC  
												  JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId  
									   )  
									   AND CH.intContractTypeId = 1  
									   AND CO.intCommodityId = 1  
									   AND CH.intContractHeaderId IN (SELECT DISTINCT intOrderId FROM tblICInventoryReceiptItem)  
									   AND CD.intContractStatusId IN (1,2,4)  
							   ) A,
								(SELECT TOP 1 intEventId, intDaysToRemind FROM tblCTEvent WHERE strEventName = ''Contract Without Weight Claim'') B
								WHERE A.intDayToShipment >= B.intDaysToRemind    
					   ) vyuLGNotifications   
							  WHERE 
								EXISTS(
									SELECT TOP 1 1 
									FROM tblCTEventRecipient X 
										LEFT JOIN tblCTEventRecipientFilter Y ON X.intEntityId = Y.intEntityId AND X.intEventId = Y.intEventId
									WHERE vyuLGNotifications.intEventId  = X.intEventId AND 
										  vyuLGNotifications.intCommodityId = ISNULL(Y.intCommodityId, vyuLGNotifications.intCommodityId) AND
										  X.intEntityId = {0} )'
	WHERE [strReminder] = N''
		AND [strType] = N'Contracts w/o weight claim'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Weight claims w/o debit note')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]

	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Weight claims w/o debit note'
		,[strMessage]		= N'{0} Weight claims are w/o debit note.'
		,[strQuery]			= N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Weight claims w/o debit note'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Weight%20claim%20w%2Fo%20debit%20note'
		,[intSort]			= @intMaxSortOrder+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Weight claims are w/o debit note.',
		[strQuery]	 = N' SELECT intContractHeaderId
					   FROM vyuLGNotifications vyu
					   JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
					   LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
					   WHERE vyu.strType = ''Weight claims w/o debit note'' AND ER.intEntityId = {0}
					   AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
	WHERE [strReminder] = N''
		AND [strType] = N'Weight claims w/o debit note'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Contracts w/o TC')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]

	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Contracts w/o TC'
		,[strMessage]		= N'{0} Contracts are w/o TC.'
		,[strQuery]			= N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o TC'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Contract%20w%2Fo%20TC'
		,[intSort]			= @intMaxSortOrder+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Contracts are w/o TC.'		,
	[strQuery]		 = N' SELECT intContractHeaderId
					   FROM vyuLGNotifications vyu
					   JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
					   LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
					   WHERE vyu.strType = ''Contracts w/o TC'' AND ER.intEntityId = {0}
					   AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
	WHERE [strReminder] = N''
		AND [strType] = N'Contracts w/o TC'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strType] = N'Contracts w/o 4C')
BEGIN
DECLARE @intMaxSortOrder INT
SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]

	INSERT INTO [tblSMReminderList] (
		[strReminder]
		,[strType]
		,[strMessage]
		,[strQuery]
		,[strNamespace]
		,[intSort]
		)
	SELECT [strReminder]	= N''
		,[strType]			= N'Contracts w/o 4C'
		,[strMessage]		= N'{0} Contracts are w/o 4C.'
		,[strQuery]			= N' SELECT intContractHeaderId
							  FROM vyuLGNotifications vyu
							  JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
							  LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
							  WHERE vyu.strType = ''Contracts w/o 4C'' AND ER.intEntityId = {0}
							  AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
		,[strNamespace]		= N'Logistics.view.LogisticsAlerts?activeTab=Contract%20w%2Fo%204C'
		,[intSort]			= @intMaxSortOrder+1
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET [strMessage] = N'{0} Contracts are w/o 4C.',
 		[strQuery]	 = N' SELECT intContractHeaderId
					   FROM vyuLGNotifications vyu
					   JOIN tblCTEventRecipient ER ON ER.intEventId = vyu.intEventId
					   LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
					   WHERE vyu.strType = ''Contracts w/o 4C'' AND ER.intEntityId = {0}
					   AND vyu.intCommodityId = ISNULL(RF.intCommodityId,vyu.intCommodityId)'
	WHERE [strReminder] = N''
		AND [strType] = N'Contracts w/o 4C'
END
GO

GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Mail Not Sent For' AND [strType] = N'Approved Contract')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT  [strReminder]       =		 N'Mail Not Sent For',
			[strType]        	=        N'Approved Contract',
			[strMessage]		=        N'{0} {1} {2} Not Sent.',
			[strQuery]  		=        N'	SELECT	intContractHeaderId 
											FROM	tblCTContractHeader CH	
											CROSS JOIN tblCTEvent EV											
											JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
											JOIN	tblSMTransaction	TN	ON	TN.intRecordId	=	CH.intContractHeaderId
											JOIN	tblSMScreen			SN	ON	SN.intScreenId	=	TN.intScreenId AND SN.strNamespace IN (''ContractManagement.view.Contract'', ''ContractManagement.view.Amendments'')
											WHERE	ISNULL(ysnMailSent,0) = 0 AND TN.ysnOnceApproved = 1
											AND		EV.strEventName  =  ''Approved Contract Mail Not Sent'' AND ER.intEntityId = {0}
											',
			[strNamespace]       =        N'ContractManagement.view.ContractAlerts?activeTab=Approved Not Sent', 
			[intSort]            =        25
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strQuery]=   N'SELECT	intContractHeaderId 
						FROM	tblCTContractHeader CH	
						CROSS JOIN tblCTEvent EV											
						JOIN	tblCTEventRecipient ER ON ER.intEventId = EV.intEventId
						JOIN	tblSMTransaction	TN	ON	TN.intRecordId	=	CH.intContractHeaderId
						JOIN	tblSMScreen			SN	ON	SN.intScreenId	=	TN.intScreenId AND SN.strNamespace IN (''ContractManagement.view.Contract'', ''ContractManagement.view.Amendments'')
						LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
						WHERE	ISNULL(ysnMailSent,0) = 0 AND TN.ysnOnceApproved = 1
						AND		EV.strEventName  =  ''Approved Contract Mail Not Sent'' AND ER.intEntityId = {0}
						AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)
						'
	WHERE [strReminder] = N'Mail Not Sent For' AND [strType] = N'Approved Contract' 
END
GO

GO
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Update' AND [strType] = N'Register')
	BEGIN
		DECLARE @sqlQuery AS NVARCHAR(MAX) = 
		N'Select DISTINCT intItemId FROM vyuSTItemsToRegister    
		WHERE ysnClick = 0 AND intEntityId = {0}   
		AND 
		(
			(
				dtmDateModified BETWEEN     
				ISNULL    
				(     
					(      
						SELECT TOP (1) dtmEndingChangeDate      
						FROM dbo.tblSTUpdateRegisterHistory           
						WHERE intStoreId =       
						(       
							SELECT TOP (1) intStoreId FROM tblSTStore       
							WHERE intCompanyLocationId =        
							(        
								SELECT TOP (1) intCompanyLocationId         
								FROM tblSMUserSecurity         
								WHERE intEntityId = {0}      
							)      
						)      
						ORDER BY intUpdateRegisterHistoryId DESC     
					),     
					(      
						SELECT TOP (1) dtmDate      
						FROM dbo.tblSMAuditLog      
						WHERE strTransactionType = ''Inventory.view.Item''      
						OR strTransactionType = ''Inventory.view.ItemLocation''      
						ORDER BY dtmDate ASC     
					)    
				)    
				AND GETUTCDATE()   
			)
		OR 
			(
				dtmDateCreated BETWEEN     
				ISNULL    
				(     
					(      
						SELECT TOP (1) dtmEndingChangeDate      
						FROM dbo.tblSTUpdateRegisterHistory           
						WHERE intStoreId =       
						(       
							SELECT TOP (1) intStoreId FROM tblSTStore       
							WHERE intCompanyLocationId =       
							(        
								SELECT TOP (1) intCompanyLocationId         
								FROM tblSMUserSecurity        
								 WHERE intEntityId = {0}       
							)      
						)      
						ORDER BY intUpdateRegisterHistoryId DESC     
					),     
					(      
						SELECT TOP (1) dtmDate      
						FROM dbo.tblSMAuditLog      
						WHERE strTransactionType = ''Inventory.view.Item''    
						OR strTransactionType = ''Inventory.view.ItemLocation''      
						ORDER BY dtmDate ASC     
					)    
				)    
				AND GETUTCDATE()
			)
		)'

		INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
		SELECT	[strReminder]		=        N'Update',
				[strType]			=        N'Register',
				[strMessage]		=        N'{0} Item(s) {2} needed to be sent to the register.',
				[strQuery]			=        @sqlQuery,
				--[strQuery]			=        N'SELECT DISTINCT intItemId FROM vyuSTItemsToRegister WHERE ysnClick = 0 AND intEntityId = {0}',
				[strNamespace]		=        N'Store.view.UpdateRegister',
				[intSort]			=        1
	END
ELSE
	BEGIN
		SET @sqlQuery = 
		N'Select DISTINCT intItemId FROM vyuSTItemsToRegister    
		WHERE ysnClick = 0 AND intEntityId = {0}   
		AND 
		(
			(
				dtmDateModified BETWEEN     
				ISNULL    
				(     
					(      
						SELECT TOP (1) dtmEndingChangeDate      
						FROM dbo.tblSTUpdateRegisterHistory           
						WHERE intStoreId =       
						(       
							SELECT TOP (1) intStoreId FROM tblSTStore       
							WHERE intCompanyLocationId =        
							(        
								SELECT TOP (1) intCompanyLocationId         
								FROM tblSMUserSecurity         
								WHERE intEntityId = {0}      
							)      
						)      
						ORDER BY intUpdateRegisterHistoryId DESC     
					),     
					(      
						SELECT TOP (1) dtmDate      
						FROM dbo.tblSMAuditLog      
						WHERE strTransactionType = ''Inventory.view.Item''      
						OR strTransactionType = ''Inventory.view.ItemLocation''      
						ORDER BY dtmDate ASC     
					)    
				)    
				AND GETUTCDATE()   
			)
		OR 
			(
				dtmDateCreated BETWEEN     
				ISNULL    
				(     
					(      
						SELECT TOP (1) dtmEndingChangeDate      
						FROM dbo.tblSTUpdateRegisterHistory           
						WHERE intStoreId =       
						(       
							SELECT TOP (1) intStoreId FROM tblSTStore       
							WHERE intCompanyLocationId =       
							(        
								SELECT TOP (1) intCompanyLocationId         
								FROM tblSMUserSecurity        
								 WHERE intEntityId = {0}       
							)      
						)      
						ORDER BY intUpdateRegisterHistoryId DESC     
					),     
					(      
						SELECT TOP (1) dtmDate      
						FROM dbo.tblSMAuditLog      
						WHERE strTransactionType = ''Inventory.view.Item''    
						OR strTransactionType = ''Inventory.view.ItemLocation''      
						ORDER BY dtmDate ASC     
					)    
				)    
				AND GETUTCDATE()
			)
		)'

		UPDATE [tblSMReminderList]
		SET [strMessage]  =     N'{0} Item(s) {2} needed to be sent to the register.',
			[strQuery]	  =     @sqlQuery,
		    [strNamespace]	=   N'Store.view.UpdateRegister'
		WHERE [strReminder] = N'Update' AND [strType] = N'Register'
	END
GO






IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Pre-shipment Sample not yet approved' AND [strType] = N'Contract')
BEGIN
	INSERT INTO [tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
	SELECT [strReminder]        =        N'Pre-shipment Sample not yet approved',
			[strType]        	=        N'Contract',
			[strMessage]		=        N'{0} {1} {2} sample not yet approved',
			[strQuery]  		=        N'	SELECT	DISTINCT CH.intContractHeaderId , null as s
												FROM	tblCTContractHeader CH	CROSS	
												JOIN	tblCTEvent			EV	
												JOIN	tblCTAction			AC	ON	AC.intActionId			=	EV.intActionId AND AC.strActionName = ''Pre-shipment Sample Notification''
												JOIN	tblCTEventRecipient ER	ON	ER.intEventId			=	EV.intEventId	LEFT
												JOIN	tblCTContractDetail CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
												JOIN	tblQMSample as SM
														on CD.intContractDetailId = SM.intContractDetailId
												JOIN	tblQMSampleType as SMT
														on SM.intSampleTypeId = SMT.intSampleTypeId
															and SMT.strSampleTypeName = ''Pre-shipment Sample''
												JOIN	tblQMSampleStatus as SMS
														on SMS.intSampleStatusId = SM.intSampleStatusId
															and SMS. strStatus <> ''Approved''
												LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
												WHERE	ER.intEntityId = {0}
												GROUP BY CH.intContractHeaderId, SM.intSampleId
												
												union

												SELECT	DISTINCT CH.intContractHeaderId , null as s
														FROM	tblCTContractHeader CH	CROSS	
														JOIN	tblCTEvent			EV	
														JOIN	tblCTAction			AC	ON	AC.intActionId			=	EV.intActionId AND AC.strActionName = ''Pre-shipment Sample Notification''
														JOIN	tblCTEventRecipient ER	ON	ER.intEventId			=	EV.intEventId
														JOIN (
																		SELECT intContractHeaderId from tblCTContractHeader b
																			join tblCTWeightGrade c
																				on b.intGradeId = c.intWeightGradeId and ysnSample = 1
																		Union
																		SELECT intContractHeaderId from tblCTContractHeader b
																			join tblCTWeightGrade c
																				on b.intWeightId = c.intWeightGradeId and ysnSample = 1
																	) a
																		on CH.intContractHeaderId = a.intContractHeaderId
														LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
														WHERE	ER.intEntityId = {0} and CH.intContractHeaderId not in (select intContractHeaderId from tblCTContractDetail where intContractDetailId in (select intContractDetailId from tblQMSample, tblQMSampleStatus
																			where tblQMSampleStatus.intSampleStatusId = tblQMSample.intSampleStatusId and tblQMSampleStatus.strStatus = ''Approved''))
														GROUP BY CH.intContractHeaderId
												
												',
			[strNamespace]       =        N'ContractManagement.view.ContractAlerts?activeTab=Sample not approved', 
			[intSort]            =        19
END
ELSE
BEGIN
	UPDATE [tblSMReminderList]
	SET	[strMessage]		=        N'{0} {1} {2} sample not yet approved',
		[strQuery]  		=        N'	SELECT	DISTINCT CH.intContractHeaderId , null as s
												FROM	tblCTContractHeader CH	CROSS	
												JOIN	tblCTEvent			EV	
												JOIN	tblCTAction			AC	ON	AC.intActionId			=	EV.intActionId AND AC.strActionName = ''Pre-shipment Sample Notification''
												JOIN	tblCTEventRecipient ER	ON	ER.intEventId			=	EV.intEventId	LEFT
												JOIN	tblCTContractDetail CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
												JOIN	tblQMSample as SM
														on CD.intContractDetailId = SM.intContractDetailId
												JOIN	tblQMSampleType as SMT
														on SM.intSampleTypeId = SMT.intSampleTypeId
															and SMT.strSampleTypeName = ''Pre-shipment Sample''
												JOIN	tblQMSampleStatus as SMS
														on SMS.intSampleStatusId = SM.intSampleStatusId
															and SMS. strStatus <> ''Approved''
												LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
												WHERE	ER.intEntityId = {0}
												GROUP BY CH.intContractHeaderId, SM.intSampleId
												
										
												
												union

												SELECT	DISTINCT CH.intContractHeaderId , null as s
														FROM	tblCTContractHeader CH	CROSS	
														JOIN	tblCTEvent			EV	
														JOIN	tblCTAction			AC	ON	AC.intActionId			=	EV.intActionId AND AC.strActionName = ''Pre-shipment Sample Notification''
														JOIN	tblCTEventRecipient ER	ON	ER.intEventId			=	EV.intEventId
														JOIN (
																		SELECT intContractHeaderId from tblCTContractHeader b
																			join tblCTWeightGrade c
																				on b.intGradeId = c.intWeightGradeId and ysnSample = 1
																		Union
																		SELECT intContractHeaderId from tblCTContractHeader b
																			join tblCTWeightGrade c
																				on b.intWeightId = c.intWeightGradeId and ysnSample = 1
																	) a
																		on CH.intContractHeaderId = a.intContractHeaderId
														LEFT JOIN tblCTEventRecipientFilter RF ON RF.intEntityId = ER.intEntityId AND ER.intEventId = RF.intEventId
														WHERE	ER.intEntityId = {0} and CH.intContractHeaderId not in (select intContractHeaderId from tblCTContractDetail where intContractDetailId in (select intContractDetailId from tblQMSample, tblQMSampleStatus
																			where tblQMSampleStatus.intSampleStatusId = tblQMSample.intSampleStatusId and tblQMSampleStatus.strStatus = ''Approved''))
														GROUP BY CH.intContractHeaderId
														
														'
	WHERE [strReminder] = N'Pre-shipment Sample not yet approved' AND [strType] = N'Contract' 
END

--START RESPONSIBLE PARTY TASK

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMReminderList WHERE CHARINDEX('CashManagement.view.ResponsiblePartyTask', strNamespace) > 0 )
	INSERT INTO tblSMReminderList(strReminder, strType,strMessage, strQuery,strNamespace, intSort, intConcurrencyId)
	SELECT 'Process',	'Bank Task',	'{0} {1} {2} unprocessed.',
		'select intTaskId from vyuCMResponsiblePartyTask where isnull(ysnStatus,0) = 0 and intEntityId = {0}',
		'CashManagement.view.ResponsiblePartyTask?showSearch=true&intEntityId={0}', 1, 1 

ELSE
	UPDATE tblSMReminderList
	SET strReminder='Process', strType='Bank Task',strMessage='{0} {1} {2} unprocessed.', 
	strQuery='select intTaskId from vyuCMResponsiblePartyTask where isnull(ysnStatus,0) = 0 and intEntityId = {0}',
	strNamespace='CashManagement.view.ResponsiblePartyTask?showSearch=true&intEntityId={0}'
	WHERE CHARINDEX('CashManagement.view.ResponsiblePartyTask', strNamespace) > 0 
GO
--END RESPONSIBLE PARTY TASK

-- BEGIN Inventory Reminders
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReminderList] WHERE [strReminder] = N'Imported' AND [strType] = N'Inventory Receipt')
BEGIN 
	DECLARE @intMaxSortOrder INT
	SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]
	
	INSERT INTO [tblSMReminderList] (
		[strReminder]
		, [strType]
		, [strMessage]
		, [strQuery]
		, [strNamespace]
		, [intSort]
	)
	SELECT 
		[strReminder] = 'Imported'
		, [strType] = 'Inventory Receipt'
		, [strMessage] = '{0} imported.'
		, [strQuery] = 
'SELECT 
	r.strReceiptNumber, r.ysnPosted, r.dtmDateCreated
FROM 
	tblICInventoryReceipt r INNER JOIN tblSMCompanyLocation cl 
		ON r.intLocationId = cl.intCompanyLocationId 
	CROSS APPLY (
		SELECT 
			u.strUserName, u.intEntityId 
		FROM  
			tblSMUserSecurity u 
		WHERE 
			u.intEntityId = {0} 
			and u.ysnStoreManager = 1 
			and u.intCompanyLocationId = cl.intCompanyLocationId 
	) u
WHERE 
	r.strDataSource = ''EdiGenerateReceipt'' 
	AND (r.ysnPosted = 0 OR r.ysnPosted IS NULL)
'
		, [strNamespace] = 'Inventory.view.InventoryReceipt?showSearch=true&searchCommand=reminderSearchConfig'
		, [intSort] = ISNULL(@intMaxSortOrder, 0) + 1
END 

GO
-- END Inventory Reminders

-- BEGIN Bank Transfer Reminders

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMReminderList WHERE strReminder='Unposted' AND strType='Bank Transfer')
BEGIN
	DECLARE @intMaxSortOrder INT 
	SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]
	INSERT INTO tblSMReminderList(strQuery, strReminder,strType, strMessage, strParameter,intSort, strNamespace)
	VALUES('SELECT intTransactionId from vyuCMBTForAccrualPosting  where intEntityId={0}'
	,'Unposted'
	,'Bank Transfer'
	,'{0} {1} {2} Unposted'
	,'intEntityId'
	,@intMaxSortOrder
	,'CashManagement.view.BankTransfer?activeTab=For Accrual Posting&showSearch=true&intEntityId={0}')
END
ELSE
	UPDATE tblSMReminderList
	set strQuery = 'select intTransactionId from vyuCMBTForAccrualPosting where intEntityId={0}'
	, strReminder = 'Unposted'
	, strType = 'Forex Bank Transfer'
	, strMessage = '{0} {1} {2} Unposted'
	, strParameter = 'intEntityId'
	, strNamespace = 'CashManagement.view.BankTransfer?activeTab=For Accrual Posting&showSearch=true&intEntityId={0}'

GO


IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMReminderList WHERE strReminder='Unposted' AND strType='Bank Transfer Swap')
BEGIN
	DECLARE @intMaxSortOrder INT 
	SELECT @intMaxSortOrder = MAX(intSort) FROM [tblSMReminderList]
	INSERT INTO tblSMReminderList(strQuery, strReminder,strType, strMessage, strParameter,intSort, strNamespace)
	VALUES('SELECT intBankSwapId from vyuCMBTForAccrualSwapPosting  where intEntityId={0}'
	,'Unposted'
	,'Bank Transfer Swap'
	,'{0} {1} {2} Unposted'
	,'intEntityId'
	,@intMaxSortOrder
	,'CashManagement.view.BankSwap?activeTab=For Accrual Posting&showSearch=true&intEntityId={0}')
END
ELSE
	UPDATE tblSMReminderList
	set strQuery = 'select intBankSwapId from vyuCMBTForAccrualSwapPosting where intEntityId={0}'
	, strReminder = 'Unposted'
	, strType = 'Forex Bank Transfer Swap'
	, strMessage = '{0} {1} {2} Unposted'
	, strParameter = 'intEntityId'
	, strNamespace = 'CashManagement.view.BankSwap?activeTab=For Accrual Posting&showSearch=true&intEntityId={0}'

GO
-- END Bank Transfer Reminders

