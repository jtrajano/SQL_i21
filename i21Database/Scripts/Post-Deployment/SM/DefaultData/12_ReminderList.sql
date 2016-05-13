GO

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

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'General Journal')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Process',
				[strType]        	=        N'General Journal',
				[strMessage]		=        N'{0} {1} {2} left unposted.',
				[strQuery]  		=        N'SELECT A.intJournalId FROM tblGLJournal A 
												CROSS APPLY(
													select PostRemind_intDaysAfterEvent, PostRemind_intDaysBeforeEvent, PostRemind_strRemindUsers from tblGLCompanyPreferenceOption
													where ISNULL(PostRemind_strNotificationMessage,'''') <> ''''
												) Options
												CROSS APPLY(
													select intEntityId from tblEMEntity where intEntityId in (select Item from dbo.fnSplitString(Options.PostRemind_strRemindUsers,'',''))
													and intEntityId = A.intEntityId
												) Entity
												CROSS APPLY(
													SELECT TOP 1 dtmEndDate FROM tblGLFiscalYearPeriod WHERE A.dtmDate BETWEEN dtmStartDate and dtmEndDate
												)Fiscal
												WHERE A.dtmDate BETWEEN DATEADD(DAY, Options.PostRemind_intDaysBeforeEvent * -1, Fiscal.dtmEndDate) AND DATEADD(DAY, Options.PostRemind_intDaysAfterEvent, Fiscal.dtmEndDate) 
												AND ysnPosted = 0
												AND A.intEntityId = {0}',
				[strNamespace]      =        N'GeneralLedger.view.GeneralJournal?unposted=1',
				[intSort]           =        8
	END	


	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Transaction')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Approve',
				[strType]        	=        N'Transaction',
				[strMessage]		=        N'{0} {1} {2} unapproved.',
				[strQuery]  		=        N'	SELECT 
													intTransactionId 
												FROM tblSMApproval 
												WHERE	ysnCurrent = 1 AND 
														strStatus IN (''Waiting for Approval'') AND 
														intApproverId = {0}',
				[strNamespace]      =        N'i21.view.Approval?activeTab=Pending',
				[intSort]           =        9
	END	


	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Transaction' AND [strType] = N'Approved')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Transaction Approved',
				[strType]        	=        N'',
				[strMessage]		=        N'{0} Transaction(s) {2} approved.',
				[strQuery]  		=        N'	SELECT 
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
				[intSort]           =        10
	END	

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Transaction' AND [strType] = N'Closed')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Transaction Closed',
				[strType]        	=        N'',
				[strMessage]		=        N'{0} Transaction(s) {2} closed.',
				[strQuery]  		=        N'	SELECT 
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
				[intSort]           =        11
	END	

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Transaction' AND [strType] = N'Unsubmitted')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Transaction Unsubmitted',
				[strType]        	=        N'',
				[strMessage]		=        N'{0} Transaction(s) {2} unsubmitted.',
				[strQuery]  		=        N'	SELECT 
													intTransactionId 
												FROM tblSMApproval 
												WHERE	ysnCurrent = 1 AND 
														strStatus IN (''Waiting for Submit'') AND 
														intSubmittedById= {0}',
				[strNamespace]      =        N'i21.view.Approval?activeTab=Closed',
				[intSort]           =        12
	END	

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Transaction' AND [strType] = N'Rejected')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])	
		SELECT [strReminder]        =        N'Transaction Rejected',
				[strType]        	=        N'',
				[strMessage]		=        N'{0} Transaction(s) {2} rejected.',
				[strQuery]  		=        N'	SELECT 
													intTransactionId 
												FROM tblSMApproval 
												WHERE	ysnCurrent = 1 AND 
														strStatus IN (''Rejected'') AND 
														intSubmittedById= {0}',
				[strNamespace]      =        N'i21.view.Approval?activeTab=Rejected',
				[intSort]           =        13
	END	
GO