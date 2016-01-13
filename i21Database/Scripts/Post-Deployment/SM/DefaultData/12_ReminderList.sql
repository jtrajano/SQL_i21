GO

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Invoice')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
		SELECT [strReminder]        =        N'Process',
			   [strType]        	=        N'Invoice',
			   [strMessage]			=        N'{0} {1} {2} {3}',
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

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'General Journal')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
		SELECT [strReminder]        =        N'Process',
			   [strType]        	=        N'General Journal',
			   [strMessage]			=        N'{0} {1} {2} {3}',
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

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Voucher')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
		SELECT [strReminder]        =        N'Process',
			   [strType]        	=        N'Voucher',
			   [strMessage]			=        N'{0} {1} {2} {3}',
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

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Purchase Order')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
		SELECT [strReminder]        =        N'Process',
			   [strType]        	=        N'Purchase Order',
			   [strMessage]			=        N'{0} {1} {2} {3}',
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
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Process' AND [strType] = N'Bill Template')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
		SELECT [strReminder]        =        N'Process',
			   [strType]        	=        N'Bill Template',
			   [strMessage]			=        N'{0} {1} {2} {3}',
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

	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMReminderList] WHERE [strReminder] = N'Approve' AND [strType] = N'Voucher')
	BEGIN
		INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strMessage], [strQuery], [strNamespace], [intSort])
		SELECT [strReminder]        =        N'Approve',
			   [strType]        	=        N'Voucher',
			   [strMessage]			=        N'{0} {1} {2} {3}',
			   [strQuery]  			=        N'SELECT * FROM vyuAPBillForApproval WHERE intEntityApproverId = {0} AND ysnApproved = 0',
			   [strNamespace]       =        N'AccountsPayable.view.VendorExpenseApproval', 
			   [intSort]            =        6
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
	
	

GO