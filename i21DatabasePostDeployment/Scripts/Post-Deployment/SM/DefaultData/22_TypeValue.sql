GO
	PRINT N'BEGIN INSERT DEFAULT TYPE VALUE'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Not Started' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'Not Started', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Open' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'Open', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'In Progress' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'In Progress', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Complete' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'Complete', 1, 1)
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Not Started' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'Not Started', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Open' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'Open', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'In Progress' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'In Progress', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Complete' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Status', N'Complete', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Priority' AND strValue = 'High' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Priority', N'High', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Priority' AND strValue = 'Normal' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Priority', N'Normal', 1, 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Priority' AND strValue = 'Low' AND ysnDefault = 1) 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [ysnDefault], [intConcurrencyId]) 
			VALUES (N'Priority', N'Low', 1, 1)
		END
GO
	PRINT N'END INSERT TYPE VALUE'
GO