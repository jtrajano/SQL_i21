GO
    TRUNCATE TABLE [dbo].[tblSMReminderList]
GO
    INSERT INTO [dbo].[tblSMReminderList] ([strReminder], [strType], [strDescription], [strQuery], [strNamespace], [intSort])
    SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'Invoice',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT * FROM tblSMRecurringTransaction WHERE strTransactionType = ''Invoice'' ' + 
										  'AND GETDATE() >= dtmNextProcess ' + 
										  'AND dtmNextProcess >= dtmStartDate ' + 
										  'AND dtmNextProcess <= dtmEndDate',
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
           [intSort]            =        1
	UNION ALL
	SELECT [strReminder]        =        N'Process',
		   [strType]        	=        N'General Journal',
           [strDescription]     =        N'{0} {1} {2} {3}',
           [strQuery]  			=        N'SELECT * FROM tblSMRecurringTransaction WHERE strTransactionType = ''General Journal'' ' + 
										  'AND GETDATE() >= dtmNextProcess ' + 
										  'AND dtmNextProcess >= dtmStartDate ' + 
										  'AND dtmNextProcess <= dtmEndDate',
           [strNamespace]       =        N'i21.view.RecurringTransaction', 
           [intSort]            =        2
GO