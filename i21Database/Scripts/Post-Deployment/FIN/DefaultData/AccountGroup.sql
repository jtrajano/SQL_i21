GO
	PRINT N'BEGIN INSERT DEFAULT ACCOUNT GROUP'
GO
--	SET IDENTITY_INSERT [dbo].[tblGLAccountGroup] ON
--GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Asset', N'Asset', 0, 1, 10000, 129, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Liability', N'Liability', 0, 1, 20000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Equity', N'Equity', 0, 1, 30000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Revenue', N'Revenue', 0, 1, 40000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Expenses' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Expenses', N'Expense', 0, 1, 50000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Sales')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales', N'Sales', 0, 1, 60000, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Cost of Goods Sold')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Cost of Goods Sold', N'Cost of Goods Sold', 0, 1, 70000, 1, NULL, NULL, NULL)
	END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payables', N'Liability', (SELECT TOP 1 intAccountGroupID FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND strAccountType = N'Liability') , 1, 20000, 1, NULL, NULL, NULL)
	END
GO
--	SET IDENTITY_INSERT [dbo].[tblGLAccountGroup] OFF
--GO
	PRINT N'END INSERT DEFAULT ACCOUNT GROUP'
GO