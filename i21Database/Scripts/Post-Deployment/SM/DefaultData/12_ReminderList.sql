﻿GO
    TRUNCATE TABLE [dbo].[tblSMReminderList]
GO
    INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strDescription], [strQuery], [strNamespace], [strParameter], [intSort])
    SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'Invoice',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT intRecurringId ' +
										  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Invoice'' ' +
										  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
										  'AND strResponsibleUser = ''{0}'' ' +
										  'UNION ' +
										  'SELECT intRecurringId ' +
										  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Invoice'' ' +
										  'AND ysnActive = 1 ' +
										  'AND strResponsibleUser = ''{0}'' ' +
										  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
										  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
		   [strParameter]		=		 N'strResponsibleUser',
           [intSort]            =        1
	UNION ALL
	SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'General Journal',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT intRecurringId ' +
                                          'FROM tblSMRecurringTransaction WHERE strTransactionType = ''General Journal'' ' +
                                          'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
                                          'AND strResponsibleUser = ''{0}'' ' +
                                          'UNION ' +
                                          'SELECT intRecurringId ' +
                                          'FROM tblSMRecurringTransaction WHERE strTransactionType = ''General Journal'' ' +
                                          'AND ysnActive = 1 ' +
                                          'AND strResponsibleUser = ''{0}'' ' +
                                          'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
                                          'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
		   [strParameter]		=		 N'strResponsibleUser',
           [intSort]            =        2
	UNION ALL
	SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'Bill',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT intRecurringId ' +
										  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bill'' ' +
										  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
										  'AND strResponsibleUser = ''{0}'' ' +
										  'UNION ' +
										  'SELECT intRecurringId ' +
										  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Bill'' ' +
										  'AND ysnActive = 1 ' +
										  'AND strResponsibleUser = ''{0}'' ' +
										  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
										  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
		   [strParameter]		=		 N'strResponsibleUser',
           [intSort]            =        3
	UNION ALL
	SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'Purchase Order',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT intRecurringId ' +
										  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Purchase Order'' ' +
										  'AND GETDATE() >= dtmNextProcess AND dtmNextProcess >= dtmStartDate AND dtmNextProcess <= dtmEndDate AND ysnActive = 1 ' +
										  'AND strResponsibleUser = ''{0}'' ' +
										  'UNION ' +
										  'SELECT intRecurringId ' +
										  'FROM tblSMRecurringTransaction WHERE strTransactionType = ''Purchase Order'' ' +
										  'AND ysnActive = 1 ' +
										  'AND strResponsibleUser = ''{0}'' ' +
										  'AND DATEDIFF(DAY, GETDATE(), dtmNextProcess) > 0 ' +
										  'AND DATEDIFF(DAY, GETDATE(), DATEADD(DAY, intWarningDays * -1 , dtmNextProcess)) <= 0 ',
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
		   [strParameter]		=		 N'strResponsibleUser',
           [intSort]            =        4
	UNION ALL
	SELECT [strReminder]        =        N'Approve',
		   [strType]        	=        N'Bill',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT * FROM vyuAPBillForApproval WHERE intEntityApproverId = {0} AND ysnApproved = 0',
           [strNamespace]       =        N'AccountsPayable.view.VendorExpenseApproval', 
		   [strParameter]		=		 N'intEntityId', 
           [intSort]            =        5
GO