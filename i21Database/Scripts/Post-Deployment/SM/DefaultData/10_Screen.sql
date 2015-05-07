GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	SET IDENTITY_INSERT [dbo].[tblSMScreen] ON
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.GeneralJournal') INSERT [dbo].[tblSMScreen] ([intScreenId], [strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) VALUES (4, N'GeneralJournal', N'General Journal', N'GeneralLedger.view.GeneralJournal', N'General Ledger', N'tblGLJournal', 0)
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.EditAccount') INSERT [dbo].[tblSMScreen] ([intScreenId], [strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) VALUES (5, N'EditAccount', N'Edit Account', N'GeneralLedger.view.EditAccount', N'General Ledger', N'tblGLAccount', 0)
	SET IDENTITY_INSERT [dbo].[tblSMScreen] OFF
GO
	PRINT N'END INSERT DEFAULT SCREEN'
GO