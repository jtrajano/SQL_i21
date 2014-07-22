GO
	PRINT N'BEGIN INSERT DEFAULT ACCOUNT TYPES'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Asset', N'Asset', 0, 1, 10000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Liability', N'Liability', 0, 1, 20000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Equity', N'Equity', 0, 1, 30000, 1, 0, 0, N'src')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Revenue', N'Revenue', 0, 1, 40000, 1, 0, 0, N'src')
	END
	IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Expenses' AND strAccountType = N'Expense')
	BEGIN
		UPDATE tblGLAccountGroup SET strAccountGroup = 'Expense' WHERE strAccountGroup = 'Expenses' AND intParentGroupId = 0
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Expense', N'Expense', 0, 1, 50000, 1, 0, 0, N'src')
	END	
GO
	PRINT N'END INSERT DEFAULT ACCOUNT TYPES'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Current Assets'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Current Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset') , 1, 10001, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Cash Accounts' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Cash Accounts', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100011, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Undeposited Funds' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Undeposited Funds', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100012, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Receivables', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100013, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Prepaids' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Prepaids', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100014, 1, NULL, NULL, NULL)
	END		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Inventories', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100015, 1, NULL, NULL, NULL)
	END
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Current Assets'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Non-Current Assets'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Non-Current Assets' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Non-Current Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset') , 1, 10002, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Assets' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Non-Current Assets' AND strAccountType = N'Asset') , 1, 100021, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Fixed Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Non-Current Assets' AND strAccountType = N'Asset') , 1, 100022, 1, NULL, NULL, NULL)
	END
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Non-Current Assets'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Current Liabilities'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Current Liabilities', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND strAccountType = N'Liability') , 1, 20001, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200011, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200012, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales Tax Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200013, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Tax Liabilities', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200014, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Customer Deposits' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Customer Deposits', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200015, 1, NULL, NULL, NULL)
	END		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Pending Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Pending Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200016, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Grain Payables' AND strAccountType = N'Liability')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Grain Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200017, 1, NULL, NULL, NULL)
	END		
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Current Liabilities'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Equity'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Retained Earnings', N'Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity') , 1, 30001, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Owners Equities', N'Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity') , 1, 30002, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Equities' AND strAccountType = N'Equity')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Equities', N'Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity') , 1, 30003, 1, NULL, NULL, NULL)
	END
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Equity'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Revenue'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 40001, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Discounts' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales Discounts', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 40002, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Income', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 40003, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Revenues' AND strAccountType = N'Revenue')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Revenues', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 40004, 1, NULL, NULL, NULL)
	END	
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Revenue'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Cost of Goods Sold'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Cost of Goods Sold', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 50001, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Purchases', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500011, 1, NULL, NULL, NULL)
	END		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases Discounts' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Purchases Discounts', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500012, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Purchases' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Purchases', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500013, 1, NULL, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Cogs' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Cogs', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500014, 1, NULL, NULL, NULL)
	END
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Cost of Goods Sold'
	PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Expense'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Purchases' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Purchases', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 50002, 1, NULL, NULL, NULL)
	END		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Expenses', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 50003, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Earnings' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Earnings', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 50004, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Expenses' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Tax Expenses', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 50005, 1, NULL, NULL, NULL)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Expenses' AND strAccountType = N'Expense')
	BEGIN
		INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Expenses', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 50006, 1, NULL, NULL, NULL)
	END
GO
	PRINT N'END INSERT DEFAULT SUB GROUPS: Expense'
GO