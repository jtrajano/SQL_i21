GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.GeneralJournal') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'GeneralJournal', N'General Journal', N'GeneralLedger.view.GeneralJournal', N'General Ledger', N'tblGLJournal', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLJournal'
			WHERE strNamespace = 'GeneralLedger.view.GeneralJournal'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.EditAccount') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'EditAccount', N'Edit Account', N'GeneralLedger.view.EditAccount', N'General Ledger', N'tblGLAccount', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLAccount'
			WHERE strNamespace = 'GeneralLedger.view.EditAccount'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.Entity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'Entity', N'Entity', N'EntityManagement.view.Entity', N'Entity Management', N'tblEntity', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEntity'
			WHERE strNamespace = 'EntityManagement.view.Entity'
		END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.LoadSchedule')
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
			VALUES (N'LoadSchedule', N'Load Schedule', N'Logistics.view.LoadSchedule', N'Logistics', N'tblLGLoad', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblLGLoad'
			WHERE strNamespace = 'Logistics.view.LoadSchedule'
		END

	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.EntityContact') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'Entity Contact', N'Entity Contact', N'EntityManagement.view.EntityContact', N'Entity Management', N'tblEntity', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEntity', strScreenId = N'Entity Contact', strScreenName = 'Entity Contact'
			WHERE strNamespace = 'EntityManagement.view.EntityContact'
		END

GO
	PRINT N'END INSERT DEFAULT SCREEN'
GO