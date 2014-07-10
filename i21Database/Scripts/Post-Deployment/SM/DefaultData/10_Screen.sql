GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	SET IDENTITY_INSERT [dbo].[tblSMScreen] ON
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Vendor') INSERT [dbo].[tblSMScreen] ([intScreenId], [strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) VALUES (2, N'Vendor', N'Vendor', N'AccountsPayable.view.Vendor', N'Accounts Payable', N'tblAPVendor', 0)
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Customer') INSERT [dbo].[tblSMScreen] ([intScreenId], [strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) VALUES (3, N'Customer', N'Customer', N'AccountsReceivable.view.Customer', N'Accounts Receivable', N'tblARCustomer', 0)
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.GeneralJournal') INSERT [dbo].[tblSMScreen] ([intScreenId], [strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) VALUES (4, N'GeneralJournal', N'General Journal', N'GeneralLedger.view.GeneralJournal', N'General Ledger', N'tblGLJournal', 0)
	SET IDENTITY_INSERT [dbo].[tblSMScreen] OFF
GO
	PRINT N'END INSERT DEFAULT SCREEN'
GO