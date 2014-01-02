﻿GO
	PRINT N'BEGIN INSERT DEFAULT ACCOUNT GROUP'
GO
	SET IDENTITY_INSERT [dbo].[tblGLAccountGroup] ON
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 1 AND strAccountGroup = N'Asset' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (1, N'Asset', N'Asset', 0, 1, 10000, 129, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 2 AND strAccountGroup = N'Liability' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (2, N'Liability', N'Liability', 0, 1, 20000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 3 AND strAccountGroup = N'Equity' AND strAccountType = N'Equity')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (3, N'Equity', N'Equity', 0, 1, 30000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 4 AND strAccountGroup = N'Revenue' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (4, N'Revenue', N'Revenue', 0, 1, 40000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 5 AND strAccountGroup = N'Expenses' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (5, N'Expenses', N'Expense', 0, 1, 50000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 6 AND strAccountGroup = N'Sales' AND strAccountType = N'Sales')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (6, N'Sales', N'Sales', 0, 1, 60000, NULL, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 7 AND strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Cost of Goods Sold')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (7, N'Cost of Goods Sold', N'Cost of Goods Sold', 0, 1, 70000, NULL, NULL, NULL, NULL)
	END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE intAccountGroupID = 8 AND strAccountGroup = N'Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (8, N'Payables', N'Liability', 0, 1, 80000, NULL, NULL, NULL, NULL)
	END
GO
	SET IDENTITY_INSERT [dbo].[tblGLAccountGroup] OFF
GO
	PRINT N'END INSERT DEFAULT ACCOUNT GROUP'
GO