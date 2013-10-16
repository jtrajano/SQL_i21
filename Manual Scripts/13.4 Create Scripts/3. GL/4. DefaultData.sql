
/****** Object:  Table [dbo].[tblGLAccountGroup]    Script Date: 10/07/2013 14:18:24 ******/
SET IDENTITY_INSERT [dbo].[tblGLAccountGroup] ON
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (1, N'Asset', N'Asset', 0, 1, 10000, 129, 0, 0, N'src')
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (4, N'Liability', N'Liability', 0, 1, 20000, 1, 0, 0, N'src')
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (2, N'Equity', N'Equity', 0, 1, 30000, 1, 0, 0, N'src')
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (5, N'Revenue', N'Revenue', 0, 1, 40000, 1, 0, 0, N'src')
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (3, N'Expenses', N'Expense', 0, 1, 50000, 1, 0, 0, N'src')
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (6, N'Sales', N'Sales', 0, 1, 60000, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblGLAccountGroup] ([intAccountGroupID], [strAccountGroup], [strAccountType], [intParentGroupID], [intGroup], [intSort], [intConcurrencyID], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (7, N'Cost of Goods Sold', N'Cost of Goods Sold', 0, 1, 70000, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[tblGLAccountGroup] OFF


