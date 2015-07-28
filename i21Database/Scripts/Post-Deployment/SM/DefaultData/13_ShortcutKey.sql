GO
	TRUNCATE TABLE [dbo].[tblSMShortcutKeys]
GO
SET IDENTITY_INSERT [dbo].[tblSMShortcutKeys] ON 

INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (1, NULL, N'btnRefresh', N'r', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (2, NULL, N'btnClose', N'x', 0, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (3, NULL, N'btnNew', N'n', 0, 0, 1, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (4, NULL, N'btnSave', N's', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (6, NULL, N'btnDelete', N'd', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (7, NULL, N'btnDeleteItems', N'd', 1, 1, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (9, NULL, N'btnUndo', N'u', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (10, NULL, N'btnOpenSelected', N'v', 0, 0, 1, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (11, NULL, N'btnEdit', N'e', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (13, NULL, N'btnFind', N's', 0, 0, 1, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (16, NULL, N'btnCancel', N'c', 0, 0, 1, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (19, NULL, N'btnPrint', N'p', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (20, NULL, N'btnAbout', N'i', 1, 0, 0, 1, 1)
INSERT [dbo].[tblSMShortcutKeys] ([intShortcutKeyId], [strModule], [strItemId], [strShortcutKey], [ctrl], [shift], [alt], [isEnabled], [intConcurrencyId]) VALUES (22, NULL, N'btnLogOut', N'l', 1, 0, 0, 1, 1)
SET IDENTITY_INSERT [dbo].[tblSMShortcutKeys] OFF
GO
	PRINT N'END INSERT DEFAULT SHORCUTKEY'
GO
