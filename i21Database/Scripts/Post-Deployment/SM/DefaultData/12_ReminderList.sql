GO
    TRUNCATE TABLE [dbo].[tblSMReminderList]
GO
    INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strDescription], [strQuery], [strNamespace], [intSort])
    SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'Invoice',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT * FROM tblSMRecurringTransaction WHERE strTransactionType = ''Invoice'' AND ysnDue = 1', 
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
           [intSort]            =        1
GO