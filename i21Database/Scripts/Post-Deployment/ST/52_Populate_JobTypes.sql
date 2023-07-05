GO
	PRINT N'BEGIN INSERT STORE JOB TYPES'
GO
	IF NOT EXISTS(SELECT '' FROM tblSTJobTypes where  strJobType = 'Reboot')
	BEGIN
		INSERT [dbo].[tblSTJobTypes] ([intJobTypeId], [strJobType], [intConcurrencyId]) VALUES (1, 'Reboot', 1)
	END
	
	IF NOT EXISTS(SELECT '' FROM tblSTJobTypes where strJobType = 'Poll Files')
	BEGIN
		INSERT [dbo].[tblSTJobTypes] ([intJobTypeId], [strJobType], [intConcurrencyId]) VALUES (2, 'Poll Files', 1)
	END

	IF NOT EXISTS(SELECT '' FROM tblSTJobTypes where strJobType = 'Change Register Password')
	BEGIN
		INSERT [dbo].[tblSTJobTypes] ([intJobTypeId], [strJobType], [intConcurrencyId]) VALUES (3, 'Change Register Password', 1)
	END

	IF NOT EXISTS(SELECT '' FROM tblSTJobTypes where strJobType = 'Passport_TPI_FSTab')
	BEGIN
		INSERT [dbo].[tblSTJobTypes] ([intJobTypeId], [strJobType], [intConcurrencyId]) VALUES (4, 'Passport_TPI_FSTab', 1)
	END
GO
	PRINT N'END INSERT STORE JOB TYPES'
GO