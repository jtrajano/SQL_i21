GO
	PRINT N'BEGIN INSERT DEFAULT TYPE VALUE'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Not Started') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'Not Started', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Open') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'Open', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'In Progress') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'In Progress', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Complete') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'Complete', 1)
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Not Started') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'Not Started', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Open') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'Open', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'In Progress') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'In Progress', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Status' AND strValue = 'Complete') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Status', N'Complete', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Priority' AND strValue = 'High') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Priority', N'High', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Priority' AND strValue = 'Normal') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Priority', N'Normal', 1)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTypeValue WHERE strType = 'Priority' AND strValue = 'Low') 
		BEGIN
			INSERT [dbo].[tblSMTypeValue] ([strType], [strValue], [intConcurrencyId]) 
			VALUES (N'Priority', N'Low', 1)
		END
GO
	PRINT N'END INSERT TYPE VALUE'
GO