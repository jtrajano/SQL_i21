GO
	PRINT N'BEGIN INSERT STORE JOB TYPES'
GO
	IF NOT EXISTS(SELECT '' FROM tblSTJobTypes where  strJobType = 'Reboot')
	BEGIN
		INSERT [dbo].[tblSTJobTypes] ([strJobType], [intConcurrencyId]) VALUES ( 'Reboot', 1)
	END
	
	IF NOT EXISTS(SELECT '' FROM tblSTJobTypes where strJobType = 'Poll Files')
	BEGIN
		INSERT [dbo].[tblSTJobTypes] ([strJobType], [intConcurrencyId]) VALUES ( 'Poll Files', 1)
	END
GO
	PRINT N'END INSERT STORE JOB TYPES'
GO