GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount)
BEGIN
		PRINT N'BEGIN EXISTING GROUPS CHECKING'
	
		DECLARE @GROUP NVARCHAR(MAX) = ''
		SELECT @GROUP = @GROUP + strAccountGroup + ', ' FROM tblGLAccountGroup GROUP BY strAccountGroup HAVING COUNT(*) > 1
	
		IF (@GROUP != '' AND LEN(@GROUP) > 1)
		BEGIN
			SET @GROUP = SUBSTRING(@GROUP,1,LEN(@GROUP)-1)
			RAISERROR ('Duplicate %s Account Group detected.', 15, 10, @GROUP)
		END
	
		PRINT N'END EXISTING GROUPS CHECKING'

		BEGIN TRANSACTION

		PRINT N'BEGIN INSERT/UPDATE DEFAULT ACCOUNT TYPES'
		PRINT N'BEGIN INSERT/UPDATE Asset Type'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Asset', intSort = 100000, strAccountGroupNamespace = 'System' WHERE strAccountGroup = 'Asset' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND intParentGroupId = 0)
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Asset', N'Asset', 0, 1, 100000, 1, 0, 0, N'System')
		END	

		PRINT N'END INSERT/UPDATE Asset Type'
		PRINT N'BEGIN INSERT/UPDATE Liability Type'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Liability', intSort = 200000, strAccountGroupNamespace = 'System' WHERE strAccountGroup = 'Liability' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND intParentGroupId = 0)
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Liability', N'Liability', 0, 1, 200000, 1, 0, 0, N'System')
		END

		PRINT N'END INSERT/UPDATE Liability Type'
		PRINT N'BEGIN INSERT/UPDATE Equity Type'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Equity', intSort = 300000, strAccountGroupNamespace = 'System' WHERE strAccountGroup = 'Equity' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND intParentGroupId = 0)
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Equity', N'Equity', 0, 1, 300000, 1, 0, 0, N'System')
		END

		PRINT N'END INSERT/UPDATE Equity Type'
		PRINT N'BEGIN INSERT/UPDATE Revenue Type'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Revenue', intSort = 400000, strAccountGroupNamespace = 'System' WHERE strAccountGroup = 'Revenue' AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND intParentGroupId = 0)
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Revenue', N'Revenue', 0, 1, 400000, 1, 0, 0, N'System')
		END

		PRINT N'END INSERT/UPDATE Revenue Type'
		PRINT N'BEGIN INSERT/UPDATE Expense Type'
	
		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Expense' OR strAccountGroup = N'Expenses') AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Expense', intSort = 500000, strAccountGroupNamespace = 'System' WHERE (strAccountGroup = N'Expense' OR strAccountGroup = N'Expenses') AND intParentGroupId = 0 AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND intParentGroupId = 0)
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Expense', N'Expense', 0, 1, 500000, 1, 0, 0, N'System')
		END	

		PRINT N'END INSERT/UPDATE Expense Type'
		PRINT N'END INSERT/UPDATE DEFAULT ACCOUNT TYPES'

		----- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-----								DEFAULT SUB GROUPS
		----- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Current Assets'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Current Asset' OR strAccountGroup = N'Current Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Current Assets'
										, intSort = 100100
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Current Asset' OR strAccountGroup = N'Current Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Current Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset') , 1, 100100, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Current Assets'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Cash Accounts'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Cash Account' OR strAccountGroup = N'Cash Accounts') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Cash Accounts'
										, intSort = 100110
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') 
										WHERE  (strAccountGroup = N'Cash Account' OR strAccountGroup = N'Cash Accounts') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Cash Accounts' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Cash Accounts', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100110, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Cash Accounts'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Undeposited Fund'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Undeposited Fund' OR strAccountGroup = N'Undeposited Funds') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Undeposited Funds'
										, intSort = 100120
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') 
										WHERE  (strAccountGroup = N'Undeposited Fund' OR strAccountGroup = N'Undeposited Funds') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Undeposited Funds' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Undeposited Funds', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100120, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Undeposited Fund'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Receivables'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Receivable' OR strAccountGroup = N'Receivables') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Receivables'
										, intSort = 100130
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') 
										WHERE  (strAccountGroup = N'Receivable' OR strAccountGroup = N'Receivables') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Receivables', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100130, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Receivables'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Prepaid'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Prepaid' OR strAccountGroup = N'Prepaids') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Prepaids'
										, intSort = 100140
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') 
										WHERE  (strAccountGroup = N'Prepaid' OR strAccountGroup = N'Prepaids') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Prepaids' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Prepaids', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100140, 1, NULL, NULL, N'System')
		END		

		PRINT N'END INSERT DEFAULT SUB GROUPS: Prepaid'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Inventories'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Inventory' OR strAccountGroup = N'Inventories') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Inventories'
										, intSort = 100150
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') 
										WHERE  (strAccountGroup = N'Inventory' OR strAccountGroup = N'Inventories') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Inventories', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Assets' AND strAccountType = N'Asset') , 1, 100150, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Inventories'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Non-Current Assets'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Non-Current Asset' OR strAccountGroup = N'Non-Current Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Non-Current Assets'
										, intSort = 100200
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Non-Current Asset' OR strAccountGroup = N'Non-Current Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Non-Current Assets' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Non-Current Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset') , 1, 100200, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Non-Current Assets'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Assets'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Asset' OR strAccountGroup = N'Other Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Assets'
										, intSort = 100210
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Non-Current Assets' AND strAccountType = N'Asset') 
										WHERE  (strAccountGroup = N'Other Asset' OR strAccountGroup = N'Other Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Assets' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Non-Current Assets' AND strAccountType = N'Asset') , 1, 100210, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Other Assets'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Fixed Asset'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Fixed Asset' OR strAccountGroup = N'Fixed Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Fixed Assets'
										, intSort = 100300
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Fixed Asset' OR strAccountGroup = N'Fixed Assets') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Fixed Assets', N'Asset', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Asset' AND strAccountType = N'Asset') , 1, 100300, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Fixed Asset'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Current Liabilities'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Current Liability' OR strAccountGroup = N'Current Liabilities') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Current Liabilities'
										, intSort = 200100
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND strAccountType = N'Liability' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Current Liability' OR strAccountGroup = N'Current Liabilities') AND strAccountType = N'Asset' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Current Liabilities', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Liability' AND strAccountType = N'Liability') , 1, 200100, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS:  Current Liabilities'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Payables'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Payable' OR strAccountGroup = N'Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Payables'
										, intSort = 200110
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Payable' OR strAccountGroup = N'Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payables' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200110, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS:  Payables'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Payables'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Payable' OR strAccountGroup = N'Other Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Payables'
										, intSort = 200120
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Other Payable' OR strAccountGroup = N'Other Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Payables' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200120, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS:  Other Payables'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Sales Tax Payables'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Sales Tax Payable' OR strAccountGroup = N'Sales Tax Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Sales Tax Payables'
										, intSort = 200130
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Sales Tax Payable' OR strAccountGroup = N'Sales Tax Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales Tax Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200130, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Sales Tax Payables'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Payroll Tax Liabilities'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Payroll Tax Liability' OR strAccountGroup = N'Payroll Tax Liabilities') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Payroll Tax Liabilities'
										, intSort = 200140
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Payroll Tax Liability' OR strAccountGroup = N'Payroll Tax Liabilities') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Tax Liabilities', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200140, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Payroll Tax Liabilities'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Customer Deposits'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Customer Deposit' OR strAccountGroup = N'Customer Deposits') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Customer Deposits'
										, intSort = 200150
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Customer Deposit' OR strAccountGroup = N'Customer Deposits') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Customer Deposits' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Customer Deposits', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200150, 1, NULL, NULL, N'System')
		END		

		PRINT N'END INSERT DEFAULT SUB GROUPS: Customer Deposits'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Pending Payables'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Pending Payable' OR strAccountGroup = N'Pending Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Pending Payables'
										, intSort = 200160
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Pending Payable' OR strAccountGroup = N'Pending Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Pending Payables' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Pending Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200160, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Pending Payables'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Grain Payables'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Grain Payable' OR strAccountGroup = N'Grain Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Grain Payables'
										, intSort = 200170
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') 
										WHERE  (strAccountGroup = N'Grain Payable' OR strAccountGroup = N'Grain Payables') AND strAccountType = N'Liability' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Grain Payables' AND strAccountType = N'Liability')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Grain Payables', N'Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Current Liabilities' AND strAccountType = N'Liability') , 1, 200170, 1, NULL, NULL, N'System')
		END		

		PRINT N'END INSERT DEFAULT SUB GROUPS: Grain Payables'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Retained Earnings'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Retained Earning' OR strAccountGroup = N'Retained Earnings') AND strAccountType = N'Equity' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Retained Earnings'
										, intSort = 300100
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Retained Earning' OR strAccountGroup = N'Retained Earnings') AND strAccountType = N'Equity' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Retained Earnings', N'Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity') , 1, 300100, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Retained Earnings'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Owners Equities'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Owners Equity' OR strAccountGroup = N'Owners Equities') AND strAccountType = N'Equity' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Owners Equities'
										, intSort = 300200
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Owners Equity' OR strAccountGroup = N'Owners Equities') AND strAccountType = N'Equity' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Owners Equities', N'Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity') , 1, 300200, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Owners Equities'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Equities'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Equity' OR strAccountGroup = N'Other Equities') AND strAccountType = N'Equity' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Equities'
										, intSort = 300300
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Other Equity' OR strAccountGroup = N'Other Equities') AND strAccountType = N'Equity' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Equities' AND strAccountType = N'Equity')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Equities', N'Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Equity' AND strAccountType = N'Equity') , 1, 300300, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Other Equities'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Sales'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Sales'
										, intSort = 400100
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue' AND intParentGroupId = 0) 
										WHERE  strAccountGroup = N'Sales' AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Sales' AND intParentGroupId = 0)
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Sales'
										, intSort = 400100
										, strAccountGroupNamespace = 'System'
										, strAccountType = 'Revenue'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue' AND intParentGroupId = 0) 
										WHERE  strAccountGroup = N'Sales' AND strAccountType = N'Sales' AND intParentGroupId = 0
			UPDATE tblGLAccountGroup SET strAccountType = 'Revenue'
										WHERE  strAccountType = N'Sales' AND intParentGroupId > 0
			UPDATE tblGLAccountGroup SET intSort = (intSort - 20000) * 10
										WHERE  strAccountType = N'Sales' AND intParentGroupId > 0 AND intSort > 60000
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 400100, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Sales'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Sales Discounts'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Sales Discount' OR strAccountGroup = N'Sales Discounts') AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Sales Discounts'
										, intSort = 400200
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Sales Discount' OR strAccountGroup = N'Sales Discounts') AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Discounts' AND strAccountType = N'Revenue')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Sales Discounts', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 400200, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Sales Discounts'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Income'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Incomes' OR strAccountGroup = N'Other Income') AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Income'
										, intSort = 400300
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Other Incomes' OR strAccountGroup = N'Other Income') AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Income', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 400300, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Other Income'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Revenues'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Revenue' OR strAccountGroup = N'Other Revenues') AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Revenues'
										, intSort = 400400
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Other Revenue' OR strAccountGroup = N'Other Revenues') AND strAccountType = N'Revenue' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Revenues' AND strAccountType = N'Revenue')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Revenues', N'Revenue', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Revenue' AND strAccountType = N'Revenue') , 1, 400400, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Other Revenues'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Cost of Goods Sold'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Cost of Goods Solds' OR strAccountGroup = N'Cost of Goods Sold') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Cost of Goods Sold'
										, intSort = 500100
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Cost of Goods Solds' OR strAccountGroup = N'Cost of Goods Sold') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Cost of Goods Sold' AND intParentGroupId = 0)
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Cost of Goods Sold'
										, intSort = 500100
										, strAccountGroupNamespace = 'System'
										, strAccountType = 'Expense'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense' AND intParentGroupId = 0) 
										WHERE  strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Cost of Goods Sold' AND intParentGroupId = 0
			UPDATE tblGLAccountGroup SET strAccountType = 'Expense'
										WHERE  strAccountType = N'Cost of Goods Sold' AND intParentGroupId > 0
			UPDATE tblGLAccountGroup SET intSort = (intSort - 20000) * 10
										WHERE  strAccountType = N'Cost of Goods Sold' AND intParentGroupId > 0 AND intSort > 70000
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Cost of Goods Sold', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 500100, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Cost of Goods Sold'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Purchases'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Purchase' OR strAccountGroup = N'Purchases') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Purchases'
										, intSort = 500110
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') 
										WHERE  (strAccountGroup = N'Purchase' OR strAccountGroup = N'Purchases') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Purchases', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500110, 1, NULL, NULL, N'System')
		END		

		PRINT N'END INSERT DEFAULT SUB GROUPS: Purchases'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Purchases Discounts'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Purchases Discount' OR strAccountGroup = N'Purchases Discounts') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Purchases Discounts'
										, intSort = 500120
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') 
										WHERE  (strAccountGroup = N'Purchases Discount' OR strAccountGroup = N'Purchases Discounts') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases Discounts' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Purchases Discounts', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500120, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Purchases Discounts'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Purchases'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Purchase' OR strAccountGroup = N'Other Purchases') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Purchases'
										, intSort = 500130
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') 
										WHERE  (strAccountGroup = N'Other Purchase' OR strAccountGroup = N'Other Purchases') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Purchases' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Purchases', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500130, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Other Purchases'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Payroll Cogs'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Payroll Cog' OR strAccountGroup = N'Payroll Cogs') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Payroll Cogs'
										, intSort = 500140
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') 
										WHERE  (strAccountGroup = N'Payroll Cog' OR strAccountGroup = N'Payroll Cogs') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Cogs' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Cogs', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , 1, 500140, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Payroll Cogs'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Other Expenses'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Other Expense' OR strAccountGroup = N'Other Expenses') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Other Expenses'
										, intSort = 500200
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Other Expense' OR strAccountGroup = N'Other Expenses') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Other Expenses', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 500200, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Other Expenses'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Payroll Earnings'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Payroll Earning' OR strAccountGroup = N'Payroll Earnings') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Payroll Earnings'
										, intSort = 500300
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Payroll Earning' OR strAccountGroup = N'Payroll Earnings') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Earnings' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Earnings', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 500300, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Payroll Earnings'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Payroll Tax Expenses'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Payroll Tax Expense' OR strAccountGroup = N'Payroll Tax Expenses') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Payroll Tax Expenses'
										, intSort = 500400
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Payroll Tax Expense' OR strAccountGroup = N'Payroll Tax Expenses') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Expenses' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Tax Expenses', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 500400, 1, NULL, NULL, N'System')
		END	

		PRINT N'END INSERT DEFAULT SUB GROUPS: Payroll Tax Expenses'
		PRINT N'BEGIN INSERT DEFAULT SUB GROUPS: Payroll Expenses'

		IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE (strAccountGroup = N'Payroll Expense' OR strAccountGroup = N'Payroll Expenses') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL))
		BEGIN
			UPDATE tblGLAccountGroup SET strAccountGroup = 'Payroll Expenses'
										, intSort = 500500
										, strAccountGroupNamespace = 'System'
										, intParentGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense' AND intParentGroupId = 0) 
										WHERE  (strAccountGroup = N'Payroll Expense' OR strAccountGroup = N'Payroll Expenses') AND strAccountType = N'Expense' AND (strAccountGroupNamespace != 'System' OR strAccountGroupNamespace IS NULL)
		END	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Expenses' AND strAccountType = N'Expense')
		BEGIN
			INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace]) VALUES (N'Payroll Expenses', N'Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Expense' AND strAccountType = N'Expense') , 1, 500500, 1, NULL, NULL, N'System')
		END

		PRINT N'END INSERT DEFAULT SUB GROUPS: Payroll Expenses'
		PRINT N'BEGIN EXISTING GROUPS CHECKING'

		SET @GROUP = ''
		SELECT @GROUP = @GROUP + strAccountGroup + ', ' FROM tblGLAccountGroup GROUP BY strAccountGroup HAVING COUNT(*) > 1
	
		IF (@GROUP != '' AND LEN(@GROUP) > 1)
		BEGIN
			SET @GROUP = SUBSTRING(@GROUP,1,LEN(@GROUP)-1)
			ROLLBACK TRANSACTION
			RAISERROR ('Duplicate %s Account Group detected.', 15, 10, @GROUP)		
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
		END
	
		PRINT N'END EXISTING GROUPS CHECKING'
END

GO