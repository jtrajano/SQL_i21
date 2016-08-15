﻿GO

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Invoice')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Invoice' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'General Journal')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Process',
				   [strType]        	=        N'General Journal',
				   [strMessage]			=        N'{0} {1} {2} unprocessed.',
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'General Journal' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Voucher')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Voucher' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Purchase Order')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Purchase Order' 
		END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bill Template')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bill Template' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Voucher')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Approve',
				   [strType]        	=        N'Voucher',
				   [strMessage]			=        N'{0} {1} {2} unapproved.',
				   [strQuery]  			=        N'SELECT * FROM vyuAPBillForApproval WHERE intEntityApproverId = {0} AND ysnApproved = 0',
				   [strNamespace]       =        N'AccountsPayable.view.VendorExpenseApproval', 
				   [intSort]            =        6
		END
	ELSE
		BEGIN
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unapproved.'
			WHERE [strReminder] = N'Approve' AND [strType] = N'Voucher' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Update' AND [strType] = N'Invoice')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Update',
				[strType]        	=        N'Invoice',
				[strMessage]		=        N'{0} Customer''s Budget need to update for final budget.',
				[strQuery]  		=        N'SELECT intEntityCustomerId, DATEADD(MONTH, 1, MAX(dtmBudgetDate)) AS dtmBudgetEndDate FROM tblARCustomerBudget GROUP BY intEntityCustomerId HAVING GETDATE() > DATEADD(MONTH, 1, MAX(dtmBudgetDate))',
				[strNamespace]      =        N'AccountsReceivable.view.Invoice', 
				[intSort]           =        7
	END	

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Post' AND [strType] = N'General Journal')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Post',
				[strType]        	=        N'General Journal',
				[strMessage]		=        N'{0} {1} {2} left unposted.',
				[strQuery]  		=        N'Select intJournalId FROM vyuGLPostRemind WHERE intEntityId = {0}',
				[strNamespace]      =        N'GeneralLedger.view.GeneralJournal?unposted=1',
				[intSort]           =        8
	END	

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 9)
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
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
		UPDATE [dbo].[tblSMReminderList] SET [strNamespace] = N'Grain.view.ScaleStationSelection?showSearch=true&searchCommand=reminderSearchConfig'
		,[strQuery] = N'SELECT intTicketUncompletedDaysAlert,ysnHasGeneratedTicketNumber,strTicketStatus from tblSCUncompletedTicketAlert SCAlert
		LEFT JOIN tblSCTicket SCTicket ON SCAlert.intCompanyLocationId = SCTicket.intProcessingLocationId
		WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
		AND ysnHasGeneratedTicketNumber = 1
		AND (strTicketStatus = ''O'' OR strTicketStatus = ''A'')
		AND SCAlert.intEntityId = {0}'  
		WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 9
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 10)
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
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
		UPDATE [dbo].[tblSMReminderList] SET [strQuery] = N'SELECT intTicketUncompletedDaysAlert,ysnHasGeneratedTicketNumber,strTicketStatus,intProcessingLocationId,SCAlert.intEntityId from tblSCUncompletedTicketAlert SCAlert,tblSCTicket SCTicket
		WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
		AND ysnHasGeneratedTicketNumber = 1
		AND (strTicketStatus = ''O'' OR strTicketStatus = ''A'')
		AND ISNULL(intCompanyLocationId,0) = 0
		AND SCAlert.intEntityId = {0}' 
		, [strNamespace] = N'Grain.view.ScaleStationSelection?showSearch=true&searchCommand=reminderSearchConfig'
		WHERE [strReminder] = N'Overdue' AND [strType] = N'Scale Ticket' AND [intSort] = 10


	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Transaction')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT	[strReminder]		=        N'Approve',
				[strType]			=        N'Transaction',
				[strMessage]		=        N'{0} {1} {2} unapproved.',
				[strQuery]			=        N'SELECT 
                                                    intTransactionId 
                                                FROM tblSMApproval 
                                                WHERE  ysnCurrent = 1 AND 
                                                        strStatus IN (''Waiting for Approval'') AND 
                                                        intApproverId = {0}',
				[strNamespace]		=        N'i21.view.Approval?activeTab=Pending',
				[intSort]			=        11
	END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Approved' AND [strType] = N'Transaction')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
		SELECT [strReminder]        =        N'Approved',
				[strType]           =        N'Transaction',
				[strMessage]        =        N'{0} Transaction(s) {2} approved.',
				[strQuery]          =        N'SELECT 
                                                    intTransactionId 
                                                FROM tblSMApproval 
                                                WHERE intTransactionId IN (
                                                    SELECT intTransactionId 
                                                    FROM tblSMTransaction 
                                                    WHERE strApprovalStatus = ''Approved''
                                                ) and ysnCurrent = 1  and strStatus = ''Approved'' 
                                                AND intSubmittedById = {0}
                                                GROUP BY intTransactionId',
				[strNamespace]      =        N'i21.view.Approval?activeTab=Approved',
				[intSort]           =        12

	END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Closed' AND [strType] = N'Transaction')
    BEGIN
        INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Closed',
                [strType]           =        N'Transaction',
                [strMessage]        =        N'{0} Transaction(s) {2} closed.',
                [strQuery]          =        N'    SELECT 
                                                    intTransactionId 
                                                FROM tblSMApproval 
                                                WHERE intTransactionId IN (
                                                        SELECT intTransactionId 
                                                        FROM tblSMTransaction 
                                                        WHERE strApprovalStatus = ''Closed''
                                                    ) 
                                                    AND ysnCurrent = 1 
                                                    AND strStatus = ''Closed'' 
                                                    AND intSubmittedById = {0}
                                                GROUP BY intTransactionId',
                [strNamespace]      =        N'i21.view.Approval?activeTab=Closed',
                [intSort]           =        13
    END    
  
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Unsubmitted' AND [strType] = N'Transaction')
    BEGIN
        INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Unsubmitted',
                [strType]           =        N'Transaction',
                [strMessage]        =        N'{0} Transaction(s) {2} unsubmitted.',
                [strQuery]          =        N'    SELECT 
                                                    intTransactionId 
                                                FROM tblSMApproval 
                                                WHERE    ysnCurrent = 1 AND 
                                                        strStatus IN (''Waiting for Submit'') AND 
                                                        intSubmittedById= {0}',
                [strNamespace]      =        N'i21.view.Approval?activeTab=Closed',
                [intSort]           =        14
    END    
  
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Rejected' AND [strType] = N'Transaction')
    BEGIN
        INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])    
        SELECT [strReminder]        =        N'Rejected',
                [strType]           =        N'Transaction',
                [strMessage]        =        N'{0} Transaction(s) {2} rejected.',
                [strQuery]          =        N'    SELECT 
                                                    intTransactionId 
                                                FROM tblSMApproval 
                                                WHERE    ysnCurrent = 1 AND 
                                                        strStatus IN (''Rejected'') AND 
                                                        intSubmittedById= {0}',
                [strNamespace]      =        N'i21.view.Approval?activeTab=Rejected',
                [intSort]           =        15
    END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Purchase Order')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
			SELECT [strReminder]        =        N'Approve',
				   [strType]        	=        N'Purchase Order',
				   [strMessage]			=        N'{0} {1} {2} unapproved.',
				   [strQuery]  			=        N'SELECT * FROM vyuPOForApproval WHERE intEntityApproverId = {0} AND ysnApproved = 0',
				   [strNamespace]       =        N'AccountsPayable.view.VendorExpenseApproval', 
				   [intSort]            =        16
		END
	ELSE
		BEGIN
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unapproved.'
			WHERE [strReminder] = N'Approve' AND [strType] = N'Purchase Order' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Sales Order')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Sales Order' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transfer')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transfer' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transaction')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bank Transaction' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bank Deposit')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Bank Deposit' 
		END

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Misc Checks')
		BEGIN
			INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
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
			UPDATE [dbo].[tblSMReminderList]
			SET	[strMessage] = N'{0} {1} {2} unprocessed.'
			WHERE [strReminder] = N'Process' AND [strType] = N'Misc Checks' 
		END
GO